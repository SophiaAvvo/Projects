WITH first_visit AS (

SELECT persistent_session_id
,MIN(w.`timestamp`) first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08'
-- GROUP BY 1

)

SELECT persistent_session_id
,w.`timestamp`
,w.referrer
,w.campaign
,w.source
,w.medium
,w.url
FROM src.weblog w
JOIN first_visit fv
	ON fv.persistent_session_id = w.persistent_session_id
	AND (
  LOWER(w.campaign) LIKE 'FB_%' -- must *begin with* this
OR w.source LIKE '%facebook%'
OR w.campaign LIKE '%PLS|%'
OR w.campaign = 'pls'
OR w.campaign = 'plsremarketing'
OR w.source = 'taboola'
  )
-- AND w.event_type = 'service_session_payment'
AND w.event_date >= '2016-07-01'
--LIMIT 100;
