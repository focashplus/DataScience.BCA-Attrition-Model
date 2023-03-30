
---Main Population by months

SELECT TransactionMonth,COUNT(*),COUNT(DISTINCT ACCNO)
FROM   apstempdb.dbo.FO_Attrition_Feature_Base
GROUP  BY TransactionMonth
ORDER  BY 1 ASC


-- Table with row for each month

DROP TABLE	IF EXISTS #allDates

SELECT		DISTINCT
			TransactionMonth AS AllDates
INTO		#allDates
FROM		apstempdb.dbo.FO_Attrition_Feature_Base
ORDER BY	TransactionMonth

-- Now cross-apply this with accounts

DROP TABLE	IF EXISTS #accountMonth

SELECT		accs.ACCNO,
			ald.AllDates
INTO		#accountMonth
FROM		#allDates ald
CROSS APPLY (SELECT DISTINCT ACCNO FROM apstempdb.dbo.FO_Attrition_Feature_Base
) accs


-- We need to make sure that months prior to the first actual use in the dataset are not included for an ACCNO

DELETE		acm
FROM		#accountMonth acm
INNER JOIN	(
				SELECT		bmsc.ACCNO,
							MIN(TransactionMonth) MinTransactionMonth
				FROM		apstempdb.dbo.FO_Attrition_Feature_Base bmsc
				GROUP BY	bmsc.ACCNO
			) minmth
ON			minmth.ACCNO = acm.ACCNO
WHERE		acm.AllDates < minmth.MinTransactionMonth


-- Join the table of accounts and dates to the actual data

DROP TABLE	IF EXISTS #annualView

SELECT		acm.ACCNO,
            acm.AllDates,
			CASE WHEN fds.ACCNO IS NULL THEN 1 ELSE 0 END Attrition -- attrition flag from the table, either they closed, or if the month isn't there they didn't use the card
INTO		#annualView
FROM		#accountMonth acm
LEFT JOIN	apstempdb.dbo.FO_Attrition_Feature_Base fds
ON			fds.ACCNO = acm.ACCNO
AND			fds.TransactionMonth = acm.AllDates



-- Only looking at accounts which haven't been closed to understand the dormancy flag for attrition
-- Creating a 3mth and a 6mth forward looking window to understand relationship between dormant months and attrition using a 3mth and 6mth inactivity definition

DECLARE		@lastMonth DATE
SELECT		@lastMonth = MAX(AllDates) FROM #annualView

DROP TABLE	IF EXISTS #dormancyBase

SELECT		anv.ACCNO,
			anv.AllDates,
			anv.Attrition, -- did they use the card this month
			SUM(anv.Attrition) OVER (PARTITION BY anv.ACCNO, frwd.NextUsed ORDER BY anv.AllDates) MonthsDormant,--to make cumulative dormant period
			frwd.NextUsed,
			DATEDIFF(MONTH,anv.AllDates, frwd.NextUsed) MonthsUntilUse,--time difference between the last 2 period
			DATEDIFF(MONTH,anv.AllDates,@lastMonth) MonthsToEndOfTimeframe,-- time difference with the latest transaction date in the table2,
			NotUsedInNext3mth,
	        NotUsedInNext6mth
INTO		#dormancyBase
FROM		#annualView anv
LEFT JOIN (
				SELECT		anv2.ACCNO,
							anv2.AllDates,
							MIN(anv3.AllDates) NextUsed,
							CASE WHEN ISNULL(MIN(anv3.AllDates),GETDATE()) < DATEADD(MONTH,6,anv2.AllDates) THEN 0 ELSE 1 END NotUsedInNext6mth, 					
		          	        CASE WHEN ISNULL(MIN(anv3.AllDates),GETDATE()) < DATEADD(MONTH,3,anv2.AllDates) THEN 0 ELSE 1 END NotUsedInNext3mth
				FROM		#annualView anv2
				LEFT JOIN	#annualView anv3
				ON			anv3.ACCNO = anv2.ACCNO
				AND			anv3.AllDates > anv2.AllDates
				AND			anv3.Attrition = 0
			--	where  anv2.ACCNO IN ('80000100374250', '80000100100029')
				GROUP BY	anv2.ACCNO,
                            anv2.AllDates
						--	ORDER BY 1,2 asc
			) frwd
ON			frwd.ACCNO = anv.ACCNO
AND			frwd.AllDates = anv.AllDates
GROUP BY anv.ACCNO,
			anv.AllDates,
			anv.Attrition,frwd.NextUsed,NotUsedInNext3mth,NotUsedInNext6mth


-----------Final Table Creations with Dormancy Targets
-----------------------------------------------------------------------------------

DROP TABLE	IF EXISTS  apstempdb.dbo.FO_DormancyInactivityWithAllPopulation

SELECT  acm.ACCNO, acm.ReviewDate, acm.TransactionMonth,
		db.Attrition, -- did they use the card this month
		db.MonthsDormant,--to make cumulative dormant period
		db.NextUsed,
		db.MonthsToEndOfTimeframe,-- time difference with the latest transaction date in the table2,
		--db.NotUsedInNext3mth AS Target3M_Dormancy,
		--db.NotUsedInNext6mth  AS Target6M_Dormancy
		CASE WHEN db.MonthsToEndOfTimeframe >= 3 THEN db.NotUsedInNext3mth ELSE NULL END  AS Target3M_Dormancy,
		CASE WHEN db.MonthsToEndOfTimeframe >= 6 THEN db.NotUsedInNext6mth ELSE NULL END  AS Target6M_Dormancy
INTO   apstempdb.dbo.FO_DormancyInactivityWithAllPopulation
FROM   apstempdb.dbo.FO_Attrition_Feature_Base acm
LEFT   JOIN   #dormancyBase db
ON     acm. Accno= db.Accno
AND    acm.TransactionMonth=db.AllDates
--WHERE  acm.ACCNO IN ('80000100374250', '80000100100029','80000100100156','80000100100162','80000100100260','80000100100287') 
--ORDER BY 1,3 asc

--------------------------------

SELECT COUNT(*)
FROM   apstempdb.dbo.FO_DormancyInactivityWithAllPopulation



SELECT TransactionMonth,COUNT(*) Nof_Customers,
       SUM(Target3M_Dormancy) AS SUM_Target3M_Dormancy,
	   SUM(Target3M_Dormancy) / CAST(COUNT(*) AS FLOAT) AS Rate_of_Target3M_Dormancy,
       SUM(Target6M_Dormancy) AS SUM_Target6M_Dormancy,
	   SUM(Target6M_Dormancy) / CAST(COUNT(*) AS FLOAT)  AS Rate_of_Target6M_Dormancy
FROM   apstempdb.dbo.FO_DormancyInactivityWithAllPopulation
GROUP  BY TransactionMonth
ORDER  BY 1 ASC

		
SELECT a.TransactionMonth,COUNT(*) Nof_Customers,
       SUM(Target3M_Dormancy) AS SUM_Target3M_Dormancy,
	   SUM(Target3M_Dormancy) / CAST(COUNT(*) AS FLOAT) AS Rate_of_Target3M_Dormancy,
       SUM(Target6M_Dormancy) AS SUM_Target6M_Dormancy,
	   SUM(Target6M_Dormancy) / CAST(COUNT(*) AS FLOAT)  AS Rate_of_Target6M_Dormancy
FROM    warehouseuserdb.dbo.FO_AttritionModel_ActiveCustomersByMonth a
LEFT JOIN apstempdb.dbo.FO_DormancyInactivityWithAllPopulation b
ON a.ACCNO=b.ACCNO
AND a.TransactionMonth=b.TransactionMonth
GROUP  BY a.TransactionMonth
ORDER  BY 1 ASC






