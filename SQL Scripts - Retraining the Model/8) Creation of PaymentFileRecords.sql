

DROP TABLE IF EXISTS #PaymentFileRecords

SELECT CustomerNumber,CARD_TRANSACTION_MONTH,COUNT(*) Total_PaymentFileRecords,
		SUM(PaymentHeld)    Total_PaymentHeld,
		SUM(PaymentApplied) Total_PaymentApplied,
		SUM(PaymentHeld)/NULLIF(CAST(COUNT(*) AS FLOAT),0) Rate_of_Total_PaymentHeld,
		SUM(PaymentApplied)/NULLIF(CAST(COUNT(*) AS FLOAT),0) Rate_of_Total_PaymentApplied,

		SUM(Amount) Total_PFR_Amt,
		SUM(PaymentHeld_Amt) Total_PaymentHeld_Amt,
		SUM(PaymentApplied_Amt) Total_PaymentApplied_Amt,
		SUM(PaymentHeld_Amt)/NULLIF(SUM(Amount),0) Rate_of_Total_PaymentHeld_Amt,
		SUM(PaymentApplied_Amt)/NULLIF(SUM(Amount),0) Rate_of_Total_PaymentApplied_Amt

INTO  #PaymentFileRecords
FROM	 
			(
			SELECT	  pfr.CustomerNumber,
				      pfr.OriginFileRecordID,
					  EOMONTH(Imported) CARD_TRANSACTION_MONTH,
					  MAX(Amount) AS Amount,
					  MAX(CASE WHEN pfr.LogicRule IS NOT NULL THEN 1 ELSE 0 END) PaymentHeld,
					  MAX(CASE WHEN pfr.LogicRule IS NULL THEN 1 ELSE 0 END)    PaymentApplied,
					  MAX(CASE WHEN pfr.LogicRule IS NOT NULL THEN Amount ELSE 0 END) PaymentHeld_Amt,
					  MAX(CASE WHEN pfr.LogicRule IS NULL THEN Amount ELSE 0 END) PaymentApplied_Amt
            FROM        apstempdb.dbo.FO_Attrition_Feature_Base a
			LEFT JOIN	WarehouseCAPDB.dbo.PaymentFileRecords pfr (NOLOCK)
			ON			a.ACCNO = pfr.CustomerNumber
		    AND         a.TransactionMonth= EOMONTH(pfr.Imported)
			WHERE	    pfr.Imported >= '2021-01-01'
			AND		    pfr.Imported <='2022-06-30'
			AND	   	    pfr.CustomerNumber IS NOT NULL
			GROUP BY pfr.CustomerNumber,pfr.OriginFileRecordID,EOMONTH(Imported)
			) b
GROUP BY CustomerNumber,CARD_TRANSACTION_MONTH

---------------------------------------------------

DROP TABLE IF EXISTS   #PaymentFileRecordsTrends
SELECT     acm.ACCNO,acm.TransactionMonth,

            ---Total Records 
            SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN  Total_PaymentFileRecords  ELSE 0 END)  AS Last_Month_Total_PaymentFileRecords,
	        SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN  Total_PaymentFileRecords ELSE 0 END)  AS Last_2M_Total_PaymentFileRecords ,
			SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentFileRecords ELSE 0 END)  AS Last_3M_Total_PaymentFileRecords,
			SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentFileRecords ELSE 0 END)  AS Last_6M_Total_PaymentFileRecords,

			SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN  Total_PaymentHeld  ELSE 0 END)  AS Last_Month_Total_PaymentHeld,
	        SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN  Total_PaymentHeld  ELSE 0 END)  AS Last_2M_Total_PaymentHeld ,
			SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentHeld  ELSE 0 END)  AS Last_3M_Total_PaymentHeld,
			SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentHeld  ELSE 0 END)  AS Last_6M_Total_PaymentHeld,

			SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN  Total_PaymentApplied  ELSE 0 END)  AS Last_Month_Total_PaymentApplied,
	        SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN  Total_PaymentApplied  ELSE 0 END)  AS Last_2M_Total_PaymentApplied ,
			SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentApplied  ELSE 0 END)  AS Last_3M_Total_PaymentApplied,
			SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentApplied  ELSE 0 END)  AS Last_6M_Total_PaymentApplied,

			-----Avg Records
									
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN b.Total_PaymentFileRecords  ELSE 0 END) /CAST(2 AS FLOAT)  AS  Avg_Last_2M_Total_PaymentFileRecords,																																										
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN b.Total_PaymentFileRecords  ELSE 0 END)/CAST(3 AS FLOAT)   AS  Avg_Last_3M_Total_PaymentFileRecords,																																										
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN b.Total_PaymentFileRecords  ELSE 0 END) /CAST(6 AS FLOAT)  AS  Avg_Last_6M_Total_PaymentFileRecords,
			 -------------------
			 
		     SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN b.Total_PaymentHeld  ELSE 0 END) /CAST(2 AS FLOAT)  AS Avg_Last_2M_Total_PaymentHeld,
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN b.Total_PaymentHeld  ELSE 0 END) /CAST(3 AS FLOAT)  AS  Avg_Last_3M_Total_PaymentHeld,
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN b.Total_PaymentHeld  ELSE 0 END) /CAST(6 AS FLOAT)  AS  Avg_Last_6M_Total_PaymentHeld,
			 -----------------

             SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN b.Total_PaymentApplied  ELSE 0 END) /CAST(2 AS FLOAT)  AS Avg_Last_2M_Total_PaymentApplied,
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN b.Total_PaymentApplied  ELSE 0 END) /CAST(3 AS FLOAT)  AS  Avg_Last_3M_Total_PaymentApplied,																																										
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN b.Total_PaymentApplied  ELSE 0 END) /CAST(6 AS FLOAT) AS  Avg_Last_6M_Total_PaymentApplied,

             ------Rate of Records

		    SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN Total_PaymentFileRecords  ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentFileRecords ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentFileRecords_M_3M,
		 
		    SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN Total_PaymentFileRecords  ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentFileRecords ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentFileRecords_M_6M,
					 
		    SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentFileRecords ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentFileRecords ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentFileRecords_3M_6M,

			-------------------
			SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN Total_PaymentHeld  ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentHeld ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentHeld_M_3M,
		 
		    SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN Total_PaymentHeld  ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentHeld ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentHeld_M_6M,
					 
		    SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentHeld ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentHeld ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentHeld_3M_6M,

			-------------------------------

		    SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN Total_PaymentApplied  ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentApplied ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentApplied_M_3M,
		 
		    SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN Total_PaymentApplied  ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentApplied ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentApplied_M_6M,
					 
		    SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentApplied ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentApplied ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentApplied_3M_6M,

			--------Total Record Amounts

			SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN  Total_PFR_Amt ELSE 0 END)  AS Last_Month_Total_PFR_Amt,
	        SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN  Total_PFR_Amt ELSE 0 END)  AS Last_2M_Total_PFR_Amt,
			SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PFR_Amt ELSE 0 END)  AS Last_3M_Total_PFR_Amt,
			SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PFR_Amt ELSE 0 END)  AS Last_6M_Total_PFR_Amt,

			SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN  Total_PaymentHeld_Amt  ELSE 0 END)  AS Last_Month_Total_PaymentHeld_Amt,
	        SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN  Total_PaymentHeld_Amt  ELSE 0 END)  AS Last_2M_Total_PaymentHeld_Amt,
			SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentHeld_Amt  ELSE 0 END)  AS Last_3M_Total_PaymentHeld_Amt,
			SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentHeld_Amt  ELSE 0 END)  AS Last_6M_Total_PaymentHeld_Amt,

			SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN  Total_PaymentApplied_Amt  ELSE 0 END)  AS Last_Month_Total_PaymentApplied_Amt,
	        SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN  Total_PaymentApplied_Amt  ELSE 0 END)  AS Last_2M_Total_PaymentApplied_Amt ,
			SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentApplied_Amt  ELSE 0 END)  AS Last_3M_Total_PaymentApplied_Amt,
			SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentApplied_Amt  ELSE 0 END)  AS Last_6M_Total_PaymentApplied_Amt,

			-----Avg Record Amounts

			 SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)   THEN b.Total_PFR_Amt  ELSE 0 END) /
			 CAST(NULLIF(SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)   THEN b.Total_PaymentFileRecords  ELSE 0 END),0) AS FLOAT)  AS Avg_Last_Month_Total_PFR_Amt,
									
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN b.Total_PFR_Amt  ELSE 0 END) /
			 CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN b.Total_PaymentFileRecords ELSE 0 END),0) AS FLOAT) AS Avg_Last_2M_Total_PFR_Amt,
									
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  b.Total_PFR_Amt  ELSE 0 END)/
			 CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  b.Total_PaymentFileRecords  ELSE 0 END),0) AS FLOAT) AS Avg_Last_3M_Total_PFR_Amt,
								
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN b.Total_PFR_Amt  ELSE 0 END) /
			 CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN b.Total_PaymentFileRecords  ELSE 0 END),0) AS FLOAT)  AS  Avg_Last_6M_Total_PFR_Amt,

			 -------------------
			 
			 SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)   THEN b.Total_PaymentApplied_Amt  ELSE 0 END) /
			 CAST(NULLIF(SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)   THEN b.Total_PaymentApplied  ELSE 0 END),0) AS FLOAT) AS Avg_Last_Month_Total_PaymentApplied_Amt,
									
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN b.Total_PaymentApplied_Amt  ELSE 0 END) /
			 CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN b.Total_PaymentApplied ELSE 0 END),0) AS FLOAT) AS Avg_Last_2M_Total_PaymentApplied_Amt,
									
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  b.Total_PaymentApplied_Amt  ELSE 0 END)/
			 CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  b.Total_PaymentApplied  ELSE 0 END),0) AS FLOAT) AS Avg_Last_3M_Total_PaymentApplied_Amt,
								
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN b.Total_PaymentApplied_Amt  ELSE 0 END) /
			 CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN b.Total_PaymentApplied  ELSE 0 END),0) AS FLOAT)  AS  Avg_Last_6M_Total_PaymentApplied_Amt,

			 -----------------

			 SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)   THEN b.Total_PaymentHeld_Amt  ELSE 0 END) /
			 CAST(NULLIF(SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)   THEN b.Total_PaymentHeld  ELSE 0 END),0) AS FLOAT)  AS Avg_Last_Month_Total_PaymentHeld_Amt,
									
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN b.Total_PaymentHeld_Amt  ELSE 0 END) /
			 CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN b.Total_PaymentHeld ELSE 0 END),0) AS FLOAT)   AS Avg_Last_2M_Total_PaymentHeld_Amt,
									
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  b.Total_PaymentHeld_Amt  ELSE 0 END)/
			 CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  b.Total_PaymentHeld  ELSE 0 END),0) AS FLOAT) AS Avg_Last_3M_Total_PaymentHeld_Amt,
								
			 SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN b.Total_PaymentHeld_Amt  ELSE 0 END) /
			 CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN b.Total_PaymentHeld  ELSE 0 END),0) AS FLOAT)  AS  Avg_Last_6M_Total_PaymentHeld_Amt,

             ---------Rate of Record Amounts
			
		    SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN Total_PFR_Amt  ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PFR_Amt ELSE 0 END),0) AS FLOAT) AS Rate_Total_PFR_Amt_M_3M,
		 
		    SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN Total_PFR_Amt  ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PFR_Amt ELSE 0 END),0) AS FLOAT) AS Rate_Total_PFR_Amt_M_6M,
					 
		    SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PFR_Amt ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PFR_Amt ELSE 0 END),0) AS FLOAT) AS Rate_Total_PFR_Amt_3M_6M,

			-------------------
			SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN Total_PaymentHeld_Amt  ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentHeld_Amt ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentHeld_Amt_M_3M,
		 
		    SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN Total_PaymentHeld_Amt  ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentHeld_Amt ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentHeld_Amt_M_6M,
					 
		    SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentHeld_Amt ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentHeld_Amt ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentHeld_Amt_3M_6M,

			-------------------

		    SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN Total_PaymentApplied_Amt  ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentApplied_Amt ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentApplied_Amt_M_3M,
		 
		    SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN Total_PaymentApplied_Amt  ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentApplied_Amt ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentApplied_Amt_M_6M,
					 
		    SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentApplied_Amt ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Total_PaymentApplied_Amt ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentApplied_Amt_3M_6M

INTO        #PaymentFileRecordsTrends
FROM        apstempdb.dbo.FO_Attrition_Feature_Base acm
LEFT JOIN   #PaymentFileRecords b
ON			acm.ACCNO=b.CustomerNumber
WHERE       b.CARD_TRANSACTION_MONTH >= DATEADD(MONTH	,-5,acm.TransactionMonth)
--AND         CustomerNumber IN ('80000100474648','80000100498320','80000100415584','80000100443961')
AND		    b.CARD_TRANSACTION_MONTH <= acm.TransactionMonth
GROUP BY  acm.ACCNO, acm.TransactionMonth   
--order BY 1,2 asc

----------------Creation of the Avg Delta Features

DROP TABLE IF EXISTS   apstempdb.dbo.FO_ActiveCustomersWith_PaymentFileRecords
SELECT a.*, 
        (Last_Month_Total_PaymentFileRecords -Avg_Last_3M_Total_PaymentFileRecords) / CAST(NULLIF(Avg_Last_3M_Total_PaymentFileRecords,0) AS FLOAT) AS Delta_Avg_Total_PaymentFileRecords_Chg_M_3M,
	    (Last_Month_Total_PaymentFileRecords -Avg_Last_6M_Total_PaymentFileRecords) / CAST(NULLIF(Avg_Last_6M_Total_PaymentFileRecords,0) AS FLOAT) AS Delta_Avg_Total_PaymentFileRecords_Chg_M_6M,
		(Avg_Last_3M_Total_PaymentFileRecords-Avg_Last_6M_Total_PaymentFileRecords) / CAST(NULLIF(Avg_Last_6M_Total_PaymentFileRecords,0) AS FLOAT) AS Delta_Avg_Total_PaymentFileRecords_Chg_3M_6M,

		 (Last_Month_Total_PaymentHeld-Last_3M_Total_PaymentHeld)/ CAST(NULLIF(Last_3M_Total_PaymentHeld,0) AS FLOAT)            AS Delta_Avg_Total_PaymentHeld_Chg_M_3M,
		 (Last_Month_Total_PaymentHeld-Avg_Last_6M_Total_PaymentHeld)/ CAST(NULLIF(Avg_Last_6M_Total_PaymentHeld,0) AS FLOAT)    AS Delta_Avg_Total_PaymentHeld_Chg_M_6M,
		 (Avg_Last_3M_Total_PaymentHeld-Avg_Last_6M_Total_PaymentHeld)/ CAST(NULLIF(Avg_Last_6M_Total_PaymentHeld,0) AS FLOAT)   AS Delta_Avg_Total_PaymentHeld_Chg_3M_6M,

		 (Last_Month_Total_PaymentApplied-Avg_Last_3M_Total_PaymentApplied)/ CAST(NULLIF(Avg_Last_3M_Total_PaymentApplied,0) AS FLOAT)  AS Delta_Avg_Total_PaymentApplied_Chg_M_3M,
		 (Last_Month_Total_PaymentApplied-Avg_Last_6M_Total_PaymentApplied)/ CAST(NULLIF(Avg_Last_6M_Total_PaymentApplied,0) AS FLOAT)  AS Delta_Avg_Total_PaymentApplied_Chg_M_6M,
		 (Avg_Last_3M_Total_PaymentApplied-Avg_Last_6M_Total_PaymentApplied)/ CAST(NULLIF(Avg_Last_6M_Total_PaymentApplied,0) AS FLOAT) AS Delta_Avg_Total_PaymentApplied_Chg_3M_6M,

       (Avg_Last_Month_Total_PFR_Amt-Avg_Last_3M_Total_PFR_Amt)/NULLIF(a.Avg_Last_3M_Total_PFR_Amt,0) Delta_Avg_Total_PFR_Amt_Chg_M_3M,
       (Avg_Last_Month_Total_PFR_Amt-Avg_Last_6M_Total_PFR_Amt)/NULLIF(a.Avg_Last_6M_Total_PFR_Amt,0) Delta_Avg_Total_PFR_Amt_Chg_M_6M,
		(Avg_Last_3M_Total_PFR_Amt-Avg_Last_6M_Total_PFR_Amt)/NULLIF(a.Avg_Last_6M_Total_PFR_Amt,0)    Delta_Avg_Total_PFR_Amt_Chg_3M_6M,

		(Avg_Last_Month_Total_PaymentApplied_Amt-Avg_Last_3M_Total_PaymentApplied_Amt)/NULLIF(a.Avg_Last_3M_Total_PaymentApplied_Amt,0) Delta_Avg_Total_PaymentApplied_Amt_Chg_M_3M,
        (Avg_Last_Month_Total_PaymentApplied_Amt-Avg_Last_6M_Total_PaymentApplied_Amt)/NULLIF(a.Avg_Last_6M_Total_PaymentApplied_Amt,0) Delta_Avg_Total_PaymentApplied_Amt_Chg_M_6M,
		(Avg_Last_3M_Total_PaymentApplied_Amt-Avg_Last_6M_Total_PaymentApplied_Amt)/NULLIF(a.Avg_Last_6M_Total_PaymentApplied_Amt,0)    Delta_Avg_Total_PaymentApplied_Amt_Chg_3M_6M,

		(Avg_Last_Month_Total_PaymentHeld_Amt-Avg_Last_3M_Total_PaymentHeld_Amt)/NULLIF(a.Avg_Last_3M_Total_PaymentHeld_Amt,0) Delta_Avg_Total_PaymentHeld_Amt_Chg_M_3M,
        (Avg_Last_Month_Total_PaymentHeld_Amt-Avg_Last_6M_Total_PaymentHeld_Amt)/NULLIF(a.Avg_Last_6M_Total_PaymentHeld_Amt,0) Delta_Avg_Total_PaymentHeld_Amt_Chg_M_6M,
		(Avg_Last_3M_Total_PaymentHeld_Amt-Avg_Last_6M_Total_PaymentHeld_Amt)/NULLIF(a.Avg_Last_6M_Total_PaymentHeld_Amt,0)    Delta_Avg_Total_PaymentHeld_Amt_Chg_3M_6M

INTO    apstempdb.dbo.FO_ActiveCustomersWith_PaymentFileRecords
FROM    #PaymentFileRecordsTrends a
--WHERE  ACCNO IN ('80000100474648','80000100498320','80000100415584','80000100443961')


