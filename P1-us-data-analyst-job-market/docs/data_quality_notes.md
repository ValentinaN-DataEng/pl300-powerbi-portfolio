# P1 Data Quality Notes

Source: `sql/03_quality_checks.sql`, run on Databricks Free Edition (Serverless Starter Warehouse), 2026-11-26.

## 1. Table inventory and keys

| Table | Rows | Key | Key unique? | Nulls / issues | Decision |
|---|---|---|---|---|---|
| `postings` | 123,849 | `job_id` | ✓ (123,849 distinct, 0 null) | `company_id` null: 1,717 (1.4%) | Valid fact key. Postings without company → "Unknown" company member in Day 3. |
| `companies` | 24,473 | `company_id` | ✓ (0 null) | `state` = company HQ, not posting location | Use as `Dim_Company`; don't use HQ state for geography. |
| `salaries` | 40,785 | `job_id` | ✓ | 0 null `pay_period` | Staging only (see §3: count differs from postings). |
| `job_skills` | 213,768 | (`job_id`, `skill_abr`) | – | 0 null keys, 0 orphan skills, **7,990 orphan jobs (3.7%)** | Inner merge with `Fact_Postings` on Day 3. |
| `skills` | 35 | `skill_abr` | ✓ | – | `Dim_Skill`. Only 35 broad skill categories (not tools like SQL/Python). |
| `job_industries` | 164,808 | (`job_id`, `industry_id`) | – | 0 orphan industries, **5,845 orphan jobs (3.5%)** | Inner merge with `Fact_Postings` on Day 3. |
| `industries` | 422 | `industry_id` | ✓ | – | `Dim_Industry`. |
| `benefits` | 67,943 | (`job_id`, `type`) | – | 0 null `type` | Optional (tooltips). |
| `bls_oews_state` | 308 | (`state_code`, `soc_code`) | – | 4 null medians (see §5) | Benchmark table. |

## 2. Salary coverage (postings)

| Metric | Value | Decision |
|---|---|---|
| Postings with no salary (`pay_period` null) | 87,776 (70.9%) | Keep rows: they still count for **Postings**. Salary measures use only rows with salary. |
| Postings with salary | 36,073 (29.1%) | Base for `AnnualSalary`. |
| Non-USD salaries | 15 (EUR 6, CAD 3, BBD 2, AUD 2, GBP 2) | Day 2: set salary to null for non-USD rows; keep the posting. |

**`pay_period` × currency (USD only):** YEARLY 20,616 · HOURLY 14,738 · MONTHLY 518 · WEEKLY 177 · **BIWEEKLY 9**

→ Day 2 `AnnualSalary` needs all five multipliers: HOURLY × 2080, WEEKLY × 52, **BIWEEKLY × 26**, MONTHLY × 12, YEARLY × 1. Validate against `normalized_salary`.

## 3. Open discrepancy: `salaries` vs `postings`

`salaries` has 40,785 job_ids, but only 36,073 postings have a `pay_period`. That's 4,712 more in `salaries`.
To check on Day 2: are these job_ids missing from `postings`, or present with null salary columns? Until resolved, `Fact_Postings` stays the single source of truth for salary.

## 4. Other columns

| Column | Finding | Decision |
|---|---|---|
| `remote_allowed` | 1 = 15,246 (12.3%); NULL = 108,603; no 0 values | Day 2: replace null with 0 so `Remote %` has a correct denominator. |
| `listed_time` | 0 nulls; epoch milliseconds | Day 2: convert to datetime (UTC). |
| `location` | Top value is "United States" (8,125 = 6.6%, no state); otherwise mostly "City, ST" (New York, NY 2,756; Chicago, IL 1,834; Houston, TX 1,762…) | Day 2: parse `StateCode` from the text after the last comma; "United States" → state unknown (excluded from state maps, BLS merge and the TX RLS role). |

## 5. BLS OEWS May 2024 (state level)

| SOC | Title | Areas | Median min | Median max | Null medians | Top-coded |
|---|---|---|---|---|---|---|
| 13-1161 | Market Research Analysts | 54 | $38,410 | $98,650 | 0 | 0 |
| 15-1211 | Computer Systems Analysts | 53 | $56,650 | $127,660 | 0 | 0 |
| 15-1243 | Database Architects | 51 | $62,760 | $161,160 | 3 | 0 |
| 15-2031 | Operations Research Analysts | 50 | $55,640 | $123,050 | 0 | 0 |
| 15-2041 | Statisticians | 48 | $48,210 | $150,240 | 0 | 0 |
| 15-2051 | Data Scientists (main benchmark) | 52 | $69,430 | $158,760 | 1 | 0 |

The values are in a plausible range, so the `;` delimiter and the number parsing worked. A few states have no published median for some SOC codes, so those states show a blank benchmark rather than 0.

## 6. Actions carried into Power BI

- [ ] Day 1: title filter → `RoleFamily` (whole-word matching); profile in Power Query to confirm the numbers above.
- [ ] Day 2: `AnnualSalary` with BIWEEKLY; null out non-USD salaries; `remote_allowed` null → 0; `StateCode` from `location`; resolve the §3 discrepancy.
- [ ] Day 3: inner merge bridges with `Fact_Postings` (removes 7,990 + 5,845 orphan rows); "Unknown" company for 1,717 postings.
