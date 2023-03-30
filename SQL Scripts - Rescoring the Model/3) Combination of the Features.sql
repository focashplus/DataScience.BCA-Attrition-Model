
DECLARE     @scoringmonth  DATE = EOMONTH('2023-02-28')

DROP TABLE	IF EXISTS    warehouseuserdb.dbo.FO_Attrition_Scoring_New_Data_Feb2023
SELECT  acm.ACCNO,
		acm.ReviewDate,
		acm.TransactionMonth,
		ov.Nof_Balance_Change,
		pt.Credits,
		db.Rate_Last_DB_Cash_Transaction,
		pf.Rate_Total_PaymentApplied_M_3M,
		pf.Last_Month_Total_PaymentApplied_Amt,
		ov.Avg_Monthly_FINAMT_Cleare_Balance,
		pt.Rate_of_Debit_Transactions,
		ov.Max_Overdraft_Limit_in_Month,
		ov.Delta_Avg_Nof_Balance_Chg_M_3M,
		onb2.Rate_Nof_Successful_Login_3M_6M,
		ov.Delta_Avg_FINAMT_Cleare_Balance_Chg_M_6M,
		ov.Rate_of_Avg_Overdraft_Count_in_Month,
		ov.Rate_Tot_Nof_Balance_Change_M_3M,
		pt.Last_2M_PostOffice_Loads,
		rv.Rate_NormalisedRevenue_3M_6M,
		onb1.Z_Value_Avg_Last_2M_Total_Online_Banking_Int,
		rv.MonthsBetween_Transaction_MinRevenueM,
		db.Avg_Last_DebitCard_Transactions_Amt,
		ov.Delta_Avg_Nof_Balance_Chg_InOverdraft_M_3M,
		ov.Rate_Nof_Balance_Chg_InOverdraft_M_3M,
		rv.Rate_NormalisedRevenue_M_6M,
		sc.RVILF04,
		NULLIF(tg.Target3M_Dormancy,0) Target3M_Dormancy
INTO      warehouseuserdb.dbo.FO_Attrition_Scoring_New_Data_Feb2023

FROM    apstempdb.dbo.FO_AttritionModel_ActiveCustomersByMonth acm

--PaymentTransfer 
LEFT JOIN  apstempdb.dbo.FO_ActiveCustomersWithPayments pt
ON         acm.ACCNO=pt.ACCNO
AND        acm.TransactionMonth = pt.TransactionMonth

--PaymentTransfer ---Debit
LEFT JOIN apstempdb.dbo.FO_ActiveCustomersWith_DebitCard_Transactions db
ON         acm.ACCNO=db.ACCNO
AND        acm.TransactionMonth = db.TransactionMonth

--Overdraft
LEFT JOIN  apstempdb.dbo.FO_Overdraft ov
ON         acm.ACCNO=ov.ACCNO
AND        acm.TransactionMonth = ov.TransactionMonth

--PaymentFile
LEFT JOIN  apstempdb.dbo.FO_ActiveCustomersWith_PaymentFileRecords pf
ON         acm.ACCNO=pf.ACCNO
AND        acm.TransactionMonth = pf.TransactionMonth

--Revenue
LEFT JOIN apstempdb.dbo.FO_ActiveCustomersWith_Revenue rv
ON         acm.ACCNO=rv.ACCNO
AND        acm.TransactionMonth = rv.TransactionMonth

--Online Banking 
LEFT JOIN apstempdb.dbo.FO_Online_Banking_With_ZValues onb1
ON         acm.ACCNO=onb1.ACCNO
AND        acm.TransactionMonth = onb1.TransactionMonth

LEFT JOIN apstempdb.dbo.FO_Online_Banking_Part2 onb2
ON        acm.ACCNO = onb2.ACCNO
AND       acm.TransactionMonth = onb2.TransactionMonth

--RV Score
LEFT JOIN apstempdb.dbo.FO_Attrition_Customer_Scores sc
ON         acm.ACCNO=sc.ACCNO
AND        acm.TransactionMonth = sc.TransactionMonth

---Target Flag
LEFT JOIN apstempdb.dbo.FO_DormancyInactivityWithAllPopulation tg
ON         acm.ACCNO=tg.ACCNO
AND        acm.TransactionMonth = tg.TransactionMonth
WHERE      acm.TransactionMonth = @scoringmonth 


SELECT TOP 100*
FROM     warehouseuserdb.dbo.FO_Attrition_Scoring_New_Data_Feb2023

SELECT COUNT(DISTINCT ACCNO),TransactionMonth
FROM      warehouseuserdb.dbo.FO_Attrition_Scoring_New_Data_Feb2023
GROUP BY TransactionMonth

--New Scored February 2023 data
SELECT Binned_Probability, COUNT(*) Nof_Customers
FROM   warehouseuserdb.dbo.FO_Attrition_XGBoost_Model_Scored_Feb2023
GROUP BY Binned_Probability
ORDER BY 1 ASC

----Scored  Validation Data 01/2022-06/2022 
--SELECT TransactionMonth ,Binned_Probability,COUNT(*) Nof_Customers
--FROM   warehouseuserdb.dbo.FO_Attrition_XGBoost_Model_Scored_Validation_Data_Final
--GROUP BY TransactionMonth ,Binned_Probability
--ORDER BY 1,2 ASC

----Scored Train+Test Data  07/2021-12/2021
--SELECT TransactionMonth ,Binned_Probability,COUNT(*) Nof_Customers
--FROM   warehouseuserdb.dbo.FO_Attrition_XGBoost_Model_Scored_9M
--WHERE  TransactionMonth BETWEEN '2021-07-31' AND '2021-12-31'
--GROUP BY TransactionMonth ,Binned_Probability
--ORDER BY 1,2 ASC


