# 🌊 ATLAS Marine
### Animal Tracking and Lifecycle Analysis System

> *Connecting satellite ocean data to real animal movements — built to show what warming seas mean for the species living in them.*

---

## What is ATLAS?

ATLAS Marine is an independent conservation data platform built on **Databricks Lakehouse** architecture. It integrates satellite tracking data from **116 individual marine animals** with 33 years of NOAA sea surface temperature records, coral bleaching alerts, and ENSO climate indices — then surfaces the findings through interactive dashboards and a global tracking map.

This is a portfolio project built entirely outside of work hours to demonstrate end-to-end data engineering for marine conservation.

---

## Key Findings

| Finding | Detail |
|---|---|
| 🌡️ Fastest warming habitat | Reef Manta Ray habitat (Raja Ampat) warmed **+0.52°C** over 34 years — the highest rate in the ATLAS dataset |
| 🪸 2024 bleaching record | **447,475** bleaching warning cells recorded in 2024 — during a **Neutral ENSO phase**. No El Niño needed. |
| 📍 Thermal stress overlap | 3 individual green turtles tracked by ATLAS were present in the Chagos Archipelago during the 2016 mass bleaching event |
| 🦈 All species above 30°C | Every species in the dataset has experienced SST above 30°C at least once during their tracked period |
| 🌊 Four bleaching events | 1998 · 2010 · 2016 · 2024 — each event worse than the last |

---

## Dashboards

**Tableau Public:** [public.tableau.com/app/profile/sharyn.mcpherson](https://public.tableau.com/app/profile/sharyn.mcpherson)

| Dashboard | Description |
|---|---|
| ENSO Phase vs SST | Average sea surface temperature by species and ENSO climate phase |
| Species Tracking Map | 69,776 observations across three ocean basins, dot size = habitat stress index |
| Ocean Warming Trend | SST trend lines by species tracking period with linear regression |
| Bleaching Timeline | 34 years of global coral bleaching warning cells (1993–2026) |

---

## Species Covered

| Species | Region | Observations | Years | IUCN Status |
|---|---|---|---|---|
| Reef Manta Ray | Raja Ampat, Indonesia | 3,224 | 2014–2022 | Vulnerable |
| Whale Shark | Gulf of Mexico | 3,382 | 2009–2015 | Endangered |
| Sperm Whale | Gulf of Mexico | 7,759 | 2011–2013 | Vulnerable |
| Green Turtle | Chagos Archipelago, Indian Ocean | 55,411 | 2012–2019 | Endangered |

---

## Tech Stack

```
Data Sources
├── Movebank (satellite tracking — 116 animals)
├── NOAA ERDDAP (sea surface temperature)
├── NOAA Coral Reef Watch (bleaching alert areas)
└── NOAA PSL (ENSO / MEI index)

Pipeline — Databricks on AWS
├── Bronze  →  Raw ingestion (Delta Lake)
├── Silver  →  Cleaned, validated, joined
└── Gold    →  Aggregated for analysis

Visualisation
├── Kepler.gl  →  Global species tracking map
└── Tableau Public  →  Four interactive dashboards

Languages & Tools
├── PySpark / Python
├── SQL (Unity Catalog)
├── H3 spatial indexing
└── Delta Lake / Unity Catalog Volumes
```

---

## Data Files

| File | Rows | Description |
|---|---|---|
| `ATLAS_Combined.csv` | 69,776 | All four species — tracking + SST + bleaching by year |
| `ATLAS_Bleaching_Timeline_clean.csv` | 34 | Annual global bleaching warning cells 1993–2026 |
| `ATLAS_Manta_Ray_clean.csv` | 3,224 | Reef Manta Ray — Raja Ampat |
| `ATLAS_Whale_Shark_clean.csv` | 3,382 | Whale Shark — Gulf of Mexico |
| `ATLAS_Sperm_Whale_clean.csv` | 7,759 | Sperm Whale — Gulf of Mexico |
| `ATLAS_Green_Turtle_clean.csv` | 55,411 | Green Turtle — Chagos Archipelago |

---

## Project Structure

```
ATLAS/
├── data/                  # CSV data files
├── notebooks/             # Databricks notebooks
│   ├── bronze/            # Raw ingestion
│   ├── silver/            # Transformation & validation
│   └── gold/              # Aggregation & analysis
├── sql/                   # Unity Catalog SQL scripts
├── kepler/                # Kepler.gl map export
└── README.md
```

---

## Why This Matters

Coral reefs support **25% of all marine life** and over **1 billion people** depend on them for food and income. The 2024 bleaching event — the worst on record — happened without El Niño. The ocean is warming fast enough that background temperatures alone now trigger mass bleaching events.

ATLAS exists to make that visible — connecting the temperature numbers to the animals actually living in those waters.

---

## Contact

**Sharyn McPherson** — Data Engineer  
📧 atlasmarine.data@gmail.com  
🐙 github.com/ShaMcP/ATLAS  
📊 public.tableau.com/app/profile/sharyn.mcpherson

---

*Data: Movebank · NOAA ERDDAP · NOAA Coral Reef Watch · NOAA PSL*  
*Built with Databricks · PySpark · Tableau Public · Kepler.gl*
