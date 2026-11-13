-- NYC Payroll Overtime Analysis
-- Engine: Amazon Athena (Presto/Trino SQL)
-- Source: NYC Open Data, Citywide Payroll Data (Fiscal Year), FY2023-FY2026
-- Raw CSV stored in S3: s3://amara-nyc-payroll-project/payroll/

-- ---------------------------------------------------------------
-- 1. Set up: database and external table over the raw CSV in S3
-- ---------------------------------------------------------------
CREATE DATABASE nyc_payroll;

CREATE EXTERNAL TABLE nyc_payroll.payroll_raw (
  fiscal_year                string,
  payroll_number             string,
  agency_name                string,
  last_name                  string,
  first_name                 string,
  mid_init                   string,
  agency_start_date          string,
  work_location_borough      string,
  title_description          string,
  leave_status_as_of_june_30 string,
  base_salary                string,
  pay_basis                  string,
  regular_hours              string,
  regular_gross_paid         string,
  ot_hours                   string,
  total_ot_paid              string,
  total_other_pay            string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES ('separatorChar' = ',', 'quoteChar' = '"')
LOCATION 's3://amara-nyc-payroll-project/payroll/'
TBLPROPERTIES ('skip.header.line.count' = '1');

-- ---------------------------------------------------------------
-- 2. Data checks: confirm columns line up and row counts per year
--    (2,227,635 rows across FY2023-FY2026)
-- ---------------------------------------------------------------
SELECT * FROM nyc_payroll.payroll_raw LIMIT 10;

SELECT fiscal_year, COUNT(*) AS employees
FROM nyc_payroll.payroll_raw
GROUP BY fiscal_year
ORDER BY fiscal_year;

-- ---------------------------------------------------------------
-- 3. Clean view: cast numbers, trim text, drop employee names
-- ---------------------------------------------------------------
CREATE VIEW nyc_payroll.payroll AS
SELECT
  TRY_CAST(fiscal_year AS integer)          AS fiscal_year,
  TRIM(agency_name)                         AS agency,
  work_location_borough                     AS borough,
  title_description                         AS title,
  pay_basis,
  TRY_CAST(base_salary AS double)           AS base_salary,
  TRY_CAST(regular_hours AS double)         AS regular_hours,
  TRY_CAST(regular_gross_paid AS double)    AS regular_pay,
  TRY_CAST(ot_hours AS double)              AS ot_hours,
  TRY_CAST(total_ot_paid AS double)         AS ot_pay,
  TRY_CAST(total_other_pay AS double)       AS other_pay
FROM nyc_payroll.payroll_raw;

-- ---------------------------------------------------------------
-- 4. Top 10 agencies by overtime cost (FY2025)
--    Output: results/ot_by_agency.csv
-- ---------------------------------------------------------------
SELECT agency,
       ROUND(SUM(ot_pay) / 1e6, 1)                    AS ot_millions,
       ROUND(SUM(ot_pay) / SUM(regular_pay) * 100, 1) AS ot_pct_of_regular
FROM nyc_payroll.payroll
WHERE fiscal_year = 2025
GROUP BY agency
ORDER BY ot_millions DESC
LIMIT 10;

-- ---------------------------------------------------------------
-- 5. Is overtime growing? Citywide trend by fiscal year
--    Output: results/ot_trend.csv
-- ---------------------------------------------------------------
SELECT fiscal_year,
       ROUND(SUM(ot_pay) / 1e6, 1)                    AS ot_millions,
       ROUND(SUM(ot_pay) / SUM(regular_pay) * 100, 1) AS ot_pct_of_regular
FROM nyc_payroll.payroll
GROUP BY fiscal_year
ORDER BY fiscal_year;

-- ---------------------------------------------------------------
-- 6. Which job titles drive overtime at the top 3 agencies? (FY2025)
--    Output: results/ot_by_title.csv
-- ---------------------------------------------------------------
SELECT agency, title,
       COUNT(*)                    AS employees,
       ROUND(AVG(ot_hours), 0)     AS avg_ot_hours,
       ROUND(SUM(ot_pay) / 1e6, 1) AS ot_millions
FROM nyc_payroll.payroll
WHERE fiscal_year = 2025
  AND agency IN ('POLICE DEPARTMENT', 'FIRE DEPARTMENT', 'DEPARTMENT OF CORRECTION')
GROUP BY agency, title
HAVING COUNT(*) >= 50
ORDER BY ot_millions DESC
LIMIT 15;

-- ---------------------------------------------------------------
-- 7. How concentrated is overtime? Share of employees who earned
--    more in overtime than in regular pay (agencies with 500+ staff)
--    Output: results/ot_concentration.csv
-- ---------------------------------------------------------------
SELECT agency,
       COUNT(*)                                              AS employees,
       SUM(CASE WHEN ot_pay > regular_pay THEN 1 ELSE 0 END) AS ot_exceeds_regular,
       ROUND(100.0 * SUM(CASE WHEN ot_pay > regular_pay THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct
FROM nyc_payroll.payroll
WHERE fiscal_year = 2025
  AND regular_pay > 0
GROUP BY agency
HAVING COUNT(*) >= 500
ORDER BY pct DESC
LIMIT 10;
