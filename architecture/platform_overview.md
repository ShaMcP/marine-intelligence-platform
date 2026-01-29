# Platform Overview

The Marine Intelligence Platform is a cloud-based data platform designed to
collect, process, and analyse marine environmental and animal movement data
to support climate research, conservation insights, and advanced analytics.

The platform follows a modern lakehouse architecture using Bronze, Silver,
and Gold data layers to ensure scalability, data quality, and analytical
flexibility.

---

## Objectives

The primary objectives of the platform are to:

- Ingest raw marine datasets from multiple public and research sources
- Clean, standardise, and enrich environmental and biological data
- Combine environmental conditions with animal movement patterns
- Enable analytical queries, dashboards, and AI-driven insights
- Provide a reproducible and extensible foundation for future research

---

## High-Level Architecture

The platform is built using a layered data architecture:

### Bronze Layer
- Stores raw, immutable data exactly as received from source systems
- Includes environmental data (e.g. phytoplankton, temperature, chlorophyll)
- Includes animal movement data (e.g. whale and shark tracking)
- Designed for traceability and reprocessing

### Silver Layer
- Contains cleaned, validated, and standardised datasets
- Applies schema enforcement, deduplication, and data quality rules
- Aligns timestamps, geospatial references, and measurement units
- Prepares datasets for analytical joins

### Gold Layer
- Hosts curated fact tables and dimension tables
- Combines environmental and biological data into analytics-ready models
- Optimised for dashboards, reporting, and machine learning workloads
- Acts as the primary source of truth for insights

---

## Technology Stack

The initial technology stack includes:

- **Databricks** for data ingestion, transformation, and lakehouse management
- **Delta Lake** for reliable storage and versioned datasets
- **SQL** as the primary transformation and analytics language
- **GitHub** for version control and documentation
- **BI tools** (e.g. Tableau) for visualisation and exploration

The architecture is designed to be cloud-agnostic and extensible, allowing
future integration with AI models, geospatial tooling, and additional data
sources.

---

## Future Enhancements

Planned future enhancements include:

- AI models to identify patterns between environmental change and animal behaviour
- Feature tables for machine learning workflows
- Real-time or near-real-time ingestion of sensor data
- Expanded geospatial analytics and mapping capabilities
