# Week 4: Gold Layer Aggregation & Analytics

## 1. Objective

The objective of Week 4 was to transform Silver-layer environmental data into **Gold-layer datasets** that are:
- Aggregated
- Insight-driven
- Optimised for analytics and reporting

The Gold layer represents the final stage of the Lakehouse pipeline.

---

## 2. Why a Gold Layer?

While Silver tables are clean and complete, they:
- Are large in volume
- Contain granular spatial data
- Are not optimised for analysis

The Gold layer:
- Reduces data volume
- Smooths noise through aggregation
- Answers analytical questions directly

---

## 3. Gold Table Design

### Table: `environmental_monthly_summary`

This table aggregates environmental conditions by:
- Year
- Month
- Spatial grid (rounded latitude and longitude)

Metrics produced:
- Average sea surface temperature
- Average chlorophyll concentration
- Number of observations per grid cell

---

## 4. Aggregation Strategy

Spatial bucketing was applied using rounded latitude and longitude values to:
- Reduce spatial noise
- Enable regional trend analysis
- Improve query performance

Monthly aggregation allows:
- Seasonal pattern detection
- Time-series analysis
- Future joins with animal tracking data

---

## 5. Validation & Quality Checks

Validation steps included:
- Ensuring all months were present
- Comparing Gold row counts to Silver inputs
- Checking for null or missing aggregations

These checks ensure analytical reliability.

---

## 6. Example Analytical Use Cases

The Gold layer enables:
- Monthly global temperature trends
- Seasonal chlorophyll variation analysis
- Regional environmental comparisons
- Downstream joins with movement or behavioural datasets

---

## 7. Key Learnings

- Aggregation design should align with analytical goals
- Gold tables should be stable and reproducible
- Clear separation between Silver and Gold improves maintainability
- Validation remains critical even after aggregation

---

## 8. Outcome

By the end of Week 4:
- Environmental data was fully analytics-ready
- Data volume was significantly reduced
- The Lakehouse pipeline was completed end-to-end
- The project transitioned from ingestion to insight
