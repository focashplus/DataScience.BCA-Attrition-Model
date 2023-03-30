

--------------Inbound/Outbound/Post Office Transactions

DROP TABLE	IF EXISTS apstempdb.dbo.FO_ActiveCustomersWithPayments
SELECT  acm.ACCNO,acm.TransactionMonth,acm.Nof_All_Transactions_Payments,

	        SUM(CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.DBCRFlag = 'CR' THEN 1 ELSE 0 END) Credits, 
			(CAST(NULLIF(SUM(CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.DBCRFlag = 'DB' THEN 1 ELSE 0 END),0) AS FLOAT)/ CAST(acm.Nof_All_Transactions_Payments AS FLOAT)) AS Rate_of_Debit_Transactions,
		
		   ---Number of the Outbound_Payments
	
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND vwtn.TXNCODE = 28 THEN 1 ELSE 0 END)   AS Last_2M_PostOffice_Loads														   
INTO     apstempdb.dbo.FO_ActiveCustomersWithPayments
FROM     apstempdb.dbo.FO_Attrition_Feature_Base acm
LEFT    JOIN  warehousenomad.dbo.vwTransactionLiteN vwtn (NOLOCK) -- consolidated view of all monetary activity on an account (payments, fees, card transactions, manual adjustments)
ON      acm.ACCNO= vwtn.ACCNO
LEFT    JOIN	WarehouseNomad.dbo.vwFeeTypesN fee
ON			vwtn.FEEID = fee.ReasonCode
WHERE		(
			vwtn.Source = 'FinAdv' -- transactions
			OR (vwtn.Source = 'Adjust' AND vwtn.FEEID = 'BP-Debit') -- outbound payments
			OR fee.FeeType = 'AccountLoad' -- inbound payments and post office loads
			) 
AND			vwtn.ctxdatelocal >= DATEADD(MONTH	,-5,acm.TransactionMonth)
AND			vwtn.ctxdatelocal <= acm.TransactionMonth
--AND      acm.ACCNO IN ('80000100100057','80000100100122','80000100100161','80000100105836')
GROUP BY acm.ACCNO,acm.TransactionMonth,acm.Nof_All_Transactions_Payments
--(935250 rows affected)




-------------------Debit Card Transactions and Cash Transaction--------------------------------------
-----------------------------------------------------------------------------------------------------
DROP TABLE	IF EXISTS apstempdb.dbo.FO_ActiveCustomersWith_DebitCard_Transactions

SELECT   acm.ACCNO,acm.TransactionMonth,

----Debit Card Amounts
			  
            AVG( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
												   vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT  ELSE NULL END)  AS Avg_Last_DebitCard_Transactions_Amt,
---------Rate Calculations 
   
            CAST(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.TXNCODE= 0 THEN 1  ELSE 0 END) AS FLOAT) /
			CAST(NULLIF(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.TXNCODE IN (0,1,9) THEN 1  ELSE 0 END),0)AS FLOAT) AS Rate_Last_DB_Cash_Transaction 


INTO    apstempdb.dbo.FO_ActiveCustomersWith_DebitCard_Transactions
FROM    apstempdb.dbo.FO_Attrition_Feature_Base acm
LEFT    JOIN  warehousenomad.dbo.vwTransactionLiteN vwtn (NOLOCK) -- consolidated view of all monetary activity on an account (payments, fees, card transactions, manual adjustments)
ON      acm.ACCNO= vwtn.ACCNO
WHERE	vwtn.Source = 'FinAdv' -- transactions
AND		vwtn.ctxdatelocal >= DATEADD(MONTH	,-5,acm.TransactionMonth)
AND		vwtn.ctxdatelocal <= acm.TransactionMonth
--AND   acm.ACCNO IN ('80000100100057','80000100100122','80000100100161','80000100105836')
GROUP BY acm.ACCNO,acm.TransactionMonth,acm.Nof_All_Transactions_Payments
--ORDER BY 1,2 asc


