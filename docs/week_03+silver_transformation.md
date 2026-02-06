# Week 3: Silver Layer Transformation & Environmental Integration

## 1. Objective

The objective of Week 3 was to transform raw environmental data ingested in the Bronze layer into clean, standardised, and analysis-ready **Silver tables** using Databricks and SQL.

This week focused on:
- Consolidating monthly raw datasets
- Standardising schemas and column names
- Adding temporal and spatial metadata
- Joining multiple environmental variables into a unified table

---

## 2. Source Data

The datasets used in this phase were sourced from NOAA and included:
- **Sea Surface Temperature (SST)** — monthly data (Jan–Dec 2025)
- **Chlorophyll Concentration (CC)** — monthly data (Jan–Dec 2025)

Each variable initially existed as **12 separate CSV files**, one per month.

---

## 3. Silver Layer Design

The Silver layer was designed to:
- Remove fragmentation caused by monthly files
- Apply consistent data types and naming conventions
- Add metadata required for time-series and spatial analysis

Two primary Silver tables were created:
- `sea_surface_temperature_silver`
- `chlorophyll_silver`

Each Silver table includes:
- `latitude`
- `longitude`
- measurement value (SST or chlorophyll)
- `year`
- `month`
- `temporal_resolution`
- spatial bounds (lat/lon upper and lower)
- `processed_timestamp`

---

## 4. Transformation Approach

For each variable:
1. January data was used to **CREATE** the Silver table
2. February–December data was **INSERTED** into the same table
3. All transformations were written in SQL
4. Validation was performed using month-level row counts

This approach mirrors production data pipelines where data arrives incrementally.

---

## 5. Unified Environmental Table

After both Silver tables were validated, they were joined to create a unified dataset:

- **Table:** `environmental_conditions_silver`
- **Join type:** LEFT JOIN
- **Join keys:** latitude, longitude, year, month

This ensures all SST observations are retained even if chlorophyll data is missing for some locations or months.

---

## 6. Challenges & Resolutions

### Public DBFS Root Disabled
- Issue: Databricks restricted access to the public DBFS root
- Resolution: Data ingestion was moved to AWS S3 and accessed from Databricks

### CSV Upload Limits
- Issue: UI limited uploads to 10 files
- Resolution: Monthly files were handled individually and consolidated in Silver

### Partial Silver Ingestion
- Issue: SST Silver table initially contained only one month
- Cause: `CREATE OR REPLACE TABLE` was re-run after inserts
- Resolution: Table was rebuilt and validated using `COUNT(*) BY month`

---

## 7. Key Learnings

- Validation queries are critical at every stage
- `CREATE OR REPLACE` should be avoided after initial table creation
- Row count differences across months are normal in environmental data
- Separating ingestion, transformation, and joins improves reliability

---

## 8. Outcome

By the end of Week 3:
- Raw environmental data was fully standardised
- Monthly datasets were consolidated
- A unified, analysis-ready environmental Silver table was created
- The pipeline reflected real-world data engineering patterns
