# P1: US Data Analyst Job Market & Salary Benchmark

> **Business question:** Which skills, industries, states and work modes pay the most for data roles in the US?
> _Impact line: to be added when the analysis is complete._

## Architecture
Kaggle CSVs + BLS OEWS → Databricks Volume → Delta tables (`portfolio.p1_jobs`) → Power BI semantic model (Import) → Power BI Service app

## Data sources
- [LinkedIn Job Postings (2023–2024)](https://www.kaggle.com/datasets/arshkon/linkedin-job-postings), Kaggle (arshkon). Public dataset; raw files are not stored in this repo.
- [BLS OEWS May 2024 State Estimates](https://www.bls.gov/oes/tables.htm), U.S. Bureau of Labor Statistics. Public domain.
  BLS has no "Data Analyst" SOC code; SOC 15-2051 (Data Scientists, which includes BI Analysts in O*NET) is used as the main benchmark proxy.

## Repo contents
| Folder | Content |
|---|---|
| `sql/` | `01_setup.sql` (catalog/schema/volume), `02_create_tables.sql` (Delta tables via `read_files`), `03_quality_checks.sql` |
| `pbip/` | Power BI project (`P1_JobMarket.pbip`, TMDL semantic model, report) |
| `docs/` | Data-quality notes, model diagram, screenshots |
| `data/` | Source links only |

## Progress
- [x] Day 0: Databricks setup, Delta tables, quality checks
- [ ] Day 1: Load and profile (Import, title filter)
- [ ] Day 2: Transform (salary normalization, unpivot, merge with BLS)
- [ ] Day 3: Star schema with M:M bridges
- [ ] Day 4: Date table and time intelligence
- [ ] Day 5: Visuals and interactivity
- [ ] Day 6: Publish, RLS, app
