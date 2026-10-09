# Data Sources

All data sources used in ATLAS Marine are publicly available. This document
describes each source, what was ingested, and its analytical purpose.

---

## Species Tracking — Movebank

**Source:** [movebank.org](https://www.movebank.org)
**Format:** CSV (one file per species)

| Species | Region | Animals | Years | Observations |
|---|---|---|---|---|
| Reef Manta Ray *(Mobula alfredi)* | Raja Ampat, Indonesia | — | 2014–2022 | 3,224 |
| Whale Shark *(Rhincodon typus)* | Gulf of Mexico | — | 2009–2015 | 3,382 |
| Sperm Whale *(Physeter macrocephalus)* | Gulf of Mexico | — | 2011–2013 | 7,759 |
| Green Turtle *(Chelonia mydas)* | Chagos Archipelago | — | 2012–2019 | 55,411 |

**Total:** 116 individual animals · 69,776 observations

**Purpose:** Core biological dataset. Timestamped lat/lon positions joined
with environmental data to reveal how warming seas affect animal movement.

---

## Sea Surface Temperature — NOAA ERDDAP

**Source:** NOAA ERDDAP
**Format:** Monthly CSV files (12 per year)
**Coverage:** 1993–2026 (33 years)

**Purpose:** Primary environmental variable. Joined to species tracking by
lat/lon grid and year/month to calculate per-observation thermal conditions.
Used in all four Tableau dashboards and all six animations.

---

## Chlorophyll Concentration — NOAA

**Source:** NOAA
**Format:** Monthly CSV files
**Coverage:** Gulf of Mexico (17–22°N) and Indian Ocean / Raja Ampat regions

**Purpose:** Indicator of phytoplankton abundance and primary productivity.
Combined with SST in the Silver `environmental_conditions_silver` table.

> **Known gap:** The Gulf of Mexico bounding box (17–22°N) excludes the
> northern Gulf (22–32°N) where whale sharks actually range. Chlorophyll
> data for whale shark observations is therefore incomplete. Fix planned
> for Phase 2: supplemental NOAA download for 22–32°N.

---

## ENSO Climate Index — NOAA PSL

**Source:** NOAA Physical Sciences Laboratory
**Format:** CSV (annual)
**Coverage:** 1993–2026

**Fields:** Year · ENSO phase (El Niño / La Niña / Neutral) · Oceanic Niño Index (ONI)

**Purpose:** Climate context for SST anomalies and bleaching events. Key
finding: in Raja Ampat, La Niña average SST (29.47°C) now exceeds El Niño
SST (28.80°C) — long-term warming is overriding the expected ENSO cooling signal.

---

## Coral Bleaching Warning Cells — ICRI

**Source:** International Coral Reef Initiative (ICRI)
**Format:** CSV (annual)
**Coverage:** 1993–2026

**Field:** Annual global count of reef cells at bleaching warning level

**Purpose:** Tracks the global scale of coral bleaching over 34 years.
Key finding: 2024 recorded 447,475 warning cells during a Neutral ENSO
phase — no El Niño required. Each of the four major bleaching events
(1998 · 2010 · 2016 · 2024) was worse than the last.
