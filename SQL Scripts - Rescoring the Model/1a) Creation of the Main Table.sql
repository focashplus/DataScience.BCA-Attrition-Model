
-- Main populations----> Active based on card usage with All Filters. 
---This script will be used as a main table on the script Combination of the all sources!!!!

-- Define Model Scoring period '01-02-2022' - '28-02-2022'
-- @startMonth: Start model has to be cover previous 6 months from scoring month to cover last 6M features. 


DECLARE     @scoringmonth  DATE = EOMONTH('2023-02-28')

DECLARE		@startMonth DATE =  DATEADD(dd, -( DAY( DATEADD(MONTH,-6,@scoringmonth) ) -1 ), DATEADD(MONTH,-6,@scoringmonth));--going to 6 months back from the scoring month and selecting the first day of it.
DECLARE		@endMonth   DATE =  DATEADD(DAY,+1,@scoringmonth) -- Added +1 day to the latest closed month to don't miss last day's transactions since they will appair the fisrt day of the next month
DECLARE	    @ReviewDate DATE = '2023-03-02' 

SELECT @startMonth 
SELECT @endMonth


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
 			aps.STATCODE STATCODE0,
			DATEDIFF(dd,COALESCE(aps.SaleDate, aps.AppDate, aps.FirstMonthActive),td.TransactionMonth) Customer_Tenure

INTO		#Data_Expanded
FROM		#FO_AttritionModel_ActiveCustomersByMonth td
LEFT JOIN	Datamart.dbo.APSCustomerView aps
ON			aps.Customer_Number = td.ACCNO



-- Table with row for each month

DROP TABLE	IF EXISTS #allDates

SELECT		DISTINCT
			TransactionMonth AS AllDates
INTO		#allDates
FROM		 #FO_AttritionModel_ActiveCustomersByMonth
ORDER BY	TransactionMonth



------------------------------------------------------------------------------------------------------------------------------------------------
-- Each customers with all months

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

DROP TABLE	IF EXISTS apstempdb.dbo.FO_AttritionModel_ActiveCustomersByMonth
SELECT	    ac.ACCNO,ac.ReviewDate,ac.TransactionMonth, b.Customer_Tenure,  ca.Nof_Last_3M_Card_Activity       
INTO        apstempdb.dbo.FO_AttritionModel_ActiveCustomersByMonth
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
AND			ca.Nof_Last_3M_Card_Activity = 3
AND         ac.TransactionMonth= @scoringmonth


SELECT TransactionMonth,COUNT(*)
FROM   apstempdb.dbo.FO_AttritionModel_ActiveCustomersByMonth
GROUP  BY TransactionMonth
ORDER  BY 1 ASC



