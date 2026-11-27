# Data

Raw data is **not** committed (size and licensing). To reproduce:

1. Download the Kaggle dataset [LinkedIn Job Postings (2023–2024)](https://www.kaggle.com/datasets/arshkon/linkedin-job-postings) and unzip it.
2. Download BLS OEWS May 2024 state data (`oesm24st.zip` → `state_M2024_dl.xlsx`) from <https://www.bls.gov/oes/tables.htm> and save it as `oews_state_2024.csv`.
3. Upload to the Databricks Volume:
   - `/Volumes/portfolio/p1_jobs/raw/linkedin/` ← postings, companies, salaries, job_skills, skills, job_industries, industries, benefits (CSV)
   - `/Volumes/portfolio/p1_jobs/raw/bls/` ← oews_state_2024.csv
4. Run `sql/01_setup.sql`, `sql/02_create_tables.sql`, `sql/03_quality_checks.sql`.
