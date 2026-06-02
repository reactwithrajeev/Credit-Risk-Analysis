USE credit_risk_Analysis;

-- Query 9: Creating a dynamic risk scoring engine
-- The Business Problem:
/* Right now, our database has separate columns for Credit Score, Income Category, and Debt Burden (DTI). 
But the Risk Management Team does not have time to look at three different columns for every single customer. 
They want a single, combined score.

We need to build a dynamic scoring engine inside our query using nested conditions.
The system should read multiple columns and assign an institutional risk tag to every borrower based on this specific corporate logic:

	If a borrower has a 'Very High Risk' DTI AND a credit score below 633, tag them as 'Critical Risk'.

	If they have a 'High Risk' DTI OR a credit score between 633 and 671, tag them as 'High Risk'.

	For everyone else, tag them as 'Normal Risk'. */ 


WITH Risk_Score as ( SELECT 
	Loan_Amount,
	Default_Flag,
	CASE 
		WHEN DTI_Risk = 'Very High Risk' AND Credit_Score < 633 THEN 'Critical Risk'
		WHEN DTI_Risk = 'High Risk' OR (Credit_Score >= 633 AND Credit_Score <= 671) THEN 'High Risk'
		ELSE 'Normal Risk'
	END AS Risk_Tier
    FROM 
        credit_risk_merged)
SELECT 
	Risk_Tier,
    COUNT(*) AS Total_Loans_Issued,
    SUM(CASE WHEN Default_Flag = 1 THEN 1 ELSE 0 END) AS Defaulter_Count,
    ROUND(SUM(CASE WHEN Default_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Default_Rate_Percentage,
    SUM(CASE WHEN Default_Flag = 1 THEN Loan_Amount ELSE 0 END) AS Total_Money_Stuck
FROM
	Risk_Score
GROUP BY 
	Risk_Tier
ORDER BY 
	Default_Rate_Percentage DESC;
    
    
    
/* INSIGHTS :- 
The Critical Risk Red Alert: Borrowers categorized as Critical Risk 
(those with both lowest credit scores and highest debt burden) have a shocking default rate of 23.36%. 
This group generated 5,219 defaults, trapping ₹61.22 Crore in bad debt. Nearly 1 out of every 4 people in this segment is failing to pay back.

The High Risk Capital Drain: While the Critical Risk tier has the highest percentage rate,
 the High Risk tier is causing the maximum cash damage to the bank. 
 It holds 17,027 defaults and has stuck a massive amount of ₹127.95 Crore of the bank's total capital. 
 This shows the massive volume size of this risky segment.

The Baseline Normal Risk Layer: Even our Normal Risk group is experiencing a baseline default rate of 9.62%, 
with ₹108.18 Crore stuck. In a typical premium bank, normal risk should stay below 3-4%. This indicates our 
overall entire customer population has an elevated risk structure.

What should the Bank do? (Action Plan): The bank needs to integrate this dynamic scoring logic into their real-time application software. 
Applications triggering a 'Critical Risk' tag must be rejected automatically at entry.
 For the 'High Risk' group, loan amounts must be slashed by 50% to minimize the massive ₹127.95 Crore capital drain. */
 
 
 
 
-- Query 10: Creating a Production-Ready Risk View

 CREATE OR REPLACE VIEW view_corporate_risk_summary AS
 SELECT 
	Region,
    Income_Category,
    Loan_Type,
    COUNT(*) AS Total_Loans_Issued,
    SUM(CASE WHEN Default_Flag = 1 THEN 1 ELSE 0 END) AS Total_Defaulter_Count,
    ROUND(SUM(CASE WHEN Default_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Segment_Default_Rate,
    SUM(Loan_Amount) AS Total_Funded_Amount,
    SUM(CASE WHEN Default_Flag = 1 THEN Loan_Amount ELSE 0 END) AS Total_Capital_At_Risk
FROM
	credit_risk_merged
GROUP BY 
	Region,
    Income_Category,
    Loan_Type;
 
 SELECT * FROM view_corporate_risk_summary limit 10;
 
-- Query 11: The Automated City-Wise Audit Engine
-- The Business Problem:
/* Management wants an automated tool where they can type any city name, 
and the system should instantly return the total loans given, total defaulters, 
default rate, and total money stuck for that specific city.
 We will build a Stored Procedure with an input parameter so that users do not need to rewrite or touch the SQL query ever again. */

DELIMITER //

-- Query 11: Creating an automated Stored Procedure for city-wise credit risk audits
DELIMITER //

CREATE PROCEDURE GetCityAudit (IN input_city VARCHAR(100))
BEGIN
    SELECT 
        City,
        COUNT(*) AS Total_Loans_Issued,
        SUM(CASE WHEN Default_Flag = 1 THEN 1 ELSE 0 END) AS Defaulter_Count,
        ROUND(SUM(CASE WHEN Default_Flag = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Default_Rate_Percentage,
        SUM(CASE WHEN Default_Flag = 1 THEN Loan_Amount ELSE 0 END) AS Total_Money_Stuck
    FROM 
        credit_risk_merged
    WHERE 
        City = input_city
    GROUP BY 
        City;
END //

DELIMITER ;

CALL GetCityAudit('Delhi');
    
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 