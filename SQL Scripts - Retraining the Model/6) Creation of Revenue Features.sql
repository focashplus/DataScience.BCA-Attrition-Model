
DROP TABLE	IF EXISTS #revenue

SELECT  acm.ACCNO, acm.TransactionMonth, 

            SUM( CASE WHEN (EOMONTH(b.revenue_month)= acm.TransactionMonth)   THEN 1  ELSE 0 END)    AS Last_Month_Revenue_Posting,
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN  1 ELSE 0 END)   AS Last_2M_Nof_Revenue_Posting_Months ,
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  1  ELSE 0 END)  AS Last_3M_Nof_Revenue_Posting_Months,
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  1  ELSE 0 END)  AS Last_6M_Nof_Revenue_Posting_Months,

            SUM( CASE WHEN (EOMONTH(b.revenue_month)= acm.TransactionMonth)   THEN b.Last_Total_Revenue   ELSE 0 END)    AS Last_Total_Revenue,
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN  b.Last_Total_Revenue  ELSE 0 END)  AS Last_2M_Total_Revenue ,
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  b.Last_Total_Revenue  ELSE 0 END)  AS Last_3M_Total_Revenue,
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  b.Last_Total_Revenue  ELSE 0 END)  AS Last_6M_Total_Revenue,

-------------

			SUM( CASE WHEN (EOMONTH(b.revenue_month)= acm.TransactionMonth)   THEN b.Last_Total_Revenue   ELSE 0 END) /
			SUM( CASE WHEN (EOMONTH(b.revenue_month)= acm.TransactionMonth)   THEN 1  ELSE 0 END)  Avg_Last_Posted_Total_Revenue,

			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN  b.Last_Total_Revenue  ELSE 0 END) /
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN  1 ELSE 0 END) AS Avg_Last_2M_Posted_Total_Revenue,

			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  b.Last_Total_Revenue  ELSE 0 END)/
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  1  ELSE 0 END)  AS Avg_Last_3M_Posted_Total_Revenue,

			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  b.Last_Total_Revenue  ELSE 0 END) /
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  1  ELSE 0 END)  AS  Avg_Last_6M_Posted_Total_Revenue,

-------------------------

			SUM( CASE WHEN (EOMONTH(b.revenue_month)= acm.TransactionMonth)   THEN b.Last_NormalisedRevenue   ELSE 0 END)    AS Last_NormalisedRevenue,
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN  b.Last_NormalisedRevenue  ELSE 0 END)  AS Last_2M_NormalisedRevenue ,
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  b.Last_NormalisedRevenue  ELSE 0 END)  AS Last_3M_NormalisedRevenue,
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  b.Last_NormalisedRevenue  ELSE 0 END)  AS Last_6M_NormalisedRevenue,

			CAST(SUM( CASE WHEN (EOMONTH(b.revenue_month)= acm.TransactionMonth) THEN b.Last_NormalisedRevenue   ELSE 0 END)  AS float) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-2,acm.TransactionMonth) THEN  b.Last_NormalisedRevenue  ELSE 0 END),0) AS float) AS Rate_NormalisedRevenue_M_3M,
		 
		    CAST(SUM( CASE WHEN (EOMONTH(b.revenue_month)= acm.TransactionMonth) THEN b.Last_NormalisedRevenue  ELSE 0 END)  AS float) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-5,acm.TransactionMonth) THEN b.Last_NormalisedRevenue ELSE 0 END),0)  AS float) AS Rate_NormalisedRevenue_M_6M,
					 
		    CAST(SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-2,acm.TransactionMonth)THEN b.Last_NormalisedRevenue ELSE 0 END)  AS float) /
		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-5,acm.TransactionMonth) THEN b.Last_NormalisedRevenue ELSE 0 END),0)  AS float) AS Rate_NormalisedRevenue_3M_6M,


			SUM( CASE WHEN (EOMONTH(b.revenue_month)= acm.TransactionMonth)   THEN Last_NormalisedRevenue   ELSE 0 END) /
			SUM( CASE WHEN (EOMONTH(b.revenue_month)= acm.TransactionMonth)   THEN 1  ELSE 0 END)  Avg_Last_Posted_NormalisedRevenue,

			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN  Last_NormalisedRevenue ELSE 0 END) /
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-1,acm.TransactionMonth)  THEN  1 ELSE 0 END) AS Avg_Last_2M_Posted_NormalisedRevenue,

			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  Last_NormalisedRevenue  ELSE 0 END)/
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-2,acm.TransactionMonth)  THEN  1  ELSE 0 END)  AS Avg_Last_3M_Posted_NormalisedRevenue,

			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  Last_NormalisedRevenue  ELSE 0 END) /
			SUM( CASE WHEN EOMONTH(b.revenue_month) >= DATEADD(MONTH,-5,acm.TransactionMonth)  THEN  1  ELSE 0 END)  AS  Avg_Last_6M_Posted_NormalisedRevenue

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

DROP TABLE	IF EXISTS #revenue2
SELECT a.*,b.Min_Revenue_Posting_Month,
      DATEDIFF(MONTH,b.Min_Revenue_Posting_Month,a.TransactionMonth) AS MonthsBetween_Transaction_MinRevenueM,
	        
	--	Last_NormalisedRevenue AS Avg_Last_NormalisedRevenue,

	  	CASE WHEN b.Min_Revenue_Posting_Month=a.TransactionMonth THEN Last_2M_NormalisedRevenue
		     WHEN DATEDIFF(MONTH,b.Min_Revenue_Posting_Month,a.TransactionMonth)>=1 THEN (Last_2M_NormalisedRevenue/2)
			 ELSE 0 END AS Avg_Last_2M_NormalisedRevenue,


	  	CASE WHEN b.Min_Revenue_Posting_Month=a.TransactionMonth THEN Last_3M_NormalisedRevenue
		     WHEN DATEDIFF(MONTH,b.Min_Revenue_Posting_Month,a.TransactionMonth)>=2 THEN (Last_3M_NormalisedRevenue/3)
		     WHEN DATEDIFF(MONTH,b.Min_Revenue_Posting_Month,a.TransactionMonth)<2 THEN (Last_6M_NormalisedRevenue/CAST(NULLIF((DATEDIFF(MONTH,b.Min_Revenue_Posting_Month,a.TransactionMonth)+1),0) AS FLOAT))
			 ELSE 0 END AS Avg_Last_3M_NormalisedRevenue,		

	
	  	CASE WHEN b.Min_Revenue_Posting_Month=a.TransactionMonth THEN Last_6M_NormalisedRevenue
		     WHEN DATEDIFF(MONTH,b.Min_Revenue_Posting_Month,a.TransactionMonth)>=5 THEN (Last_6M_NormalisedRevenue/6)
			 WHEN DATEDIFF(MONTH,b.Min_Revenue_Posting_Month,a.TransactionMonth)<5 AND DATEDIFF(MONTH,b.Min_Revenue_Posting_Month,a.TransactionMonth)>=1 THEN (Last_6M_NormalisedRevenue/CAST(NULLIF((DATEDIFF(MONTH,b.Min_Revenue_Posting_Month,a.TransactionMonth)+1),0) AS FLOAT))
			 ELSE 0 END AS Avg_Last_6M_NormalisedRevenue
INTO #revenue2
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

----------------------------------------------------------------------------------------------------
------------------------------Standardizations------------------------------------------------

----Z value standardization

DROP TABLE	IF EXISTS #Z_Value_Indicaters
SELECT ACCNO,STDEV(Last_NormalisedRevenue)     AS STDEV_Avg_Last_NormalisedRevenue,    AVG(Last_NormalisedRevenue)    AS MEAN_Avg_Last_NormalisedRevenue,
                              STDEV(Avg_Last_2M_NormalisedRevenue)  AS STDEV_Avg_Last_2M_NormalisedRevenue, AVG(Avg_Last_2M_NormalisedRevenue) AS MEAN_Avg_Last_2M_NormalisedRevenue,
						      STDEV(Avg_Last_3M_NormalisedRevenue)  AS STDEV_Avg_Last_3M_NormalisedRevenue, AVG(Avg_Last_3M_NormalisedRevenue) AS MEAN_Avg_Last_3M_NormalisedRevenue,
						      STDEV(Avg_Last_6M_NormalisedRevenue)  AS STDEV_Avg_Last_6M_NormalisedRevenue ,AVG(Avg_Last_6M_NormalisedRevenue) AS MEAN_Avg_Last_6M_NormalisedRevenue


INTO   #Z_Value_Indicaters
FROM   #revenue2
--where  ACCNO IN ('80010100120430','80000100449508','80000100490334','80000100490345')
GROUP  BY ACCNO



---- Min-Max Standardizations

DROP TABLE	IF EXISTS #Min_Max_Standardization
SELECT ACCNO, MIN(Last_NormalisedRevenue)     AS MIN_Avg_Last_NormalisedRevenue,    MAX(Last_NormalisedRevenue)    AS MAX_Avg_Last_NormalisedRevenue,
                         MIN(Avg_Last_2M_NormalisedRevenue)  AS MIN_Avg_Last_2M_NormalisedRevenue, MAX(Avg_Last_2M_NormalisedRevenue) AS MAX_Avg_Last_2M_NormalisedRevenue,
						 MIN(Avg_Last_3M_NormalisedRevenue)  AS MIN_Avg_Last_3M_NormalisedRevenue, MAX(Avg_Last_3M_NormalisedRevenue) AS MAX_Avg_Last_3M_NormalisedRevenue,
						 MIN(Avg_Last_6M_NormalisedRevenue)  AS MIN_Avg_Last_6M_NormalisedRevenue ,MAX(Avg_Last_6M_NormalisedRevenue) AS MAX_Avg_Last_6M_NormalisedRevenue


INTO #Min_Max_Standardization
FROM   #revenue2
--where  ACCNO IN ('80010100120430','80000100449508','80000100490334','80000100490345')
GROUP BY ACCNO
--ORDER BY 1,2 asc



DROP TABLE	IF EXISTS apstempdb.dbo.FO_ActiveCustomersWith_Revenue
SELECT a.*,(Last_NormalisedRevenue-MEAN_Avg_Last_NormalisedRevenue)          / NULLIF(STDEV_Avg_Last_NormalisedRevenue,0)    AS Z_Value_Avg_Last_NormalisedRevenue,
           (Avg_Last_2M_NormalisedRevenue-MEAN_Avg_Last_2M_NormalisedRevenue)/ NULLIF(STDEV_Avg_Last_2M_NormalisedRevenue,0)  AS Z_Value_Avg_Last_2M_NormalisedRevenue,
		   (Avg_Last_3M_NormalisedRevenue-MEAN_Avg_Last_3M_NormalisedRevenue)/ NULLIF(STDEV_Avg_Last_3M_NormalisedRevenue,0)  AS Z_Value_Avg_Last_3M_NormalisedRevenue,
		   (Avg_Last_6M_NormalisedRevenue-MEAN_Avg_Last_6M_NormalisedRevenue)/ NULLIF(STDEV_Avg_Last_6M_NormalisedRevenue,0)  AS Z_Value_Avg_Last_6M_NormalisedRevenue,
		   ------------------------------
		   (Last_NormalisedRevenue   - MIN_Avg_Last_NormalisedRevenue)       / NULLIF((MAX_Avg_Last_NormalisedRevenue    - MIN_Avg_Last_NormalisedRevenue),0)    AS MinMaxStd_Avg_Last_NormalisedRevenue, 
           (Avg_Last_2M_NormalisedRevenue- MIN_Avg_Last_2M_NormalisedRevenue)/ NULLIF((MAX_Avg_Last_2M_NormalisedRevenue - MIN_Avg_Last_2M_NormalisedRevenue),0) AS MinMaxStd_Avg_Last_2M_NormalisedRevenue,
		   (Avg_Last_3M_NormalisedRevenue- MIN_Avg_Last_3M_NormalisedRevenue)/ NULLIF((MAX_Avg_Last_3M_NormalisedRevenue - MIN_Avg_Last_3M_NormalisedRevenue),0) AS MinMaxStd_Avg_Last_3M_NormalisedRevenue,
		   (Avg_Last_6M_NormalisedRevenue- MIN_Avg_Last_6M_NormalisedRevenue)/ NULLIF((MAX_Avg_Last_6M_NormalisedRevenue - MIN_Avg_Last_6M_NormalisedRevenue),0) AS MinMaxStd_Avg_Last_6M_NormalisedRevenue

INTO  apstempdb.dbo.FO_ActiveCustomersWith_Revenue
FROM #revenue2 a
LEFT JOIN #Z_Value_Indicaters b
ON   a.ACCNO=b.ACCNO  
LEFT JOIN  #Min_Max_Standardization c
ON   a.ACCNO=c.ACCNO  
----WHERE ACCNO IN ('80010100120430','80000100449508','80000100490334','80000100490345')

