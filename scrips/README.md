# Scripts

Python scripts used to build the ATLAS Marine data exports.

---

## Files

| File | Description |
|---|---|
| `build_combined.py` | Builds ATLAS_Combined.csv — unions four species tracking CSVs and LEFT JOINs bleaching data on year |

---

## build_combined.py

**Why it exists:** Tableau Public does not support multiple data source connections
in one workbook. Merging everything into one CSV before publishing avoids the
"Dashboard Unavailable" error that appears when a second connection is added.

**What it does:**
1. Loads four species tracking CSVs into pandas DataFrames
2. Unions all four species with `pd.concat`
3. LEFT JOINs bleaching warning cells onto the union on `year`
4. Validates the result — null checks, species counts, SST > 30°C check
5. Exports `data/ATLAS_Combined.csv` — 69,776 rows, primary Tableau source

**Run from the repo root:**
```
pip install pandas
python scripts/build_combined.py
```
