 


 ----Check whether the ACCTYPE=17 during the previous window, if so how many times, when was it first changed etc. This indicates that the customers has been granted a limit increase.
 -- a.ACCNO IN ('80000100101861','80000100104741') their all fildate's ACCTYPE are 17 and ACCTYPEPADs are 0. 


DROP TABLE IF EXISTS   apstempdb.dbo.FODistinct_Overdraft_Usage


SELECT ACCNO, TransactionMonth, Overdraft_Limit,FINAMT,FINAMTPAD,Rate_of_Usaged_Overdraft_Limit,MAX(ROW_NUM) ROW_NUM   --b.FINAMT,b.FINAMTPAD,
INTO   apstempdb.dbo.FODistinct_Overdraft_Usage
FROM 
		(
		SELECT  a.ACCNO, a.TransactionMonth,b.ACCTYPEPAD AS Overdraft_Limit,b.filedate,b.FINAMT,b.FINAMTPAD,
				sum(case when finamt < 0 then ABS(finamt) else 0 end) / NULLIF(SUM(acctypepad),0) Rate_of_Usaged_Overdraft_Limit,
	  			ROW_NUMBER() OVER( PARTITION BY A.ACCNO,a.TransactionMonth,b.FINAMT ORDER BY FILEDATE ASC) ROW_NUM
		FROM     apstempdb.dbo.FO_Attrition_Feature_Base a
		INNER   JOIN   warehousenomad.dbo.vwaccountpad b
		ON      a.ACCNO=b.ACCNO
		AND     a.TransactionMonth=EOMONTH(b.filedate)
		WHERE   EOMONTH(b.filedate)>='2021-01-01' AND EOMONTH(b.filedate)<'2022-07-01'
		--and   a.ACCNO IN ('80000100345997','80000100489545')--,'80010100120430','80000100449508','80000100490334','80000100490345')
		GROUP   BY  a.ACCNO, a.TransactionMonth,b.ACCTYPEPAD ,b.filedate,b.FINAMT,b.FINAMTPAD
		--order BY 1,2 asc
		) c
GROUP BY ACCNO, TransactionMonth, Overdraft_Limit,FINAMT,FINAMTPAD,Rate_of_Usaged_Overdraft_Limit

----

DROP TABLE IF EXISTS   #FO_Distinct_Overdraft_Rates

SELECT ACCNO, TransactionMonth,Max_Overdraft_Limit_in_Month,Avg_Monthly_FINAMT_Cleare_Balance,

      Monthly_Used_Overdraft_Amt/ NULLIF(Nof_Balance_Chg_InOverdraft,0) AS Avg_Monthly_Used_Overdraft_Amt,
	  ABS( Monthly_Used_Overdraft_Amt/ NULLIF(Nof_Balance_Chg_InOverdraft,0) / NULLIF(Avg_Monthly_FINAMT_Cleare_Balance,0))  AS Rate_of_Avg_Overdraft_Amt_in_Month,
	  Nof_Balance_Change,
	  Nof_Balance_Chg_InOverdraft,
	  Nof_Balance_Chg_InOverdraft/CAST(NULLIF(Nof_Balance_Change,0) AS FLOAT) AS Rate_of_Avg_Overdraft_Count_in_Month

INTO  #FO_Distinct_Overdraft_Rates
FROM 
		(
		SELECT a.ACCNO, a.TransactionMonth,AVG(FINAMT) Avg_Monthly_FINAMT_Cleare_Balance, 
										   SUM(CASE WHEN finamt < 0 THEN ABS(finamt) ELSE 0 END) Monthly_Used_Overdraft_Amt,
										   COUNT(*) Nof_Balance_Change,
										   SUM(CASE WHEN finamt < 0 THEN 1 ELSE 0 END) Nof_Balance_Chg_InOverdraft,
										   MAX(Overdraft_Limit) Max_Overdraft_Limit_in_Month,
										   MAX(ROW_NUM) NofMaxDays_with_Same_Balance_InMonth
		FROM   apstempdb.dbo.FODistinct_Overdraft_Usage a
		--WHERE  ACCNO IN ('80000100345997','80000100489545','80000100432184','80000100101861','80000100104741')
		GROUP BY  a.ACCNO, a.TransactionMonth
		--order BY 1,2 asc
		)c


-------------

DROP TABLE IF EXISTS   #FO_Distinct_Overdraft_Trends

SELECT  a.ACCNO, a.TransactionMonth, 
					
	 SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-1,a.TransactionMonth)  THEN 1 ELSE 0 END) Nof_Balance_Months_in_2M,
																										
	 SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-2,a.TransactionMonth)  THEN 1  ELSE 0 END) Nof_Balance_Months_in_3M,
																										
	 SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-5,a.TransactionMonth)  THEN 1 ELSE 0 END) Nof_Balance_Months_in_6M,

   ------FINAMT_Cleare_Balance  
	 						
	SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-1,a.TransactionMonth)  THEN b.Avg_Monthly_FINAMT_Cleare_Balance  ELSE 0 END)  Tot_Balance_in_2M,
	 																																		
	SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-2,a.TransactionMonth)  THEN  b.Avg_Monthly_FINAMT_Cleare_Balance  ELSE 0 END) Tot_Balance_in_3M,
	 																																		
	SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-5,a.TransactionMonth)  THEN b.Avg_Monthly_FINAMT_Cleare_Balance  ELSE 0 END)  Tot_Balance_in_6M,


			 SUM( CASE WHEN (EOMONTH(b.Balance_Month)= a.TransactionMonth)   THEN b.Avg_Monthly_FINAMT_Cleare_Balance  ELSE 0 END)     AS Avg_Monthly_FINAMT_Cleare_Balance,
									
			 SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-1,a.TransactionMonth)  THEN b.Avg_Monthly_FINAMT_Cleare_Balance  ELSE 0 END) / 
			 CAST(NULLIF( SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-1,a.TransactionMonth)  THEN 1 ELSE 0 END),0) AS FLOAT)  AS Avg_Last_2M_FINAMT_Cleare_Balance,
																																															 
			 SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-2,a.TransactionMonth)  THEN  b.Avg_Monthly_FINAMT_Cleare_Balance  ELSE 0 END)/ 
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-2,a.TransactionMonth)  THEN 1  ELSE 0 END) ,0) AS FLOAT)  AS Avg_Last_3M_FINAMT_Cleare_Balance,
																																															
			 SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-5,a.TransactionMonth)  THEN b.Avg_Monthly_FINAMT_Cleare_Balance  ELSE 0 END) / 
			 CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-5,a.TransactionMonth)  THEN 1  ELSE 0 END),0) AS FLOAT)  AS Avg_Last_6M_FINAMT_Cleare_Balance,

  -----Nof_Balance_Change
            SUM( CASE WHEN (EOMONTH(b.Balance_Month)= a.TransactionMonth)               THEN  b.Nof_Balance_Change ELSE 0 END)  AS Last_Month_Nof_Balance_Change,
			SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-1,a.TransactionMonth)  THEN b.Nof_Balance_Change ELSE 0 END) Tot_Nof_Balance_Change_in_2M,
	 																														  
			SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-2,a.TransactionMonth)  THEN b.Nof_Balance_Change ELSE 0 END) Tot_Nof_Balance_Change_in_3M,
	 																														 
			SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-5,a.TransactionMonth)  THEN b.Nof_Balance_Change ELSE 0 END) Tot_Nof_Balance_Change_in_6M,


									
			SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-1,a.TransactionMonth)  THEN b.Nof_Balance_Change ELSE 0 END) / 
			                CAST(NULLIF( SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-1,a.TransactionMonth)  THEN 1 ELSE 0 END),0) AS FLOAT)  AS Avg_Last_2M_Nof_Balance_Change,
																																											
			SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-2,a.TransactionMonth)  THEN b.Nof_Balance_Change ELSE 0 END) / 										
			                CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-2,a.TransactionMonth)  THEN 1  ELSE 0 END) ,0) AS FLOAT)  AS Avg_Last_3M_Nof_Balance_Change,
																																										      
			SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-5,a.TransactionMonth)  THEN b.Nof_Balance_Change ELSE 0 END) / 										  
			                CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-5,a.TransactionMonth)  THEN 1  ELSE 0 END),0) AS FLOAT)  AS Avg_Last_6M_Nof_Balance_Change,

            
			 SUM(b.Nof_Balance_Change) /CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-2,a.TransactionMonth)  THEN b.Nof_Balance_Change ELSE 0 END),0) AS FLOAT) AS Rate_Tot_Nof_Balance_Change_M_3M,
			 SUM(b.Nof_Balance_Change)/ CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-5,a.TransactionMonth)  THEN b.Nof_Balance_Change ELSE 0 END),0) AS FLOAT) AS Rate_Tot_Nof_Balance_Change_M_6M,
			 SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-2,a.TransactionMonth)  THEN b.Nof_Balance_Change ELSE 0 END)/
			        CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-5,a.TransactionMonth)  THEN b.Nof_Balance_Change ELSE 0 END),0) AS FLOAT) Rate_Tot_Nof_Balance_Change_3M_6M,

---Nof Overdraft change

        SUM( CASE WHEN (EOMONTH(b.Balance_Month)= a.TransactionMonth)                    THEN  b.Nof_Balance_Chg_InOverdraft ELSE 0 END)  AS Last_Month_Nof_Balance_Chg_InOverdraft,
	    SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-1,a.TransactionMonth)  THEN  b.Nof_Balance_Chg_InOverdraft ELSE 0 END)  AS Last_2M_Nof_Balance_Chg_InOverdraft ,
		SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-2,a.TransactionMonth)  THEN  b.Nof_Balance_Chg_InOverdraft ELSE 0 END)  AS Last_3M_Nof_Balance_Chg_InOverdraft,
		SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-5,a.TransactionMonth)  THEN  b.Nof_Balance_Chg_InOverdraft ELSE 0 END)  AS Last_6M_Nof_Balance_Chg_InOverdraft,


		SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-1,a.TransactionMonth)  THEN b.Nof_Balance_Chg_InOverdraft ELSE 0 END) / 
			                CAST(NULLIF( SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-1,a.TransactionMonth)  THEN 1 ELSE 0 END),0) AS FLOAT)  AS Avg_Last_2M_Nof_Balance_Chg_InOverdraft,																																											
	    SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-2,a.TransactionMonth)  THEN b.Nof_Balance_Chg_InOverdraft ELSE 0 END) / 										
		                    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-2,a.TransactionMonth)  THEN 1  ELSE 0 END) ,0) AS FLOAT)  AS Avg_Last_3M_Nof_Balance_Chg_InOverdraft,																																									      
	    SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-5,a.TransactionMonth)  THEN b.Nof_Balance_Chg_InOverdraft ELSE 0 END) / 										  
			                CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-5,a.TransactionMonth)  THEN 1  ELSE 0 END),0) AS FLOAT)  AS Avg_Last_6M_Nof_Balance_Chg_InOverdraft,


		SUM(b.Nof_Balance_Change) /CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-2,a.TransactionMonth)  THEN b.Nof_Balance_Chg_InOverdraft ELSE 0 END),0) AS FLOAT) AS Rate_Nof_Balance_Chg_InOverdraft_M_3M,
		SUM(b.Nof_Balance_Change)/ CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-5,a.TransactionMonth)  THEN b.Nof_Balance_Chg_InOverdraft ELSE 0 END),0) AS FLOAT) AS Rate_Nof_Balance_Chg_InOverdraft_M_6M,
		SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-2,a.TransactionMonth)  THEN b.Nof_Balance_Chg_InOverdraft ELSE 0 END)/
		        CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Balance_Month) >= DATEADD(MONTH,-5,a.TransactionMonth)  THEN b.Nof_Balance_Chg_InOverdraft ELSE 0 END),0) AS FLOAT) Rate_Nof_Balance_Chg_InOverdraft_3M_6M


INTO #FO_Distinct_Overdraft_Trends
FROM      apstempdb.dbo.FO_Attrition_Feature_Base a
LEFT join
----months only have balance transaction
	(
	SELECT a.ACCNO, a.TransactionMonth AS Balance_Month,AVG(FINAMT) Avg_Monthly_FINAMT_Cleare_Balance, 
										   SUM(CASE WHEN finamt < 0 THEN ABS(finamt) ELSE 0 END) Monthly_Used_Overdraft_Amt,
										   COUNT(*) Nof_Balance_Change,
										   SUM(CASE WHEN finamt < 0 THEN 1 ELSE 0 END) Nof_Balance_Chg_InOverdraft,
										   MAX(Overdraft_Limit) Max_Overdraft_Limit_in_Month,
										   MAX(ROW_NUM) NofMaxDays_with_Same_Balance_InMonth
   FROM   apstempdb.dbo.FODistinct_Overdraft_Usage a
  -- WHERE  ACCNO IN ('80000100345997','80000100489545','80000100432184','80000100101861','80000100104741')
   GROUP BY  a.ACCNO, a.TransactionMonth
   --ORDER BY 1,2 ASC
   )b
ON 			a.ACCNO=b.ACCNO
WHERE       b.Balance_Month >= DATEADD(MONTH	,-5,a.TransactionMonth)
AND		    b.Balance_Month <= a.TransactionMonth
--and  A.ACCNO IN ('80000100345997','80000100489545','80000100432184','80000100101861','80000100104741')
group BY  a.ACCNO, a.TransactionMonth
--ORDER BY 1,2 asc

----------------------------------------------------------------------

DROP TABLE IF EXISTS #FO_Overdraft_Delta
SELECT  a.ACCNO, a.TransactionMonth,

        (Avg_Monthly_FINAMT_Cleare_Balance -Avg_Last_3M_FINAMT_Cleare_Balance) / CAST(NULLIF(Avg_Last_3M_FINAMT_Cleare_Balance,0) AS FLOAT) AS Delta_Avg_FINAMT_Cleare_Balance_Chg_M_3M,
	    (Avg_Monthly_FINAMT_Cleare_Balance -Avg_Last_6M_FINAMT_Cleare_Balance) / CAST(NULLIF(Avg_Last_6M_FINAMT_Cleare_Balance,0) AS FLOAT) AS Delta_Avg_FINAMT_Cleare_Balance_Chg_M_6M,
		(Avg_Last_3M_FINAMT_Cleare_Balance -Avg_Last_6M_FINAMT_Cleare_Balance) / CAST(NULLIF(Avg_Last_6M_FINAMT_Cleare_Balance,0) AS FLOAT) AS Delta_Avg_FINAMT_Cleare_Balance_Chg_3M_6M,

		(Last_Month_Nof_Balance_Change -Avg_Last_3M_Nof_Balance_Change) / CAST(NULLIF(Avg_Last_3M_Nof_Balance_Change,0) AS FLOAT)  AS  Delta_Avg_Nof_Balance_Chg_M_3M,
	    (Last_Month_Nof_Balance_Change -Avg_Last_6M_Nof_Balance_Change) / CAST(NULLIF(Avg_Last_6M_Nof_Balance_Change,0) AS FLOAT)  AS  Delta_Avg_Nof_Balance_Chg_M_6M,
		(Avg_Last_3M_Nof_Balance_Change -Avg_Last_6M_Nof_Balance_Change) / CAST(NULLIF(Avg_Last_6M_Nof_Balance_Change,0) AS FLOAT) AS Delta_Avg_Nof_Balance_Chg_3M_6M,


		(Last_Month_Nof_Balance_Chg_InOverdraft -Avg_Last_3M_Nof_Balance_Chg_InOverdraft) / CAST(NULLIF(Avg_Last_3M_Nof_Balance_Chg_InOverdraft,0) AS FLOAT) AS  Delta_Avg_Nof_Balance_Chg_InOverdraft_M_3M,
	    (Last_Month_Nof_Balance_Chg_InOverdraft -Avg_Last_6M_Nof_Balance_Chg_InOverdraft) / CAST(NULLIF(Avg_Last_6M_Nof_Balance_Chg_InOverdraft,0) AS FLOAT) AS  Delta_Avg_Nof_Balance_Chg_InOverdraft_M_6M,
		(Avg_Last_3M_Nof_Balance_Chg_InOverdraft -Avg_Last_6M_Nof_Balance_Chg_InOverdraft) / CAST(NULLIF(Avg_Last_6M_Nof_Balance_Chg_InOverdraft,0) AS FLOAT) AS Delta_Avg_Nof_Balance_Chg_InOverdraft_3M_6M

INTO  #FO_Overdraft_Delta
FROM #FO_Distinct_Overdraft_Trends a
--WHERE  A.ACCNO IN ('80000100345997','80000100489545','80000100432184','80000100101861','80000100104741')
--ORDER BY 1,2 asc




-------Creation of Final Overdraft Table

DROP TABLE IF EXISTS warehouseuserdb.dbo.FO_Overdraft

SELECT acm.ACCNO, acm.TransactionMonth,
		a.Max_Overdraft_Limit_in_Month,
		a.Avg_Monthly_Used_Overdraft_Amt,
		a.Rate_of_Avg_Overdraft_Amt_in_Month,
		a.Nof_Balance_Change,
	    a.Nof_Balance_Chg_InOverdraft,
		a.Rate_of_Avg_Overdraft_Count_in_Month,

		------------------

		b.Avg_Monthly_FINAMT_Cleare_Balance,
		b.Avg_Last_2M_FINAMT_Cleare_Balance,
		b.Avg_Last_3M_FINAMT_Cleare_Balance,
		b.Avg_Last_6M_FINAMT_Cleare_Balance,
		b.Last_Month_Nof_Balance_Change,
		b.Tot_Nof_Balance_Change_in_2M,
		b.Tot_Nof_Balance_Change_in_3M,
		b.Tot_Nof_Balance_Change_in_6M,
		b.Avg_Last_2M_Nof_Balance_Change,
		b.Avg_Last_3M_Nof_Balance_Change,
		b.Avg_Last_6M_Nof_Balance_Change,
		b.Rate_Tot_Nof_Balance_Change_M_3M,
		b.Rate_Tot_Nof_Balance_Change_M_6M,
		b.Rate_Tot_Nof_Balance_Change_3M_6M,
		b.Last_Month_Nof_Balance_Chg_InOverdraft,
		b.Last_2M_Nof_Balance_Chg_InOverdraft,
		b.Last_3M_Nof_Balance_Chg_InOverdraft,
		b.Last_6M_Nof_Balance_Chg_InOverdraft,
		b.Avg_Last_2M_Nof_Balance_Chg_InOverdraft,
		b.Avg_Last_3M_Nof_Balance_Chg_InOverdraft,
		b.Avg_Last_6M_Nof_Balance_Chg_InOverdraft,
		b.Rate_Nof_Balance_Chg_InOverdraft_M_3M,
		b.Rate_Nof_Balance_Chg_InOverdraft_M_6M,
		b.Rate_Nof_Balance_Chg_InOverdraft_3M_6M,

		c.Delta_Avg_FINAMT_Cleare_Balance_Chg_M_3M,
		c.Delta_Avg_FINAMT_Cleare_Balance_Chg_M_6M,
		c.Delta_Avg_FINAMT_Cleare_Balance_Chg_3M_6M,
		c.Delta_Avg_Nof_Balance_Chg_M_3M,
		c.Delta_Avg_Nof_Balance_Chg_M_6M,
		c.Delta_Avg_Nof_Balance_Chg_3M_6M,
		c.Delta_Avg_Nof_Balance_Chg_InOverdraft_M_3M,
		c.Delta_Avg_Nof_Balance_Chg_InOverdraft_M_6M,
		c.Delta_Avg_Nof_Balance_Chg_InOverdraft_3M_6M

INTO         warehouseuserdb.dbo.FO_Overdraft
FROM         apstempdb.dbo.FO_Attrition_Feature_Base acm
LEFT JOIN    #FO_Distinct_Overdraft_Rates a
ON           acm.ACCNO=a.ACCNO
AND          acm.TransactionMonth  =a.TransactionMonth
LEFT JOIN    #FO_Distinct_Overdraft_Trends b
ON           acm.ACCNO=b.ACCNO
AND          acm.TransactionMonth  =b.TransactionMonth 
LEFT JOIN    #FO_Overdraft_Delta c
ON           acm.ACCNO=c.ACCNO
AND          acm.TransactionMonth  =c.TransactionMonth  

--SELECT *
--FROM   warehouseuserdb.dbo.FO_Overdraft
--WHERE  ACCNO IN('80000100345997','80000100489545','80000100432184','80000100101861','80000100104741')
--ORDER  BY 1,2 ASC