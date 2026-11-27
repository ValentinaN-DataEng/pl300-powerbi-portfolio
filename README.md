# PL-300 Power BI Portfolio

Four end-to-end Power BI projects built on **Databricks (Delta) → Power BI semantic model → Power BI Service app**, created while preparing for the Microsoft **PL-300 (Power BI Data Analyst)** certification.

| # | Project | Storage mode | Status |
|---|---|---|---|
| P1 | [US Data Analyst Job Market & Salary Benchmark](P1-us-data-analyst-job-market/) | Import | In progress |
| P2 | US Power Grid Demand & Generation Mix | Import + incremental refresh | Planned |
| P3 | Federal Construction Contracts: Cost Growth & Schedule Control | Import + gateway | Planned |
| P4 | Medicare Part D Prescribing & Drug Cost Analysis | Composite (DirectQuery + Dual + aggregations) | Planned |

**Stack:** Databricks Free Edition (Unity Catalog, Volumes, Delta, SQL Warehouse) · Power BI Desktop (.pbip / TMDL) · Power Query (M) · DAX · Power BI Service

Each project folder contains the SQL used in Databricks, the Power BI project files, and docs (data-quality notes, model diagram, screenshots).
