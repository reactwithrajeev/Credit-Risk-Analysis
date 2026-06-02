CREATE DATABASE Credit_Risk_Analysis;
USE Credit_Risk_Analysis;

SELECT * FROM credit_risk_merged;
SELECT * FROM applicant_details;
SELECT * FROM loan_details;
SELECT * FROM repayment_history;

-- Query 1: Low-income borrowers with bad loan grades
-- The Business Problem:
/* In our Python analysis, we saw that middle-income and low-income groups take a lot of loans from us. Now, management wants to know 
about the most dangerous zone in this segment. We need to find the total number of customers who have low or middle income, 
have been given our worst loan grades (E and F), and have already defaulted. Management wants to see how many such customers exist, 
how much money is stuck with them, and what percentage of our total default loss is coming from this single group. */

SELECT 
income_category,
loan_grade,
COUNT(*) AS defaulter_count,
SUM(loan_amount) AS Total_Capital_At_Risk,
ROUND(SUM(loan_amount)*100/(
	SELECT SUM(loan_amount)
	FROM credit_risk_merged
	WHERE default_flag =1),2) AS Total_Default_PCT_Share
FROM
	credit_risk_merged
WHERE 
	default_flag = 1
	AND Income_Category IN ('Low', 'Middle')
	AND Loan_Grade IN ('E', 'F')
GROUP BY
	income_category,
	loan_grade
ORDER BY 
    Total_Capital_At_Risk DESC;
    
    
/* INSIGHTS : 
The Middle Income & Grade E Danger Zone: Borrowers who have a Middle Income and are given a Grade E rating are the biggest 
reason for the bank's losses. This small group alone has 6,412 defaults. They have stopped payments for a huge amount 
of ₹50.22 Crore, which is 16.89% (almost one-fifth) of the bank's total dooba hua paisa.

The Middle Income & Grade F Risk: Even though Grade F is considered worse than Grade E,
Middle Income borrowers in Grade F are also causing a big problem. They have 2,938 defaults which adds up to ₹22.57 Crore,
making up 7.59% of the total default loss. This proves our system is failing to judge the risk of middle-income earners in these bad grades.

Low Income Group is Safe in Volume: Interestingly, Low Income borrowers in Grades E and F combined have very low losses (only ₹7.01 Crore total). 
They make up less than 2.4% of the bank's total defaults. This means even though these poor people are risky, the bank was smart enough not to
give them big loan amounts.

What should the Bank do? (Action Plan): The bank must immediately stop giving automatic loans to any Middle Income applicant who gets a Grade E or F rating.
If we fix the rules for just this one combination, we can save up to 24.48% (16.89% + 7.59%) of our total loss. */

-- Query 2: The Co-Applicant & Asset Collateral Security Gap
-- The Business Problem:
/* When people apply for loans, some apply alone (Single) while others might have family support (Married). 
Also, some own a house, while others live on rent. Management wants to know if providing unsecured 
products (like Personal Loans or Business Loans) to single individuals who do not own a home (Own_House = 'No') is a bad idea. 
We need to find out the default rate and total money stuck for this specific vulnerable segment compared to the rest of the portfolio. */


SELECT 
	marital_status,
	own_house,
	COUNT(*) AS Total_Loan_Issued,
	SUM(CASE WHEN default_flag =1 THEN 1 ELSE 0 END) AS Defaulter_Count,
	ROUND(SUM(CASE WHEN Default_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Default_Rate_Percentage,
	SUM(CASE WHEN default_flag =1 THEN loan_amount ELSE 0 END ) AS Total_Money_Stuck 
FROM 
	credit_risk_merged
WHERE 
	loan_type IN ('Personal Loan','Business Loan')
GROUP BY 
	marital_status,
    own_house
ORDER BY 
	marital_status,Default_Rate_Percentage DESC;


/* INSIGHTS : 
The Single & Homeowner Risk: Surprisingly, borrowers who are Single but own a house have the highest default rate at 13.29%. 
They account for 1,644 defaults and have stuck ₹79.70 Crore in bad debt. 
This shows that simply owning a house does not guarantee clean repayment if the borrower is single and taking unsecured loans.

The Widowed & No House Risk Group: Borrowers who are Widowed and do not own a house are the second biggest danger zone. 
They have a default rate of 13.14% with 2,348 defaults, sticking a huge amount of ₹119.46 Crore of the bank's money. 
This is a highly vulnerable segment due to a lack of both family structure and asset support.

The Married Homeowner Volume Risk: Borrowers who are Married and own a house have a high default rate of 12.80%. 
While they seem stable on paper, they have caused 1,512 defaults totaling ₹78.04 Crore. 
This proves that even with family support and asset backing, unsecured Personal and Business loans remain highly risky.

What should the Bank do? (Action Plan): The bank cannot blindly trust "Home Ownership" as a safety feature anymore. 
For any applicant taking an unsecured loan with a default probability above 12.5% (like Single Homeowners or Widowed non-homeowners), 
the bank must demand a financial co-applicant or guarantor to safely back the debt. */


-- Query 3: High interest rates vs loan defaults


/* The Business Problem:
Usually, when a bank thinks a customer is risky, it charges them a higher interest rate to protect itself. 
But sometimes, this high interest rate becomes a trap. The borrower cannot afford the heavy monthly EMIs and ends up defaulting.

Management wants to see if our high interest rates are actually forcing people to default. We need to divide our loans into 3 simple groups:
 Low interest (under 10%), 
 Medium interest (10% to 15%), 
 and High interest (above 15%). 
 For each group, we want to see the total loans given, the total number of defaulters, the default rate percentage, and the total money stuck. */
 
SELECT 
    CASE 
        WHEN Interest_Rate < 10.0 THEN 'Low (<10%)'
        WHEN Interest_Rate >= 10.0 AND Interest_Rate <= 15.0 THEN 'Medium (10%-15%)'
        ELSE 'High (>15%)'
    END AS Interest_Rate_Group,
    COUNT(*) AS Total_Loans_Issued,
    SUM(CASE WHEN Default_Flag = 1 THEN 1 ELSE 0 END) AS Defaulter_Count,
    ROUND(SUM(CASE WHEN Default_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Default_Rate_Percentage,
    SUM(CASE WHEN Default_Flag = 1 THEN Loan_Amount ELSE 0 END) AS Total_Money_Stuck
FROM 
    credit_risk_merged
GROUP BY 
    CASE 
        WHEN Interest_Rate < 10.0 THEN 'Low (<10%)'
        WHEN Interest_Rate >= 10.0 AND Interest_Rate <= 15.0 THEN 'Medium (10%-15%)'
        ELSE 'High (>15%)'
    END
ORDER BY 
    Default_Rate_Percentage DESC;
 
 
 /* INSIGHTS : 
The High Interest Rate Trap: Loans given at a High interest rate (above 15%) are the biggest source of trouble for the bank. 
This group has a very high default rate of 12.95% with 38,245 defaults. A massive amount of ₹270.15 Crore is stuck in this group, 
which shows that high monthly EMIs are making it impossible for borrowers to pay back on time.

The Medium Interest Rate Safety: On the other side, loans given at a Medium interest rate (10% to 15%) are performing much better. 
Their default rate is only 5.27%, and the total money stuck is just ₹27.20 Crore. This means when interest rates are reasonable, 
borrowers pay back their EMIs more comfortably.

Zero Low-Interest Footprint: The data shows that the bank has not issued any loans in the Low interest (under 10%) bracket. 
The portfolio is entirely leaning toward charging higher interest rates to make quick profits, which is backfiring and causing massive cash losses.

What should the Bank do? (Action Plan): The bank needs to stop over-charging customers in the name of risk pricing. 
Instead of putting a high interest rate on risky profiles, the bank should offer a medium interest rate but ask for extra security, 
like a guarantee from a family member or a higher initial down payment. */

-- Query 4: High debt burden vs job experience
-- The Business Problem:
/* If a customer already owes a lot of money to other banks, they fall into the "Very High Risk" DTI (Debt-to-Income) group. 
Now, management wants to see if a borrower's job experience (Years_At_Job) helps them handle this heavy debt burden. 
We need to look only at the Very High Risk DTI customers and group them by their job experience to find out their default rate and the total money stuck. */

SELECT
	Years_At_Job, 
	COUNT(*) AS Total_Loans_Issued,
	SUM(CASE WHEN Default_Flag = 1 THEN 1 ELSE 0 END) AS Defaulter_Count,
	ROUND(SUM(CASE WHEN Default_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Default_Rate_Percentage,
	SUM(CASE WHEN Default_Flag = 1 THEN Loan_Amount ELSE 0 END) AS Total_Money_Stuck
FROM 
    credit_risk_merged
WHERE 
    DTI_Risk = 'Very High Risk'
GROUP BY 
    Years_At_Job
ORDER BY 
    Years_At_Job ASC;



/* INSIGHTS : 
The Low-Experience Cash Trap: Borrowers with 0 to 1 year of experience who are already under heavy debt are a huge risk. 
Combined, they have 4,572 defaults (2,440 + 2,132), sticking over ₹60.62 Crore of the bank's money. 
Since they are new to their jobs and carry high personal debt, they fail to manage their monthly EMIs.

The Experience Myth: Surprisingly, having more job experience does not protect the bank if the borrower has a very high debt burden. 
For example, borrowers with 7 years of experience have a high default rate of 18.51%, and those with 11 years hit a dangerous 22.78% default rate.

Extreme Subprime Behavior in Senior Tiers: In the senior brackets, the situation gets even worse due to high DTI. 
Borrowers with 23, 24, and 28 years of experience have shocking default rates of 37.50%, 50.00%, and 36.67% respectively. 
This proves that high existing debt structure destroys a person's capability to repay, no matter how stable their career is.

What should the Bank do? (Action Plan): The bank must stop using "Years at Job" as a compensating factor to approve high-DTI loans. 
If an applicant's debt-to-income ratio is in the 'Very High Risk' tier, the loan must be rejected automatically, 
even if the person has 10 or 20 years of work experience. */














































































    