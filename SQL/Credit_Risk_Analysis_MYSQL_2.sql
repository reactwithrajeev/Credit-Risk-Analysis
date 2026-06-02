USE credit_risk_analysis;

-- Query 5: Finding the highest risk loan products in each region
-- The Business Problem:
/* Management wants to study our product performance across different parts of the country (North, South, East, West, Central). 
Specifically, they want to know which types of loans (like Home Loan, Personal Loan, etc.) are causing the highest default rates in each separate region.

We need to calculate the total loans issued and the default rate for every combination of region and loan type. 
Then, we will use a window function to find and rank the top 2 most risky loan products for each individual region so management can take quick action. */



WITH Regional_Risk AS (SELECT 
	region,
    loan_type,
    COUNT(*) AS Total_Loan_Issued,
    ROUND(SUM(CASE WHEN Default_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Default_Rate_Percentage,
	SUM(CASE WHEN Default_Flag = 1 THEN Loan_Amount ELSE 0 END) AS Total_Money_Stuck
FROM 
	credit_risk_merged
GROUP BY 
	region,
    loan_type),
Risk_Ranking as (SELECT 
	region,
    loan_type,
    total_loan_issued,
    default_rate_percentage,
    total_money_stuck,
    DENSE_RANK() OVER(PARTITION BY Region ORDER BY Default_Rate_Percentage DESC) AS Risk_Rank
FROM 
	Regional_Risk)
SELECT * FROM
Risk_Ranking
WHERE Risk_Rank <=2;


/* INSIGHTS:- 
The South Region Danger: The South region is the most dangerous zone for our portfolio. 
Business Loans in the South have the highest default rate across the country at 14.56%, sticking ₹11.18 Crore. 
Right behind it, Home Loans in the South hit a shocking 13.79% default rate, locking up a massive ₹32.66 Crore.

The Home Loan Capital Trap: Across all 5 regions (Central, East, North, South, West), 
Home Loans consistently hold Rank 1 or Rank 2 in risk. Even worse, 
the absolute amount of dooba hua paisa is highest in Home Loans everywhere. 
For example, ₹30.71 Crore is stuck in Central and ₹29.48 Crore in North just from Home Loans.
 This proves that having a property as security is not stopping people from defaulting.

Business Loans Consistency in Risk: Business Loans take the number 1 risk rank in almost every region except Central. 
It hits 13.58% in the East, 13.44% in the North, and 13.13% in the West. 
This means small or local business segments are facing severe cash flow issues across India and cannot pay their EMIs.

What should the Bank do? (Action Plan): The bank needs to review its regional audit rules immediately. 
Since South and Central regions are losing massive capital in Home Loans, 
the underwriting team must check property valuations more strictly before approving. 
For Business Loans, the bank should stop giving high-value loans without extra monthly business revenue proof. */




-- Query 6: Dividing the portfolio by credit scores using NTILE
-- The Business Problem:
/* Management wants to divide our entire customer base into 4 equal groups (Quartiles) based on their credit scores, 
from lowest to highest. We will use the window function NTILE(4) to do this automatically.

Group 1 will have the worst credit scores, and Group 4 will have the best credit scores. 
Management wants to see the total loans given, the number of defaulters, the default rate, 
and the total money stuck for each of these 4 equal groups. 
This will show us exactly how much loss our bottom-tier customers are causing. */


WITH Score_Buckets AS (SELECT 
	credit_score,
    loan_amount,
    default_flag,
    NTILE(4) OVER(ORDER BY credit_score ASC) AS Score_Quartile
FROM 
	credit_risk_merged)
SELECT 
	Score_Quartile,
    MIN(credit_score) AS Min_Credit_Score,
    MAX(credit_score) AS Max_Credit_Score,
    COUNT(*) AS Total_Loan_Issued,
    SUM(CASE WHEN Default_Flag = 1 THEN 1 ELSE 0 END) AS Defaulter_Count,
    ROUND(SUM(CASE WHEN Default_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Default_Rate_Percentage,
    SUM(CASE WHEN Default_Flag = 1 THEN Loan_Amount ELSE 0 END) AS Total_Money_Stuck
FROM
	Score_Buckets
GROUP BY 
	Score_Quartile
ORDER BY 
	Score_Quartile ASC;


/* INSIGHTS :- 
The Bottom Quartile Crisis: The first group (Score_Quartile 1), which contains our lowest credit scores from 477 to 633, 
is a major loss maker. It has a high default rate of 19.40% with 17,100 defaults, 
locking up a huge amount of ₹109.06 Crore in bad debt. This proves that our absolute bottom-tier credit users are highly unstable.

The High-Risk Middle Tier: The second group (Score_Quartile 2), with scores between 633 and 671,
 is also highly risky. It hits a default rate of 13.39% and holds ₹85.11 Crore in stuck capital. 
 Together, Quartiles 1 and 2 are responsible for more than half of the bank's total loan failures.

The Safest Tier Performance: On the opposite side, the top group (Score_Quartile 4), 
containing our best credit scores from 711 to 900, is performing incredibly well. 
Its default rate is only 4.35%, and the total money stuck is just ₹32.91 Crore, 
even though it holds the same number of loans as the other groups.

What should the Bank do? (Action Plan): The bank needs to change its credit approval strategy entirely based on these 4 buckets. 
We must enforce strict rejection or decrease the loan approval amounts for anyone with a credit score below 633 (Quartile 1). 
Instead, the marketing team should focus on driving high-volume campaigns targeting borrowers with scores above 711 (Quartile 4) to ensure safer returns. */



-- Query 7: Running total of capital at risk over time
-- The Business Problem:
/* Management wants to understand the velocity of our risk over time. 
They want to see a month-on-month trend of how our portfolio grows. Specifically, 
they want to track the continuous accumulation of our funded amount alongside the dooba hua paisa based on the loan issue dates.

To achieve this, we will write a query that calculates the total monthly loan amount and monthly defaulted capital, 
and then uses the window function SUM() OVER to compute a cumulative running total for both metrics as time progresses. */ 



WITH Monthly_Agg AS (SELECT 
	DATE_FORMAT(issue_date, '%Y-%m') AS Loan_Month,
    SUM(Loan_Amount) AS Monthly_Funded_Amount,
    SUM(CASE WHEN Default_Flag = 1 THEN Loan_Amount ELSE 0 END) AS Monthly_Defaulted_Amount
FROM 
	credit_risk_merged
GROUP BY 
	DATE_FORMAT(Issue_Date, '%Y-%m'))
SELECT
	Loan_Month,
    Monthly_Funded_Amount,
    SUM(Monthly_Funded_Amount) OVER(ORDER BY Loan_Month ASC) AS Running_Total_Funded_Capital,
    Monthly_Defaulted_Amount,
    SUM(Monthly_Defaulted_Amount) OVER(ORDER BY Loan_Month ASC) AS Running_Total_Capital_At_Risk
FROM 
	Monthly_Agg
ORDER BY 
	Loan_Month ASC;
    

/* 
The Portfolio Growth Milestone: The bank's overall lending business has grown at a highly steady speed over the last 3 years. 
Starting from just ₹19.71 Crore in monthly funding in May 2023, the overall portfolio successfully crossed the ₹1,000 Crore milestone in July 2024 
and closed at a massive ₹2,500.86 Crore total cumulative funding by April 2026.

The Dangerously Stable Default Velocity: The total money stuck in defaults is growing at a highly predictable and dangerous speed 
alongside our lending growth. The cumulative money stuck crossed ₹100 Crore in June 2024 and jumped past ₹200 Crore by May 2025. 
It currently stands at ₹297.36 Crore. This means our collection recovery speed is not able to stop the loss accumulation.

The Consistent 11.8% Risk Ratio: If you calculate the percentage of total defaults against total funding month-on-month, 
it sits consistently around 11.8% (For example, in April 2026: $\frac{297.36}{2500.86} \times 100 \approx 11.89\%$). 
This proves that our default problem is built into the system structurally; it is not a one-time seasonal issue.

What should the Bank do? (Action Plan): Management needs to put a strict cap on maximum monthly exposure 
when cumulative losses grow by more than ₹8-9 Crore in any single month (like what happened in October 2025). 
The risk management team should launch an aggressive collection cleanup drive to clear the 
existing ₹297.36 Crore before expanding the portfolio any further. */


-- Query 8: Tracking sudden jumps in payment delays
-- The Business Problem:
/* When a borrower starts delaying their monthly payments, it is a big warning sign. 
Management wants to find those specific customers whose payment delay (measured in Days Past Due, or DPD) 
suddenly jumped by more than 30 days compared to their very last month. 
This indicates that their financial situation is getting worse very quickly. 
We need to count how many such unique customers hit this danger zone every month and calculate the average number of days their delay increased.
*/ 

WITH Monthly_DPD AS (SELECT 
	Applicant_ID,
    DATE_FORMAT(Paid_Date, '%Y-%m') AS Payment_Month,
    DPD_Days AS Current_Month_DPD,
    LAG(DPD_Days,1,0) OVER (PARTITION BY Applicant_ID ORDER BY 
    Paid_Date ASC) AS Previous_Month_DPD
FROM
	Repayment_History)
SELECT 
	Payment_Month,
	COUNT(DISTINCT Applicant_ID) AS Red_Alert_Customer_Count,
	ROUND(AVG(Current_Month_DPD - Previous_Month_DPD), 2) AS Avg_Delay_Jump_Days
FROM
	Monthly_DPD
WHERE 
    (Current_Month_DPD - Previous_Month_DPD) > 30
GROUP BY 
    Payment_Month
ORDER BY 
    Payment_Month ASC;



/* The First-Payment Shock: The data reveals a massive risk group in the first row (marked as NULL month). 
There are 5,273 unique customers who started their very first loan installment with a massive payment delay of 84.94 days. 
This shows severe fraud or complete repayment failure right at the beginning of the loan lifecycle.

The Dangerous 90-Day Delay Pattern: For customers who cross the 30-day delay threshold, 
the average jump in delay (Avg_Delay_Jump_Days) continuously stays between 85 and 98 days month-on-month. 
This proves that once a customer misses their payment cycle significantly, 
they do not just miss it by a few days—they completely stop paying for nearly 3 months.

Stable Peak Danger Zone: From mid-2024 to early 2026, the volume of unique "Red Alert" customers remains highly stable, 
averaging between 260 and 290 customers every single month. 
This means the bank has a continuous pipeline of regular borrowers turning into high-risk defaulters month after month.

What should the Bank do? (Action Plan): The collection team must act within the first 15 days of a missed payment. 
Since the data shows that delays quickly blow up to 90 days, 
waiting for a standard 30-day or 60-day window to contact the customer is a losing strategy. 
Early automated warnings and immediate phone tracking are required. */































































































