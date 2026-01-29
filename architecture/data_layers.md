# Data Layers

The Marine Intelligence Platform follows a Bronze, Silver, and Gold data
architecture to ensure data quality, scalability, and analytical flexibility.

---

## Bronze Layer

- Raw data ingested directly from source systems
- No transformations applied beyond basic metadata
- Stored in immutable Delta tables

**Key goal:** Preserve original data for traceability and reprocessing.

---

## Silver Layer

- Cleaned and standardised datasets
- Schema enforcement and data validation
- Timestamp and geospatial alignment
- Prepared for cross-domain joins

**Key goal:** Create reliable, analytics-ready datasets.

---

## Gold Layer

- Curated fact and dimension tables
- Integrated environmental and animal movement data
- Optimised for BI tools and AI workloads

**Key goal:** Provide a trusted source of insight and decision-making.
