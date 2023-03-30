

DROP TABLE IF EXISTS apstempdb.dbo.FO_Attrition_Customer_Scores
SELECT *
INTO   apstempdb.dbo.FO_Attrition_Customer_Scores
FROM
(
SELECT a.ACCNO,a.TransactionMonth,MAX(Score_Month) Max_Score_Month,ROW_NUMBER() OVER (PARTITION BY a.ACCNO, a.TransactionMonth order BY MAX(Score_Month) desc) row_num,
       b.RNILF04, b.TEILF04,b.RVILF04

FROM   apstempdb.dbo.FO_Attrition_Feature_Base a
LEFT JOIN 
			(
			SELECT LEFT(Reference10,14) ACCNO,  
				  EOMONTH(FileDate) Score_Month,
				  CONVERT(INT,RNILF04) AS RNILF04,
				  CONVERT(INT,TEILF04) AS TEILF04,
				  CONVERT(INT,RVILF04) AS RVILF04
			FROM   flatfile.dbo.EquDecisionBatchFileReturnArchivev2
			WHERE  FileDate>= '2021-01-01' 
			)b
ON     A.ACCNO= B.ACCNO
where  Score_Month <= TransactionMonth
--AND    a.ACCNO IN ('80000100415584')
GROUP BY a.ACCNO,a.TransactionMonth,b.RNILF04, b.TEILF04,b.RVILF04
--ORDER BY 1,2,3 ASC
)c
WHERE row_num=1
--ORDER BY 1,2,3 ASC










