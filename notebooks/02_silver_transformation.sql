-- =============================================================================
-- ATLAS Marine | Silver Layer Transformation
-- Animal Tracking and Lifecycle Analysis System
-- =============================================================================
-- Purpose: Clean, standardise, and enrich Bronze data into Silver tables.
--          Apply schema enforcement, deduplication, unit alignment, and
--          geospatial/temporal metadata. Prepare for Gold aggregations.
--
-- Key lesson learned: Never use CREATE OR REPLACE TABLE after initial creation.
--          Use INSERT INTO for incremental loads. Validate with COUNT(*) BY month
--          after every batch to catch partial ingestion early.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. SPECIES UNION — All four species into one tracking table
-- -----------------------------------------------------------------------------
-- Pattern: UNION ALL preserves all rows across species.
-- Each source table has the same schema from Bronze, so union is clean.
-- Species column already populated at Bronze — no lookup needed.

CREATE TABLE IF NOT EXISTS atlas_silver.species_tracking_silver (
    animal_id             STRING,
    timestamp             TIMESTAMP,
    latitude              DOUBLE,
    longitude             DOUBLE,
    sst_celsius           DOUBLE,
    year                  INT,
    month                 INT,
    species               STRING,
    data_source           STRING,
    processed_timestamp   TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
COMMENT 'Unified species tracking Silver table. 116 individual animals across 4 species. 69,776 records.';

INSERT INTO atlas_silver.species_tracking_silver
SELECT
    animal_id,
    timestamp,
    latitude,
    longitude,
    sst_celsius,
    year,
    month,
    species,
    data_source,
    current_timestamp() AS processed_timestamp
FROM atlas_bronze.manta_ray_raw

UNION ALL

SELECT
    animal_id,
    timestamp,
    latitude,
    longitude,
    sst_celsius,
    year,
    month,
    species,
    data_source,
    current_timestamp()
FROM atlas_bronze.whale_shark_raw

UNION ALL

SELECT
    animal_id,
    timestamp,
    latitude,
    longitude,
    sst_celsius,
    year,
    month,
    species,
    data_source,
    current_timestamp()
FROM atlas_bronze.sperm_whale_raw

UNION ALL

SELECT
    animal_id,
    timestamp,
    latitude,
    longitude,
    sst_celsius,
    year,
    month,
    species,
    data_source,
    current_timestamp()
FROM atlas_bronze.green_turtle_raw;

-- Validate: check row counts by species
SELECT species, COUNT(*) AS records
FROM atlas_silver.species_tracking_silver
GROUP BY species
ORDER BY records DESC;

-- -----------------------------------------------------------------------------
-- 2. SEA SURFACE TEMPERATURE — Silver cleaning
-- -----------------------------------------------------------------------------
-- Month 1 (January) creates the table.
-- Months 2–12 are INSERT INTO — not CREATE OR REPLACE.
-- Learned this the hard way: CREATE OR REPLACE wipes prior inserts.

CREATE TABLE IF NOT EXISTS atlas_silver.sea_surface_temperature_silver (
    latitude              DOUBLE,
    longitude             DOUBLE,
    sst_celsius           DOUBLE,
    year                  INT,
    month                 INT,
    temporal_resolution   STRING,
    lat_lower             DOUBLE,
    lat_upper             DOUBLE,
    lon_lower             DOUBLE,
    lon_upper             DOUBLE,
    processed_timestamp   TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
PARTITIONED BY (year)
COMMENT 'Cleaned SST Silver table. NOAA monthly data 1993–2026. Spatial bounds added for grid alignment.';

INSERT INTO atlas_silver.sea_surface_temperature_silver
SELECT
    latitude,
    longitude,
    sst_celsius,
    year,
    month,
    'monthly'                           AS temporal_resolution,
    FLOOR(latitude)                     AS lat_lower,
    FLOOR(latitude) + 1                 AS lat_upper,
    FLOOR(longitude)                    AS lon_lower,
    FLOOR(longitude) + 1               AS lon_upper,
    current_timestamp()                 AS processed_timestamp
FROM atlas_bronze.sst_raw
WHERE sst_celsius IS NOT NULL
  AND latitude  BETWEEN -90  AND 90
  AND longitude BETWEEN -180 AND 180;

-- Validate: all 12 months present per year
SELECT year, month, COUNT(*) AS row_count
FROM atlas_silver.sea_surface_temperature_silver
GROUP BY year, month
ORDER BY year, month;

-- -----------------------------------------------------------------------------
-- 3. CHLOROPHYLL — Silver cleaning
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS atlas_silver.chlorophyll_silver (
    latitude              DOUBLE,
    longitude             DOUBLE,
    chlorophyll_mgl       DOUBLE,
    year                  INT,
    month                 INT,
    temporal_resolution   STRING,
    lat_lower             DOUBLE,
    lat_upper             DOUBLE,
    lon_lower             DOUBLE,
    lon_upper             DOUBLE,
    processed_timestamp   TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
PARTITIONED BY (year)
COMMENT 'Cleaned chlorophyll Silver table. Indicator of phytoplankton / primary productivity.';

INSERT INTO atlas_silver.chlorophyll_silver
SELECT
    latitude,
    longitude,
    chlorophyll_mgl,
    year,
    month,
    'monthly'                           AS temporal_resolution,
    FLOOR(latitude)                     AS lat_lower,
    FLOOR(latitude) + 1                 AS lat_upper,
    FLOOR(longitude)                    AS lon_lower,
    FLOOR(longitude) + 1               AS lon_upper,
    current_timestamp()                 AS processed_timestamp
FROM atlas_bronze.chlorophyll_raw
WHERE chlorophyll_mgl IS NOT NULL
  AND chlorophyll_mgl >= 0;

-- -----------------------------------------------------------------------------
-- 4. UNIFIED ENVIRONMENTAL TABLE
-- -----------------------------------------------------------------------------
-- LEFT JOIN: keeps all SST rows even if no matching chlorophyll observation.
-- Join keys: latitude, longitude, year, month (all four required for accuracy).
-- Same pattern used in production data pipelines for environmental integration.

CREATE TABLE IF NOT EXISTS atlas_silver.environmental_conditions_silver (
    latitude              DOUBLE,
    longitude             DOUBLE,
    year                  INT,
    month                 INT,
    sst_celsius           DOUBLE,
    chlorophyll_mgl       DOUBLE,
    temporal_resolution   STRING,
    processed_timestamp   TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
PARTITIONED BY (year)
COMMENT 'Unified environmental Silver table. SST LEFT JOIN chlorophyll on lat/lon/year/month.';

INSERT INTO atlas_silver.environmental_conditions_silver
SELECT
    s.latitude,
    s.longitude,
    s.year,
    s.month,
    s.sst_celsius,
    c.chlorophyll_mgl,
    s.temporal_resolution,
    current_timestamp()         AS processed_timestamp
FROM atlas_silver.sea_surface_temperature_silver s
LEFT JOIN atlas_silver.chlorophyll_silver c
    ON  s.latitude  = c.latitude
    AND s.longitude = c.longitude
    AND s.year      = c.year
    AND s.month     = c.month;

-- Validate: check null chlorophyll (expected where coverage gaps exist)
SELECT
    COUNT(*)                                                    AS total_rows,
    SUM(CASE WHEN chlorophyll_mgl IS NULL THEN 1 ELSE 0 END)  AS null_chlorophyll,
    SUM(CASE WHEN sst_celsius     IS NULL THEN 1 ELSE 0 END)  AS null_sst
FROM atlas_silver.environmental_conditions_silver;

-- -----------------------------------------------------------------------------
-- 5. ENSO — Silver cleaning
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS atlas_silver.enso_silver (
    year                  INT,
    enso_phase            STRING,
    oni_index             DOUBLE,
    processed_timestamp   TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
COMMENT 'Cleaned ENSO Silver table. Used to contextualise SST anomalies across 33 years.';

INSERT INTO atlas_silver.enso_silver
SELECT
    year,
    TRIM(UPPER(enso_phase)) AS enso_phase,   -- standardise casing
    oni_index,
    current_timestamp()
FROM atlas_bronze.enso_raw
WHERE year IS NOT NULL;

-- -----------------------------------------------------------------------------
-- 6. BLEACHING — Silver cleaning
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS atlas_silver.bleaching_silver (
    year                      INT,
    bleaching_warning_cells   INT,
    processed_timestamp       TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
COMMENT 'Cleaned ICRI bleaching Silver table. 34 years 1993–2026. 2024 record: 447,475 cells.';

INSERT INTO atlas_silver.bleaching_silver
SELECT
    year,
    bleaching_warning_cells,
    current_timestamp()
FROM atlas_bronze.bleaching_raw
WHERE year                    IS NOT NULL
  AND bleaching_warning_cells IS NOT NULL
  AND bleaching_warning_cells  > 0;

-- Final validation across all Silver tables
SELECT 'species_tracking'           AS table_name, COUNT(*) AS rows FROM atlas_silver.species_tracking_silver
UNION ALL
SELECT 'sst',                                       COUNT(*)         FROM atlas_silver.sea_surface_temperature_silver
UNION ALL
SELECT 'chlorophyll',                               COUNT(*)         FROM atlas_silver.chlorophyll_silver
UNION ALL
SELECT 'environmental_conditions',                  COUNT(*)         FROM atlas_silver.environmental_conditions_silver
UNION ALL
SELECT 'enso',                                      COUNT(*)         FROM atlas_silver.enso_silver
UNION ALL
SELECT 'bleaching',                                 COUNT(*)         FROM atlas_silver.bleaching_silver;
