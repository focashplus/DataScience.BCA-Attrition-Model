

DROP TABLE	IF EXISTS #revenue

SELECT  acm.ACCNO, acm.TransactionMonth, 
		 
		    CAST(SUM( CASE WHEN (EOMONTH(b.revenue_month)= acm.TransactionMonth) THEN b.Last_NormalisedRevenue  ELSE 0 END)  AS FLOAT) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-5,acm.TransactionMonth) THEN b.Last_NormalisedRevenue ELSE 0 END),0)  AS FLOAT) AS Rate_NormalisedRevenue_M_6M,
					 
		    CAST(SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-2,acm.TransactionMonth)THEN b.Last_NormalisedRevenue ELSE 0 END)  AS FLOAT) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-5,acm.TransactionMonth) THEN b.Last_NormalisedRevenue ELSE 0 END),0)  AS FLOAT) AS Rate_NormalisedRevenue_3M_6M
INTO  #revenue
FROM apstempdb.dbo.FO_Attrition_Feature_Base acm
LEFT JOIN 
				(
				SELECT a.ACCNO,a.TransactionMonth AS revenue_month,
							SUM(CASE WHEN EOMONTH(ctx.PostingDate)= a.TransactionMonth  THEN ctx.TotalRevenue ELSE 0 END )    AS Last_Total_Revenue,
							SUM(CASE WHEN EOMONTH(ctx.PostingDate)= a.TransactionMonth  THEN ctx.TotalRevenue -(ctx.AnnualFeeValue + ctx.MONFValue) ELSE 0 END )   AS Last_NormalisedRevenue,
							SUM(CASE WHEN EOMONTH(ctx.PostingDate)= a.TransactionMonth  THEN (ctx.AnnualFeeValue + ctx.MONFValue) ELSE 0 END )    AS Last_Total_Fee
							--COUNT(DISTINCT(EOMONTH(ctx.PostingDate))) Nof_Revenue_Posting_Months
				FROM          apstempdb.dbo.FO_Attrition_Feature_Base a 
				LEFT JOIN	Datamart.dbo.TransactionRevenueFYCurrent_CORTEX ctx (NOLOCK)
				ON			a.ACCNO = ctx.CustomerNumber
				AND         EOMONTH(ctx.PostingDate)=a.TransactionMonth
				--where  a.ACCNO IN ('80010100120430','80000100449508','80000100490334','80000100490345')
				GROUP BY	a.ACCNO, A.TransactionMonth
				)b
ON			acm.ACCNO=b.ACCNO
WHERE       b.revenue_month >= DATEADD(MONTH	,-5,acm.TransactionMonth)
AND		    b.revenue_month <= acm.TransactionMonth
GROUP BY  acm.ACCNO, acm.TransactionMonth                    
--ORDER BY 1,2 asc

------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE	IF EXISTS  apstempdb.dbo.FO_ActiveCustomersWith_Revenue
SELECT a.*,b.Min_Revenue_Posting_Month,
      DATEDIFF(MONTH,b.Min_Revenue_Posting_Month,a.TransactionMonth) AS MonthsBetween_Transaction_MinRevenueM
INTO  apstempdb.dbo.FO_ActiveCustomersWith_Revenue
FROM #revenue a
LEFT JOIN 
        (
		SELECT      acm.ACCNO, MIN(EOMONTH(PostingDate)) AS Min_Revenue_Posting_Month,MAX(EOMONTH(PostingDate)) AS Max_Revenue_Posting_Month
		FROM        #revenue acm
		LEFT JOIN	Datamart.dbo.TransactionRevenueFYCurrent_CORTEX ctx (NOLOCK)
		ON			acm.ACCNO = ctx.CustomerNumber
		WHERE	    ctx.PostingDate <= acm.TransactionMonth
		--AND         acm.ACCNO IN ('80010100120430','80000100449508','80000100490334','80000100490345')
    	GROUP BY acm.ACCNO
		--ORDER BY 1,2 ASC
		)b
ON     a.ACCNO=b.ACCNO

