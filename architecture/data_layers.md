# Data Layers

ATLAS follows a Bronze, Silver, and Gold medallion architecture on Databricks
Delta Lake to ensure data quality, traceability, and analytical flexibility.

---

## Bronze Layer — `mcphersonsharyn_bronze`

Raw data ingested exactly as received from source systems. No transformations
applied beyond metadata enrichment (`ingested_at` timestamp).

| Table | Source | Rows |
|---|---|---|
| `manta_ray_raw` | Movebank — Reef Manta Ray, Raja Ampat | 3,224 |
| `whale_shark_raw` | Movebank — Whale Shark, Gulf of Mexico | 3,382 |
| `sperm_whale_raw` | Movebank — Sperm Whale, Gulf of Mexico | 7,759 |
| `green_turtle_raw` | Movebank — Green Turtle, Chagos Archipelago | 55,411 |
| `sst_raw` | NOAA ERDDAP — monthly SST 1993–2026 | partitioned by year |
| `chlorophyll_raw` | NOAA — monthly chlorophyll 1993–2026 | partitioned by year |
| `enso_raw` | NOAA PSL — annual ENSO phase + ONI index | 34 |
| `bleaching_raw` | ICRI — annual bleaching warning cell counts | 34 |

**Key principle:** Data is never modified after ingestion. Reprocessing always starts from Bronze.

---

## Silver Layer — `mcphersonsharyn_silver`

Cleaned, validated, and standardised datasets ready for analytical joins.

| Table | Description |
|---|---|
| `species_tracking_silver` | UNION ALL of all four species — 69,776 rows |
| `sea_surface_temperature_silver` | Cleaned SST with spatial bound columns |
| `chlorophyll_silver` | Cleaned chlorophyll with spatial bound columns |
| `environmental_conditions_silver` | SST LEFT JOIN chlorophyll on lat/lon/year/month |
| `enso_silver` | ENSO phase uppercased and trimmed |
| `bleaching_silver` | Bleaching records with nulls and zeros filtered |

**Key lesson:** `CREATE OR REPLACE TABLE` wipes existing data. Always use
`CREATE TABLE IF NOT EXISTS` then `INSERT INTO` for incremental loads.

---

## Gold Layer — `mcphersonsharyn_gold`

Aggregated, analytics-ready tables optimised for Tableau dashboards and reporting.

| Table | Description |
|---|---|
| `atlas_combined_gold` | 69,776 rows — tracking + ENSO + bleaching (primary Tableau source) |
| `environmental_monthly_gold` | SST + chlorophyll by year/month/spatial grid |
| `species_sst_summary_gold` | Per-species SST avg/min/max by year |
| `bleaching_timeline_gold` | Annual bleaching trend with YoY change and ENSO phase |
| `raja_ampat_warming_gold` | Raja Ampat annual SST — validates +0.52°C finding |

**Key principle:** Gold tables answer analytical questions directly. Reduced
volume, smoothed noise, trusted output.
