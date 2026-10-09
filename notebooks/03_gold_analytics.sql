-- =============================================================================
-- ATLAS Marine | Gold Layer Analytics
-- Animal Tracking and Lifecycle Analysis System
-- =============================================================================
-- Purpose: Aggregate Silver data into Gold tables optimised for dashboards,
--          reporting, and insight generation. Gold tables answer analytical
--          questions directly — reduced volume, smoothed noise, trusted output.
--
-- Gold tables produced:
--   1. atlas_combined_gold        — species tracking + bleaching (Tableau-ready)
--   2. environmental_monthly_gold — SST + chlorophyll aggregated by grid/month
--   3. species_sst_summary_gold   — per-species temperature analytics
--   4. bleaching_timeline_gold    — annual bleaching trend with ENSO context
--   5. raja_ampat_warming_gold    — Raja Ampat SST trend (key finding: +0.52°C)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. ATLAS COMBINED — Species tracking enriched with bleaching context
-- -----------------------------------------------------------------------------
-- This is the primary Tableau data source (ATLAS_Combined.csv).
-- LEFT JOIN bleaching on year so all 69,776 tracking rows are preserved.
-- Avoids the Tableau Public "Multiple Connections" error — one source, all data.

CREATE TABLE IF NOT EXISTS mcphersonsharyn_gold.atlas_combined_gold (
    animal_id                 STRING,
    timestamp                 TIMESTAMP,
    latitude                  DOUBLE,
    longitude                 DOUBLE,
    sst_celsius               DOUBLE,
    year                      INT,
    month                     INT,
    species                   STRING,
    data_source               STRING,
    enso_phase                STRING,
    bleaching_warning_cells   INT
)
USING DELTA
COMMENT 'Gold: 69,776 rows. Species tracking LEFT JOINed with bleaching + ENSO on year. Primary Tableau source.';

INSERT INTO mcphersonsharyn_gold.atlas_combined_gold
SELECT
    t.animal_id,
    t.timestamp,
    t.latitude,
    t.longitude,
    t.sst_celsius,
    t.year,
    t.month,
    t.species,
    t.data_source,
    e.enso_phase,
    b.bleaching_warning_cells
FROM mcphersonsharyn_silver.species_tracking_silver t
LEFT JOIN mcphersonsharyn_silver.enso_silver    e ON t.year = e.year
LEFT JOIN mcphersonsharyn_silver.bleaching_silver b ON t.year = b.year;

-- Validate: zero nulls on bleaching_warning_cells expected
SELECT
    COUNT(*)                                                              AS total_rows,
    SUM(CASE WHEN bleaching_warning_cells IS NULL THEN 1 ELSE 0 END)    AS null_bleaching,
    SUM(CASE WHEN enso_phase              IS NULL THEN 1 ELSE 0 END)    AS null_enso
FROM mcphersonsharyn_gold.atlas_combined_gold;

-- -----------------------------------------------------------------------------
-- 2. ENVIRONMENTAL MONTHLY SUMMARY
-- -----------------------------------------------------------------------------
-- Aggregated by year, month, and spatial grid (rounded lat/lon).
-- Spatial bucketing reduces noise and improves query performance.
-- Enables seasonal pattern detection and regional comparison.

CREATE TABLE IF NOT EXISTS mcphersonsharyn_gold.environmental_monthly_gold (
    year                  INT,
    month                 INT,
    lat_grid              DOUBLE,   -- ROUND(latitude, 1)
    lon_grid              DOUBLE,   -- ROUND(longitude, 1)
    avg_sst_celsius       DOUBLE,
    avg_chlorophyll_mgl   DOUBLE,
    observation_count     BIGINT
)
USING DELTA
PARTITIONED BY (year)
COMMENT 'Gold: Environmental conditions aggregated by year/month/spatial grid. Seasonal trend analysis.';

INSERT INTO mcphersonsharyn_gold.environmental_monthly_gold
SELECT
    year,
    month,
    ROUND(latitude,  1)         AS lat_grid,
    ROUND(longitude, 1)         AS lon_grid,
    AVG(sst_celsius)            AS avg_sst_celsius,
    AVG(chlorophyll_mgl)        AS avg_chlorophyll_mgl,
    COUNT(*)                    AS observation_count
FROM mcphersonsharyn_silver.environmental_conditions_silver
GROUP BY year, month, ROUND(latitude, 1), ROUND(longitude, 1);

-- Validate: all months present for each year
SELECT year, COUNT(DISTINCT month) AS months_present
FROM mcphersonsharyn_gold.environmental_monthly_gold
GROUP BY year
ORDER BY year;

-- -----------------------------------------------------------------------------
-- 3. SPECIES SST SUMMARY — Per-species temperature analytics
-- -----------------------------------------------------------------------------
-- Key finding: all four species recorded SST above 30°C at least once.
-- Manta rays in Raja Ampat warmed +0.52°C over the 33-year dataset.

CREATE TABLE IF NOT EXISTS mcphersonsharyn_gold.species_sst_summary_gold (
    species           STRING,
    year              INT,
    avg_sst_celsius   DOUBLE,
    min_sst_celsius   DOUBLE,
    max_sst_celsius   DOUBLE,
    tracking_records  BIGINT
)
USING DELTA
COMMENT 'Gold: Per-species SST averages by year. Source for Ocean Warming and Species Temperature dashboards.';

INSERT INTO mcphersonsharyn_gold.species_sst_summary_gold
SELECT
    species,
    year,
    AVG(sst_celsius)   AS avg_sst_celsius,
    MIN(sst_celsius)   AS min_sst_celsius,
    MAX(sst_celsius)   AS max_sst_celsius,
    COUNT(*)           AS tracking_records
FROM mcphersonsharyn_silver.species_tracking_silver
WHERE sst_celsius IS NOT NULL
GROUP BY species, year
ORDER BY species, year;

-- Key findings check
SELECT species, MAX(max_sst_celsius) AS peak_sst
FROM mcphersonsharyn_gold.species_sst_summary_gold
GROUP BY species
ORDER BY peak_sst DESC;
-- Expected: all species above 30°C

-- -----------------------------------------------------------------------------
-- 4. BLEACHING TIMELINE — Annual trend with ENSO context
-- -----------------------------------------------------------------------------
-- Used for standalone Bleaching Timeline dashboard (separate Tableau workbook).
-- 2024 finding: 447,475 warning cells during Neutral ENSO — unprecedented.
-- Previous peaks (1998, 2010, 2016) all coincided with El Niño events.

CREATE TABLE IF NOT EXISTS mcphersonsharyn_gold.bleaching_timeline_gold (
    year                      INT,
    bleaching_warning_cells   INT,
    enso_phase                STRING,
    oni_index                 DOUBLE,
    yoy_change_cells          INT,       -- year-over-year change
    yoy_change_pct            DOUBLE     -- year-over-year % change
)
USING DELTA
COMMENT 'Gold: Annual bleaching trend 1993–2026 with ENSO phase. 2024 record: 447,475 cells (Neutral ENSO).';

INSERT INTO mcphersonsharyn_gold.bleaching_timeline_gold
SELECT
    b.year,
    b.bleaching_warning_cells,
    e.enso_phase,
    e.oni_index,
    b.bleaching_warning_cells - LAG(b.bleaching_warning_cells)
        OVER (ORDER BY b.year)                                  AS yoy_change_cells,
    ROUND(
        (b.bleaching_warning_cells - LAG(b.bleaching_warning_cells)
            OVER (ORDER BY b.year))
        * 100.0
        / NULLIF(LAG(b.bleaching_warning_cells) OVER (ORDER BY b.year), 0),
        2
    )                                                           AS yoy_change_pct
FROM mcphersonsharyn_silver.bleaching_silver b
LEFT JOIN mcphersonsharyn_silver.enso_silver e ON b.year = e.year
ORDER BY b.year;

-- Notable events check
SELECT year, bleaching_warning_cells, enso_phase
FROM mcphersonsharyn_gold.bleaching_timeline_gold
WHERE bleaching_warning_cells > 200000
ORDER BY bleaching_warning_cells DESC;
-- Expected: 2024 (447,475 Neutral), 1998, 2010, 2016

-- -----------------------------------------------------------------------------
-- 5. RAJA AMPAT WARMING — Key finding validation
-- -----------------------------------------------------------------------------
-- Raja Ampat bounding box: lat 0°S–4°S, lon 130°E–135°E
-- Finding: +0.52°C warming over 33 years — highest rate in the ATLAS dataset.
-- Manta ray primary habitat — directly affects feeding and reproduction.

CREATE TABLE IF NOT EXISTS mcphersonsharyn_gold.raja_ampat_warming_gold (
    year              INT,
    avg_sst_celsius   DOUBLE,
    observation_count BIGINT
)
USING DELTA
COMMENT 'Gold: Raja Ampat annual SST trend. Key finding: +0.52°C over 33 years. Manta ray primary habitat.';

INSERT INTO mcphersonsharyn_gold.raja_ampat_warming_gold
SELECT
    year,
    AVG(sst_celsius)    AS avg_sst_celsius,
    COUNT(*)            AS observation_count
FROM mcphersonsharyn_silver.environmental_conditions_silver
WHERE latitude  BETWEEN -4  AND 0
  AND longitude BETWEEN 130 AND 135
GROUP BY year
ORDER BY year;

-- Warming trend: compare earliest vs latest decade
SELECT
    CASE
        WHEN year BETWEEN 1993 AND 2002 THEN '1993–2002 baseline'
        WHEN year BETWEEN 2016 AND 2026 THEN '2016–2026 recent'
    END                          AS period,
    ROUND(AVG(avg_sst_celsius), 3) AS avg_sst
FROM mcphersonsharyn_gold.raja_ampat_warming_gold
WHERE year BETWEEN 1993 AND 2002
   OR year BETWEEN 2016 AND 2026
GROUP BY 1;
-- Expected delta: ~+0.52°C

-- -----------------------------------------------------------------------------
-- FINAL GOLD SUMMARY
-- -----------------------------------------------------------------------------
SELECT 'atlas_combined'           AS gold_table, COUNT(*) AS rows FROM mcphersonsharyn_gold.atlas_combined_gold
UNION ALL
SELECT 'environmental_monthly',                  COUNT(*)         FROM mcphersonsharyn_gold.environmental_monthly_gold
UNION ALL
SELECT 'species_sst_summary',                    COUNT(*)         FROM mcphersonsharyn_gold.species_sst_summary_gold
UNION ALL
SELECT 'bleaching_timeline',                     COUNT(*)         FROM mcphersonsharyn_gold.bleaching_timeline_gold
UNION ALL
SELECT 'raja_ampat_warming',                     COUNT(*)         FROM mcphersonsharyn_gold.raja_ampat_warming_gold;
