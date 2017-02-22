/* note that there are blank source/medium/campaign fields often 
utm_medium and utm_source are always blank 
taboola does not show up in any field (campaign, source, medium, url) but referral field, usually with "3d" in front, indicating it is a referral*/


WITH channel AS (

SELECT DISTINCT persistent_session_id
--,MIN(w.`timestamp`) AS first_visit_timestamp
--,'Facebook' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE 'fb_%' -- must *begin with* this; note some are lower case (rarely)
OR w.source LIKE '%facebook%'
OR w.campaign LIKE '%PLS|%'
OR w.campaign = 'pls'
OR w.campaign = 'plsremarketing')
-- GROUP BY 1

UNION

SELECT DISTINCT persistent_session_id
-- ,MIN(w.`timestamp`) AS first_visit_timestamp
--,'Facebook' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-03-18' -- ALS product launch
  AND (w.campaign LIKE '%PLS|%'
OR w.campaign = 'pls'
OR w.campaign = 'plsremarketing')
-- GROUP BY 1

UNION

SELECT persistent_session_id
--,MIN(w.`timestamp`) AS first_visit_timestamp
--,'Taboola' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-04-24'
  AND w.source = 'taboola'
--GROUP BY 1
)


,all_channels AS (
SELECT c.persistent_session_id
,w.source
,w.medium
,w.campaign
,MIN(w.`timestamp`) first_visit_timestamp
,COUNT(DISTINCT w.`timestamp`) views_per_channel
FROM channel c
JOIN src.weblog w
ON c.persistent_session_id = w.persistent_session_id
GROUP BY 1,2,3,4

)

,channel_count AS (
SELECT *
,ROW_NUMBER() OVER(PARTITION BY persistent_session_id ORDER BY first_visit_timestamp) ChannelOrder
FROM all_channels

)


/*,first_visit AS (
SELECT cc.persistent_session_id
,cc.first_visit_timestamp
,CASE
	WHEN LOWER(cc.campaign) LIKE 'fb_%' -- must *begin with* this; note some are lower case (rarely)
		OR cc.source LIKE '%facebook%'
		THEN 'Facebook'
	WHEN cc.campaign LIKE '%PLS|%'
		OR cc.campaign = 'pls'
		OR cc.campaign = 'plsremarketing'
	THEN 'SEM - ALS'
	WHEN LOWER(cc.medium) LIKE '%email%'
		THEN 'Email'
	WHEN LOWER(cc.medium) LIKE '%affiliate%'
		OR REGEXP_MATCH(cc.source, r'(boomerater|lifecare)')
	THEN 'Affiliates' 
	ELSE 'Other'
	END	Channel
FROM channel_count cc
		ON cc.persistent_session_id = c.persistent_session_id
		AND cc.
)*/

,als_transactions AS (
	select DISTINCT persistent_session_id
		,`timestamp`
		,event_date
		,regexp_extract(url, 'thank_you\/([0-9]+)', 1) as order_id
	from src.page_view 
	where page_type = 'LS-Thankyou' 
	and event_date >= '2016-02-08'
  
)

/*,als_detail AS (
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
,COUNT(als.order_id) Total_Purchases
FROM als_transactions als
left join src.ocato_advice_sessions oas 
	on cast(als.order_id as INT) = oas.id 
left join src.ocato_offers oo 
	on oas.offer_id = oo.id 
left join src.ocato_packages op 
	on oo.package_id = op.id 
GROUP BY 1
) */

SELECT w.persistent_session_id
,fv.first_visit_timestamp
,CASE
	WHEN fv.first_visit_timestamp >= '2016-02-08'
	AND (w.campaign LIKE 'FB_%' -- must *begin with* this
	OR w.source LIKE '%facebook%')
		THEN 'First-Touch'
	WHEN fv.first_visit_timestamp >= '2016-03-18'
	AND (w.campaign LIKE '%PLS|%'
	OR w.campaign = 'pls'
	OR w.campaign = 'plsremarketing')
		THEN 'First-Touch'
	WHEN fv.first_visit_timestamp >= '2016-04-24'
	AND w.source = 'taboola'
		THEN 'Taboola'
	ELSE 'Not First-Touch'
	END First_Touch_Flag
,CASE
	WHEN fv.first_visit_timestamp >= '2016-02-08'
	AND (w.campaign LIKE 'FB_%' 
	OR w.source LIKE '%facebook%')
		THEN 'Facebook ALS Campaigns'
	WHEN fv.first_visit_timestamp >= '2016-03-18'
	AND (w.campaign LIKE '%PLS|%'
	OR w.campaign = 'pls'
	OR w.campaign = 'plsremarketing')
		THEN 'SEM - ALS Campaigns'
	WHEN fv.first_visit_timestamp >= '2016-04-24'
	AND w.source = 'taboola'
		THEN 'Taboola'
	ELSE 'Other'
	END Channel
,fv.ChannelOrder
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
,w.referrer
,w.campaign
,w.source
,w.medium
,w.url
,w.event_date
,COUNT(DISTINCT w.session_id) Session_Count
,AVG(CASE
		WHEN fv.first_visit_timestamp < als.`timestamp`
			THEN DATEDIFF(als.event_date, w.event_date)
		ELSE NULL
	END) avg_days_to_purchase_all
,AVG(CASE 
		WHEN op.name LIKE '%advice session%' AND fv.first_visit_timestamp < als.`timestamp`
			THEN DATEDIFF(als.event_date, w.event_date)
		ELSE NULL
	END) avg_days_to_purchase_advisor
,AVG(CASE 
		WHEN op.name LIKE '%review%' AND fv.first_visit_timestamp < als.`timestamp`
			THEN DATEDIFF(als.event_date, w.event_date)
		ELSE NULL
	END) avg_days_to_purchase_doc_review
,AVG(CASE 
		WHEN op.name LIKE '%review%'
			THEN NULL
		WHEN op.name LIKE '%advice session%'
			THEN NULL
		WHEN fv.first_visit_timestamp >= als.`timestamp`
			THEN NULL
		ELSE DATEDIFF(als.event_date, w.event_date)
	END) avg_days_to_purchase_offline
,SUM(CASE 
		WHEN op.name LIKE '%advice session%' AND fv.first_visit_timestamp < als.`timestamp`
			THEN 1
		ELSE 0
	END) Advice_Purchases
,SUM(CASE 
		WHEN op.name LIKE '%review%' AND fv.first_visit_timestamp < als.`timestamp`
			THEN 1
		ELSE 0
	END) Doc_Review_Purchases
,SUM(CASE 
		WHEN op.name LIKE '%review%'
			THEN 0
		WHEN op.name LIKE '%advice session%'
			THEN 0
		WHEN op.name IS NOT NULL AND fv.first_visit_timestamp < als.`timestamp`
			THEN 1
		ELSE 0
	END) Other_Offline_Purchases
,MIN(als.event_date) First_Purchase_Date
,MAX(als.event_date) Last_Purchase_Date
,COUNT(CASE
		WHEN fv.first_visit_timestamp < als.`timestamp`
			THEN als.order_id
		ELSE NULL
		END) Total_Purchases
,COUNT(CASE
		WHEN fv.first_visit_timestamp >= als.`timestamp`
			THEN als.order_id
		ELSE NULL
		END) Pre_Channel_Touch_Purchases
FROM src.weblog w
JOIN channel_count fv
	ON fv.persistent_session_id = w.persistent_session_id
	AND w.`timestamp` = fv.first_visit_timestamp
	AND fv.ChannelOrder = 1
	AND w.event_type IN('page_view', 'service_session_payment')
LEFT JOIN als_transactions als
	ON als.persistent_session_id = w.persistent_session_id
	-- AND fv.first_visit_timestamp < als.`timestamp`
left join src.ocato_advice_sessions oas 
	on cast(als.order_id as INT) = oas.id 
left join src.ocato_offers oo 
	on oas.offer_id = oo.id 
left join src.ocato_packages op 
	on oo.package_id = op.id
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
