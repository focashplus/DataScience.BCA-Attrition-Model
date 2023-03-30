

DECLARE     @scoringmonth  DATE = EOMONTH('2023-02-28')
DECLARE		@startMonth DATE =  DATEADD(dd, -( DAY( DATEADD(month,-6,@scoringmonth) ) -1 ), DATEADD(month,-6,@scoringmonth));--going to 6 months back from the scoring month and selecting the first day.
DECLARE		@endMonth   DATE =  DATEADD(day,+1,@scoringmonth) -- Added +1 day to the latest closed month to don't miss last day's transactions since they will appair the fisrt day of the next month



DROP TABLE IF EXISTS #PaymentFileRecords
SELECT CustomerNumber,CARD_TRANSACTION_MONTH,
        COUNT(*) Total_PaymentFileRecords,
		SUM(PaymentHeld)    Total_PaymentHeld,
		SUM(PaymentApplied) Total_PaymentApplied,
		SUM(Amount) Total_PFR_Amt,
		SUM(PaymentHeld_Amt) Total_PaymentHeld_Amt,
		SUM(PaymentApplied_Amt) Total_PaymentApplied_Amt
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
			WHERE	    pfr.Imported >= @startMonth
			AND		    pfr.Imported <=@endMonth
			AND	   	    pfr.CustomerNumber IS NOT NULL
			GROUP BY pfr.CustomerNumber,pfr.OriginFileRecordID,EOMONTH(Imported)
			) b
GROUP BY CustomerNumber,CARD_TRANSACTION_MONTH

---------------------------------------------------

DROP TABLE IF EXISTS   apstempdb.dbo.FO_ActiveCustomersWith_PaymentFileRecords
SELECT     acm.ACCNO,acm.TransactionMonth,

		    SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN Total_PaymentApplied  ELSE 0 END) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.CARD_TRANSACTION_MONTH) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Total_PaymentApplied ELSE 0 END),0) AS FLOAT) AS Rate_Total_PaymentApplied_M_3M,

			SUM( CASE WHEN (EOMONTH(b.CARD_TRANSACTION_MONTH)= acm.TransactionMonth)                    THEN  Total_PaymentApplied_Amt  ELSE 0 END)  AS Last_Month_Total_PaymentApplied_Amt
	     
		
INTO        apstempdb.dbo.FO_ActiveCustomersWith_PaymentFileRecords
FROM        apstempdb.dbo.FO_Attrition_Feature_Base acm
LEFT JOIN   #PaymentFileRecords b
ON			acm.ACCNO=b.CustomerNumber
WHERE       b.CARD_TRANSACTION_MONTH >= DATEADD(MONTH	,-5,acm.TransactionMonth)
AND		    b.CARD_TRANSACTION_MONTH <= acm.TransactionMonth
GROUP BY  acm.ACCNO, acm.TransactionMonth   



