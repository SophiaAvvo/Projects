/* note that there are blank source/medium/campaign fields often 
utm_medium and utm_source are always blank 
taboola does not show up in any field (campaign, source, medium, url) but referral field, usually with "3d" in front, indicating it is a referral*/


WITH channel AS (

SELECT persistent_session_id
,MIN(w.`timestamp`) AS first_visit_timestamp
,'Facebook' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE 'fb_%' -- must *begin with* this; note some are lower case (rarely)
OR w.source LIKE '%facebook%')
GROUP BY 1

UNION

SELECT persistent_session_id
,MIN(w.`timestamp`) AS first_visit_timestamp
,'SEM - ALS Campaigns' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-03-18' -- from Mira
  AND (w.campaign LIKE '%PLS|%'
OR w.campaign = 'pls'
OR w.campaign = 'plsremarketing')
GROUP BY 1

UNION

SELECT persistent_session_id
,MIN(w.`timestamp`) AS first_visit_timestamp
,'Taboola' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-04-24'
  AND w.source = 'taboola'
GROUP BY 1

)

,first_visit AS (
SELECT persistent_session_id
,first_visit_timestamp
,Channel
,ROW_NUMBER() OVER(PARTITION BY persistent_session_id ORDER BY first_visit_timestamp) Num
FROM channel

)

,als_transactions AS (
	select DISTINCT persistent_session_id
		,regexp_extract(url, 'thank_you\/([0-9]+)', 1)) as order_id
	from src.page_view 
	where page_type = 'LS-Thankyou' 
	and event_date >= '2016-02-08'
	GROUP BY 1
  
)

,als_detail AS (
SELECT als.persistent_session_id
,SUM(CASE 
		WHEN op.name LIKE '%advice session%'
			THEN 1
		ELSE 0
	END) Advice_Purchases
,SUM(CASE 
		WHEN op.name LIKE '%review%'
			THEN 1
		ELSE 0
	END) Doc_Review_Purchases
,SUM(CASE 
		WHEN op.name LIKE '%review%'
			THEN 0
		WHEN op.name LIKE '%advice session%'
			THEN 0
		ELSE 1
	END) Other_Offline_Purchases
,COUNT(als.order_id) TotalPurchases
FROM als_transactions als
left join src.ocato_advice_sessions oas 
	on cast(als.order_id as INT) = oas.id 
left join src.ocato_offers oo 
	on oas.offer_id = oo.id 
left join src.ocato_packages op 
	on oo.package_id = op.id 
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
,fv.Num
,CASE
	WHEN LOWER(w.referrer) LIKE '%facebook%'
	AND w.url LIKE '%logged_in=true%'
		THEN 1
	ELSE 0
END IsFacebookSignIn
,CASE
	WHEN w.source LIKE '%facebook%' 
	AND w.campaign IS NULL -- in GA it's "not set"; in Hadoop it's NULL
		THEN 'Unpaid Facebook'
	ELSE 'Paid Facebook'
END IsPaidFB
,als.order_id_count
,w.referrer
,w.campaign
,w.source
,w.medium
,w.utm_source
,w.utm_medium
,w.url
,w.event_date
FROM src.weblog w
JOIN first_visit fv
	ON fv.persistent_session_id = w.persistent_session_id
	AND w.`timestamp` = fv.first_visit_timestamp
AND w.event_type IN('page_view', 'service_session_payment')
LEFT JOIN als_transactions als
	ON als.persistent_session_id = w.persistent_session_id
	AND fv.Num = 1
