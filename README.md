# NYC Payroll Overtime Analysis

**Where is New York City's $3B overtime bill going, and which agencies are at risk?**

An end-to-end cloud analytics project: 2.2M+ NYC payroll records stored in **AWS S3**, cleaned and analyzed with **Athena SQL**, and visualized in **Tableau**.

**[View the interactive dashboard on Tableau Public](https://public.tableau.com/views/NYCPayrollOvertimeAnalysis/Dashboard1)**

![NYC Payroll Overtime Dashboard](dashboard.png)

## Key findings

1. **Citywide overtime rose 19% in three years**, from $2.53B (FY2023) to $3.02B (FY2026), while holding steady at about 10% of regular pay.
2. **NYPD is the largest overtime spender**: $1.09B in FY2025, about 37% of all city overtime.
3. **Correction is the biggest risk.** Overtime equals 47% of regular pay, and 5.9% of staff (568 people) earned more in overtime than in base salary, 3x any other agency. This points to understaffing and burnout risk.
4. **A few job titles drive most of the cost**: Police Officers ($458M), Firefighters ($302M) and Correction Officers ($279M). FDNY Captains average 791 overtime hours a year, about 15 hours a week.

## Tools and workflow

| Step | Tool | What I did |
|---|---|---|
| Store | AWS S3 | Uploaded the raw payroll CSVs (FY2023–FY2026) |
| Query | Amazon Athena (SQL) | Built an external table, a clean view (type casting, trimming, names removed), and 4 analysis queries |
| Visualize | Tableau Public | Built KPI cards, a trend line and 3 bar charts, with Correction highlighted |

## Repository contents

- `queries.sql`: all SQL, from table setup to the 4 analysis queries
- `results/`: query outputs used in the dashboard (CSV)
- `dashboard.png`: dashboard screenshot

## Data notes

- Source: [NYC Open Data, Citywide Payroll Data (Fiscal Year)](https://data.cityofnewyork.us/City-Government/Citywide-Payroll-Data-Fiscal-Year-/k397-673e)
- Agency names are blank in the FY2026 source data, so agency and job-title charts use FY2025. The citywide trend uses FY2023–FY2026.
- Employee names were excluded from the clean view.

## Author

**Amara Obi**, MBA in Business Analytics and Risk Management, PMP
[LinkedIn](https://www.linkedin.com/in/amara-obi)
