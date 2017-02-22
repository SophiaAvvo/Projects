/* note that there are blank source/medium/campaign fields often 
utm_medium and utm_source are generally blank */


WITH first_visit AS (

SELECT persistent_session_id
,MIN(w.`timestamp`) first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-06-01'--'2016-02-08'
GROUP BY 1

)

,als_transactions AS (
	select persistent_session_id
		,COUNT(regexp_extract(url, 'thank_you\/([0-9]+)', 1)) as order_id_count
	from src.page_view 
	where page_type = 'LS-Thankyou' 
	and event_date >= '2016-07-01'-- between '2016-04-24' and '2016-04-30'
	GROUP BY 1
  
)

SELECT w.persistent_session_id
,w.`timestamp`
,CASE
	WHEN w.campaign LIKE 'FB_%' -- must *begin with* this
	OR w.source LIKE '%facebook%'
		THEN 'Facebook'
	WHEN w.campaign LIKE '%PLS|%'
	OR w.campaign = 'pls'
	OR w.campaign = 'plsremarketing'
		THEN 'SEM - ALS Campaigns'
	WHEN w.source = 'taboola'
		THEN 'Taboola'
	ELSE 'Error'
	END Channel
,CASE
	WHEN LOWER(w.referrer) = 'facebook'
		THEN 'Facebook Sign-in'
	ELSE 'Other Sign-in'
END IsFacebookSignIn
,CASE
	WHEN w.source LIKE '%facebook%' 
	AND w.campaign IS NULL
		THEN 'Unpaid Facebook'
	ELSE 'Paid Facebook'
END IsPaidFB
,als.order_id_count
,w.referrer
,w.campaign
,w.source
,w.medium
,w.url

FROM src.weblog w
JOIN first_visit fv
	ON fv.persistent_session_id = w.persistent_session_id
	AND w.`timestamp` = fv.first_visit_timestamp
  AND (w.campaign LIKE 'FB_%' -- must *begin with* this
OR w.source LIKE '%facebook%'
OR w.campaign LIKE '%PLS|%'
OR w.campaign = 'pls'
OR w.campaign = 'plsremarketing'
OR w.source = 'taboola'
  )
AND w.event_type IN('page_view', 'service_session_payment')
AND w.event_date >= '2016-07-01'
LEFT JOIN als_transactions als
	ON als.persistent_session_id = w.persistent_session_id
	