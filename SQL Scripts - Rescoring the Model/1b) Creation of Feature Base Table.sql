

--Population fo the Featuree Derivation ----> Active based on card usage

DECLARE     @scoringmonth  DATE = EOMONTH('2023-02-28')

DECLARE		@startMonth DATE =  DATEADD(dd, -( DAY( DATEADD(month,-6,@scoringmonth) ) -1 ), DATEADD(month,-6,@scoringmonth));--going to 6 months back from the scoring month and selecting the first day.
DECLARE		@endMonth   DATE =  DATEADD(DAY,+1,@scoringmonth) -- Added +1 day to the latest closed month to don't miss last day's transactions since they will appair the fisrt day of the next month
DECLARE	    @ReviewDate DATE = '2023-03-02' 

SELECT @startMonth 
SELECT @endMonth

DROP TABLE	IF EXISTS   apstempdb.dbo.FO_Attrition_Feature_Base

SELECT		vwtn.ACCNO,
            @ReviewDate AS ReviewDate,
			EOMONTH(vwtn.ctxdatelocal) TransactionMonth,
			COUNT(*) Nof_All_Transactions_Payments --Transactions +Outbound+Inbound Payments
INTO		apstempdb.dbo.FO_Attrition_Feature_Base
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



SELECT TransactionMonth, COUNT(*)
FROM apstempdb.dbo.FO_Attrition_Feature_Base
GROUP BY TransactionMonth
ORDER BY 1 asc