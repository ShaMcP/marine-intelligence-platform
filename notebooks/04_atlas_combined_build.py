"""
ATLAS Marine | Combined Dataset Build
Animal Tracking and Lifecycle Analysis System

Purpose:
    Build ATLAS_Combined.csv — the primary Tableau Public data source.
    Unions four species tracking CSVs, then LEFT JOINs bleaching warning
    cells on year so all 69,776 tracking rows carry bleaching context.

Why this script exists:
    Tableau Public does not support multiple data source connections in
    one workbook. Attempting to add bleaching data as a second connection
    caused a "Dashboard Unavailable" error across all dashboards.
    Solution: merge everything into one CSV before publishing to Tableau.

Output:
    ATLAS_Combined.csv — 69,776 rows, 13 columns, 0 nulls on key fields.

Author: Sharyn McPherson
        github.com/ShaMcP/marine-intelligence-platform
"""

import pandas as pd

# =============================================================================
# 1. LOAD SPECIES TRACKING CSVs
# =============================================================================

print("Loading species tracking data...")

manta      = pd.read_csv('data/manta_ray_tracking.csv')
whale_shark = pd.read_csv('data/whale_shark_tracking.csv')
sperm      = pd.read_csv('data/sperm_whale_tracking.csv')
turtle     = pd.read_csv('data/green_turtle_tracking.csv')

print(f"  Manta ray:    {len(manta):,} rows")
print(f"  Whale shark:  {len(whale_shark):,} rows")
print(f"  Sperm whale:  {len(sperm):,} rows")
print(f"  Green turtle: {len(turtle):,} rows")

# =============================================================================
# 2. UNION ALL FOUR SPECIES
# =============================================================================

print("\nUnioning species data...")

union = pd.concat([manta, whale_shark, sperm, turtle], ignore_index=True)

print(f"  Union total: {len(union):,} rows")
print(f"  Species present: {union['species'].unique().tolist()}")

# =============================================================================
# 3. LOAD BLEACHING DATA
# =============================================================================

print("\nLoading bleaching warning cells...")

bleaching = pd.read_csv('data/ATLAS_Bleaching_Timeline_clean.csv')

# Ensure year columns are the same type for the join
bleaching['year'] = bleaching['year'].astype(int)
union['year']     = union['year'].astype(int)

print(f"  Bleaching rows: {len(bleaching)} (1993–2026)")
print(f"  Year range: {bleaching['year'].min()} – {bleaching['year'].max()}")

# =============================================================================
# 4. LEFT JOIN bleaching onto union on year
# =============================================================================
# LEFT JOIN preserves ALL tracking rows.
# Every tracking record gets its year's bleaching_warning_cells value.
# Any tracking year not in the bleaching dataset would become NaN —
# but since bleaching covers 1993–2026 and tracking does too, result is 0 nulls.

print("\nJoining bleaching data onto species tracking...")

merged = union.merge(bleaching[['year', 'bleaching_warning_cells']],
                     on='year',
                     how='left')

print(f"  Merged rows:  {len(merged):,}")
print(f"  Columns:      {list(merged.columns)}")

# =============================================================================
# 5. VALIDATE
# =============================================================================

print("\nValidation checks:")

null_counts = merged.isnull().sum()
print(f"  Null values per column:\n{null_counts[null_counts > 0]}")

if null_counts['bleaching_warning_cells'] == 0:
    print("  ✓ Zero nulls on bleaching_warning_cells")
else:
    print(f"  ⚠ {null_counts['bleaching_warning_cells']} nulls on bleaching_warning_cells — check year coverage")

species_counts = merged.groupby('species').size()
print(f"\n  Records by species:\n{species_counts}")

sst_above_30 = merged.groupby('species').apply(
    lambda x: (x['sst_celsius'] > 30).any()
)
print(f"\n  Species with SST > 30°C:\n{sst_above_30}")

# Key finding check
manta_only = merged[merged['species'].str.lower().str.contains('manta')]
print(f"\n  Manta ray SST range: {manta_only['sst_celsius'].min():.2f}°C – {manta_only['sst_celsius'].max():.2f}°C")

# 2024 bleaching check
bleaching_2024 = merged[merged['year'] == 2024]['bleaching_warning_cells'].iloc[0]
print(f"  2024 bleaching warning cells: {bleaching_2024:,}")

# =============================================================================
# 6. EXPORT
# =============================================================================

output_path = 'data/ATLAS_Combined.csv'
merged.to_csv(output_path, index=False)

print(f"\n✓ ATLAS_Combined.csv written to {output_path}")
print(f"  {len(merged):,} rows × {len(merged.columns)} columns")

# =============================================================================
# NOTES ON TABLEAU PUBLISHING
# =============================================================================
# 1. Upload ATLAS_Combined.csv to Tableau Public Desktop
# 2. Use this as the single data source for the main ATLAS_Marine workbook
# 3. For the Bleaching Timeline dashboard, use ATLAS_Bleaching_Timeline_clean.csv
#    in a SEPARATE workbook (Book2 / ATLAS_Marine_Bleaching)
#    This avoids the "Multiple Connections" error on Tableau Public
# 4. Publish each workbook separately to Tableau Public
