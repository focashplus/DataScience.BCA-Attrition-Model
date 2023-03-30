
------Combining the Ready Tables
------------------------------------------------------

DROP TABLE	IF EXISTS warehouseuserdb.dbo.FO_AT_Model_Final_Table

SELECT acm.*, 
--Targets
      ISNULL(dp.Target3M_Dormancy,0) AS Target3M_Dormancy,
	  ISNULL(dp.Target6M_Dormancy,0) AS Target6M_Dormancy,
	  ISNULL(sia.Inactivation_In3M,0) AS Inactivation_In3M,
	  ISNULL(sia.Inactivation_In6M,0) AS Inactivation_In6M,
---Payments /Transactions
      Rate_of_Debit_Transactions,
      Rate_of_Credit_Transactions,
      Debits,
      Credits,
      Total_BillAmt,
      Last_2M_Outbound_Payments,
      Last_3M_Outbound_Payments,
      Last_6M_Outbound_Payments,
      Last_Outbound_Payments_Amt,
      Last_2M_Outbound_Payments_Amt,
      Last_3M_Outbound_Payments_Amt,
      Last_6M_Outbound_Payments_Amt,
      Avg_Last_Outbound_Payments_Amt,
      Avg_Last_2M_Outbound_Payments_Amt,
      Avg_Last_3M_Outbound_Payments_Amt,
      Avg_Last_6M_Outbound_Payments_Amt,
      Last_Inbound_Payments,
      Last_2M_Inbound_Payments,
      Last_3M_Inbound_Payments,
      Last_6M_Inbound_Payments,
      Last_2M_Inbound_Payments_Amt,
      Last_3M_Inbound_Payments_Amt,
      Last_6M_Inbound_Payments_Amt,
      Avg_Last_Inbound_Payments,
      Avg_Last_2M_Inbound_Payments,
      Avg_Last_3M_Inbound_Payments,
      Avg_Last_6M_Inbound_Payments,
      Last_PostOffice_Loads,
      Last_2M_PostOffice_Loads,
      Last_3M_PostOffice_Loads,
      Last_6M_PostOffice_Loads,
      Last_PostOffice_Loads_Amt,
      Last_2M_PostOffice_Loads_Amt,
      Last_3M_PostOffice_Loads_Amt,
      Last_6M_PostOffice_Loads_Amt,
      Avg_Last_PostOffice_Loads_Amt,
      Avg_Last_2M_PostOffice_Loads_Amt,
      Avg_Last_3M_PostOffice_Loads_Amt,
      Avg_Last_6M_PostOffice_Loads_Amt,

		-- Fee
		Nof_Total_Fee,
		Total_Fee_Amt,
		Net_Nof_Total_Fee,
		Net_Total_Fee_Amt,
		Last_6M_Nof_FIS_Charged_Fees,
		FIS_Charged_Fees_Amt,
		Last_6M_FIS_Charged_Fees_Amt,
		Nof_CashPlus_Charged_Fees,
		Last_6M_CashPlus_Charged_Fees,
		Last_6M_CashPlus_Charged_Fees_Amt,
		Nof_FIS_Refunded_Fees,
		Last_6M_Nof_FIS_Refunded_Fees,
		FIS_Refunded_Fees_Amt,
		Last_6M_FIS_Refunded_Fees_Amt,
		Nof_CashPlus_Refunded_Fees,
		Last_6M_Nof_CashPlus_Refunded_Fees,
		CashPlus_Refunded_Fees_Amt,

		---Debit Card
		Last_DebitCard_Transactions,
		Last_2M_DebitCard_Transactions,
		Last_3M_DebitCard_Transactions,
		Last_6M_DebitCard_Transactions,

		Rate_DebitCard_Transactions_M_3M,
		Rate_DebitCard_Transactions_M_6M,
		Rate_DebitCard_Transactions_3M_6M,

		Last_DebitCard_Transactions_Amt,
		Last_2M_DebitCard_Transactions_Amt,
		Last_3M_DebitCard_Transactions_Amt,
		Last_6M_DebitCard_Transactions_Amt,
		Rate_DebitCard_Transactions_Amt_M_3M,
		Rate_DebitCard_Transactions_Amt_M_6M,
		Rate_DebitCard_Transactions_Amt_3M_6M,
		Avg_Last_DebitCard_Transactions_Amt,
		Avg_Last_2M_DebitCard_Transactions_Amt,
		Avg_Last_3M_DebitCard_Transactions_Amt,
		Avg_Last_6M_DebitCard_Transactions_Amt,
		Last_DebitCard_Cash_Transactions,
		Last_2M_DebitCard_Cash_Transactions,
		Last_3M_DebitCard_Cash_Transactions,
		Rate_DebitCard_Cash_Transactions_M_3M,
		Rate_DebitCard_Cash_Transactions_M_6M,
		Rate_DebitCard_Cash_Transactions_3M_6M,
		Last_DebitCard_Cash_Transactions_Amt,
		Last_2M_DebitCard_Cash_Transactions_Amt,
		Last_3M_DebitCard_Cash_Transactions_Amt,
		Last_6M_DebitCard_Cash_Transactions_Amt,
		Rate_DebitCard_Cash_Transactions_Amt_M_3M,
		Rate_DebitCard_Cash_Transactions_Amt_M_6M,
		Rate_DebitCard_Cash_Transactions_Amt_3M_6M,
		Avg_Last_DebitCard_Cash_Transactions_Amt,
		Avg_Last_2M_DebitCard_Cash_Transactions_Amt,
		Avg_Last_3M_DebitCard_Cash_Transactions_Amt,
		Avg_Last_6M_DebitCard_Cash_Transactions_Amt,
		Rate_Last_DB_Cash_Transaction ,
		Rate_Last_2M_DB_Cash_Transaction,
		Rate_Last_3M_DB_Cash_Transaction,
		Rate_Last_6M_DB_Cash_Transaction,
		Rate_Last_DB_Cash_Transaction_Amt,
		Rate_Last_2M_DB_Cash_Transaction_Amt
		Rate_Last_3M_DB_Cash_Transaction_Amt,
		Rate_Last_6M_DB_Cash_Transaction_Amt,
		Last_DebitCard_Funds_Transactions,
		Last_2M_DebitCard_Funds_Transactions,
		Last_3M_DebitCard_Funds_Transactions,
		Last_6M_DebitCard_Funds_Transactions,
		Last_DebitCard_Funds_Transactions_Amt,
		Last_2M_DebitCard_Funds_Transactions_Amt,
		Last_3M_DebitCard_Funds_Transactions_Amt,
		Last_6M_DebitCard_Funds_Transactions_Amt,
		Rate_DebitCard_Fund_Transactions_Amt_M_3M,
		Rate_DebitCard_Fund_Transactions_Amt_M_6M,
		Rate_DebitCard_Fund_Transactions_Amt_3M_6M,
		Avg_Last_DebitCard_Funds_Transactions_Amt,
		Avg_Last_2M_DebitCard_Funds_Transactions_Amt,
		Avg_Last_3M_DebitCard_Funds_Transactions_Amt,
		Avg_Last_6M_DebitCard_Funds_Transactions_Amt,

		--Inbound Calls					
		Last_M_Inb_Calls				,
		Last_2M_Inb_Calls				,
		Last_3M_Inb_Calls				,
		Last_6M_Inb_Calls				,
		Last_M_DissatisfiedCalls		,
		Last_2M_Dissatisfied_Calls		,
		Last_3M_Dissatisfied_Calls		,
		Last_6M_Dissatisfied_Calls		,
		Last_M_WaitTime_incAbandon		,
		Last_2M_WaitTime_incAbandon		,
		Last_3M_WaitTime_incAbandon		,
		Last_6M_WaitTime_incAbandon		,
		Avg_Last_M_WaitTime_incAbandon	,
		Avg_Last_2M_WaitTime_incAbandon	,
		Avg_Last_3M_WaitTime_incAbandon	,
		Avg_Last_6M_WaitTime_incAbandon	,

		---Revenue 
		Last_Month_Revenue_Posting,
		Last_2M_Nof_Revenue_Posting_Months,
		Last_3M_Nof_Revenue_Posting_Months,
		Last_6M_Nof_Revenue_Posting_Months,
		Last_Total_Revenue,
		Last_2M_Total_Revenue,
		Last_3M_Total_Revenue,
		Last_6M_Total_Revenue,
		Avg_Last_Posted_Total_Revenue,
		Avg_Last_2M_Posted_Total_Revenue,
		Avg_Last_3M_Posted_Total_Revenue,
		Avg_Last_6M_Posted_Total_Revenue,
		Last_NormalisedRevenue,
		Last_2M_NormalisedRevenue,
		Last_3M_NormalisedRevenue,
		Last_6M_NormalisedRevenue,
		Rate_NormalisedRevenue_M_3M,
		Rate_NormalisedRevenue_M_6M,
		Rate_NormalisedRevenue_3M_6M,
		Avg_Last_Posted_NormalisedRevenue,
		Avg_Last_2M_Posted_NormalisedRevenue,
		Avg_Last_3M_Posted_NormalisedRevenue,
		Avg_Last_6M_Posted_NormalisedRevenue,
		Min_Revenue_Posting_Month,
		MonthsBetween_Transaction_MinRevenueM,
		Avg_Last_2M_NormalisedRevenue,
		Avg_Last_3M_NormalisedRevenue,
		Avg_Last_6M_NormalisedRevenue,
		Z_Value_Avg_Last_NormalisedRevenue,
		Z_Value_Avg_Last_2M_NormalisedRevenue,
		Z_Value_Avg_Last_3M_NormalisedRevenue,
		Z_Value_Avg_Last_6M_NormalisedRevenue,
		MinMaxStd_Avg_Last_NormalisedRevenue,
		MinMaxStd_Avg_Last_2M_NormalisedRevenue,
		MinMaxStd_Avg_Last_3M_NormalisedRevenue,

	---Online Banking
		Total_Online_Banking_Interaction,
		Nof_Successful_Login,
		Nof_Unsuccessful_Login,
		Rate_of_Successful_Login,
		Connection_Not_Trusted_Device,
		Connection_Android_Device,
		Connection_iOS_Device,
		Rate_of_Not_Trusted_Login,
		Rate_of_Android_Login,
		Rate_of_iOS_Login,
		Nof_Logins_by_Website,
		Nof_Logins_by_MobileApp,
		Nof_Logins_by_UnknownSource,
		Nof_Logins_by_OpenBankingWeb,
		Rate_of_Logins_by_Website,
		Rate_of_Logins_by_MobileX,
		Rate_of_Logins_by_UnknownSource,
		Rate_of_Logins_by_OpenBankingWeb,
		--------------
		onb2.Last_Total_Online_Banking_Interaction,
		onb2.Last_2M_Total_Online_Banking_Interaction,
		onb2.Last_3M_Total_Online_Banking_Interaction,
		onb2.Last_6M_Total_Online_Banking_Interaction,
		onb2.Rate_Total_Online_Banking_Interaction_M_3M,
		onb2.Rate_Total_Online_Banking_Interaction_M_6M,
		onb2.Rate_Total_Online_Banking_Interaction_3M_6M,
		onb2.Last_Nof_Successful_Login,
		onb2.Last_2M_Nof_Successful_Login,
		onb2.Last_3M_Nof_Successful_Login,
		onb2.Last_6M_Nof_Successful_Login,
		onb2.Rate_Nof_Successful_Login_M_3M,
		onb2.Rate_Nof_Successful_Login_M_6M,
		onb2.Rate_Nof_Successful_Login_3M_6M,

		onb2.Last_Nof_Unsuccessful_Login,
		onb2.Last_2M_Nof_Unsuccessful_Login, 
		onb2.Last_3M_Nof_Unsuccessful_Login,
		onb2.Last_6M_Nof_Unsuccessful_Login,
		onb2.Rate_Nof_Unsuccessful_Login_M_3M,
		onb2.Rate_Nof_Unsuccessful_Login_M_6M,
		onb2.Rate_Nof_Unsuccessful_Login_3M_6M,

		------------------
		onb3.Avg_Last_2M_Total_Online_Banking_Interaction,
		onb3.Avg_Last_3M_Total_Online_Banking_Interaction,
		onb3.Avg_Last_6M_Total_Online_Banking_Interaction,
		onb3.Avg_Last_2M_Nof_Successful_Login,
		onb3.Avg_Last_3M_Nof_Successful_Login,
		onb3.Avg_Last_6M_Nof_Successful_Login,
		onb3.Avg_Last_2M_Nof_Unsuccessful_Login,
		onb3.Avg_Last_3M_Nof_Unsuccessful_Login,
		onb3.Avg_Last_6M_Nof_Unsuccessful_Login,
		--------------------
		onb4.Z_Value_Last_Total_Online_Banking_Int,
		onb4.Z_Value_Avg_Last_2M_Total_Online_Banking_Int,
		onb4.Z_Value_Avg_Last_3M_Total_Online_Banking_Int,
		onb4.Z_Value_Avg_Last_6M_Total_Online_Banking_Int,

		onb4.Z_Value_Last_Nof_Successful_Login,
		onb4.Z_Value_Avg_Last_2M_Nof_Successful_Login,
		onb4.Z_Value_Avg_Last_3M_Nof_Successful_Login,
		onb4.Z_Value_Avg_Last_6M_Nof_Successful_Login,

		onb4.Z_Value_Last_Nof_Unsuccessful_Login,
		onb4.Z_Value_Avg_Last_2M_Nof_Unsuccessful_Login,
		onb4.Z_Value_Avg_Last_3M_Nof_Unsuccessful_Login,
		onb4.Z_Value_Avg_Last_6M_Nof_Unsuccessful_Login,

		----------PaymentFileRecords

		pfr.Last_Month_Total_PaymentFileRecords,
		pfr.Last_2M_Total_PaymentFileRecords,
		pfr.Last_3M_Total_PaymentFileRecords,
		pfr.Last_6M_Total_PaymentFileRecords,
		pfr.Last_Month_Total_PaymentHeld,
		pfr.Last_2M_Total_PaymentHeld,
		pfr.Last_3M_Total_PaymentHeld,
		pfr.Last_6M_Total_PaymentHeld,
		pfr.Last_Month_Total_PaymentApplied,
		pfr.Last_2M_Total_PaymentApplied,
		pfr.Last_3M_Total_PaymentApplied,
		pfr.Last_6M_Total_PaymentApplied,
		pfr.Avg_Last_2M_Total_PaymentFileRecords,
		pfr.Avg_Last_3M_Total_PaymentFileRecords,
		pfr.Avg_Last_6M_Total_PaymentFileRecords,
		pfr.Avg_Last_2M_Total_PaymentHeld,
		pfr.Avg_Last_3M_Total_PaymentHeld,
		pfr.Avg_Last_6M_Total_PaymentHeld,
		pfr.Avg_Last_2M_Total_PaymentApplied,
		pfr.Avg_Last_3M_Total_PaymentApplied,
		pfr.Avg_Last_6M_Total_PaymentApplied,
		pfr.Rate_Total_PaymentFileRecords_M_3M,
		pfr.Rate_Total_PaymentFileRecords_M_6M,
		pfr.Rate_Total_PaymentFileRecords_3M_6M,
		pfr.Rate_Total_PaymentHeld_M_3M,
		pfr.Rate_Total_PaymentHeld_M_6M,
		pfr.Rate_Total_PaymentHeld_3M_6M,
		pfr.Rate_Total_PaymentApplied_M_3M,
		pfr.Rate_Total_PaymentApplied_M_6M,
		pfr.Rate_Total_PaymentApplied_3M_6M,
		pfr.Last_Month_Total_PFR_Amt,
		pfr.Last_2M_Total_PFR_Amt,
		pfr.Last_3M_Total_PFR_Amt,
		pfr.Last_6M_Total_PFR_Amt,
		pfr.Last_Month_Total_PaymentHeld_Amt,
		pfr.Last_2M_Total_PaymentHeld_Amt,
		pfr.Last_3M_Total_PaymentHeld_Amt,
		pfr.Last_6M_Total_PaymentHeld_Amt,
		pfr.Last_Month_Total_PaymentApplied_Amt,
		pfr.Last_2M_Total_PaymentApplied_Amt,
		pfr.Last_3M_Total_PaymentApplied_Amt,
		pfr.Last_6M_Total_PaymentApplied_Amt,
		pfr.Avg_Last_Month_Total_PFR_Amt,
		pfr.Avg_Last_2M_Total_PFR_Amt,
		pfr.Avg_Last_3M_Total_PFR_Amt,
		pfr.Avg_Last_6M_Total_PFR_Amt,
		pfr.Avg_Last_Month_Total_PaymentApplied_Amt,
		pfr.Avg_Last_2M_Total_PaymentApplied_Amt,
		pfr.Avg_Last_3M_Total_PaymentApplied_Amt,
		pfr.Avg_Last_6M_Total_PaymentApplied_Amt,
		pfr.Avg_Last_Month_Total_PaymentHeld_Amt,
		pfr.Avg_Last_2M_Total_PaymentHeld_Amt,
		pfr.Avg_Last_3M_Total_PaymentHeld_Amt,
		pfr.Avg_Last_6M_Total_PaymentHeld_Amt,
		pfr.Rate_Total_PFR_Amt_M_3M,
		pfr.Rate_Total_PFR_Amt_M_6M,
		pfr.Rate_Total_PFR_Amt_3M_6M,
		pfr.Rate_Total_PaymentHeld_Amt_M_3M,
		pfr.Rate_Total_PaymentHeld_Amt_M_6M,
		pfr.Rate_Total_PaymentHeld_Amt_3M_6M,
		pfr.Rate_Total_PaymentApplied_Amt_M_3M,
		pfr.Rate_Total_PaymentApplied_Amt_M_6M,
		pfr.Rate_Total_PaymentApplied_Amt_3M_6M,
		pfr.Delta_Avg_Total_PaymentFileRecords_Chg_M_3M,
		pfr.Delta_Avg_Total_PaymentFileRecords_Chg_M_6M,
		pfr.Delta_Avg_Total_PaymentFileRecords_Chg_3M_6M,
		pfr.Delta_Avg_Total_PaymentHeld_Chg_M_3M,
		pfr.Delta_Avg_Total_PaymentHeld_Chg_M_6M, 
		pfr.Delta_Avg_Total_PaymentHeld_Chg_3M_6M,
		pfr.Delta_Avg_Total_PaymentApplied_Chg_M_3M,
		pfr.Delta_Avg_Total_PaymentApplied_Chg_M_6M,
		pfr.Delta_Avg_Total_PaymentApplied_Chg_3M_6M,
		pfr.Delta_Avg_Total_PFR_Amt_Chg_M_3M,
		pfr.Delta_Avg_Total_PFR_Amt_Chg_M_6M,
		pfr.Delta_Avg_Total_PFR_Amt_Chg_3M_6M,
		pfr.Delta_Avg_Total_PaymentApplied_Amt_Chg_M_3M,
		pfr.Delta_Avg_Total_PaymentApplied_Amt_Chg_M_6M,
		pfr.Delta_Avg_Total_PaymentApplied_Amt_Chg_3M_6M,
		pfr.Delta_Avg_Total_PaymentHeld_Amt_Chg_M_3M,
		pfr.Delta_Avg_Total_PaymentHeld_Amt_Chg_M_6M,
		pfr.Delta_Avg_Total_PaymentHeld_Amt_Chg_3M_6M,

        ------Overdraft
		
		ovd.Max_Overdraft_Limit_in_Month ,
		ovd.Avg_Monthly_Used_Overdraft_Amt ,
		ovd.Rate_of_Avg_Overdraft_Amt_in_Month ,
		ovd.Nof_Balance_Change ,
		ovd.Nof_Balance_Chg_InOverdraft ,
		ovd.Rate_of_Avg_Overdraft_Count_in_Month ,
		ovd.Avg_Monthly_FINAMT_Cleare_Balance ,
		ovd.Avg_Last_2M_FINAMT_Cleare_Balance ,
		ovd.Avg_Last_3M_FINAMT_Cleare_Balance ,
		ovd.Avg_Last_6M_FINAMT_Cleare_Balance ,
		ovd.Last_Month_Nof_Balance_Change ,
		ovd.Tot_Nof_Balance_Change_in_2M ,
		ovd.Tot_Nof_Balance_Change_in_3M ,
		ovd.Tot_Nof_Balance_Change_in_6M ,
		ovd.Avg_Last_2M_Nof_Balance_Change ,
		ovd.Avg_Last_3M_Nof_Balance_Change ,
		ovd.Avg_Last_6M_Nof_Balance_Change ,
		ovd.Rate_Tot_Nof_Balance_Change_M_3M ,
		ovd.Rate_Tot_Nof_Balance_Change_M_6M ,
		ovd.Rate_Tot_Nof_Balance_Change_3M_6M ,
		ovd.Last_Month_Nof_Balance_Chg_InOverdraft ,
		ovd.Last_2M_Nof_Balance_Chg_InOverdraft ,
		ovd.Last_3M_Nof_Balance_Chg_InOverdraft ,
		ovd.Last_6M_Nof_Balance_Chg_InOverdraft ,
		ovd.Avg_Last_2M_Nof_Balance_Chg_InOverdraft ,
		ovd.Avg_Last_3M_Nof_Balance_Chg_InOverdraft ,
		ovd.Avg_Last_6M_Nof_Balance_Chg_InOverdraft ,
		ovd.Rate_Nof_Balance_Chg_InOverdraft_M_3M ,
		ovd.Rate_Nof_Balance_Chg_InOverdraft_M_6M ,
		ovd.Rate_Nof_Balance_Chg_InOverdraft_3M_6M ,
		ovd.Delta_Avg_FINAMT_Cleare_Balance_Chg_M_3M ,
		ovd.Delta_Avg_FINAMT_Cleare_Balance_Chg_M_6M ,
		ovd.Delta_Avg_FINAMT_Cleare_Balance_Chg_3M_6M ,
		ovd.Delta_Avg_Nof_Balance_Chg_M_3M ,
		ovd.Delta_Avg_Nof_Balance_Chg_M_6M ,
		ovd.Delta_Avg_Nof_Balance_Chg_3M_6M ,
		ovd.Delta_Avg_Nof_Balance_Chg_InOverdraft_M_3M ,
		ovd.Delta_Avg_Nof_Balance_Chg_InOverdraft_M_6M ,
		ovd.Delta_Avg_Nof_Balance_Chg_InOverdraft_3M_6M,

		-----Scores
		RNILF04,
		TEILF04,
		RVILF04

INTO    warehouseuserdb.dbo.FO_AT_Model_Final_Table
FROM    warehouseuserdb.dbo.FO_AttritionModel_ActiveCustomersByMonth AS acm
-- Target Dormancy
LEFT  JOIN  apstempdb.dbo.FO_DormancyInactivityWithAllPopulation AS dp
ON    acm.ACCNO= dp.ACCNO
AND   acm.TransactionMonth=dp.TransactionMonth

-- Target Inactivity
LEFT JOIN  apstempdb.dbo.FO_StatusInactivityWithAllPopulation sia
ON    acm.ACCNO= sia.ACCNO
AND   acm.TransactionMonth=sia.TransactionMonth

--- Outbound/Inbound Payments
LEFT JOIN  apstempdb.dbo.FO_ActiveCustomersWithPayments acp
ON     acm.ACCNO= acp.ACCNO
AND    acm.TransactionMonth =acp.TransactionMonth

--  Fee
LEFT JOIN apstempdb.dbo.FO_ActiveCustomersWithFee  acf
ON     acm.ACCNO= acf.ACCNO
AND    acm.TransactionMonth=acf.TransactionMonth

--Debit Card Transactions
LEFT JOIN apstempdb.dbo.FO_ActiveCustomersWith_DebitCard_Transactions  acd
ON     acm.ACCNO= acd.ACCNO
AND    acm.TransactionMonth=acd.TransactionMonth

--Inbound Calls 
LEFT JOIN apstempdb.dbo.FO_Customer_Inbound_Calls cl
ON       acm.ACCNO = cl.ACCNO
AND      acm.TransactionMonth = cl.TransactionMonth

--Revenue

LEFT JOIN apstempdb.dbo.FO_ActiveCustomersWith_Revenue rev
ON        acm.ACCNO = rev.ACCNO
AND       acm.TransactionMonth = rev.TransactionMonth

--Online Banking

LEFT JOIN apstempdb.dbo.FO_Online_Banking_Part1 onb1
ON        acm.ACCNO = onb1.ACCNO
AND       acm.TransactionMonth = onb1.Online_Banking_Login_Month

LEFT JOIN apstempdb.dbo.FO_Online_Banking_Part2 onb2
ON        acm.ACCNO = onb2.ACCNO
AND       acm.TransactionMonth = onb2.TransactionMonth

LEFT JOIN apstempdb.dbo.FO_Online_Banking_Averages onb3
ON        acm.ACCNO = onb3.ACCNO
AND       acm.TransactionMonth = onb3.TransactionMonth

LEFT JOIN apstempdb.dbo.FO_Online_Banking_With_ZValues onb4
ON        acm.ACCNO = onb4.ACCNO
AND       acm.TransactionMonth = onb4.TransactionMonth

---PaymentFileRecords

LEFT JOIN apstempdb.dbo.FO_ActiveCustomersWith_PaymentFileRecords pfr
ON        acm.ACCNO = pfr.ACCNO
AND       acm.TransactionMonth = pfr.TransactionMonth

---Overdraft

LEFT JOIN  warehouseuserdb.dbo.FO_Overdraft ovd
ON        acm.ACCNO = ovd.ACCNO
AND       acm.TransactionMonth = ovd.TransactionMonth

---Scores
LEFT JOIN apstempdb.dbo.FO_Attrition_Customer_Scores cs
ON        acm.ACCNO = cs.ACCNO
AND       acm.TransactionMonth = cs.TransactionMonth



---------------------------------------------------------------------------------------------

---Selecting Last 6 Months of the 2021 as a Training Period. 2022 will be used as Validation data


DROP TABLE	IF EXISTS warehouseuserdb.dbo.FO_AT_Model_Training_Table
SELECT *
INTO   warehouseuserdb.dbo.FO_AT_Model_Training_Table
FROM   warehouseuserdb.dbo.FO_AT_Model_Final_Table
WHERE  TransactionMonth BETWEEN '2021-07-31' AND '2021-12-31'


DROP TABLE	IF EXISTS warehouseuserdb.dbo.FO_AT_Model_Validation_Table
SELECT *
INTO   warehouseuserdb.dbo.FO_AT_Model_Validation_Table
FROM   warehouseuserdb.dbo.FO_AT_Model_Final_Table
WHERE  TransactionMonth BETWEEN '2022-01-01' AND '2022-06-30'


-------Test
SELECT TransactionMonth,COUNT(*) Nof_Customers,
       SUM(Target3M_Dormancy) AS SUM_Target3M_Dormancy,
	   SUM(Target3M_Dormancy) / CAST(COUNT(*) AS FLOAT) AS Rate_of_Target3M_Dormancy,
       SUM(Target6M_Dormancy) AS SUM_Target6M_Dormancy,
	   SUM(Target6M_Dormancy) / CAST(COUNT(*) AS FLOAT)  AS Rate_of_Target6M_Dormancy
FROM   warehouseuserdb.dbo.FO_AT_Model_Final_Table
GROUP  BY TransactionMonth
ORDER  BY 1 ASC


SELECT TransactionMonth,COUNT(*) Nof_Customers,
       SUM(Target3M_Dormancy) AS SUM_Target3M_Dormancy,
	   SUM(Target3M_Dormancy) / CAST(COUNT(*) AS FLOAT) AS Rate_of_Target3M_Dormancy,
       SUM(Target6M_Dormancy) AS SUM_Target6M_Dormancy,
	   SUM(Target6M_Dormancy) / CAST(COUNT(*) AS FLOAT)  AS Rate_of_Target6M_Dormancy
FROM   warehouseuserdb.dbo.FO_AT_Model_Training_Table
GROUP  BY TransactionMonth
ORDER  BY 1 ASC

SELECT TransactionMonth,COUNT(*) Nof_Customers,
       SUM(Target3M_Dormancy) AS SUM_Target3M_Dormancy,
	   SUM(Target3M_Dormancy) / CAST(COUNT(*) AS FLOAT) AS Rate_of_Target3M_Dormancy,
       SUM(Target6M_Dormancy) AS SUM_Target6M_Dormancy,
	   SUM(Target6M_Dormancy) / CAST(COUNT(*) AS FLOAT)  AS Rate_of_Target6M_Dormancy
FROM     warehouseuserdb.dbo.FO_AT_Model_Validation_Table
GROUP  BY TransactionMonth
ORDER  BY 1 ASC


SELECT COUNT(*), Target3M_Dormancy
FROM warehouseuserdb.dbo.FO_AT_Model_Validation_Table
group BY Target3M_Dormancy



SELECT TransactionMonth,COUNT(*),SUM(Target3M_Dormancy)
FROM   warehouseuserdb.dbo.FO_AT_Model_Final_Table
GROUP BY TransactionMonth
ORDER BY 1 asc