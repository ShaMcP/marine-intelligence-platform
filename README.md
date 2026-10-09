# 🌊 ATLAS Marine
### Animal Tracking and Lifecycle Analysis System

> *Connecting satellite ocean data to real animal movements — built to show what warming seas mean for the species living in them.*

---

## What is ATLAS?

ATLAS Marine is an independent conservation data platform built on **Databricks Lakehouse** architecture. It integrates satellite tracking data from **116 individual marine animals** with 33 years of NOAA sea surface temperature records, coral bleaching alerts, and ENSO climate indices — then surfaces the findings through interactive dashboards, a global tracking map, and a suite of animated species visualisations.

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
| 🌊 La Niña paradox | In Raja Ampat, La Niña average SST (29.47°C) **exceeds** El Niño SST (28.80°C) — long-term warming is overriding the expected ENSO cooling signal |

---

## Animated Visualisations

Six canvas-based animations built to show how animal movements relate to ocean conditions over time. All run in the browser — no installation needed.

| Animation | Description |
|---|---|
| **Species Tracking** | 4-panel dot animation — all four species across their full tracking period |
| **Movement Trails** | Fading movement history with adjustable trail length (2 / 4 / 6 / 12 months) |
| **SST Thermal Landscape** | Bilinear-interpolated temperature heatmap beneath observation dots |
| **ENSO Phase Overlay** | Panels tint by El Niño / La Niña / Neutral phase with live MEI index bar |
| **Habitat Stress Index** | Dots coloured 0–4 by composite pressure score (SST + chlorophyll + microplastics + bleaching) |
| **Green Turtle Deep Dive** | 10,000 full-resolution observations in the Western Indian Ocean — the densest view in the dataset |

> **Data note:** Telemetry reflects deployments available at time of ingestion. Phase 2 will extend all four species to present via Movebank and OBIS-SEAMAP re-query (current cutoffs: Green Turtle 2012–2019, Reef Manta Ray 2014–2022, Sperm Whale 2011–2013, Whale Shark 2009–2015).

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
