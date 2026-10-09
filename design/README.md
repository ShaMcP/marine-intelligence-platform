# Animated Visualisations

Six browser-based animations built with the HTML5 Canvas API and vanilla
JavaScript. No installation or external libraries required — open any file
in a browser and it runs.

All animations use the ATLAS gold-layer export data embedded directly in
the HTML file.

---

## Files

| File | Animation | Description |
|---|---|---|
| `atlas_animation.html` | Species Tracking | 4-panel dot animation — all four species across their full tracking period |
| `atlas_trails.html` | Movement Trails | Fading movement history with adjustable trail length (2 / 4 / 6 / 12 months) |
| `atlas_heatmap.html` | SST Thermal Landscape | Bilinear-interpolated temperature heatmap beneath observation dots |
| `atlas_enso.html` | ENSO Phase Overlay | Panels tint by El Niño / La Niña / Neutral phase with live MEI index bar |
| `atlas_stress.html` | Habitat Stress Index | Dots coloured 0–4 by composite pressure score (SST + chlorophyll + bleaching) |
| `atlas_turtle_deepdive.html` | Green Turtle Deep Dive | 10,000 full-resolution observations in the Western Indian Ocean |

---

## Technical Notes

- Built with the HTML5 Canvas API — browser built-in, no external libraries
- Data embedded in each file as a JavaScript array (exported from Gold layer)
- Animations are frame-based using `requestAnimationFrame`
- All six files are self-contained and run offline

---

## Data

Visualisation data exported from `mcphersonsharyn_gold` Unity Catalog tables
via Databricks. Species tracking data covers 69,776 observations across
116 individual animals and four species.

> **Note:** The Green Turtle Deep Dive currently shows 10,000 observations
> due to the Databricks UI 10,000-row export cap. The full dataset contains
> 55,411 rows. Full export planned for Phase 2.
