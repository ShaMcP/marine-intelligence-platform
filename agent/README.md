# ATLAS — Animal Tracking & Lifecycle Analysis System

## Meet Ray

Ray is the first agent in the ATLAS marine intelligence platform. She is 33 years old — one year for every year of NOAA ocean temperature data she was trained on — and she calls the Chagos Archipelago home, one of the most pristine and protected marine environments on Earth.

Ray analyses ocean species data, climate patterns and environmental conditions across the world's oceans. Ask her anything about marine life and she will respond through four different lenses: journalist, researcher, conservationist, or general public.

---

## What ATLAS Does

ATLAS is an AI marine intelligence agent built on top of a Databricks Lakehouse data pipeline. It takes observational data on marine species — where they are, when, and at what ocean temperature — and makes that data conversational and accessible through a generative AI layer.

The current dataset covers 69,776 observations across four species and three ocean basins, cross-referenced against 33 years of NOAA sea surface temperature data and ENSO climate cycle classifications (El Niño, La Niña, Neutral).

---

## Species Covered

| Species | Observations | Location |
|---|---|---|
| Green Turtle | 55,247 | Chagos Archipelago, Gulf of Aden |
| Sperm Whale | 7,759 | North Atlantic |
| Whale Shark | 3,330 | Ningaloo Reef |
| Reef Manta Ray | 1,451 | Raja Ampat |

---

## Architecture

```
Raw Data (OBIS / NOAA / research datasets)
        ↓
Bronze Layer — Databricks (raw ingestion, no transformation)
        ↓
Silver Layer — Databricks (cleaned, standardised, joined with SST data)
        ↓
Gold Layer — Databricks (aggregated by species / location / ENSO phase)
        ↓
ATLAS_DATA summary — curated text fed to Ray as context
        ↓
Ray (Claude Haiku via Anthropic API) — four personas, conversational responses
        ↓
Flask API — /api/ask and /api/health endpoints
        ↓
atlas-ui.html — deep ocean UI, served directly by Flask
        ↓
Render.com — cloud hosting, auto-deploys on every GitHub push
```

---

## The Four Personas

Ray adapts her communication style based on who she is talking to:

- **Journalist** — leads with the most significant finding, authoritative and accessible
- **Researcher** — precise, references sample sizes, acknowledges data limitations  
- **Conservationist** — grounds findings in conservation implications, closes with action
- **Public** — clear and simple language, weaves in ocean fun facts

---

## Tech Stack

| Component | Technology |
|---|---|
| Data pipeline | Databricks Lakehouse (Bronze → Silver → Gold) |
| AI model | Claude Haiku (Anthropic API) |
| Backend | Python, Flask, Flask-CORS |
| Production server | Gunicorn |
| Frontend | Vanilla HTML, CSS, JavaScript |
| Hosting | Render.com |
| Version control | GitHub |

---

## Running Locally

```bash
cd agent
pip install -r requirements.txt
export ANTHROPIC_API_KEY=your_key_here
python atlas_server.py
```

Then open `http://localhost:5050` in your browser.

---

## Deployment

ATLAS is hosted on Render. Any push to the `agent/` folder in this repository triggers an automatic redeploy. The Anthropic API key is stored as a secret environment variable on Render — it is never exposed in the code or the browser.

**Live:** https://marine-intelligence-platform.onrender.com

---

## Roadmap

- [ ] Global Fishing Watch vessel density layer
- [ ] NASA Ocean Color chlorophyll-a data
- [ ] Marine heatwave event tracking
- [ ] Coral bleaching events
- [ ] Ocean acidification data
- [ ] Shipping lane density
- [ ] Live connection to Databricks Gold layer (replacing curated summary)
- [ ] Kelpie — Scottish & coastal waters agent (Firth of Clyde)
- [ ] Finn — fishing pressure & vessel tracking agent
- [ ] Coral — reef health & bleaching agent
- [ ] Drift — ocean currents & plastic pollution agent
- [ ] Luma — deep ocean & acoustics agent

---

## About

ATLAS is an independent portfolio project exploring the intersection of data engineering, marine conservation and generative AI. Built by Sharyn McPherson, Data Engineer, Glasgow.

*Ray's home coordinates: 6.0°S, 71.5°E — Chagos Archipelago, Indian Ocean.*
