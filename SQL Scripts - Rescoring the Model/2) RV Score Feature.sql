


DECLARE     @scoringmonth  DATE = EOMONTH('2023-02-28')
DECLARE		@startMonth DATE =  DATEADD(dd, -( DAY( DATEADD(month,-6,@scoringmonth) ) -1 ), DATEADD(month,-6,@scoringmonth));--going to 6 months back from the scoring month and selecting the first day.
DECLARE		@endMonth   DATE =  DATEADD(day,+1,@scoringmonth) -- Added +1 day to the latest closed month to don't miss last day's transactions since they will appair the fisrt day of the next month


DROP TABLE IF EXISTS apstempdb.dbo.FO_Attrition_Customer_Scores
SELECT *
INTO   apstempdb.dbo.FO_Attrition_Customer_Scores
FROM
		(
		SELECT a.ACCNO,a.TransactionMonth,MAX(Score_Month) Max_Score_Month,ROW_NUMBER() OVER (PARTITION BY a.ACCNO, a.TransactionMonth order BY MAX(Score_Month) desc) row_num,b.RVILF04

		FROM   apstempdb.dbo.FO_Attrition_Feature_Base a
		LEFT JOIN 
					(
					SELECT LEFT(Reference10,14) ACCNO, EOMONTH(FileDate) Score_Month,CONVERT(INT,RVILF04) AS RVILF04
					FROM   flatfile.dbo.EquDecisionBatchFileReturnArchivev2
					WHERE  FileDate>= @startMonth 
					)b
		ON     A.ACCNO= B.ACCNO
		where  Score_Month <= TransactionMonth
		GROUP BY a.ACCNO,a.TransactionMonth,b.RVILF04
		)c
WHERE row_num=1




