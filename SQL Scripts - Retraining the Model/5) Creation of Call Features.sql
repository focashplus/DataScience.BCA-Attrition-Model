

----------How many times does customer interact with customer service? And the waiting durations
-----------------------------------------------------------------------------------------


DROP TABLE	IF EXISTS apstempdb.dbo.FO_Customer_Inbound_Calls

SELECT		ac.ACCNO,
			ac.TransactionMonth,
		    EOMONTH(DATEADD(MONTH	,-5,ac.TransactionMonth)) AS Begining_of_6M_CallPeriod,

	        ---Number of the inbound calls
			COUNT( CASE WHEN EOMONTH(ibl.call_date)= ac.TransactionMonth THEN ibl.d_record_id ELSE NULL END) Last_M_Inb_Calls,
			COUNT( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-1,ac.TransactionMonth) THEN ibl.d_record_id ELSE NULL END) Last_2M_Inb_Calls,
			COUNT( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN ibl.d_record_id ELSE NULL END) Last_3M_Inb_Calls,
			COUNT( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN ibl.d_record_id ELSE NULL END) Last_6M_Inb_Calls,

			COUNT( CASE WHEN EOMONTH(ibl.call_date)= ac.TransactionMonth THEN ibl.d_record_id ELSE NULL END)/
			(CAST(NULLIF(COUNT( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN ibl.d_record_id ELSE NULL END),0) AS FLOAT)) Rate_of_Inb_Call_Last_M_3M,

			COUNT( CASE WHEN EOMONTH(ibl.call_date)= ac.TransactionMonth THEN ibl.d_record_id ELSE NULL END)/
			(CAST(NULLIF(COUNT( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN ibl.d_record_id ELSE NULL END),0) AS FLOAT)) Rate_of_Inb_Call_Last_M_6M,

			COUNT( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN ibl.d_record_id ELSE NULL END) /
			(CAST(NULLIF(COUNT( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN ibl.d_record_id ELSE NULL END),0) AS FLOAT)) Rate_of_Inb_Call_Last_3M_6M,

			--COUNT( ibl.d_record_id) Total_6M,

			--- Dissatisfied_Calls
			SUM( CASE WHEN EOMONTH(ibl.call_date) = ac.TransactionMonth THEN acn.Dissatisfied ELSE NULL END) Last_M_DissatisfiedCalls,
		    SUM( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-1,ac.TransactionMonth) THEN acn.Dissatisfied ELSE NULL END) Last_2M_Dissatisfied_Calls,
			SUM( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN acn.Dissatisfied ELSE NULL END) Last_3M_Dissatisfied_Calls,
			SUM( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN acn.Dissatisfied ELSE NULL END) Last_6M_Dissatisfied_Calls,

		    COUNT( CASE WHEN EOMONTH(ibl.call_date)= ac.TransactionMonth THEN  acn.Dissatisfied ELSE NULL END)/
			(CAST(NULLIF(COUNT( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN  acn.Dissatisfied ELSE NULL END),0) AS FLOAT)) Rate_of_Dissatisfied_Call_Last_M_3M,

			COUNT( CASE WHEN EOMONTH(ibl.call_date)= ac.TransactionMonth THEN  acn.Dissatisfied ELSE NULL END)/
			(CAST(NULLIF(COUNT( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN  acn.Dissatisfied ELSE NULL END),0) AS FLOAT)) Rate_of_Dissatisfied_Call_Last_M_6M,

			COUNT( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN  acn.Dissatisfied ELSE NULL END) /
			(CAST(NULLIF(COUNT( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN  acn.Dissatisfied ELSE NULL END),0) AS FLOAT)) Rate_of_Dissatisfied_Call_Last_3M_6M,

			--SUM(acn.Dissatisfied) Nof_Dissatisfied_Inb_Calls_in6M,

			---Inbound Waiting times
			SUM( CASE WHEN EOMONTH(ibl.call_date) = ac.TransactionMonth THEN acn.WaitTime_incAbandon ELSE NULL END) Last_M_WaitTime_incAbandon,
		    SUM( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-1,ac.TransactionMonth) THEN acn.WaitTime_incAbandon ELSE NULL END) Last_2M_WaitTime_incAbandon,
			SUM( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN acn.WaitTime_incAbandon ELSE NULL END) Last_3M_WaitTime_incAbandon,
			SUM( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN acn.WaitTime_incAbandon ELSE NULL END) Last_6M_WaitTime_incAbandon,
			--SUM(acn.WaitTime_incAbandon) Total_WaitTime_incAbandon_in6M,

			---Avg Inbound Waiting times
			AVG( CASE WHEN EOMONTH(ibl.call_date) = ac.TransactionMonth THEN acn.WaitTime_incAbandon ELSE NULL END) Avg_Last_M_WaitTime_incAbandon,
		    AVG( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-1,ac.TransactionMonth) THEN acn.WaitTime_incAbandon ELSE NULL END) Avg_Last_2M_WaitTime_incAbandon,
			AVG( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-2,ac.TransactionMonth) THEN acn.WaitTime_incAbandon ELSE NULL END) Avg_Last_3M_WaitTime_incAbandon,
			AVG( CASE WHEN EOMONTH(ibl.call_date) >= DATEADD(MONTH,-5,ac.TransactionMonth) THEN acn.WaitTime_incAbandon ELSE NULL END) Avg_Last_6M_WaitTime_incAbandon
			--AVG(acn.WaitTime_incAbandon) AVG_Total_WaitTime_incAbandon_in6M

INTO        apstempdb.dbo.FO_Customer_Inbound_Calls
FROM		apstempdb.dbo.FO_Attrition_Feature_Base ac
LEFT JOIN	ExternalData.Noble.inboundlog ibl
ON			ac.ACCNO=ibl.filler2  
INNER  JOIN datamart.SSAS.CallCentre_AllCallsNoble acn 
ON          ibl.d_record_id = acn.d_record_id 
AND	        ibl.call_date >= DATEADD(MONTH	,-5,ac.TransactionMonth)
AND			ibl.call_date <= ac.TransactionMonth
GROUP BY	ac.ACCNO, ac.TransactionMonth


