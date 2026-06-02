# 🏦 Credit Risk Analysis — BFSI Domain

> **End-to-end Data Analytics Project | BFSI Domain**
>
> Analyst: **Rajeev Kumar** | Tools: Python · SQL · Power BI

![Python](https://img.shields.io/badge/Python-3.x-blue?logo=python)
![MySQL](https://img.shields.io/badge/MySQL-Advanced-orange?logo=mysql)
![PowerBI](https://img.shields.io/badge/PowerBI-Dashboard-yellow?logo=powerbi)
![Domain](https://img.shields.io/badge/Domain-BFSI-green)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

---

## 📌 Project Overview

This project is a complete end-to-end **Credit Risk Analysis** built on a BFSI domain dataset.
The goal was to analyze **3,52,500 loan repayment records** across 3 linked tables, identify which customer segments are most likely to default on their loans, and give actionable business recommendations to reduce portfolio risk.

| Detail | Information |
|--------|-------------|
| **Domain** | BFSI — Credit Risk & Loan Defaults |
| **Dataset** | 3,52,500 records · 41 columns (after merge) |
| **Tables** | 3 tables — Applicants · Loans · Repayments |
| **Regions** | North · South · East · West · Central |
| **Loan Types** | Personal · Home · Auto · Business · Gold · Education |
| **Portfolio Default Rate** | **11.70%** — Almost 2x the industry average of 5–8% ⚠️ |

---

## 🛠️ Tools & Technologies

| Tool | Purpose |
|------|---------|
| **Python** (Pandas, NumPy, Matplotlib, Seaborn) | Data Cleaning, Feature Engineering, EDA |
| **MySQL** | Advanced SQL Analysis — CTEs, Window Functions, Stored Procedures |
| **Power BI** | Interactive 3-Page Dashboard with Advanced DAX |

---

## 📁 Project Structure

```
Credit-Risk-Analysis/
│
├── 📂 Dataset/
│   ├── applicant_details_cleaned.csv       # 20,000 rows — customer demographics
│   ├── loan_details_cleaned.csv            # 30,000 rows — loan information
│   ├── repayment_history_cleaned.csv       # 3,52,500 rows — EMI payment history
│   └── credit_risk_merged.csv             # Final merged table — 3,52,500 rows · 41 columns
│
├── 📂 Python/
│   ├── Credit_Risk_Analysis.ipynb          # Jupyter Notebook — Cleaning + EDA
│   └── Charts/
│       ├── eda1_overall_default.png
│       ├── eda2_loangrade_default.png
│       ├── eda3_creditscore_default.png
│       ├── eda4_employment_default.png
│       ├── eda5_income_default.png
│       ├── eda6_loantype_default.png
│       ├── eda7_agegroup_default.png
│       ├── eda8_dti_default.png
│       ├── eda9_region_default.png
│       └── eda10_correlation_heatmap.png
│
├── 📂 SQL/
│   ├── Credit_Risk_Analysis_MYSQL.sql      # Queries 1–4
│   ├── Credit_Risk_Analysis_MYSQL_2.sql    # Queries 5–8
│   └── Credit_Risk_Analysis_MYSQL_3.sql    # Queries 9–11 + View + Stored Procedure
│
├── 📂 PowerBI/
│   └── Credit_Risk_Analysis_PBI_Report.pbix
│
└── README.md
```

---

## 🔍 Phase 1 — Data Cleaning (Python)

### 3 Tables — Raw Data

| Table | Raw Rows | Columns | Key Columns |
|-------|----------|---------|-------------|
| applicant_details | 20,000 | 14 | Age, Income, Credit_Score, Employment_Type |
| loan_details | 30,000 | 12 | Loan_Grade, Loan_Type, Interest_Rate, DTI_% |
| repayment_history | 3,52,500 | 11 | DPD_Days, Payment_Status, Default_Flag |
| **Merged** | **3,52,500** | **41** | All columns combined |

### Cleaning Steps Applied

| # | Problem | Column | Fix Applied |
|---|---------|--------|-------------|
| 1 | Inconsistent gender values | Gender | Male/M/MALE → Male using `.map()` |
| 2 | Missing numeric values | Annual_Income, Credit_Score, Loan_Amount, Interest_Rate | `fillna(median)` |
| 3 | Missing categorical values | Education | `fillna(mode)` |
| 4 | Missing payment amounts | Amount_Paid | `fillna(0)` — no payment made |
| 5 | Missing payment dates | Paid_Date | Left as NULL — defaulted accounts have no date |
| 6 | Wrong data types | Issue_Date, Due_Date, Paid_Date | `pd.to_datetime()` |
| 7 | Feature Engineering | 5 new columns | `pd.cut()` for categorization |
| 8 | 3 tables merge | All tables | `pd.merge()` with left join on Applicant_ID → Loan_ID |

### Feature Engineering — 5 New Columns Created

| New Column | Source Column | Categories |
|------------|--------------|------------|
| Credit_Score_Category | Credit_Score | Poor · Fair · Good · Very Good · Excellent |
| Age_Group | Age | 21–30 · 31–40 · 41–50 · 51–65 |
| Income_Category | Annual_Income | Low · Lower Middle · Middle · Upper Middle · High |
| DTI_Risk | Debt_To_Income_% | Low Risk · Moderate Risk · High Risk · Very High Risk |
| Loan_Size | Loan_Amount | Small · Medium · Large · Very Large |

**Result after cleaning:** 3,52,500 clean records · 41 columns ✅

---

## 📊 Phase 2 — EDA (Python)

### 10 Business Questions Answered

| # | Chart | Business Question | Key Finding |
|---|-------|------------------|-------------|
| 1 | Overall Default Distribution | What is the portfolio default rate? | **11.70%** — HIGH RISK — 2x industry average |
| 2 | Loan Grade wise Default Rate | Which loan grade defaults most? | Grade F: **23.79%** vs Grade A: **1.04%** — 23x gap |
| 3 | Credit Score Category wise | How does credit score affect default? | Poor: **24.19%** vs Excellent: **1.06%** |
| 4 | Employment Type wise | Which employment type is riskiest? | Freelancer: **13.80%** — income instability |
| 5 | Income Category wise | Does income affect default? | Low: **16.67%** vs High: **3.33%** — 5x gap |
| 6 | Loan Type wise | Which loan product is riskiest? | Business Loan: **13.43%** — cash flow issues |
| 7 | Age Group wise | Which age group defaults most? | 21–30: **12.47%** — first-time borrowers |
| 8 | DTI Risk wise | Does debt burden drive default? | Very High DTI: **15.72%** vs Low DTI: **10.02%** |
| 9 | Region wise | Which region has highest risk? | South: **12.36%** — only 1.11% gap across regions |
| 10 | Correlation Heatmap | Which factor drives default most? | Credit Score: **-0.18** (strongest predictor) |

### EDA Charts Preview

| EDA 1 — Overall Default | EDA 2 — Loan Grade |
|---|---|
| ![EDA1](Credit-Risk-Analysis/blob/master/Python/charts/eda1_overall_default.png) | ![EDA2](Python/Charts/eda2_loangrade_default.png) |

| EDA 3 — Credit Score | EDA 10 — Correlation Heatmap |
|---|---|
| ![EDA3](Python/Charts/eda3_creditscore_default.png) | ![EDA10](Python/Charts/eda10_correlation_heatmap.png) |

---

## 💾 Phase 3 — SQL Analysis (MySQL)

### 11 Queries — Basic to Advanced

| # | Query | SQL Concept | Key Finding |
|---|-------|-------------|-------------|
| 1 | Low Income + Bad Loan Grade Defaults | Subquery, GROUP BY | Middle Income + Grade E = **16.89% of total losses** |
| 2 | Marital Status + House Ownership Risk | CASE WHEN inside SUM() | Single + Home Owner defaults at **13.29%** |
| 3 | Interest Rate vs Default Rate | CASE WHEN Groups | High rate (>15%) = **12.95%** default vs Medium = **5.27%** |
| 4 | Very High DTI + Job Experience | WHERE + GROUP BY | 24 years experience + High DTI = **50% default rate** |
| 5 | Top 2 Risky Products Per Region | **Chained CTEs + DENSE_RANK()** | Business Loan is Rank 1 risk in 4/5 regions |
| 6 | Credit Score Quartile Analysis | **CTE + NTILE(4)** | Bottom quartile (477–633) defaults at **19.40%** |
| 7 | Running Total of Capital at Risk | **CTE + SUM() OVER** | Cumulative default capital = **₹2,973 Crore** |
| 8 | Sudden DPD Jump Detection | **CTE + LAG() OVER PARTITION BY** | 5,273 customers — **84.94 day delay on first payment** |
| 9 | Dynamic Risk Scoring Engine | **CTE + Nested CASE WHEN** | Critical Risk borrowers default at **23.36%** |
| 10 | Production-Ready Risk View | **CREATE OR REPLACE VIEW** | 150-combination risk summary view |
| 11 | Automated City-Wise Audit Engine | **STORED PROCEDURE with IN Parameter** | Delhi: 16,902 loans · 11.87% default · ₹143 Cr stuck |

---

## 🖥️ Phase 4 — Power BI Dashboard

### 3-Page Interactive Dashboard

**Page 1 — Portfolio Overview**
- 5 KPI Cards: Total Loans · Default Rate % · Total Defaulters · Total Loan Amount · Capital at Risk
- Donut Chart: Overall Default Distribution (88.3% vs 11.7%)
- Bar Chart: Loan Grade wise Default Rate — with Red/Blue conditional formatting
- Bar Chart: Region wise Default Rate
- Tile Slicer: Filter by Loan Type

**Page 2 — Customer Risk Analysis**
- Bar Chart: Credit Score Category wise Default Rate
- Bar Chart: Income Category wise Default Rate
- Bar Chart: Age Group wise Default Rate
- Bar Chart: Employment Type wise Default Rate
- Tile Slicer: Filter by Region

**Page 3 — Loan & Repayment Analysis**
- Bar Chart: Loan Type wise Default Rate
- Bar Chart: DTI Risk wise Default Rate
- Line Chart: Monthly Default Trend (May 2023 – Apr 2026)
- Bar Chart: Interest Rate Group wise Default Rate
- Slicers: Loan Grade + Year filter

### DAX Measures Used

```dax
Total Loans              = COUNTROWS(credit_risk_merged)
Total Defaulters         = SUM(credit_risk_merged[Default_Flag])
Default Rate %           = DIVIDE([Total Defaulters], [Total Loans], 0) * 100
Non Default Rate %       = 100 - [Default Rate %]
Total Loan Amount Cr     = DIVIDE(SUM(credit_risk_merged[Loan_Amount]), 10000000, 0)
Total Capital at Risk Cr = DIVIDE(CALCULATE(SUM(credit_risk_merged[Loan_Amount]), credit_risk_merged[Default_Flag]=1), 10000000, 0)
Avg Credit Score         = AVERAGE(credit_risk_merged[Credit_Score])
Avg DTI %                = AVERAGE(credit_risk_merged[Debt_To_Income_%])
Default Rate By Grade    = DIVIDE(CALCULATE(COUNTROWS(credit_risk_merged), credit_risk_merged[Default_Flag]=1), COUNTROWS(credit_risk_merged), 0) * 100
```

### Advanced Power BI Features Used
- ✅ **Conditional Formatting** — Red/Blue bars based on 11% threshold
- ✅ **Drill Through Page** — Click any region → Region Detail page with full breakdown
- ✅ **Tooltip Page** — Hover on any visual → Mini KPI popup (Total Loans, Default Rate, Capital at Risk)
- ✅ **SELECTEDVALUE DAX** — Dynamic title on Drill Through page
- ✅ **Hidden Pages** — Drill Through and Tooltip pages hidden for clean UI
- ✅ **Tile Slicers** — Interactive filters on every page

---

## 🔑 Top Key Findings

| # | Finding | Business Impact |
|---|---------|----------------|
| 1 | Portfolio default rate is **11.70%** — almost 2x industry average | Entire credit approval process needs review |
| 2 | Grade F borrowers default at **23.79%** — 23x higher than Grade A | Limit or stop loans to Grade E and F |
| 3 | Middle Income + Grade E/F = **24.48% of total default loss** | Fixing this one segment saves 1/4 of all losses |
| 4 | High interest rate (>15%) loans default at **12.95%** | High EMI is creating repayment trap |
| 5 | Very High DTI borrowers default at **15.72%** | DTI must be primary rejection filter |
| 6 | 5,273 customers delayed **84.94 days on first payment** | First payment behavior is a strong fraud signal |
| 7 | Cumulative default capital = **₹2,973 Crore** | Aggressive collection drive urgently needed |

---

## 🎯 Business Recommendations

| # | Recommendation | Expected Impact |
|---|----------------|----------------|
| 1 | Stop approving loans for Middle Income + Grade E/F combination | Saves **24.48%** of total default losses |
| 2 | Set strict DTI cap — reject if new EMI pushes into Very High Risk DTI | Reduces Very High DTI defaults from 15.72% |
| 3 | Use Credit Score as primary filter — demand extra collateral for Poor category | Reduces Poor category default from 24.19% |
| 4 | Reduce interest rates on risky profiles — offer medium rate with extra security | Reduces high-rate default from 12.95% to near 5.27% |
| 5 | Launch early collection — act within 15 days of missed payment | Prevents 90-day delay spiral |
| 6 | Flag first-payment delays as fraud signal — investigate 5,273 such accounts | Prevents ₹60+ Crore early-stage losses |

---

## 📬 Contact

**Rajeev Kumar**
- 📧 Email: hireraajeev@gmail.com
- 💼 LinkedIn: [linkedin.com/in/reactwithrajeev](https://www.linkedin.com/in/reactwithrajeev/)
- 🐙 GitHub: [github.com/reactwithrajeev](https://github.com/reactwithrajeev)

---

> ⭐ If you found this project helpful, please give it a star!

*This project is part of a complete Data Analytics portfolio covering Python, SQL, Excel, and Power BI.*
