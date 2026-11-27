-- P1: create Delta tables from CSV files in the Volume with read_files
-- Long text columns (description, skills_desc, URLs) are excluded on purpose: not analyzed, and they bloat the Import model.

-- POSTINGS (multiline quoted text -> multiLine + escape; FAILFAST surfaces parsing errors)
CREATE OR REPLACE TABLE portfolio.p1_jobs.postings AS
SELECT
  try_cast(try_cast(job_id     AS DOUBLE) AS BIGINT) AS job_id,
  try_cast(try_cast(company_id AS DOUBLE) AS BIGINT) AS company_id,
  company_name, title, location,
  CAST(zip_code AS STRING) AS zip_code, CAST(fips AS STRING) AS fips,
  try_cast(min_salary AS DOUBLE) AS min_salary,
  try_cast(med_salary AS DOUBLE) AS med_salary,
  try_cast(max_salary AS DOUBLE) AS max_salary,
  pay_period, currency, compensation_type,
  try_cast(normalized_salary AS DOUBLE) AS normalized_salary,
  formatted_work_type, formatted_experience_level,
  try_cast(try_cast(remote_allowed AS DOUBLE) AS INT) AS remote_allowed,
  try_cast(try_cast(views   AS DOUBLE) AS INT) AS views,
  try_cast(try_cast(applies AS DOUBLE) AS INT) AS applies,
  application_type, sponsored,
  try_cast(try_cast(listed_time AS DOUBLE) AS BIGINT) AS listed_time  -- epoch ms
FROM read_files('/Volumes/portfolio/p1_jobs/raw/linkedin/postings.csv',
  format => 'csv', header => true, multiLine => true, escape => '"', mode => 'FAILFAST');

-- COMPANIES
CREATE OR REPLACE TABLE portfolio.p1_jobs.companies AS
SELECT try_cast(try_cast(company_id AS DOUBLE) AS BIGINT) AS company_id,
       name, company_size, state, country, city
FROM read_files('/Volumes/portfolio/p1_jobs/raw/linkedin/companies.csv',
  format => 'csv', header => true, multiLine => true, escape => '"', mode => 'FAILFAST');

-- SMALL TABLES (schema inference is enough)
CREATE OR REPLACE TABLE portfolio.p1_jobs.salaries AS
SELECT * FROM read_files('/Volumes/portfolio/p1_jobs/raw/linkedin/salaries.csv', format => 'csv', header => true);

CREATE OR REPLACE TABLE portfolio.p1_jobs.job_skills AS
SELECT * FROM read_files('/Volumes/portfolio/p1_jobs/raw/linkedin/job_skills.csv', format => 'csv', header => true);

CREATE OR REPLACE TABLE portfolio.p1_jobs.skills AS
SELECT * FROM read_files('/Volumes/portfolio/p1_jobs/raw/linkedin/skills.csv', format => 'csv', header => true);

CREATE OR REPLACE TABLE portfolio.p1_jobs.job_industries AS
SELECT * FROM read_files('/Volumes/portfolio/p1_jobs/raw/linkedin/job_industries.csv', format => 'csv', header => true);

CREATE OR REPLACE TABLE portfolio.p1_jobs.industries AS
SELECT * FROM read_files('/Volumes/portfolio/p1_jobs/raw/linkedin/industries.csv', format => 'csv', header => true);

CREATE OR REPLACE TABLE portfolio.p1_jobs.benefits AS
SELECT * FROM read_files('/Volumes/portfolio/p1_jobs/raw/linkedin/benefits.csv', format => 'csv', header => true);

-- BLS OEWS May 2024, state level (CSV saved from Excel with ';' delimiter)
-- '*' = estimate not released, '#' = top-coded wage -> both become NULL; flag keeps top-coded rows visible.
-- regexp_replace keeps digits only, so '108,020', '108.020' and '108020' all parse correctly (annual wages are whole dollars).
CREATE OR REPLACE TABLE portfolio.p1_jobs.bls_oews_state AS
SELECT
  PRIM_STATE AS state_code, AREA_TITLE AS state_name,
  OCC_CODE   AS soc_code,   OCC_TITLE  AS soc_title,
  try_cast(regexp_replace(TOT_EMP,  '[^0-9]', '') AS INT)    AS tot_emp,
  try_cast(regexp_replace(A_MEAN,   '[^0-9]', '') AS DOUBLE) AS a_mean,
  try_cast(regexp_replace(A_MEDIAN, '[^0-9]', '') AS DOUBLE) AS a_median,
  trim(A_MEDIAN) = '#' AS a_median_topcoded
FROM read_files('/Volumes/portfolio/p1_jobs/raw/bls/oews_state_2024.csv',
  format => 'csv', sep => ';', header => true, inferColumnTypes => false)
WHERE OCC_CODE IN ('15-2051','15-2041','15-2031','13-1161','15-1211','15-1243');
