

-- Main populations----> Active based on card usage with All Filters. 
---This script will be used as a main table on the script Combination of the all sources!!!!

-- G1: Model training period is 01/07/2021- 31/12/2021 and to drive model input features we will go back till 01/01/2021 for last 6M features.
-- G2: Model validation period is 01/01/2022- 30/06/2022 and to drive model input features we will go back till 01/10/2021.
-- @startMonth will be '2021-01-01' to able to cover the last 6M features, and @endMonth will be '2022-10-01' to able cover the 3 Months dormancy flag (for validation period's '2022-06-30' dormancy targets, we have to cover the card transactions until '2022-09-30'


DECLARE		@startMonth DATE = '2021-01-01'
DECLARE		@endMonth DATE   = '2022-10-01'  -- Added +1 day to the latest closed 30/06/2022 month to don't miss last day's transactions since they will appair at 01/07/2022
DECLARE	    @ReviewDate DATE = '2022-07-05' 


DROP TABLE	IF EXISTS  #FO_AttritionModel_ActiveCustomersByMonth

SELECT		vwtn.ACCNO,
            @ReviewDate AS ReviewDate,
			EOMONTH(vwtn.ctxdatelocal) TransactionMonth,
			COUNT(*) Nof_All_Transactions_Payments --Transactions +Outbound+Inbound Payments
INTO		 #FO_AttritionModel_ActiveCustomersByMonth
FROM		warehousenomad.dbo.vwTransactionLiteN vwtn (NOLOCK) -- consolidated view of all monetary activity on an account (payments, fees, card transactions, manual adjustments)
LEFT JOIN	WarehouseNomad.dbo.vwFeeTypesN fee
ON			vwtn.FEEID = fee.ReasonCode
INNER JOIN	Datamart.dbo.APSCustomerView aps (NOLOCK)
ON			vwtn.ACCNO = aps.Customer_Number
LEFT JOIN	(
				SELECT		DISTINCT
							csa.CustomerNumber
				FROM		WarehouseBPM.OpsManagement.ArcCaseAccounts csa (NOLOCK)
				INNER JOIN	WarehouseBPM.OpsManagement.ArcCaseActions aca (NOLOCK)
				ON			aca.ArcCases_Id = csa.ArcCases_Id
				AND			aca.CustomerNumber = csa.CustomerNumber
				INNER JOIN	WarehouseBPM.OpsManagement.ArcActions actns (NOLOCK)
				ON			aca.ArcActions_Id = actns.Id
				WHERE		actns.Name = 'Auto60DayClosureNoResponse'
			) arc -- removing accounts which are closed in ARC due to FinCrime team requesting information and the customer never responding
ON			aps.Customer_Number = arc.CustomerNumber
WHERE		(
			vwtn.Source = 'FinAdv' -- transactions
			OR (vwtn.Source = 'Adjust' AND vwtn.FEEID = 'BP-Debit') -- outbound payments
			OR fee.FeeType = 'AccountLoad' -- inbound payments and post office loads
			) 
AND			vwtn.ctxdatelocal >= @startMonth
AND			vwtn.ctxdatelocal < @endMonth
AND			arc.CustomerNumber IS NULL -- not in the ARC sub-query around closures
AND			aps.BusinessType = 'Corporate' -- only business current accounts
GROUP BY	vwtn.ACCNO, EOMONTH(vwtn.ctxdatelocal)


-----------------Additional Exclutions--------------------------------------------------
--------------------------------------------------------------------------------------------------------------------


DROP TABLE	IF EXISTS #Data_Expanded

SELECT td.*,
 			acc1.STATCODE STATCODE0,
			acc2.STATCODE STATCODE1,
			acc3.STATCODE STATCODE2,
			acc4.STATCODE STATCODE3,
			DATEDIFF(dd,COALESCE(aps.SaleDate, aps.AppDate, aps.FirstMonthActive),td.TransactionMonth) Customer_Tenure

INTO		#Data_Expanded
FROM		 #FO_AttritionModel_ActiveCustomersByMonth td
LEFT JOIN	warehousenomad.dbo.accountcard acc1 (NOLOCK)
ON			acc1.ACCNO = td.ACCNO
AND			acc1.filedate = td.TransactionMonth
AND			acc1.PRIMARYCARD = 'Y'
LEFT JOIN	warehousenomad.dbo.accountcard acc2 (NOLOCK)
ON			acc2.ACCNO = td.ACCNO
AND			acc2.PRIMARYCARD = 'Y'
AND			acc2.filedate = DATEADD(mm,1,td.TransactionMonth)
LEFT JOIN	warehousenomad.dbo.accountcard acc3 (NOLOCK)
ON			acc3.ACCNO = td.ACCNO
AND			acc3.PRIMARYCARD = 'Y'
AND			acc3.filedate = DATEADD(mm,2,td.TransactionMonth)
LEFT JOIN	warehousenomad.dbo.accountcard acc4 (NOLOCK)
ON			acc4.ACCNO = td.ACCNO
AND			acc4.PRIMARYCARD = 'Y'
AND			acc4.filedate = DATEADD(mm,3,td.TransactionMonth)
LEFT JOIN	Datamart.dbo.APSCustomerView aps
ON			aps.Customer_Number = td.ACCNO




---Main Population by months

SELECT TransactionMonth,COUNT(*),COUNT(DISTINCT ACCNO)
FROM   #FO_AttritionModel_ActiveCustomersByMonth
GROUP  BY TransactionMonth
ORDER  BY 1 ASC


-- Table with row for each month

DROP TABLE	IF EXISTS #allDates

SELECT		DISTINCT
			TransactionMonth AS AllDates
INTO		#allDates
FROM		 #FO_AttritionModel_ActiveCustomersByMonth
ORDER BY	TransactionMonth



------------------------------------------------------------------------------------------------------------------------------------------------
-- Each customers with all transactional months

DROP TABLE	IF EXISTS #accountMonth

SELECT		accs.ACCNO,
			ald.AllDates
INTO		#accountMonth
FROM		#allDates ald
CROSS APPLY (SELECT DISTINCT ACCNO FROM  #FO_AttritionModel_ActiveCustomersByMonth
) accs


-- Calculation of the consecutively last 3months card activity

DROP TABLE	IF EXISTS #Months_with_Card_Activity

SELECT  ACCNO,Alldates,Card_Activity_Month,
        LAG(Card_Activity_Month, 1) OVER(PARTITION BY ACCNO ORDER BY AllDates ASC) AS Card_Activity_Month_Prev_M,
		LAG(Card_Activity_Month, 2) OVER(PARTITION BY ACCNO ORDER BY AllDates ASC) AS Card_Activity_Month_Prev_2M,
		Card_Activity_Flag,
        ISNULL(LAG(Card_Activity_Flag, 1) OVER(PARTITION BY ACCNO ORDER BY AllDates ASC),0) AS Card_Activity_Flag_Prev_M,
		ISNULL(LAG(Card_Activity_Flag, 2) OVER(PARTITION BY ACCNO ORDER BY AllDates ASC),0) AS Card_Activity_Flag_Prev_2M,
		 Card_Activity_Flag+ISNULL(LAG(Card_Activity_Flag, 1) OVER(PARTITION BY ACCNO ORDER BY AllDates ASC),0)+
		                    ISNULL(LAG(Card_Activity_Flag, 2) OVER(PARTITION BY ACCNO ORDER BY AllDates ASC),0) AS Nof_Last_3M_Card_Activity
INTO #Months_with_Card_Activity
FROM  

(
SELECT acm.*,Card_Activity_Month, CASE WHEN Card_Activity_Month IS NOT NULL THEN 1 ELSE 0 END AS Card_Activity_Flag
FROM		#accountMonth acm
LEFT JOIN	(
				SELECT		bmsc.ACCNO,TransactionMonth Card_Activity_Month
				FROM		 #FO_AttritionModel_ActiveCustomersByMonth bmsc
				--WHERE      bmsc.ACCNO IN ('80000100151759')--,'80000100486982', '80000100432014','80000100468574')
				GROUP BY	bmsc.ACCNO,TransactionMonth
				
			) ca
ON	    acm.ACCNO = ca.ACCNO
AND		acm.AllDates = ca.Card_Activity_Month
--WHERE  acm.ACCNO IN ('80000100151759')--,'80000100486982', '80000100432014','80000100468574')
)a
ORDER BY 1,2 ASC


-------Choosing the BUS promo code
---------------------------------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #Customers_With_Promo_Codes
SELECT ac.ACCNO,LEFT(c.PromoCode,3) promochannel
INTO   #Customers_With_Promo_Codes
FROM   #FO_AttritionModel_ActiveCustomersByMonth ac 
INNER JOIN WarehouseCAPDB.dbo.DirectSalesBarCodes dsb (NOLOCK) ON dsb.CustomerNumber = ac.ACCNO
INNER JOIN WarehouseURU.dbo.Customer c (NOLOCK) ON dsb.URUReference = c.CustomerRef
LEFT  JOIN Datamart.dbo.PromoCodeClassification pcc ON pcc.PromoCode = c.PromoCode
WHERE LEFT(c.PromoCode,3) IN ('BUS','BAS', 'BCB')
--AND    ac.accno='80000100368184' --INV
GROUP BY ac.ACCNO,LEFT(c.PromoCode,3)


-------Creation of the main table-----------------------
---------------------------------------------------------------------------------------

DROP TABLE	IF EXISTS  warehouseuserdb.dbo.FO_AttritionModel_ActiveCustomersByMonth
SELECT	    ac.ACCNO,ac.ReviewDate,ac.TransactionMonth, b.Customer_Tenure,  ca.Nof_Last_3M_Card_Activity       
INTO        warehouseuserdb.dbo.FO_AttritionModel_ActiveCustomersByMonth
FROM		#FO_AttritionModel_ActiveCustomersByMonth  ac
INNER JOIN  #Customers_With_Promo_Codes pc
ON          ac.ACCNO=pc.ACCNO
LEFT  JOIN  #Data_Expanded b
ON          ac.ACCNO=b.ACCNO
AND         ac.TransactionMonth = b.TransactionMonth
LEFT JOIN   #Months_with_Card_Activity ca
ON          ac.ACCNO=ca.ACCNO
AND         ac.TransactionMonth = ca.AllDates 
WHERE	    b.Customer_Tenure >= 90
AND			b.STATCODE0 NOT IN ('77','07','89')
AND			b.STATCODE1 NOT IN ('77','07','89')
AND			b.STATCODE2 NOT IN ('77','07','89')
AND			b.STATCODE3 NOT IN ('77','07','89')
AND			ca.Nof_Last_3M_Card_Activity = 3

SELECT TransactionMonth,COUNT(*)
FROM   warehouseuserdb.dbo.FO_AttritionModel_ActiveCustomersByMonth
GROUP  BY TransactionMonth
ORDER  BY 1 ASC



