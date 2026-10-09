# Platform Overview

ATLAS Marine (Animal Tracking and Lifecycle Analysis System) is an independent
conservation data platform built on Databricks Lakehouse architecture. It
integrates satellite tracking data from 116 individual marine animals with
33 years of NOAA environmental records to surface findings through interactive
dashboards and animated species visualisations.

---

## Objectives

- Ingest raw species tracking and environmental data from public sources
- Clean, validate, and enrich data through a medallion pipeline
- Join animal movement data with sea surface temperature, chlorophyll, ENSO, and bleaching records
- Deliver findings through Tableau dashboards, Kepler.gl maps, and browser-based animations
- Provide a reproducible, documented foundation for Phase 2 extensions

---

## High-Level Architecture

### Bronze Layer — `mcphersonsharyn_bronze`
- Raw data ingested exactly as received — no transformations
- 8 Delta tables: 4 species tracking + SST + chlorophyll + ENSO + bleaching
- Data loaded via Databricks UI upload into Unity Catalog volumes
- Partitioned by year for SST and chlorophyll tables

### Silver Layer — `mcphersonsharyn_silver`
- Cleaned, validated, and standardised datasets
- Species union: all four tracking tables merged into `species_tracking_silver`
- Spatial bounds columns added (lat/lon floor grids) for environmental joins
- SST LEFT JOIN chlorophyll into `environmental_conditions_silver`
- ENSO phase standardised to uppercase; bleaching nulls and zeros filtered

### Gold Layer — `mcphersonsharyn_gold`
- Analytics-ready aggregations for dashboards and reporting
- `atlas_combined_gold` — 69,776 rows: tracking + ENSO + bleaching (primary Tableau source)
- `species_sst_summary_gold` — per-species temperature analytics by year
- `bleaching_timeline_gold` — annual trend with year-over-year change and ENSO context
- `raja_ampat_warming_gold` — Raja Ampat SST trend validating the +0.52°C finding
- `environmental_monthly_gold` — SST + chlorophyll aggregated by spatial grid

---

## Technology Stack

| Layer | Tool |
|---|---|
| **Cloud platform** | Databricks on AWS |
| **Storage format** | Delta Lake (Unity Catalog) |
| **Transformation** | PySpark / SQL |
| **Spatial indexing** | H3 hexagonal indexing (res4) |
| **Tracking map** | Kepler.gl |
| **Dashboards** | Tableau Public |
| **Animations** | HTML5 Canvas API (vanilla JS) |
| **Version control** | GitHub |

---

## Phase 2 Planned Enhancements

- COPY INTO from S3 to replace manual UI uploads
- Extended telemetry via Movebank and OBIS-SEAMAP re-query (all four species to present)
- Supplemental NOAA chlorophyll download for Gulf of Mexico 22–32°N (whale shark range)
- Full Green Turtle Deep Dive export (55,411 rows — current UI cap is 10,000)
- Feature tables for machine learning workflows
