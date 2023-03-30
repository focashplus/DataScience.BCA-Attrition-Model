

--------------Inbound/Outbound/Post Office Transactions

DROP TABLE	IF EXISTS apstempdb.dbo.FO_ActiveCustomersWithPayments

SELECT  acm.ACCNO,acm.TransactionMonth,acm.Nof_All_Transactions_Payments,

            SUM(CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.DBCRFlag = 'DB' THEN 1 ELSE 0 END) Debits,
	        SUM(CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.DBCRFlag = 'CR' THEN 1 ELSE 0 END) Credits, 

			(CAST(NULLIF(SUM(CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.DBCRFlag = 'DB' THEN 1 ELSE 0 END),0) AS FLOAT)/ CAST(acm.Nof_All_Transactions_Payments AS FLOAT)) AS Rate_of_Debit_Transactions,
			(CAST(NULLIF(SUM(CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.DBCRFlag = 'CR' THEN 1 ELSE 0 END),0) AS FLOAT)/ CAST(acm.Nof_All_Transactions_Payments AS FLOAT)) AS Rate_of_Credit_Transactions,

		    SUM(CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) THEN vwtn.BILLAMT ELSE 0 END) Total_BillAmt,

	        ---Number of the Outbound_Payments
			-----------------------------------------------------------------------------------------------------------------------
			SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                  (vwtn.Source  = 'Adjust' AND vwtn.FEEID = 'BP-Debit') THEN 1 ELSE 0 END) AS Last_Outbound_Payments,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
			                  (vwtn.Source  = 'Adjust' AND vwtn.FEEID = 'BP-Debit') THEN 1 ELSE 0 END)  AS Last_2M_Outbound_Payments,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND 
			                  (vwtn.Source  = 'Adjust' AND vwtn.FEEID = 'BP-Debit') THEN 1 ELSE 0 END) AS Last_3M_Outbound_Payments,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
						      (vwtn.SOURCE  = 'Adjust' AND vwtn.FEEID = 'BP-Debit') THEN 1 ELSE 0 END)  AS Last_6M_Outbound_Payments,
            
			SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
							 (vwtn.Source  = 'Adjust' AND vwtn.FEEID = 'BP-Debit') THEN vwtn.BILLAMT   ELSE 0 END)    AS Last_Outbound_Payments_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
							 (vwtn.Source  = 'Adjust' AND vwtn.FEEID = 'BP-Debit') THEN  vwtn.BILLAMT  ELSE 0 END)   AS Last_2M_Outbound_Payments_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND 
							 (vwtn.Source  = 'Adjust' AND vwtn.FEEID = 'BP-Debit') THEN  vwtn.BILLAMT  ELSE 0 END) AS Last_3M_Outbound_Payments_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
							 (vwtn.SOURCE  = 'Adjust' AND vwtn.FEEID = 'BP-Debit') THEN  vwtn.BILLAMT  ELSE 0 END)  AS  Last_6M_Outbound_Payments_Amt,

            AVG( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
								(vwtn.Source  = 'Adjust' AND vwtn.FEEID = 'BP-Debit') THEN vwtn.BILLAMT  ELSE NULL END) AS Avg_Last_Outbound_Payments_Amt,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
								(vwtn.Source  = 'Adjust' AND vwtn.FEEID = 'BP-Debit') THEN  vwtn.BILLAMT ELSE NULL END) AS Avg_Last_2M_Outbound_Payments_Amt,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND 
								(vwtn.Source  = 'Adjust' AND vwtn.FEEID = 'BP-Debit') THEN  vwtn.BILLAMT ELSE NULL END) AS Avg_Last_3M_Outbound_Payments_Amt,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
			                    (vwtn.SOURCE  = 'Adjust' AND vwtn.FEEID = 'BP-Debit') THEN  vwtn.BILLAMT ELSE NULL END) AS Avg_Last_6M_Outbound_Payments_Amt,    

			---Number of the Inbound_Payments
		    --------------------------------------------------------------------------------------------------
		    SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                                     fee.FeeType = 'AccountLoad' THEN 1  ELSE 0 END)  AS Last_Inbound_Payments,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
			                                     fee.FeeType = 'AccountLoad'  THEN 1 ELSE 0 END)  AS Last_2M_Inbound_Payments,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND 
			                                     fee.FeeType = 'AccountLoad' THEN 1 ELSE   0 END) AS Last_3M_Inbound_Payments,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND 
			                                     fee.FeeType = 'AccountLoad'  THEN 1 ELSE  0 END) AS Last_6M_Inbound_Payments,


			SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                                  fee.FeeType = 'AccountLoad' THEN  vwtn.BILLAMT  ELSE 0 END) AS Last_Inbound_Payments_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
			                                  fee.FeeType = 'AccountLoad'  THEN  vwtn.BILLAMT ELSE 0 END) Last_2M_Inbound_Payments_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND 
			                                  fee.FeeType = 'AccountLoad' THEN  vwtn.BILLAMT  ELSE 0 END) Last_3M_Inbound_Payments_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND 
			                                  fee.FeeType = 'AccountLoad'  THEN  vwtn.BILLAMT ELSE 0 END) Last_6M_Inbound_Payments_Amt,

            AVG( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                                 fee.FeeType = 'AccountLoad' THEN  vwtn.BILLAMT  ELSE NULL END) AS Avg_Last_Inbound_Payments,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
			                                 fee.FeeType = 'AccountLoad'  THEN  vwtn.BILLAMT ELSE NULL END) Avg_Last_2M_Inbound_Payments,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND 
			                                 fee.FeeType = 'AccountLoad' THEN  vwtn.BILLAMT  ELSE NULL END) Avg_Last_3M_Inbound_Payments,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND 
			                                 fee.FeeType = 'AccountLoad'  THEN  vwtn.BILLAMT ELSE NULL END) Avg_Last_6M_Inbound_Payments,

          
		   ---Number of the Outbound_Payments
		   ---------------------------------------
		    SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
														  vwtn.TXNCODE = 28 THEN 1  ELSE 0 END)  AS Last_PostOffice_Loads,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
														  vwtn.TXNCODE = 28 THEN 1 ELSE 0 END)   AS Last_2M_PostOffice_Loads,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND 
														  vwtn.TXNCODE = 28 THEN 1 ELSE 0 END) AS Last_3M_PostOffice_Loads,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
														  vwtn.TXNCODE = 28 THEN 1 ELSE 0 END)  AS Last_6M_PostOffice_Loads,

            SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
														 vwtn.TXNCODE = 28 THEN vwtn.BILLAMT  ELSE 0 END) AS Last_PostOffice_Loads_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
														 vwtn.TXNCODE = 28 THEN vwtn.BILLAMT ELSE 0 END)  AS Last_2M_PostOffice_Loads_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND 
														 vwtn.TXNCODE = 28 THEN vwtn.BILLAMT ELSE  0 END) AS Last_3M_PostOffice_Loads_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
			                                             vwtn.TXNCODE = 28 THEN vwtn.BILLAMT ELSE  0 END) AS Last_6M_PostOffice_Loads_Amt,   

						  
            AVG( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
												   vwtn.TXNCODE = 28 THEN vwtn.BILLAMT  ELSE 0 END)  AS Avg_Last_PostOffice_Loads_Amt,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
												   vwtn.TXNCODE = 28 THEN vwtn.BILLAMT ELSE 0 END)   AS Avg_Last_2M_PostOffice_Loads_Amt,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND 
			                                       vwtn.TXNCODE = 28 THEN vwtn.BILLAMT ELSE   0 END) AS Avg_Last_3M_PostOffice_Loads_Amt,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
			                                       vwtn.TXNCODE = 28 THEN vwtn.BILLAMT ELSE  0 END)  AS Avg_Last_6M_PostOffice_Loads_Amt   												   
INTO    apstempdb.dbo.FO_ActiveCustomersWithPayments
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



------------------------------Fee Calculations
-----------------------------------------------------------


--(143048 rows affected)

DROP TABLE	IF EXISTS apstempdb.dbo.FO_ActiveCustomersWithFee

SELECT   acm.ACCNO,acm.TransactionMonth,acm.Nof_All_Transactions_Payments,
        SUM(CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) THEN 1 ELSE 0 END) Nof_Total_Fee,
		SUM(CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) THEN vwtn.BILLAMT ELSE 0 END) Total_Fee_Amt,
    ---Net Last Month
		SUM(CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) THEN 1 ELSE 0 END) - 
		SUM(CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			( (vwtn.Source = 'Fee' AND vwtn.DBCRFlag = 'CR') OR (vwtn.FEEID LIKE 'F1%' AND vwtn.DBCRFlag = 'CR')) THEN 1 ELSE 0 END)  AS Net_Nof_Total_Fee, 
     
		SUM(CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) THEN vwtn.BILLAMT ELSE 0 END) - 
		SUM(CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			( (vwtn.Source = 'Fee' AND vwtn.DBCRFlag = 'CR') OR (vwtn.FEEID LIKE 'F1%' AND vwtn.DBCRFlag = 'CR')) THEN vwtn.BILLAMT ELSE 0 END) AS Net_Total_Fee_Amt,    

---------------------------------------

           	SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                  (vwtn.Source = 'Fee' AND vwtn.DBCRFlag = 'DB') THEN 1  ELSE 0 END) AS Nof_FIS_Charged_Fees,
            
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
			                  (vwtn.Source = 'Fee' AND vwtn.DBCRFlag = 'DB') THEN 1  ELSE 0 END) AS Last_6M_Nof_FIS_Charged_Fees,

           	SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                  (vwtn.Source = 'Fee' AND vwtn.DBCRFlag = 'DB') THEN  vwtn.BILLAMT  ELSE 0 END) AS FIS_Charged_Fees_Amt,
            
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
			                  (vwtn.Source = 'Fee' AND vwtn.DBCRFlag = 'DB') THEN  vwtn.BILLAMT  ELSE 0 END) AS Last_6M_FIS_Charged_Fees_Amt,


     ------------------------------------------------------
	      	SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                  (vwtn.FEEID LIKE 'F1%' AND vwtn.DBCRFlag = 'DB') THEN 1  ELSE 0 END) AS Nof_CashPlus_Charged_Fees,
            
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
			                  (vwtn.FEEID LIKE 'F1%' AND vwtn.DBCRFlag = 'DB') THEN 1  ELSE 0 END) AS Last_6M_CashPlus_Charged_Fees,

           	SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                  (vwtn.FEEID LIKE 'F1%' AND vwtn.DBCRFlag = 'DB') THEN  vwtn.BILLAMT  ELSE 0 END) AS CashPlus_Charged_Fees_Amt,
            
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
			                  (vwtn.FEEID LIKE 'F1%' AND vwtn.DBCRFlag = 'DB') THEN  vwtn.BILLAMT  ELSE 0 END) AS Last_6M_CashPlus_Charged_Fees_Amt,
-----------------------------------------------

            SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                  (vwtn.Source = 'Fee' AND vwtn.DBCRFlag = 'CR') THEN 1  ELSE 0 END) AS Nof_FIS_Refunded_Fees,
            
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
			                  (vwtn.Source = 'Fee' AND vwtn.DBCRFlag = 'CR') THEN 1  ELSE 0 END) AS Last_6M_Nof_FIS_Refunded_Fees,

           	SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                  (vwtn.Source = 'Fee' AND vwtn.DBCRFlag = 'CR') THEN  vwtn.BILLAMT  ELSE 0 END) AS FIS_Refunded_Fees_Amt,
            
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
			                  (vwtn.Source = 'Fee' AND vwtn.DBCRFlag = 'CR') THEN  vwtn.BILLAMT  ELSE 0 END) AS Last_6M_FIS_Refunded_Fees_Amt,


     ------------------------------------------------------
	      	SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                  (vwtn.FEEID LIKE 'F1%' AND vwtn.DBCRFlag = 'CR') THEN 1  ELSE 0 END) AS Nof_CashPlus_Refunded_Fees,
            
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
			                  (vwtn.FEEID LIKE 'F1%' AND vwtn.DBCRFlag = 'CR') THEN 1  ELSE 0 END) AS Last_6M_Nof_CashPlus_Refunded_Fees,

           	SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                  (vwtn.FEEID LIKE 'F1%' AND vwtn.DBCRFlag = 'CR') THEN  vwtn.BILLAMT  ELSE 0 END) AS CashPlus_Refunded_Fees_Amt,
            
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
			                  (vwtn.FEEID LIKE 'F1%' AND vwtn.DBCRFlag = 'CR') THEN  vwtn.BILLAMT  ELSE 0 END) AS Last_6M_CashPlus_Refunded_Fees_Amt
INTO  apstempdb.dbo.FO_ActiveCustomersWithFee
FROM  apstempdb.dbo.FO_Attrition_Feature_Base acm
LEFT  JOIN warehousenomad.dbo.vwTransactionLiteN vwtn
ON    acm.ACCNO= vwtn.ACCNO
LEFT  JOIN	WarehouseNomad.dbo.vwFeeTypesN fee
ON			vwtn.FEEID = fee.ReasonCode
WHERE		(
			vwtn.Source = 'Fee' -- FIS Fees
			OR vwtn.FEEID LIKE 'F1%' -- Cashplus Fees
			) 
AND			vwtn.ctxdatelocal >= DATEADD(MONTH	,-5,acm.TransactionMonth)
AND			vwtn.ctxdatelocal <= acm.TransactionMonth
--AND      acm.ACCNO IN ('80000100450883','80000100454511','80000100438647','80000100516889')
GROUP BY acm.ACCNO,acm.TransactionMonth,acm.Nof_All_Transactions_Payments



-------------------Debit Card Transactions and Cash Transaction--------------------------------------
-----------------------------------------------------------------------------------------------------
DROP TABLE	IF EXISTS apstempdb.dbo.FO_ActiveCustomersWith_DebitCard_Transactions

SELECT   acm.ACCNO,acm.TransactionMonth,acm.Nof_All_Transactions_Payments,

---Debit Card Transactions
		    SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                                              vwtn.TXNCODE IN (0,1,9) THEN 1  ELSE 0 END)  AS Last_DebitCard_Transactions ,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
														  vwtn.TXNCODE IN (0,1,9) THEN 1 ELSE 0 END)   AS Last_2M_DebitCard_Transactions,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND 
														  vwtn.TXNCODE IN (0,1,9) THEN 1 ELSE   0 END) AS Last_3M_DebitCard_Transactions,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
														  vwtn.TXNCODE IN (0,1,9) THEN 1 ELSE  0 END)  AS Last_6M_DebitCard_Transactions,


		 
            CAST(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN 1  ELSE 0 END) AS float) /
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN 1 ELSE 0 END),0) AS float) AS Rate_DebitCard_Transactions_M_3M,
																																										  
		    CAST(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN 1  ELSE 0 END) AS float)/							  
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN 1 ELSE 0 END),0) AS FLOAT) AS Rate_DebitCard_Transactions_M_6M,
					 																																					   
		    CAST(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN 1 ELSE 0 END) AS FLOAT) /			   
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN 1 ELSE 0 END),0) AS FLOAT) AS Rate_DebitCard_Transactions_3M_6M,

----Debit Card Amounts

            SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
														 vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT  ELSE 0 END) AS Last_DebitCard_Transactions_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
														 vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT ELSE 0 END)  AS Last_2M_DebitCard_Transactions_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND 
														 vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT ELSE 0 END) AS Last_3M_DebitCard_Transactions_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
			                                             vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT ELSE 0 END) AS Last_6M_DebitCard_Transactions_Amt,   
	
		   CAST(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT  ELSE 0 END) AS float) /
		   CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT ELSE 0 END),0) AS float) AS Rate_DebitCard_Transactions_Amt_M_3M,
		 
		   CAST(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT  ELSE 0 END) AS float)  /
		   CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT ELSE 0 END),0) AS float) AS Rate_DebitCard_Transactions_Amt_M_6M,
					 
		   CAST(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT ELSE 0 END) AS float)  /
		   CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT ELSE 0 END),0) AS float) AS Rate_DebitCard_Transactions_Amt_3M_6M,

			  
            AVG( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
												   vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT  ELSE NULL END)  AS Avg_Last_DebitCard_Transactions_Amt,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
												   vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT ELSE NULL END)   AS Avg_Last_2M_DebitCard_Transactions_Amt,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND 
			                                       vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT ELSE   NULL END) AS Avg_Last_3M_DebitCard_Transactions_Amt,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
			                                       vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT ELSE  NULL END)  AS Avg_Last_6M_DebitCard_Transactions_Amt ,
	
-----------Debit Card Cash Transactions

            SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                                              vwtn.TXNCODE= 0 THEN 1  ELSE 0 END)  AS Last_DebitCard_Cash_Transactions ,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
														  vwtn.TXNCODE= 0 THEN 1 ELSE 0 END)   AS Last_2M_DebitCard_Cash_Transactions,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND 
														  vwtn.TXNCODE= 0 THEN 1 ELSE   0 END) AS Last_3M_DebitCard_Cash_Transactions,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
														  vwtn.TXNCODE= 0 THEN 1 ELSE  0 END)  AS Last_6M_DebitCard_Cash_Transactions,
	
		    CAST(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND   vwtn.TXNCODE= 0 THEN 1  ELSE 0 END) AS float) /
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND    vwtn.TXNCODE= 0 THEN 1 ELSE 0 END),0) AS float) AS Rate_DebitCard_Cash_Transactions_M_3M,
		 																																							   
		    CAST(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.TXNCODE= 0 THEN 1  ELSE 0 END)  AS float) /							  
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND   vwtn.TXNCODE= 0 THEN 1 ELSE 0 END),0) AS float) AS  Rate_DebitCard_Cash_Transactions_M_6M,
					 																																				  
		    CAST(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND   vwtn.TXNCODE= 0 THEN 1 ELSE 0 END)  AS float) /			  
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND   vwtn.TXNCODE= 0 THEN 1 ELSE 0 END),0) AS float) AS  Rate_DebitCard_Cash_Transactions_3M_6M,



            SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                                          vwtn.TXNCODE= 0 THEN vwtn.BILLAMT  ELSE 0 END)   AS Last_DebitCard_Cash_Transactions_Amt ,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
												      vwtn.TXNCODE= 0 THEN vwtn.BILLAMT ELSE 0 END)    AS Last_2M_DebitCard_Cash_Transactions_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND  
												      vwtn.TXNCODE= 0 THEN vwtn.BILLAMT ELSE   0 END)  AS Last_3M_DebitCard_Cash_Transactions_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
													    vwtn.TXNCODE= 0 THEN vwtn.BILLAMT ELSE  0 END) AS Last_6M_DebitCard_Cash_Transactions_Amt,


	        CAST(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND   vwtn.TXNCODE= 0 THEN vwtn.BILLAMT  ELSE 0 END) AS float) /
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND    vwtn.TXNCODE= 0 THEN vwtn.BILLAMT ELSE 0 END),0)AS float) AS Rate_DebitCard_Cash_Transactions_Amt_M_3M,
		 																																										
		    CAST(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.TXNCODE= 0 THEN vwtn.BILLAMT  ELSE 0 END) AS float) /								
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND   vwtn.TXNCODE= 0 THEN vwtn.BILLAMT ELSE 0 END),0) AS float) AS Rate_DebitCard_Cash_Transactions_Amt_M_6M,
					 																																							
		    CAST(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND   vwtn.TXNCODE= 0 THEN vwtn.BILLAMT ELSE 0 END) AS float) /			
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND   vwtn.TXNCODE= 0 THEN vwtn.BILLAMT ELSE 0 END),0) AS float) AS Rate_DebitCard_Cash_Transactions_Amt_3M_6M,


            AVG( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                                            vwtn.TXNCODE= 0 THEN vwtn.BILLAMT  ELSE NULL END)  AS Avg_Last_DebitCard_Cash_Transactions_Amt ,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
			    										vwtn.TXNCODE= 0 THEN vwtn.BILLAMT ELSE NULL END)   AS Avg_Last_2M_DebitCard_Cash_Transactions_Amt,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND 
			  										    vwtn.TXNCODE= 0 THEN vwtn.BILLAMT ELSE NULL END) AS Avg_Last_3M_DebitCard_Cash_Transactions_Amt,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 
													    vwtn.TXNCODE= 0 THEN vwtn.BILLAMT ELSE  NULL END)  AS Avg_Last_6M_DebitCard_Cash_Transactions_Amt,
---------Rate Calculations 
   
            CAST(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.TXNCODE= 0 THEN 1  ELSE 0 END) AS float) /
			CAST(NULLIF(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.TXNCODE IN (0,1,9) THEN 1  ELSE 0 END),0)AS float)                  AS Rate_Last_DB_Cash_Transaction ,

			CAST(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND vwtn.TXNCODE= 0 THEN 1 ELSE 0 END) AS float)/
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN 1 ELSE 0 END),0) AS float) AS Rate_Last_2M_DB_Cash_Transaction,
           
		    CAST(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND vwtn.TXNCODE= 0 THEN 1 ELSE   0 END) AS float) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN 1 ELSE 0 END),0) AS float) AS Rate_Last_3M_DB_Cash_Transaction,
         
	        CAST(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND vwtn.TXNCODE= 0 THEN 1 ELSE   0 END) AS float) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN 1 ELSE 0 END),0) AS float) AS Rate_Last_6M_DB_Cash_Transaction,

------------------------    
            CAST(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.TXNCODE= 0 THEN vwtn.BILLAMT   ELSE 0 END)  AS float) /
			CAST(NULLIF(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT   ELSE 0 END),0) AS float)                  AS Rate_Last_DB_Cash_Transaction_Amt,

			CAST(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND vwtn.TXNCODE= 0 THEN vwtn.BILLAMT  ELSE 0 END)  AS float)/
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT  ELSE 0 END),0)  AS float) AS Rate_Last_2M_DB_Cash_Transaction_Amt,
           
		    CAST(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND vwtn.TXNCODE= 0 THEN vwtn.BILLAMT  ELSE   0 END)  AS float) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT  ELSE 0 END),0)  AS float) AS Rate_Last_3M_DB_Cash_Transaction_Amt,
         
	        CAST(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND vwtn.TXNCODE= 0 THEN vwtn.BILLAMT  ELSE   0 END) AS float) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND vwtn.TXNCODE IN (0,1,9) THEN vwtn.BILLAMT  ELSE 0 END),0)  AS float) AS Rate_Last_6M_DB_Cash_Transaction_Amt,

-- ------Debit Fund Transactions
  
            SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                                              vwtn.TXNCODE= 26 THEN 1  ELSE 0 END)  AS Last_DebitCard_Funds_Transactions ,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
														  vwtn.TXNCODE= 26 THEN 1 ELSE 0 END)   AS Last_2M_DebitCard_Funds_Transactions,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND 					
														  vwtn.TXNCODE= 26 THEN 1 ELSE   0 END) AS Last_3M_DebitCard_Funds_Transactions,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 					
														  vwtn.TXNCODE= 26 THEN 1 ELSE  0 END)  AS Last_6M_DebitCard_Funds_Transactions,

----------Debit Fund Amount

            SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                                          vwtn.TXNCODE= 26 THEN vwtn.BILLAMT  ELSE 0 END)   AS Last_DebitCard_Funds_Transactions_Amt ,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth) AND 
												      vwtn.TXNCODE= 26 THEN vwtn.BILLAMT ELSE 0 END)    AS Last_2M_DebitCard_Funds_Transactions_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND  						
												      vwtn.TXNCODE= 26 THEN vwtn.BILLAMT ELSE   0 END)  AS Last_3M_DebitCard_Funds_Transactions_Amt,
			SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 							
													    vwtn.TXNCODE= 26 THEN vwtn.BILLAMT ELSE  0 END) AS Last_6M_DebitCard_Funds_Transactions_Amt,


		    CAST(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND   vwtn.TXNCODE= 26 THEN vwtn.BILLAMT  ELSE 0 END)  AS float) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND    vwtn.TXNCODE= 26 THEN vwtn.BILLAMT ELSE 0 END),0) AS float) AS Rate_DebitCard_Fund_Transactions_Amt_M_3M,
		 																																										  
		    CAST(SUM( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND  vwtn.TXNCODE= 26 THEN vwtn.BILLAMT  ELSE 0 END)  AS float) /							  
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND   vwtn.TXNCODE= 26 THEN vwtn.BILLAMT ELSE 0 END),0)  AS float) AS Rate_DebitCard_Fund_Transactions_Amt_M_6M,
					 																																							  
		    CAST(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth) AND   vwtn.TXNCODE= 26 THEN vwtn.BILLAMT ELSE 0 END)  AS float) /			  
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth) AND   vwtn.TXNCODE= 26 THEN vwtn.BILLAMT ELSE 0 END),0)  AS float) AS Rate_DebitCard_Fund_Transactions_Amt_3M_6M,


            AVG( CASE WHEN (EOMONTH(vwtn.ctxdatelocal)= acm.TransactionMonth) AND 
			                                            vwtn.TXNCODE= 26 THEN vwtn.BILLAMT  ELSE NULL END)  AS Avg_Last_DebitCard_Funds_Transactions_Amt ,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-1,acm.TransactionMonth)  AND 
			    										vwtn.TXNCODE= 26 THEN vwtn.BILLAMT ELSE  NULL END)  AS Avg_Last_2M_DebitCard_Funds_Transactions_Amt,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-2,acm.TransactionMonth)  AND 							
			  										    vwtn.TXNCODE= 26 THEN vwtn.BILLAMT ELSE  NULL END)  AS Avg_Last_3M_DebitCard_Funds_Transactions_Amt,
			AVG( CASE WHEN EOMONTH(vwtn.ctxdatelocal) >= DATEADD(MONTH,-5,acm.TransactionMonth)  AND 							
													    vwtn.TXNCODE= 26 THEN vwtn.BILLAMT ELSE  NULL END)  AS Avg_Last_6M_DebitCard_Funds_Transactions_Amt

INTO    apstempdb.dbo.FO_ActiveCustomersWith_DebitCard_Transactions
FROM    apstempdb.dbo.FO_Attrition_Feature_Base acm
LEFT    JOIN  warehousenomad.dbo.vwTransactionLiteN vwtn (NOLOCK) -- consolidated view of all monetary activity on an account (payments, fees, card transactions, manual adjustments)
ON      acm.ACCNO= vwtn.ACCNO
LEFT    JOIN	WarehouseNomad.dbo.vwFeeTypesN fee
ON		vwtn.FEEID = fee.ReasonCode
WHERE	vwtn.Source = 'FinAdv' -- transactions
AND		vwtn.ctxdatelocal >= DATEADD(MONTH	,-5,acm.TransactionMonth)
AND		vwtn.ctxdatelocal <= acm.TransactionMonth
--AND   acm.ACCNO IN ('80000100100057','80000100100122','80000100100161','80000100105836')
GROUP BY acm.ACCNO,acm.TransactionMonth,acm.Nof_All_Transactions_Payments
--ORDER BY 1,2 asc


