-- =============================================================================
-- ATLAS Marine | Bronze Layer Ingestion
-- Animal Tracking and Lifecycle Analysis System
-- =============================================================================
-- Purpose: Ingest raw species tracking and environmental data into immutable
--          Bronze Delta tables. No transformations beyond metadata enrichment.
--          Data preserved exactly as received for traceability and reprocessing.
-- Sources:
--   - Movebank species tracking CSVs (manta ray, whale shark, sperm whale, green turtle)
--   - NOAA sea surface temperature (monthly CSVs)
--   - NOAA chlorophyll concentration (monthly CSVs)
--   - NOAA ENSO climate index
--   - ICRI coral bleaching warning cells
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. SPECIES TRACKING — Reef Manta Ray
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS atlas_bronze.manta_ray_raw (
    animal_id         STRING,
    timestamp         TIMESTAMP,
    latitude          DOUBLE,
    longitude         DOUBLE,
    sst_celsius       DOUBLE,
    year              INT,
    month             INT,
    species           STRING,
    data_source       STRING,
    ingested_at       TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
COMMENT 'Raw Movebank tracking data — Reef Manta Ray (Mobula alfredi). Raja Ampat region primary habitat.';

-- Load from CSV
COPY INTO atlas_bronze.manta_ray_raw
FROM '/mnt/atlas/raw/species/manta_ray_tracking.csv'
FILEFORMAT = CSV
FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'true');

-- -----------------------------------------------------------------------------
-- 2. SPECIES TRACKING — Whale Shark
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS atlas_bronze.whale_shark_raw (
    animal_id         STRING,
    timestamp         TIMESTAMP,
    latitude          DOUBLE,
    longitude         DOUBLE,
    sst_celsius       DOUBLE,
    year              INT,
    month             INT,
    species           STRING,
    data_source       STRING,
    ingested_at       TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
COMMENT 'Raw Movebank tracking data — Whale Shark (Rhincodon typus).';

COPY INTO atlas_bronze.whale_shark_raw
FROM '/mnt/atlas/raw/species/whale_shark_tracking.csv'
FILEFORMAT = CSV
FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'true');

-- -----------------------------------------------------------------------------
-- 3. SPECIES TRACKING — Sperm Whale
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS atlas_bronze.sperm_whale_raw (
    animal_id         STRING,
    timestamp         TIMESTAMP,
    latitude          DOUBLE,
    longitude         DOUBLE,
    sst_celsius       DOUBLE,
    year              INT,
    month             INT,
    species           STRING,
    data_source       STRING,
    ingested_at       TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
COMMENT 'Raw Movebank tracking data — Sperm Whale (Physeter macrocephalus).';

COPY INTO atlas_bronze.sperm_whale_raw
FROM '/mnt/atlas/raw/species/sperm_whale_tracking.csv'
FILEFORMAT = CSV
FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'true');

-- -----------------------------------------------------------------------------
-- 4. SPECIES TRACKING — Green Turtle
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS atlas_bronze.green_turtle_raw (
    animal_id         STRING,
    timestamp         TIMESTAMP,
    latitude          DOUBLE,
    longitude         DOUBLE,
    sst_celsius       DOUBLE,
    year              INT,
    month             INT,
    species           STRING,
    data_source       STRING,
    ingested_at       TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
COMMENT 'Raw Movebank tracking data — Green Turtle (Chelonia mydas). Includes 2016 Chagos bleaching event overlap.';

COPY INTO atlas_bronze.green_turtle_raw
FROM '/mnt/atlas/raw/species/green_turtle_tracking.csv'
FILEFORMAT = CSV
FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'true');

-- -----------------------------------------------------------------------------
-- 5. ENVIRONMENTAL — Sea Surface Temperature (NOAA, monthly)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS atlas_bronze.sst_raw (
    latitude          DOUBLE,
    longitude         DOUBLE,
    sst_celsius       DOUBLE,
    year              INT,
    month             INT,
    data_source       STRING,
    ingested_at       TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
PARTITIONED BY (year)
COMMENT 'Raw NOAA sea surface temperature. Monthly resolution. 33 years (1993–2026).';

-- Load each monthly file incrementally (mirrors production pipeline pattern)
-- January initialises the table; Feb–Dec are inserted
COPY INTO atlas_bronze.sst_raw
FROM '/mnt/atlas/raw/environmental/sst/'
FILEFORMAT = CSV
FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'true');

-- -----------------------------------------------------------------------------
-- 6. ENVIRONMENTAL — Chlorophyll Concentration (NOAA, monthly)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS atlas_bronze.chlorophyll_raw (
    latitude          DOUBLE,
    longitude         DOUBLE,
    chlorophyll_mgl   DOUBLE,
    year              INT,
    month             INT,
    data_source       STRING,
    ingested_at       TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
PARTITIONED BY (year)
COMMENT 'Raw NOAA chlorophyll concentration. Indicator of phytoplankton abundance and primary productivity.';

COPY INTO atlas_bronze.chlorophyll_raw
FROM '/mnt/atlas/raw/environmental/chlorophyll/'
FILEFORMAT = CSV
FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'true');

-- -----------------------------------------------------------------------------
-- 7. CLIMATE — ENSO Index
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS atlas_bronze.enso_raw (
    year              INT,
    enso_phase        STRING,   -- El Nino / La Nina / Neutral
    oni_index         DOUBLE,   -- Oceanic Nino Index
    ingested_at       TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
COMMENT 'NOAA ENSO climate index. Used to contextualise SST anomalies and bleaching events.';

COPY INTO atlas_bronze.enso_raw
FROM '/mnt/atlas/raw/climate/enso_index.csv'
FILEFORMAT = CSV
FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'true');

-- -----------------------------------------------------------------------------
-- 8. CORAL BLEACHING — ICRI Warning Cells
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS atlas_bronze.bleaching_raw (
    year                      INT,
    bleaching_warning_cells   INT,   -- global count of reef cells at warning level
    ingested_at               TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
COMMENT 'ICRI coral bleaching warning cell counts 1993–2026. 2024 record: 447,475 cells during Neutral ENSO.';

COPY INTO atlas_bronze.bleaching_raw
FROM '/mnt/atlas/raw/bleaching/bleaching_warning_cells.csv'
FILEFORMAT = CSV
FORMAT_OPTIONS ('header' = 'true', 'inferSchema' = 'true');

-- -----------------------------------------------------------------------------
-- VALIDATION — Bronze row counts
-- -----------------------------------------------------------------------------
SELECT 'manta_ray'    AS table_name, COUNT(*) AS row_count FROM atlas_bronze.manta_ray_raw
UNION ALL
SELECT 'whale_shark',                COUNT(*)               FROM atlas_bronze.whale_shark_raw
UNION ALL
SELECT 'sperm_whale',                COUNT(*)               FROM atlas_bronze.sperm_whale_raw
UNION ALL
SELECT 'green_turtle',               COUNT(*)               FROM atlas_bronze.green_turtle_raw
UNION ALL
SELECT 'sst',                        COUNT(*)               FROM atlas_bronze.sst_raw
UNION ALL
SELECT 'chlorophyll',                COUNT(*)               FROM atlas_bronze.chlorophyll_raw
UNION ALL
SELECT 'enso',                       COUNT(*)               FROM atlas_bronze.enso_raw
UNION ALL
SELECT 'bleaching',                  COUNT(*)               FROM atlas_bronze.bleaching_raw;
