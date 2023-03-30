
---Main Population by months

SELECT TransactionMonth,COUNT(*),COUNT(DISTINCT ACCNO)
FROM   warehouseuserdb.dbo.FO_AttritionModel_ActiveCustomersByMonth
GROUP  BY TransactionMonth
ORDER  BY 1 ASC


---------All Inactivation of the Customers in the Time Period

DECLARE		@startMonth DATE = '2021-01-01'
DECLARE		@endMonth DATE   = '2022-10-01' 

DROP TABLE	IF EXISTS #InactiveAccounts

SELECT		hist.Customer_Number ACCNO,EOMONTH(MIN(hist.ValidFrom)) Close_Date
INTO        #InactiveAccounts
FROM		Datamart.dbo.APSCustomerViewHistory hist (NOLOCK)
INNER JOIN  warehouseuserdb.dbo.FO_AttritionModel_ActiveCustomersByMonth ac
ON          hist.Customer_Number=ac.ACCNO
WHERE	    hist.STATCODE IN ('06')
AND         hist.ValidFrom > = @startMonth
AND         hist.ValidFrom < @endMonth
--AND         hist.Customer_Number IN('80000100363181','80000100431511','80000100110113')
GROUP BY    hist.Customer_Number 


--------------Creation of the all Base with Status Inactivities

DROP TABLE	IF EXISTS  apstempdb.dbo.FO_StatusInactivityWithAllPopulation

SELECT		ac.ACCNO,
			ac.TransactionMonth,
			MIN(iac.Close_Date) Next_Close_Date,
			DATEDIFF(MONTH,ac.TransactionMonth, ISNULL(MIN(iac.Close_Date),GETDATE())) AS MonthOfBtw_Inactivation,
		    CASE WHEN DATEDIFF(MONTH,ac.TransactionMonth, ISNULL(MIN(iac.Close_Date),GETDATE())) <= 3 THEN 1 ELSE 0 END Inactivation_In3M,
			--CASE WHEN DATEDIFF(MONTH,ac.TransactionMonth, ISNULL(MIN(iac.Close_Date),GETDATE())) = 3 THEN 1 ELSE 0 END Inactivation_3M_Later,
			CASE WHEN DATEDIFF(MONTH,ac.TransactionMonth, ISNULL(MIN(iac.Close_Date),GETDATE())) <= 6 THEN 1 ELSE 0 END Inactivation_In6M
		--	CASE WHEN DATEDIFF(MONTH,ac.TransactionMonth, ISNULL(MIN(iac.Close_Date),GETDATE())) = 6 THEN 1 ELSE 0 END Inactivation_6M_Later
INTO        apstempdb.dbo.FO_StatusInactivityWithAllPopulation
FROM		warehouseuserdb.dbo.FO_AttritionModel_ActiveCustomersByMonth ac
LEFT JOIN	#InactiveAccounts iac
ON			ac.ACCNO = iac.ACCNO
AND			iac.Close_Date > ac.TransactionMonth
GROUP BY	ac.ACCNO,ac.TransactionMonth

----------------Rate of the Status Inactivities by Months

SELECT  TransactionMonth, COUNT(*) Nof_Customers, 

        SUM(Inactivation_In3M)     AS Inactivation_In3M,
		SUM(Inactivation_In3M)/ CAST(COUNT(*) AS FLOAT) AS Rate_of_Inactivation_In3M,
		SUM(Inactivation_In6M)     AS Inactivation_In6M,
		SUM(Inactivation_In6M)/ CAST(COUNT(*) AS FLOAT) AS Rate_of_Inactivation_In6M
FROM   apstempdb.dbo.FO_StatusInactivityWithAllPopulation
GROUP  BY TransactionMonth
ORDER  BY 1 asc







