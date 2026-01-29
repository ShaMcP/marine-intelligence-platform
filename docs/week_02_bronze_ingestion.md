# Week 2 – Bronze Layer Ingestion

This week focuses on defining and implementing the initial Bronze layer
for the Marine Intelligence Platform.

The Bronze layer is responsible for storing raw, immutable data exactly
as received from source systems.

---

## Objectives

- Identify the first datasets to ingest
- Define Bronze layer storage patterns
- Understand schema and data characteristics
- Prepare for downstream Silver transformations

---

## Selected Initial Datasets

### Environmental Data
- Sea surface temperature
- Chlorophyll concentration
- Phytoplankton indicators

**Reason for selection:**
These datasets form the environmental baseline required to understand
marine ecosystem conditions and climate signals.

---

## Ingestion Approach

- Data will be ingested in raw format
- No transformations beyond basic metadata
- Data stored as Delta tables in Databricks
- Partitioning considered on ingestion date or region where applicable

---

## Expected Output

- Bronze Delta tables containing raw environmental data
- Clear traceability to source datasets
- Reproducible ingestion logic
