# Data

Processed datasets exported from the ATLAS Marine Gold layer (`mcphersonsharyn_gold`).
All files are CSV format and ready for use in Tableau, Python, or any analytics tool.

---

## Files

| File | Rows | Description |
|---|---|---|
| `ATLAS_Combined.csv` | 69,776 | All four species — tracking + ENSO phase + bleaching warning cells by year. Primary Tableau data source. |
| `ATLAS_Bleaching_Timeline_clean.csv` | 34 | Annual global coral bleaching warning cells 1993–2026 with ENSO phase. |
| `ATLAS_Manta_Ray_clean.csv` | 3,224 | Reef Manta Ray tracking — Raja Ampat, Indonesia. 2014–2022. |
| `ATLAS_Whale_Shark_clean.csv` | 3,382 | Whale Shark tracking — Gulf of Mexico. 2009–2015. |
| `ATLAS_Sperm_Whale_clean.csv` | 7,759 | Sperm Whale tracking — Gulf of Mexico. 2011–2013. |
| `ATLAS_Green_Turtle_clean.csv` | 55,411 | Green Turtle tracking — Chagos Archipelago, Indian Ocean. 2012–2019. |

---

## Columns — Species Tracking Files

| Column | Description |
|---|---|
| `animal_id` | Unique identifier for each tagged individual |
| `timestamp` | Date and time of observation |
| `latitude` | Decimal degrees |
| `longitude` | Decimal degrees |
| `sst_celsius` | Sea surface temperature at observation point |
| `year` | Year of observation |
| `month` | Month of observation |
| `species` | Common species name |
| `data_source` | Movebank study identifier |

---

## Columns — ATLAS_Combined.csv (additional)

| Column | Description |
|---|---|
| `enso_phase` | El Niño / La Niña / Neutral — NOAA annual classification |
| `bleaching_warning_cells` | Global coral reef cells at bleaching warning level (ICRI) |

---

## Source

Raw data sourced from:
- **Movebank** — satellite species tracking
- **NOAA ERDDAP** — sea surface temperature
- **NOAA PSL** — ENSO / ONI index
- **ICRI** — coral bleaching warning cells

Processed through the ATLAS Bronze → Silver → Gold Databricks pipeline.
