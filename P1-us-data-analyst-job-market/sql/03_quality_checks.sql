-- P1: data-quality checks (results documented in docs/data_quality_notes.md)

-- 1. Inventory: row count per table
SELECT 'postings' AS tbl, COUNT(*) AS rows_ FROM portfolio.p1_jobs.postings
UNION ALL SELECT 'companies',      COUNT(*) FROM portfolio.p1_jobs.companies
UNION ALL SELECT 'salaries',       COUNT(*) FROM portfolio.p1_jobs.salaries
UNION ALL SELECT 'job_skills',     COUNT(*) FROM portfolio.p1_jobs.job_skills
UNION ALL SELECT 'skills',         COUNT(*) FROM portfolio.p1_jobs.skills
UNION ALL SELECT 'job_industries', COUNT(*) FROM portfolio.p1_jobs.job_industries
UNION ALL SELECT 'industries',     COUNT(*) FROM portfolio.p1_jobs.industries
UNION ALL SELECT 'benefits',       COUNT(*) FROM portfolio.p1_jobs.benefits
UNION ALL SELECT 'bls_oews_state', COUNT(*) FROM portfolio.p1_jobs.bls_oews_state;

-- 2. postings: key uniqueness, nulls, salary coverage
SELECT COUNT(*) AS rows_, COUNT(DISTINCT job_id) AS distinct_jobs,
       count_if(job_id IS NULL) AS null_job_id, count_if(title IS NULL) AS null_title,
       count_if(company_id IS NULL) AS null_company,
       count_if(pay_period IS NULL) AS no_salary,
       count_if(currency IS NOT NULL AND currency <> 'USD') AS non_usd,
       count_if(remote_allowed IS NULL) AS remote_null,
       count_if(listed_time IS NULL) AS null_listed
FROM portfolio.p1_jobs.postings;

-- 3. postings: pay_period x currency
SELECT pay_period, currency, COUNT(*) AS n
FROM portfolio.p1_jobs.postings GROUP BY ALL ORDER BY n DESC;

-- 4. companies: key uniqueness
SELECT COUNT(*) AS rows_, COUNT(DISTINCT company_id) AS distinct_ids,
       count_if(company_id IS NULL) AS null_id, count_if(name IS NULL) AS null_name
FROM portfolio.p1_jobs.companies;

-- 5. salaries
SELECT COUNT(*) AS rows_, COUNT(DISTINCT job_id) AS distinct_jobs,
       count_if(pay_period IS NULL) AS null_pay_period
FROM portfolio.p1_jobs.salaries;

-- 6. job_skills bridge: null keys + orphans
SELECT COUNT(*) AS rows_,
       count_if(js.job_id IS NULL OR js.skill_abr IS NULL) AS null_keys,
       count_if(s.skill_abr IS NULL) AS orphan_skill,
       count_if(p.job_id IS NULL)    AS orphan_job
FROM portfolio.p1_jobs.job_skills js
LEFT JOIN portfolio.p1_jobs.skills   s ON js.skill_abr = s.skill_abr
LEFT JOIN portfolio.p1_jobs.postings p ON try_cast(js.job_id AS BIGINT) = p.job_id;

-- 7. job_industries bridge: orphans
SELECT COUNT(*) AS rows_,
       count_if(i.industry_id IS NULL) AS orphan_industry,
       count_if(p.job_id IS NULL)      AS orphan_job
FROM portfolio.p1_jobs.job_industries ji
LEFT JOIN portfolio.p1_jobs.industries i ON ji.industry_id = i.industry_id
LEFT JOIN portfolio.p1_jobs.postings   p ON try_cast(ji.job_id AS BIGINT) = p.job_id;

-- 8. dimensions: key uniqueness
SELECT 'skills' AS tbl, COUNT(*) AS rows_, COUNT(DISTINCT skill_abr) AS distinct_keys FROM portfolio.p1_jobs.skills
UNION ALL
SELECT 'industries', COUNT(*), COUNT(DISTINCT industry_id) FROM portfolio.p1_jobs.industries;

-- 9. benefits
SELECT COUNT(*) AS rows_, count_if(type IS NULL) AS null_type FROM portfolio.p1_jobs.benefits;

-- 10. BLS coverage per SOC code
SELECT soc_code, COUNT(*) AS areas,
       MIN(a_median) AS min_median, MAX(a_median) AS max_median,
       count_if(a_median IS NULL) AS no_median, count_if(a_median_topcoded) AS topcoded
FROM portfolio.p1_jobs.bls_oews_state GROUP BY soc_code ORDER BY soc_code;
