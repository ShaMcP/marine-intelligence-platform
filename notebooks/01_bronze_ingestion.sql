-- =============================================================================
-- ATLAS Marine | Bronze Layer Ingestion
-- Animal Tracking and Lifecycle Analysis System
-- =============================================================================
-- Purpose: Ingest raw species tracking and environmental data into immutable
--          Bronze Delta tables. No transformations beyond metadata enrichment.
--          Data preserved exactly as received for traceability and reprocessing.
-- Schema:  mcphersonsharyn_bronze (Unity Catalog)
-- Sources:
--   - Movebank species tracking CSVs (manta ray, whale shark, sperm whale, green turtle)
--   - NOAA sea surface temperature (monthly CSVs)
--   - NOAA chlorophyll concentration (monthly CSVs)
--   - NOAA ENSO climate index
--   - ICRI coral bleaching warning cells
-- =============================================================================
-- NOTE ON INGESTION METHOD
-- Source CSVs were uploaded manually via the Databricks UI (Add Data → Upload Files)
-- rather than from a mounted S3 path. The DBFS root was restricted in this workspace
-- and S3 bucket configuration was deferred to Phase 2. Each file was uploaded into
-- a Unity Catalog volume and the resulting path used in the INSERT INTO statements.
-- The CREATE TABLE statements below define the schema; data was loaded via the
-- Databricks UI upload wizard which generates INSERT INTO statements automatically.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. SPECIES TRACKING — Reef Manta Ray
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mcphersonsharyn_bronze.manta_ray_raw (
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

-- Data loaded via Databricks UI upload → Unity Catalog volume
-- Production pattern: COPY INTO from S3 (Phase 2)

-- -----------------------------------------------------------------------------
-- 2. SPECIES TRACKING — Whale Shark
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mcphersonsharyn_bronze.whale_shark_raw (
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
COMMENT 'Raw Movebank tracking data — Whale Shark (Rhincodon typus). Gulf of Mexico. 2009–2015.';

-- NOTE: Chlorophyll bounding box for Gulf of Mexico (17–22°N) excludes northern Gulf
-- (22–32°N) where whale sharks actually range. Habitat stress index for this species
-- is therefore calculated without valid CC data for most of their tracked area.
-- Fix planned for Phase 2: supplemental NOAA CC download for 22–32°N.

-- -----------------------------------------------------------------------------
-- 3. SPECIES TRACKING — Sperm Whale
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mcphersonsharyn_bronze.sperm_whale_raw (
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
COMMENT 'Raw Movebank tracking data — Sperm Whale (Physeter macrocephalus). Gulf of Mexico. 2011–2013.';

-- -----------------------------------------------------------------------------
-- 4. SPECIES TRACKING — Green Turtle
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mcphersonsharyn_bronze.green_turtle_raw (
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
COMMENT 'Raw Movebank tracking data — Green Turtle (Chelonia mydas). Chagos Archipelago. 2012–2019. Includes 2016 bleaching event overlap.';

-- -----------------------------------------------------------------------------
-- 5. ENVIRONMENTAL — Sea Surface Temperature (NOAA, monthly)
-- -----------------------------------------------------------------------------
-- NOTE: SST dataset spans 1993–2026. Each year has 12 monthly CSV files.
-- The Databricks UI upload limit is 10 files per batch — files were uploaded
-- in two batches per year. Schema initialised once with CREATE TABLE IF NOT EXISTS;
-- subsequent batches used INSERT INTO to avoid overwriting earlier months.
-- Lesson: CREATE OR REPLACE TABLE wipes the table — never use it after initial creation.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mcphersonsharyn_bronze.sst_raw (
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

-- Validation after each batch — catches partial ingestion before it propagates
SELECT year, month, COUNT(*) AS row_count
FROM mcphersonsharyn_bronze.sst_raw
GROUP BY year, month
ORDER BY year, month;

-- -----------------------------------------------------------------------------
-- 6. ENVIRONMENTAL — Chlorophyll Concentration (NOAA, monthly)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mcphersonsharyn_bronze.chlorophyll_raw (
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

-- -----------------------------------------------------------------------------
-- 7. CLIMATE — ENSO Index
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mcphersonsharyn_bronze.enso_raw (
    year              INT,
    enso_phase        STRING,   -- El Nino / La Nina / Neutral
    oni_index         DOUBLE,   -- Oceanic Nino Index
    ingested_at       TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
COMMENT 'NOAA ENSO climate index. Used to contextualise SST anomalies and bleaching events.';

-- -----------------------------------------------------------------------------
-- 8. CORAL BLEACHING — ICRI Warning Cells
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mcphersonsharyn_bronze.bleaching_raw (
    year                      INT,
    bleaching_warning_cells   INT,   -- global count of reef cells at warning level
    ingested_at               TIMESTAMP DEFAULT current_timestamp()
)
USING DELTA
COMMENT 'ICRI coral bleaching warning cell counts 1993–2026. 2024 record: 447,475 cells during Neutral ENSO.';

-- -----------------------------------------------------------------------------
-- VALIDATION — Bronze row counts
-- -----------------------------------------------------------------------------
SELECT 'manta_ray'    AS table_name, COUNT(*) AS row_count FROM mcphersonsharyn_bronze.manta_ray_raw
UNION ALL
SELECT 'whale_shark',                COUNT(*)               FROM mcphersonsharyn_bronze.whale_shark_raw
UNION ALL
SELECT 'sperm_whale',                COUNT(*)               FROM mcphersonsharyn_bronze.sperm_whale_raw
UNION ALL
SELECT 'green_turtle',               COUNT(*)               FROM mcphersonsharyn_bronze.green_turtle_raw
UNION ALL
SELECT 'sst',                        COUNT(*)               FROM mcphersonsharyn_bronze.sst_raw
UNION ALL
SELECT 'chlorophyll',                COUNT(*)               FROM mcphersonsharyn_bronze.chlorophyll_raw
UNION ALL
SELECT 'enso',                       COUNT(*)               FROM mcphersonsharyn_bronze.enso_raw
UNION ALL
SELECT 'bleaching',                  COUNT(*)               FROM mcphersonsharyn_bronze.bleaching_raw;
