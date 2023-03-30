

DROP TABLE IF EXISTS #only_accounts

SELECT DISTINCT ACCNO AS ACCNO
INTO #only_accounts
FROM apstempdb.dbo.FO_Attrition_Feature_Base 
  
  ----------------------

DECLARE     @scoringmonth  DATE = EOMONTH('2023-02-28')
DECLARE		@startMonth DATE =  DATEADD(dd, -( DAY( DATEADD(MONTH,-6,@scoringmonth) ) -1 ), DATEADD(MONTH,-6,@scoringmonth));--going to 6 months back from the scoring month and selecting the first day.
DECLARE		@endMonth   DATE =  DATEADD(DAY,+1,@scoringmonth) -- Added +1 day to the latest closed month to don't miss last day's transactions since they will appair the fisrt day of the next month


DROP TABLE IF EXISTS apstempdb.dbo.FO_Online_Banking_Part1
SELECT
                    ac.ACCNO,  EOMONTH(ipl.Created) Online_Banking_Login_Month,
	                COUNT(*) Total_Online_Banking_Interaction,
					SUM(CASE WHEN  ipl.PageAction = 'ValidUser' THEN 1 ELSE 0 END) AS Nof_Successful_Login
					
        INTO        apstempdb.dbo.FO_Online_Banking_Part1
        FROM        #only_accounts ac
		LEFT JOIN   WarehouseCAPDB.dbo.Cards crd (NOLOCK)
		ON          ac.ACCNO= crd.PrimaryCardNumber
		INNER JOIN  WarehouseCAPDB.dbo.UserAccounts uac (NOLOCK)
	    ON          crd.Number = uac.PersonID
		INNER JOIN  WarehouseArchive.dbo.IPLogging ipl (NOLOCK)
		ON          uac.UserName = ipl.APSUserName
		INNER JOIN  WarehouseCAPDB.usersecurity.TrustedDevice tdv (NOLOCK)
		ON          tdv.DeviceID = ipl.DeviceID
		AND         tdv.UserAccountID = uac.UserAccountID
		AND         ipl.Created >= tdv.DateCreated
		AND         ISNULL(tdv.DeletedDate, GETDATE()) > ipl.Created
		WHERE       ipl.Created>=@startMonth
		--AND       crd.PrimaryCardNumber IN ('80000100100029','81000100100113','81000100100109')---('80000100451788','80000100475619','80000100466395','80000100448770')
		GROUP BY ac.ACCNO, EOMONTH(ipl.Created)
		--ORDER BY 1,2 asc

----------------------


DROP TABLE IF EXISTS apstempdb.dbo.FO_Online_Banking_Part2
SELECT     ac.ACCNO, ac.TransactionMonth,

            ----Total_Online_Banking_Interaction   
			SUM( CASE WHEN b.Online_Banking_Login_Month >= DATEADD(MONTH,-1,ac.TransactionMonth)  THEN  b.Total_Online_Banking_Interaction  ELSE 0 END)  AS Last_2M_Total_Online_Banking_Interaction,

		    CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Online_Banking_Login_Month) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN  b.Nof_Successful_Login ELSE 0 END),0) AS FLOAT) /		
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Online_Banking_Login_Month) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN  b.Nof_Successful_Login ELSE 0 END),0) AS FLOAT) AS Rate_Nof_Successful_Login_3M_6M


INTO		apstempdb.dbo.FO_Online_Banking_Part2
FROM		apstempdb.dbo.FO_Attrition_Feature_Base ac
INNER JOIN	apstempdb.dbo.FO_Online_Banking_Part1 b
ON          ac.ACCNO=b.ACCNO
WHERE       b.Online_Banking_Login_Month >= DATEADD(MONTH	,-5,ac.TransactionMonth)
AND		    b.Online_Banking_Login_Month <= ac.TransactionMonth
GROUP BY    ac.ACCNO, ac.TransactionMonth
--ORDER BY  1,2 asc


----------------------------------------------------------------------------------------------------
------------------------------Averages------------------------------------------------

DROP TABLE IF EXISTS apstempdb.dbo.FO_Online_Banking_Averages

SELECT  a.ACCNO,a.TransactionMonth,
		Last_2M_Total_Online_Banking_Interaction /CAST(2 AS FLOAT)  Avg_Last_2M_Total_Online_Banking_Interaction
INTO  apstempdb.dbo.FO_Online_Banking_Averages
FROM  apstempdb.dbo.FO_Online_Banking_Part2 a

----------------------------------------------------------------------------------------------------
------------------------------Standardizations------------------------------------------------

DROP TABLE IF EXISTS #ZScores
SELECT a.ACCNO,
	    STDEV(Avg_Last_2M_Total_Online_Banking_Interaction)  AS STDEV_Avg_Last_2M_Total_Online_Banking_Interaction, 
		AVG(Avg_Last_2M_Total_Online_Banking_Interaction)    AS MEAN_Avg_Last_2M_Total_Online_Banking_Interaction
INTO #ZScores
FROM   apstempdb.dbo.FO_Online_Banking_Averages a
GROUP BY a.ACCNO 


------------

DROP TABLE IF EXISTS apstempdb.dbo.FO_Online_Banking_With_ZValues

SELECT a.*,

        (Avg_Last_2M_Total_Online_Banking_Interaction - MEAN_Avg_Last_2M_Total_Online_Banking_Interaction)/ NULLIF( STDEV_Avg_Last_2M_Total_Online_Banking_Interaction,0)  AS Z_Value_Avg_Last_2M_Total_Online_Banking_Int

INTO  apstempdb.dbo.FO_Online_Banking_With_ZValues
FROM apstempdb.dbo.FO_Online_Banking_Averages a
LEFT JOIN  #ZScores b
ON   a.ACCNO=b.ACCNO  


