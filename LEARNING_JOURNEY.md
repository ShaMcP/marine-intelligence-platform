# 🌊 ATLAS Marine — Learning Journey

**Building an independent conservation data platform from scratch.**

This document is an honest account of how ATLAS Marine was built — what I planned, what broke, what I learned, and how I fixed it. It covers the full journey from an empty Databricks workspace to published dashboards, a live GitHub repo, and a suite of animated visualisations.

---

## Why I built this

It started simply enough. I needed to learn Databricks.

I'm a Data Engineer at Capgemini. A few years ago I made a career switch into tech, completed the Code First Girls Data Engineering bootcamp, and landed my role from there. I wanted a portfolio project that proved what I could actually do, end-to-end — something that might help with a promotion, something that showed I could build a real data platform, not just follow a tutorial.

I chose the ocean deliberately. I've always had an interest in ocean life — the scale of it, the way it makes everything else feel small and manageable at the same time. I grew up watching ocean documentaries and being near the water has always felt like the clearest my head gets. If I was going to spend months building this, it was going to be for something that mattered.

So I spun up a workspace and started ingesting CSVs.

Nine months later, the goals I started with — proof of capability, career advancement, an independent technical contribution — haven't gone away. But they've grown into something bigger. I actually want to help. I want the ocean to be okay. I want the animals in this dataset — the manta rays in Raja Ampat, the green turtles in Chagos, the whale sharks crossing the Indo-Pacific — to have habitat worth living in.

When I found that Raja Ampat had warmed by +0.52°C over 33 years, I didn't feel proud of the query. I felt worried about the manta rays.

When the 2024 bleaching data came in at 447,475 warning cells — a record, during a Neutral ENSO year, without El Niño amplification — I sat with that for a while before writing up the finding.

ATLAS started as a learning project. It became something I care about. I'm sharing it because the data is real, the findings matter, and the more people who can build on this kind of work, the better.

---

## The hardest lesson: shipping it

I started with just two datasets — sea surface temperature and chlorophyll concentration. That was enough to build a pipeline. But I kept finding more data I wanted to add. Species tracking. ENSO indices. Coral bleaching. More species. Better coverage. Cleaner joins. I wanted everything to be perfect before anyone saw it.

The problem with perfect is that it never arrives.

At some point I had to accept that ATLAS being out in the world — imperfect, incomplete, but real — was more valuable than ATLAS being perfect and invisible. A published platform that other analysts and engineers can learn from, adapt, and build on is worth more than a flawless one that only exists on my laptop.

So I stopped adding and started publishing.

That was its own kind of discipline. If you're building something similar, I'd say: pick a point where the core story is true and the data supports it, and ship it. You can always add more. You can't learn from something that nobody can see.

---

## Phase 1 — Setting up Databricks

**Goal:** Get a Databricks workspace running and connected to GitHub.

**What I did:**
- Created a Databricks workspace
- Set up GitHub repository integration
- Reviewed lakehouse architecture concepts (Bronze / Silver / Gold)
- Planned initial ingestion strategy

**What I learned:**
The Bronze / Silver / Gold model isn't just a naming convention — it's a discipline. Bronze is a contract with your future self: *don't touch the raw data*. Every transformation happens downstream, so you can always reprocess from source. This became important later when I had to rebuild tables from scratch after making mistakes in Silver.

**Outcome:** Platform foundation established. Repository structure aligned with how real data teams work.

---

## Phase 2 — Bronze Layer Ingestion

**Goal:** Ingest raw marine datasets into immutable Delta tables.

**Datasets selected:**
- Sea Surface Temperature (NOAA, monthly CSVs 1993–2026)
- Chlorophyll concentration (NOAA, monthly CSVs)
- Species tracking data (Movebank — manta ray, whale shark, sperm whale, green turtle)
- ENSO climate index (NOAA)
- Coral bleaching warning cells 

**What broke:**
Databricks restricted access to the public DBFS root. The original plan was to use AWS S3 as the storage layer — but the S3 bucket configuration didn't come together. Rather than get stuck, I took the practical route: downloaded all the source data to my local machine and uploaded it manually into Databricks. Not the production pattern, but it kept the pipeline moving.

The CSV upload UI in Databricks also has a 10-file limit. The SST and chlorophyll datasets each had 12 monthly files (one per month, per year). I had to handle them in batches.

**What I learned:**
- Always check your storage access before writing ingestion logic
- 10-file UI limits are real — plan for programmatic ingestion from S3
- Partition Bronze tables by year from the start — retrofitting partitions is painful

---

## Phase 3 — Silver Layer Transformation

**Goal:** Clean, standardise, and join environmental data into analytics-ready Silver tables.

**What I built:**
- `sea_surface_temperature_silver` — 12 months consolidated, spatial bounds added
- `chlorophyll_silver` — same structure
- `environmental_conditions_silver` — SST LEFT JOIN chlorophyll on lat/lon/year/month

**The mistake that cost me two hours:**

I used `CREATE OR REPLACE TABLE` to add each monthly batch of SST data. After adding January, I ran `CREATE OR REPLACE` for February — and wiped January. Then again for March — wiped January and February. By the time I validated with `COUNT(*) BY month`, I only had December.

The fix: `CREATE TABLE IF NOT EXISTS` once, then `INSERT INTO` for every subsequent batch. This is the correct pattern for incremental loads in production pipelines and I now use it automatically.

**What I learned:**
- `CREATE OR REPLACE TABLE` is destructive — never use it after initial creation
- Validate with `COUNT(*) BY month` after every batch, not just at the end
- Row count differences across months are normal in environmental data (spatial coverage varies)
- LEFT JOIN is the right choice when you want to preserve all observations from one side

**Key query I'm proud of:**
```sql
SELECT year, month, COUNT(*) AS row_count
FROM sea_surface_temperature_silver
GROUP BY year, month
ORDER BY year, month;
```
This single query caught every partial ingestion mistake before it propagated downstream.

---

## Phase 4 — Gold Layer & Analytics

**Goal:** Aggregate Silver data into Gold tables that answer analytical questions directly.

**What I built:**
- `environmental_monthly_summary` — SST and chlorophyll aggregated by year/month/spatial grid
- `species_sst_summary` — per-species temperature analytics
- `bleaching_timeline` — annual bleaching trend with ENSO context
- `raja_ampat_warming` — Raja Ampat SST trend 

**The spatial bucketing decision:**
Raw SST data has thousands of lat/lon coordinates. Querying it at full resolution is slow and noisy. I rounded latitude and longitude to 1 decimal place to create spatial grid cells. This reduced volume significantly, smoothed out measurement noise, and made the Gold tables fast enough for Tableau without pre-aggregation.

**The finding I didn't expect:**

When I ran the Raja Ampat trend query, I got +0.52°C warming over 33 years. That's the highest rate in the ATLAS dataset. Raja Ampat is the primary habitat of the Reef Manta Rays I was tracking. The animals showing the most temperature exposure are living in the fastest-warming patch of ocean I measured.


**What I learned:**
- Gold tables should answer questions, not just store data — design them around your analytical goals
- Spatial bucketing is a skill — too coarse and you lose signal, too fine and you lose performance
- Validation at Gold is just as important as Bronze — aggregation can hide missing data

---

## Phase 5 — Tableau: Desktop to Public

After building the Databricks pipeline, I exported the data to CSV and built the dashboards in Tableau. This phase had its own learning curve — Tableau Desktop (trial) behaves differently from Tableau Public (free), and that difference caused several hours of troubleshooting.

**The four dashboards:**
1. Ocean Warming Trends
2. Species Temperature Exposure
3. ENSO vs SST Analysis
4. Coral Bleaching Timeline

---

**Problem 1 — Tableau Desktop trial vs Tableau Public**

I started with Tableau Desktop deliberately — it has a native Databricks connector, which meant I could connect directly to my lakehouse data without exporting to CSV first. That was the right call for the pipeline I'd built. When the trial ended, I moved to Tableau Public, and discovered that several features I'd been relying on weren't available there. Tableau Public is a free hosted platform for sharing dashboards publicly, but it has real constraints that Desktop doesn't — including no Databricks connection and no multiple data sources. Understanding this difference earlier would have saved a lot of rework.

---

**Problem 2 — Red exclamation marks after republish**

After publishing to Tableau Public and reopening the workbook, all charts went blank with red exclamation marks on every field. The data source connection had been lost when moving between environments.

*Fix:* Reconnect the data source via the Data menu, point it back to the CSV file, and republish. Charts came back immediately.

---

**Problem 3 — "Dashboard Unavailable" — the Multiple Connections error**

This was the biggest blocker. Tableau Public does not support multiple data source connections in one workbook. I had the species tracking data as one source and the bleaching data as a second — and as soon as both were connected, every single dashboard showed "Dashboard Unavailable". Not just the bleaching one. All of them.

*Fix:* Move the join upstream. I merged the bleaching warning cells into the species tracking CSV using a Python LEFT JOIN on year (see `notebooks/04_atlas_combined_build.py`). One CSV, one connection, all dashboards restored. The lesson: Tableau Public's constraints have to shape your data architecture, not the other way around.

---

**Problem 4 — Bleaching Timeline showing wrong years and a broken Y axis**

After merging everything into one CSV, the Bleaching Timeline chart showed only 2008–2022 instead of 1993–2026. The Y axis displayed "2500M" — billions — instead of the actual warning cell counts.

The cause: the merged CSV only contained years where species were being tracked. When Tableau summed bleaching_warning_cells across 69,776 tracking rows, it multiplied the annual value by all the rows for that year — producing impossibly large numbers.

*Fix:* A completely separate workbook. The Bleaching Timeline now uses `ATLAS_Bleaching_Timeline_clean.csv` — 34 rows, one per year, 1993–2026. SUM on 34 rows gives exactly the right values. Two Tableau Public workbooks, both published separately.

---

**What I learned:**
- Tableau Desktop and Tableau Public are not the same product — know which one you're building for before you start
- Tableau Public allows only one data source connection per workbook — this has to shape how you prepare your data
- When a tool has a hard constraint, the fix is usually upstream in the data, not inside the tool
- Always check your aggregation logic — SUM behaves very differently on a 34-row table vs a 69,776-row table
- Two separate workbooks for two different data stories is cleaner than forcing everything into one

---

## Phase 6 — Animated Visualisations

**Goal:** Build a suite of browser-based animations that show animal movement and ocean conditions changing over time — making the data visible in a way static dashboards can't.

The inspiration came from a MarineTraffic visualisation of Arctic shipping routes — a grid of moving dots that made vessel density immediately legible. I wanted the same thing for ATLAS: not just charts of averages, but the actual animals moving through a warming ocean, month by month.

**What I built:**

Six self-contained HTML canvas animations, each built to answer a different question:

| Animation | Question it answers |
|---|---|
| Species tracking dots | Where are the animals, and when? |
| Movement trails | How do individuals move across months? |
| SST thermal landscape | What does the temperature field look like beneath the animals? |
| ENSO phase overlay | Does El Niño / La Niña change where animals go? |
| Habitat stress index | Which animals are under the most environmental pressure? |
| Green Turtle deep dive | What does full-resolution tracking density actually look like? |

**The data pipeline for animations:**

All six animations are driven by the same Databricks Gold layer queries used for the dashboards — the difference is output format. Instead of CSVs for Tableau, I wrote queries that export sampled tracking data with environmental columns (SST, MEI value, ENSO phase, habitat stress index) and converted them from Apple Numbers format into embedded JSON using a Python `numbers-parser` script.

The embedded JSON structure groups observations by species → year → month, so each animation frame is an O(1) lookup:
```python
tracks[species][year][month]  # → [[lat, lon, sst, ...], ...]
```

**The mistake documented in the queries (Mistake 6):**

The chlorophyll concentration bounding box for the Gulf of Mexico covered 17–22°N — which excluded the northern Gulf (22–32°N) where whale sharks actually live. This means the habitat stress index for Whale Shark is calculated without valid CC data for most of their range. Documented honestly in the animation notes and flagged for Phase 2 fix via a supplemental NOAA CC download.

**The unexpected finding:**

While building the ENSO animation, I discovered that in Raja Ampat, La Niña average SST (29.47°C) is *higher* than El Niño SST (28.80°C). ENSO theory predicts the opposite — La Niña should cool the Indo-Pacific. The finding suggests that long-term ocean warming has pushed the baseline temperature high enough that even La Niña's cooling signal can no longer bring SST below El Niño levels from a decade ago. The ENSO signal hasn't disappeared; the warming trend underneath it has grown large enough to obscure it.

**What I learned:**
- The Canvas API is powerful enough for production-quality data visualisation with no external libraries
- Bilinear interpolation at render time (for the heatmap) is computationally cheap enough to run in a `requestAnimationFrame` loop
- Sampling data (every 10th row) is the right call for animation performance — 10,000 points on a canvas renders fine; 55,000 does not
- The Green Turtle deep dive uses all 10,000 available observations at 1.8px dots — the density itself becomes the signal
- Data cutoffs are not a failure; they're a known state of the pipeline. Document them, plan the re-query, and ship what you have.

**Outcome:** Six animations, all published as shareable links and committed to `design/` in the repository. The Green Turtle deep dive is the most striking — 10,000 dots clustering around Chagos, colouring warmer as the months move into the Indian Ocean's summer.

---

## The Key Findings

These came from the data, not from what I expected to find.

| Finding | What the data showed |
|---|---|
| Raja Ampat warming | +0.52°C over 33 years — fastest in the dataset |
| 2024 bleaching anomaly | 447,475 warning cells during **Neutral ENSO** — previous records were all El Niño years |
| Green turtles in Chagos 2016 | 3 green turtles present during the 2016 bleaching event — confirmed by timestamp overlap |
| All species above 30°C | Every tracked species recorded SST above thermal stress threshold at least once |
| La Niña paradox in Raja Ampat | La Niña SST (29.47°C) exceeds El Niño SST (28.80°C) — long-term warming overriding ENSO signal |

The 2024 bleaching finding is the one that surprised me most. Every major bleaching event before it — 1998, 2010, 2016 — coincided with El Niño warming. 2024 broke the record in a Neutral ENSO year. The ocean was warm enough on its own.

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Databricks | Lakehouse platform — ingestion, transformation, analytics |
| Delta Lake | ACID-compliant storage, schema enforcement, versioning |
| SQL | Primary transformation and analytics language |
| Python (pandas, numbers-parser) | Dataset merging, Tableau prep, animation data export |
| Tableau Public | Interactive dashboards |
| Kepler.gl | Global tracking map (HTML) |
| Canvas API | Six animated species visualisations |
| GitHub | Version control and portfolio |

---

## What I'd do differently

1. **Plan the Tableau data source constraints first.** I built the pipeline assuming I could use multiple sources in Tableau Public. I couldn't. If I'd known that, I'd have built the merged CSV from the start.

2. **Use `INSERT INTO` from day one.** The `CREATE OR REPLACE` mistake in Silver cost me real time and made me doubt my row counts for a week.

3. **Validate after every step, not just at the end.** I added validation queries throughout the notebooks now, but early on I was trusting the pipeline too much.

4. **Add Kepler.gl earlier.** The global tracking map was the last thing I built and it ended up being visually the most compelling part of the project. It would have shaped how I thought about the data from the start.

5. **Check bounding boxes before building downstream visualisations.** The chlorophyll CC data for the Gulf of Mexico excluded the northern Gulf — where the whale sharks actually live. One `SELECT MIN(lat), MAX(lat)` before writing the habitat stress query would have caught it.

---

## What's next

**Immediate:**
- Databricks for Social Good application (free compute credits for conservation projects)
- Manta Trust outreach — sharing the Raja Ampat finding directly with researchers
- UKRI / NERC grant research (Spring 2027 target)

**Phase 2 — Data extension:**
- Re-query Movebank and OBIS-SEAMAP for post-2022 telemetry deployments and re-ingest through the Bronze → Gold pipeline to bring all four species up to present day
- Supplemental NOAA CC download for 22–32°N northern Gulf of Mexico to fix the Whale Shark chlorophyll bounding box (Mistake 6)
- Additional species beyond the current four
- Ocean plastic and pollution data — layering pollution density alongside animal movement to understand exposure risk
- Shipping traffic data — identifying overlap between vessel routes and species habitats, particularly for whale strike risk
- Near-real-time SST ingestion — moving from annual CSV exports to live satellite feeds

**Adding AI and machine learning:**
- Predictive modelling — using historical SST, ENSO, and bleaching patterns to forecast future thermal stress events
- Anomaly detection — flagging unusual animal behaviour or movement that may signal environmental disturbance
- Species distribution modelling — predicting where species are likely to be found under different climate scenarios
- Natural language interface — allowing researchers to query ATLAS findings in plain English rather than SQL

**Platform:**
- Connecting ATLAS to live Databricks compute via the Databricks for Social Good programme
- Feature store for ML workflows — making the environmental and tracking data reusable across models
- API layer — so external researchers can query ATLAS data without needing to access the lakehouse directly

---

## A bigger ambition

I'd like ATLAS to become a template for conservation data science.

The architecture — Bronze / Silver / Gold lakehouse, satellite tracking joined to environmental baselines, published dashboards and a global map — is species-agnostic. It could be adapted for bird migration, freshwater ecosystems, terrestrial habitat monitoring, river pollution tracking, or any domain where movement data needs to be read alongside climate and environmental signals.

The addition of shipping traffic and pollution data would take ATLAS from a climate monitoring platform to a full human-impact platform — not just asking *how warm is the ocean* but *what are we doing to the animals living in it*.

If you're a researcher, conservationist, or data engineer working in this space and you find this useful, I'd love to hear from you. The whole point of making it open is so it doesn't have to be rebuilt from scratch every time someone asks the same questions about a different set of animals.

---

*Built independently, outside of work hours, to demonstrate end-to-end data engineering for marine conservation.*

*Sharyn McPherson | Glasgow | [github.com/ShaMcP/marine-intelligence-platform](https://github.com/ShaMcP/marine-intelligence-platform)*
