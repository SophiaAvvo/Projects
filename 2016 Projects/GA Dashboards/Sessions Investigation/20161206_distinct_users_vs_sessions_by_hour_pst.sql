SELECT Date
,HOUR(SEC_TO_TIMESTAMP(visitStartTime - 25200)) AS session_hour_pst
,COUNT(totals.visits) AS Sessions_Total
,count(DISTINCT CONCAT(fullVisitorId, STRING(visitId)), 100000) Alternate_session_count
,EXACT_COUNT_DISTINCT(fullVisitorID) distinct_visitor_id_count
,COUNT(CASE WHEN visitNumber = 1 THEN fullVisitorID ELSE NULL END) AS first_visit_count
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-01-01'),CURRENT_TIMESTAMP())
GROUP BY 1,2