  
    DROP TABLE IF EXISTS #only_accounts

	SELECT DISTINCT ACCNO AS ACCNO
	INTO #only_accounts
	FROM apstempdb.dbo.FO_Attrition_Feature_Base 
  
  ----------------------

DROP TABLE IF EXISTS apstempdb.dbo.FO_Online_Banking_Part1
SELECT
                    ac.ACCNO,  EOMONTH(ipl.Created) Online_Banking_Login_Month,
	                COUNT(*) Total_Online_Banking_Interaction,
					SUM(CASE WHEN  ipl.PageAction = 'ValidUser' THEN 1 ELSE 0 END) AS Nof_Successful_Login,
					SUM(CASE WHEN  ipl.PageAction = 'InvalidUser' THEN 1 ELSE 0 END) AS Nof_Unsuccessful_Login,
					SUM(CASE WHEN  ipl.PageAction = 'ValidUser' THEN 1 ELSE 0 END)/  (CAST(NULLIF(COUNT(*),0) AS FLOAT)) AS Rate_of_Successful_Login,
					---
					SUM(CASE WHEN tdv.DeviceType IS NULL THEN 1 ELSE 0 END)   AS Connection_Not_Trusted_Device,
					SUM(CASE WHEN tdv.DeviceType='Android' THEN 1 ELSE 0 END) AS Connection_Android_Device,
					SUM(CASE WHEN tdv.DeviceType='iOS' THEN 1 ELSE 0 END)     AS Connection_iOS_Device,
					SUM(CASE WHEN tdv.DeviceType IS null THEN 1 ELSE 0 END)/ (CAST(NULLIF(COUNT(*),0) AS FLOAT)) AS Rate_of_Not_Trusted_Login,
					SUM(CASE WHEN tdv.DeviceType='Android' THEN 1 ELSE 0 END) /(CAST(NULLIF(COUNT(*),0) AS FLOAT)) AS Rate_of_Android_Login,
					SUM(CASE WHEN tdv.DeviceType='iOS' THEN 1 ELSE 0 END) /(CAST(NULLIF(COUNT(*),0) AS FLOAT)) AS Rate_of_iOS_Login,
					-----
					SUM(CASE WHEN ipl.SourceSystem='Digital' THEN 1 ELSE 0 END) AS Nof_Logins_by_Website,
					SUM(CASE WHEN ipl.SourceSystem='MobileX' THEN 1 ELSE 0 END) AS Nof_Logins_by_MobileApp,
					SUM(CASE WHEN ipl.SourceSystem IS null THEN 1 ELSE 0 END) AS Nof_Logins_by_UnknownSource,
					SUM(CASE WHEN ipl.SourceSystem='OpenBankingWeb' THEN 1 ELSE 0 END) AS Nof_Logins_by_OpenBankingWeb,
                    
					SUM(CASE WHEN ipl.SourceSystem='Digital' THEN 1 ELSE 0 END) /  (CAST(NULLIF(COUNT(*),0) AS FLOAT)) AS Rate_of_Logins_by_Website,
					SUM(CASE WHEN ipl.SourceSystem='MobileX' THEN 1 ELSE 0 END) /  (CAST(NULLIF(COUNT(*),0) AS FLOAT)) AS Rate_of_Logins_by_MobileX,
					SUM(CASE WHEN ipl.SourceSystem IS null THEN 1 ELSE 0 END) /  (CAST(NULLIF(COUNT(*),0) AS FLOAT)) AS Rate_of_Logins_by_UnknownSource,
					SUM(CASE WHEN ipl.SourceSystem='OpenBankingWeb' THEN 1 ELSE 0 END) /  (CAST(NULLIF(COUNT(*),0) AS FLOAT)) AS Rate_of_Logins_by_OpenBankingWeb
        INTO        apstempdb.dbo.FO_Online_Banking_Part1
        FROM        #only_accounts ac
		LEFT JOIN   WarehouseCAPDB.dbo.Cards crd (NOLOCK)
		ON          ac.ACCNO= crd.PrimaryCardNumber
		INNER JOIN  WarehouseCAPDB.dbo.UserAccounts uac (NOLOCK)
	    ON          crd.Number = uac.PersonID
		INNER JOIN  WarehouseArchive.dbo.IPLogging ipl (NOLOCK)
		ON          uac.UserName = ipl.APSUserName
		inner JOIN  WarehouseCAPDB.usersecurity.TrustedDevice tdv (NOLOCK)
		ON          tdv.DeviceID = ipl.DeviceID
		AND         tdv.UserAccountID = uac.UserAccountID
		AND         ipl.Created >= tdv.DateCreated
		AND         ISNULL(tdv.DeletedDate, GETDATE()) > ipl.Created
		WHERE       ipl.Created>='2021-01-01'
		--AND       crd.PrimaryCardNumber IN ('80000100100029','81000100100113','81000100100109')---('80000100451788','80000100475619','80000100466395','80000100448770')
		GROUP BY ac.ACCNO, EOMONTH(ipl.Created)
		--ORDER BY 1,2 asc

----------------------


DROP TABLE IF EXISTS apstempdb.dbo.FO_Online_Banking_Part2
SELECT ac.ACCNO, ac.TransactionMonth, 
            ----Total_Online_Banking_Interaction
            SUM( CASE WHEN b.Online_Banking_Login_Month = ac.TransactionMonth   THEN b.Total_Online_Banking_Interaction   ELSE 0 END)                    AS Last_Total_Online_Banking_Interaction,
			SUM( CASE WHEN b.Online_Banking_Login_Month >= DATEADD(MONTH,-1,ac.TransactionMonth)  THEN  b.Total_Online_Banking_Interaction  ELSE 0 END)  AS Last_2M_Total_Online_Banking_Interaction,
			SUM( CASE WHEN b.Online_Banking_Login_Month >= DATEADD(MONTH,-2,ac.TransactionMonth)  THEN  b.Total_Online_Banking_Interaction  ELSE 0 END)  AS Last_3M_Total_Online_Banking_Interaction,
			SUM( CASE WHEN b.Online_Banking_Login_Month >= DATEADD(MONTH,-5,ac.TransactionMonth)  THEN  b.Total_Online_Banking_Interaction  ELSE 0 END)  AS Last_6M_Total_Online_Banking_Interaction,

			CAST(SUM( CASE WHEN b.Online_Banking_Login_Month = ac.TransactionMonth  THEN b.Total_Online_Banking_Interaction ELSE 0 END)  AS FLOAT) /
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Online_Banking_Login_Month) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN  b.Total_Online_Banking_Interaction ELSE 0 END),0) AS float) AS Rate_Total_Online_Banking_Interaction_M_3M,

			CAST(SUM( CASE WHEN b.Online_Banking_Login_Month = ac.TransactionMonth  THEN b.Total_Online_Banking_Interaction ELSE 0 END)  AS FLOAT) /
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Online_Banking_Login_Month) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN  b.Total_Online_Banking_Interaction ELSE 0 END),0) AS float) AS Rate_Total_Online_Banking_Interaction_M_6M,

			CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Online_Banking_Login_Month) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN  b.Total_Online_Banking_Interaction ELSE 0 END),0) AS float) /
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Online_Banking_Login_Month) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN  b.Total_Online_Banking_Interaction ELSE 0 END),0) AS float) AS Rate_Total_Online_Banking_Interaction_3M_6M,
  
            ----NOF SUCCESSFUL LOGIN
			SUM( CASE WHEN b.Online_Banking_Login_Month = ac.TransactionMonth   THEN b.Nof_Successful_Login   ELSE 0 END)    AS Last_Nof_Successful_Login,
			SUM( CASE WHEN b.Online_Banking_Login_Month >= DATEADD(MONTH,-1,ac.TransactionMonth)  THEN  b.Nof_Successful_Login  ELSE 0 END)  AS Last_2M_Nof_Successful_Login,
			SUM( CASE WHEN b.Online_Banking_Login_Month >= DATEADD(MONTH,-2,ac.TransactionMonth)  THEN  b.Nof_Successful_Login  ELSE 0 END)  AS Last_3M_Nof_Successful_Login,
			SUM( CASE WHEN b.Online_Banking_Login_Month >= DATEADD(MONTH,-5,ac.TransactionMonth)  THEN  b.Nof_Successful_Login  ELSE 0 END)  AS Last_6M_Nof_Successful_Login,

			CAST(SUM( CASE WHEN b.Online_Banking_Login_Month = ac.TransactionMonth  THEN b.Nof_Successful_Login ELSE 0 END)  AS FLOAT) /
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Online_Banking_Login_Month) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN  b.Nof_Successful_Login ELSE 0 END),0) AS float) AS Rate_Nof_Successful_Login_M_3M,

			CAST(SUM( CASE WHEN b.Online_Banking_Login_Month = ac.TransactionMonth  THEN b.Nof_Successful_Login ELSE 0 END)  AS FLOAT) /
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Online_Banking_Login_Month) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN  b.Nof_Successful_Login ELSE 0 END),0) AS float) AS Rate_Nof_Successful_Login_M_6M,
																																							 
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Online_Banking_Login_Month) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN  b.Nof_Successful_Login ELSE 0 END),0) AS float) /		
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Online_Banking_Login_Month) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN  b.Nof_Successful_Login ELSE 0 END),0) AS float) AS Rate_Nof_Successful_Login_3M_6M,


			 ---NOF UNSUCCESSFUL LOGIN
			SUM( CASE WHEN b.Online_Banking_Login_Month = ac.TransactionMonth                     THEN  b.Nof_Unsuccessful_Login  ELSE 0 END)  AS Last_Nof_Unsuccessful_Login,
			SUM( CASE WHEN b.Online_Banking_Login_Month >= DATEADD(MONTH,-1,ac.TransactionMonth)  THEN  b.Nof_Unsuccessful_Login  ELSE 0 END)  AS Last_2M_Nof_Unsuccessful_Login, 
			SUM( CASE WHEN b.Online_Banking_Login_Month >= DATEADD(MONTH,-2,ac.TransactionMonth)  THEN  b.Nof_Unsuccessful_Login  ELSE 0 END)  AS Last_3M_Nof_Unsuccessful_Login,
			SUM( CASE WHEN b.Online_Banking_Login_Month >= DATEADD(MONTH,-5,ac.TransactionMonth)  THEN  b.Nof_Unsuccessful_Login  ELSE 0 END)  AS Last_6M_Nof_Unsuccessful_Login,

			CAST(SUM( CASE WHEN b.Online_Banking_Login_Month = ac.TransactionMonth  THEN b.Nof_Unsuccessful_Login ELSE 0 END)  AS FLOAT) /
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Online_Banking_Login_Month) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN  b.Nof_Unsuccessful_Login ELSE 0 END),0) AS FLOAT) AS Rate_Nof_Unsuccessful_Login_M_3M,
																																													   
			CAST(SUM( CASE WHEN b.Online_Banking_Login_Month = ac.TransactionMonth  THEN b.Nof_Unsuccessful_Login ELSE 0 END)  AS FLOAT) /											   
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Online_Banking_Login_Month) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN  b.Nof_Unsuccessful_Login ELSE 0 END),0) AS FLOAT) AS Rate_Nof_Unsuccessful_Login_M_6M,
																																	 												  
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Online_Banking_Login_Month) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN  b.Nof_Unsuccessful_Login ELSE 0 END),0) AS FLOAT) /		
			CAST(NULLIF(SUM( CASE WHEN EOMONTH(b.Online_Banking_Login_Month) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN  b.Nof_Unsuccessful_Login ELSE 0 END),0) AS FLOAT) AS Rate_Nof_Unsuccessful_Login_3M_6M

INTO		apstempdb.dbo.FO_Online_Banking_Part2
FROM		apstempdb.dbo.FO_Attrition_Feature_Base ac
INNER JOIN	apstempdb.dbo.FO_Online_Banking_Part1 b
ON          ac.ACCNO=b.ACCNO
WHERE       b.Online_Banking_Login_Month >= DATEADD(MONTH	,-5,ac.TransactionMonth)
AND		    b.Online_Banking_Login_Month <= ac.TransactionMonth
--AND       ac.ACCNO IN ('80000100100029','81000100100113','81000100100109')---('80000100451788','80000100475619','80000100466395','80000100448770')
GROUP BY    ac.ACCNO, ac.TransactionMonth
--ORDER BY  1,2 asc


----------------------------------------------------------------------------------------------------
------------------------------Averages------------------------------------------------

DROP TABLE IF EXISTS apstempdb.dbo.FO_Online_Banking_Averages

SELECT  a.ACCNO,a.TransactionMonth,
        Last_Total_Online_Banking_Interaction,
	    Last_2M_Total_Online_Banking_Interaction,
	    Last_3M_Total_Online_Banking_Interaction,
	    Last_6M_Total_Online_Banking_Interaction,
		Last_2M_Total_Online_Banking_Interaction /CAST(2 AS FLOAT)  Avg_Last_2M_Total_Online_Banking_Interaction,
		Last_3M_Total_Online_Banking_Interaction /CAST(3 AS FLOAT)  Avg_Last_3M_Total_Online_Banking_Interaction,
		Last_6M_Total_Online_Banking_Interaction /CAST(6 AS FLOAT)  Avg_Last_6M_Total_Online_Banking_Interaction,
		
		--------------------
		Last_Nof_Successful_Login,
		Last_2M_Nof_Successful_Login,
		Last_3M_Nof_Successful_Login,
		Last_6M_Nof_Successful_Login,
		Last_2M_Nof_Successful_Login/ CAST(2 AS FLOAT)  Avg_Last_2M_Nof_Successful_Login,
		Last_3M_Nof_Successful_Login/ CAST(3 AS FLOAT)  Avg_Last_3M_Nof_Successful_Login,
		Last_6M_Nof_Successful_Login/ CAST(6 AS FLOAT)  Avg_Last_6M_Nof_Successful_Login,
		-----------------
        
		Last_Nof_Unsuccessful_Login,
		Last_2M_Nof_Unsuccessful_Login,
		Last_3M_Nof_Unsuccessful_Login,
		Last_6M_Nof_Unsuccessful_Login,
		Last_2M_Nof_Unsuccessful_Login/CAST(2 AS FLOAT)   Avg_Last_2M_Nof_Unsuccessful_Login,
		Last_3M_Nof_Unsuccessful_Login/CAST(3 AS FLOAT)   Avg_Last_3M_Nof_Unsuccessful_Login,
		Last_6M_Nof_Unsuccessful_Login/CAST(6 AS FLOAT)   Avg_Last_6M_Nof_Unsuccessful_Login

INTO  apstempdb.dbo.FO_Online_Banking_Averages
FROM  apstempdb.dbo.FO_Online_Banking_Part2 a
--where a.ACCNO IN ('80000100100029','81000100100113','81000100100109')
--ORDER BY 1,2 asc

----------------------------------------------------------------------------------------------------
------------------------------Standardizations------------------------------------------------

DROP TABLE IF EXISTS #ZScores
SELECT a.ACCNO,


	    STDEV(Last_Total_Online_Banking_Interaction)         AS STDEV_Avg_Total_Online_Banking_Interaction,         AVG(Last_Total_Online_Banking_Interaction)        AS MEAN_Avg_Total_Online_Banking_Interaction,
	    STDEV(Avg_Last_2M_Total_Online_Banking_Interaction)  AS STDEV_Avg_Last_2M_Total_Online_Banking_Interaction, AVG(Avg_Last_2M_Total_Online_Banking_Interaction) AS MEAN_Avg_Last_2M_Total_Online_Banking_Interaction,
		STDEV(Avg_Last_3M_Total_Online_Banking_Interaction)  AS STDEV_Avg_Last_3M_Total_Online_Banking_Interaction, AVG(Avg_Last_3M_Total_Online_Banking_Interaction) AS MEAN_Avg_Last_3M_Total_Online_Banking_Interaction,
	    STDEV(Avg_Last_6M_Total_Online_Banking_Interaction)  AS STDEV_Avg_Last_6M_Total_Online_Banking_Interaction, AVG(Avg_Last_6M_Total_Online_Banking_Interaction) AS MEAN_Avg_Last_6M_Total_Online_Banking_Interaction,

		----------
		 
	    STDEV(Last_Nof_Successful_Login)         AS STDEV_Avg_Last_Nof_Successful_Login,    AVG(Last_Nof_Successful_Login)        AS MEAN_Avg_Last_Nof_Successful_Login,
	    STDEV(Avg_Last_2M_Nof_Successful_Login)  AS STDEV_Avg_Last_2M_Nof_Successful_Login, AVG(Avg_Last_2M_Nof_Successful_Login) AS MEAN_Avg_Last_2M_Nof_Successful_Login,
		STDEV(Avg_Last_3M_Nof_Successful_Login)  AS STDEV_Avg_Last_3M_Nof_Successful_Login, AVG(Avg_Last_3M_Nof_Successful_Login) AS MEAN_Avg_Last_3M_Nof_Successful_Login,
	    STDEV(Avg_Last_6M_Nof_Successful_Login)  AS STDEV_Avg_Last_6M_Nof_Successful_Login, AVG(Avg_Last_6M_Nof_Successful_Login) AS MEAN_Avg_Last_6M_Nof_Successful_Login,
		------------

		STDEV(Last_Nof_Unsuccessful_Login)         AS STDEV_Avg_Last_Nof_Unsuccessful_Login,      AVG(Last_Nof_Unsuccessful_Login)        AS MEAN_Avg_Last_Nof_Unsuccessful_Login,
	    STDEV(Avg_Last_2M_Nof_Unsuccessful_Login)  AS STDEV_Avg_Last_2M_Nof_Unsuccessful_Login, AVG(Avg_Last_2M_Nof_Unsuccessful_Login) AS MEAN_Avg_Last_2M_Nof_Unsuccessful_Login,
		STDEV(Avg_Last_3M_Nof_Unsuccessful_Login)  AS STDEV_Avg_Last_3M_Nof_Unsuccessful_Login, AVG(Avg_Last_3M_Nof_Unsuccessful_Login) AS MEAN_Avg_Last_3M_Nof_Unsuccessful_Login,
	    STDEV(Avg_Last_6M_Nof_Unsuccessful_Login)  AS STDEV_Avg_Last_6M_Nof_Unsuccessful_Login, AVG(Avg_Last_6M_Nof_Unsuccessful_Login) AS MEAN_Avg_Last_6M_Nof_Unsuccessful_Login
INTO #ZScores
FROM   apstempdb.dbo.FO_Online_Banking_Averages a
--where a.ACCNO IN ('80000100100029','81000100100113','81000100100109')
GROUP BY a.ACCNO 
--ORDER BY 1,2 asc


------------

DROP TABLE IF EXISTS apstempdb.dbo.FO_Online_Banking_With_ZValues

SELECT a.*,(Last_Total_Online_Banking_Interaction-MEAN_Avg_Total_Online_Banking_Interaction)                 / NULLIF(STDEV_Avg_Total_Online_Banking_Interaction,0)           AS Z_Value_Last_Total_Online_Banking_Int,
           (Avg_Last_2M_Total_Online_Banking_Interaction - MEAN_Avg_Last_2M_Total_Online_Banking_Interaction)/ NULLIF( STDEV_Avg_Last_2M_Total_Online_Banking_Interaction,0)  AS Z_Value_Avg_Last_2M_Total_Online_Banking_Int,
		   (Avg_Last_3M_Total_Online_Banking_Interaction - MEAN_Avg_Last_3M_Total_Online_Banking_Interaction)/ NULLIF( STDEV_Avg_Last_3M_Total_Online_Banking_Interaction,0)  AS Z_Value_Avg_Last_3M_Total_Online_Banking_Int,
		   (Avg_Last_6M_Total_Online_Banking_Interaction - MEAN_Avg_Last_6M_Total_Online_Banking_Interaction)/ NULLIF( STDEV_Avg_Last_6M_Total_Online_Banking_Interaction,0)  AS Z_Value_Avg_Last_6M_Total_Online_Banking_Int,

		   ------

		   (Last_Nof_Successful_Login        - MEAN_Avg_Last_Nof_Successful_Login)   / NULLIF( STDEV_Avg_Last_Nof_Successful_Login,0)     AS Z_Value_Last_Nof_Successful_Login,
           (Avg_Last_2M_Nof_Successful_Login - MEAN_Avg_Last_2M_Nof_Successful_Login)/ NULLIF( STDEV_Avg_Last_2M_Nof_Successful_Login,0)  AS Z_Value_Avg_Last_2M_Nof_Successful_Login,
		   (Avg_Last_3M_Nof_Successful_Login - MEAN_Avg_Last_3M_Nof_Successful_Login)/ NULLIF( STDEV_Avg_Last_3M_Nof_Successful_Login,0)  AS Z_Value_Avg_Last_3M_Nof_Successful_Login,
		   (Avg_Last_6M_Nof_Successful_Login - MEAN_Avg_Last_6M_Nof_Successful_Login)/ NULLIF( STDEV_Avg_Last_6M_Nof_Successful_Login,0)  AS Z_Value_Avg_Last_6M_Nof_Successful_Login,

		   ------

		   (Last_Nof_Unsuccessful_Login        - MEAN_Avg_Last_Nof_Unsuccessful_Login)   / NULLIF( STDEV_Avg_Last_Nof_Unsuccessful_Login,0)     AS Z_Value_Last_Nof_Unsuccessful_Login,
           (Avg_Last_2M_Nof_Unsuccessful_Login - MEAN_Avg_Last_2M_Nof_Unsuccessful_Login)/ NULLIF( STDEV_Avg_Last_2M_Nof_Unsuccessful_Login,0)  AS Z_Value_Avg_Last_2M_Nof_Unsuccessful_Login,
		   (Avg_Last_3M_Nof_Unsuccessful_Login - MEAN_Avg_Last_3M_Nof_Unsuccessful_Login)/ NULLIF( STDEV_Avg_Last_3M_Nof_Unsuccessful_Login,0)  AS Z_Value_Avg_Last_3M_Nof_Unsuccessful_Login,
		   (Avg_Last_6M_Nof_Unsuccessful_Login - MEAN_Avg_Last_6M_Nof_Unsuccessful_Login)/ NULLIF( STDEV_Avg_Last_6M_Nof_Unsuccessful_Login,0)  AS Z_Value_Avg_Last_6M_Nof_Unsuccessful_Login

INTO  apstempdb.dbo.FO_Online_Banking_With_ZValues
FROM apstempdb.dbo.FO_Online_Banking_Averages a
LEFT JOIN  #ZScores b
ON   a.ACCNO=b.ACCNO  


