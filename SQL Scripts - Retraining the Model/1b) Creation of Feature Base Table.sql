
--Population fo the Featuree Derivation ----> Active based on card usage

-- G1: Model training period is 01/07/2021- 31/12/2021 and to drive model input features we will go back till 01/01/2021 for last 6M features.
-- G2: Model validation period is 01/01/2022- 30/06/2022 and to drive model input features we will go back till 01/10/2021.
-- @startMonth will be '2021-01-01' to able to cover the last 6M features, and @endMonth will be '2022-10-01' to able cover the 3 Months dormancy flag (for validation period's '2022-06-30' dormancy targets, we have to cover the card transactions until '2022-09-30'

DECLARE		@startMonth DATE = '2021-01-01'
DECLARE		@endMonth DATE   = '2022-10-01'  -- Added +1 day to the latest closed 30/06/2022 month to don't miss last day's transactions since they will appair at 01/07/2022
DECLARE	    @ReviewDate DATE = '2022-07-05' 


DROP TABLE	IF EXISTS   apstempdb.dbo.FO_Attrition_Feature_Base

SELECT		vwtn.ACCNO,
            @ReviewDate AS ReviewDate,
			EOMONTH(vwtn.ctxdatelocal) TransactionMonth,
			COUNT(*) Nof_All_Transactions_Payments --Transactions +Outbound+Inbound Payments
INTO		 apstempdb.dbo.FO_Attrition_Feature_Base
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

