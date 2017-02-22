/* note that there are blank source/medium/campaign fields often 
utm_medium and utm_source are always blank 
taboola does not show up in any field (campaign, source, medium, url) but referral field, usually with "3d" in front, indicating it is a referral*/


WITH channels AS (

SELECT persistent_session_id
,1 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Facebook_RU_Acq
,0 AS Is_Facebook_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'Affiliates/Partners' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.medium) LIKE '%affiliate%' 
  OR LOWER(w.medium) LIKE '%boomerater%' 
	OR LOWER(w.medium) LIKE '%lifecare%'
	)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15	

	
UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,1 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Facebook_RU_Acq
,0 AS Is_Facebook_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'SEM - Brand' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%branded_terms%'
		OR LOWER(w.campaign) = 'brand|rlsa%'
		OR LOWER(w.campaign) = 'brand'
	)
	AND LOWER(w.campaign) NOT LIKE "%fb%"
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	
UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,1 AS Is_SEM_QA
,0 AS Is_Facebook_RU_Acq
,0 AS Is_Facebook_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'SEM - Q&A' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%legal_q_&_a_search%'
		OR LOWER(w.campaign) LIKE '%legalqa%'
		)
AND LOWER(w.campaign) NOT LIKE '%fb%'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
  
UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,1 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Facebook_RU_Acq
,0 AS Is_Facebook_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'SEM - ALS' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%pls|%'
		OR LOWER(w.campaign) = 'pls'
		OR LOWER(w.campaign) = 'plsremarketing'
	)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,1 AS Is_Facebook_RU_Acq
,0 AS Is_Facebook_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'Paid FB - RU' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.medium) LIKE '%cpc%' 
	OR LOWER(w.medium) LIKE '%cpm%')	
  AND (LOWER(campaign) LIKE '%fb_%' 
	OR LOWER(campaign) LIKE '%acq%'
		)
  AND LOWER(w.source) NOT LIKE '%google%'		
  AND LOWER(w.campaign) NOT LIKE '%2016brandvideos_t_acq%'
  AND LOWER(w.campaign) NOT LIKE '%fb_boosted%'
  AND LOWER(w.campaign) NOT LIKE '%lawyer%'
  AND LOWER(w.campaign) NOT LIKE '%pokemon%'
  AND LOWER(w.campaign) NOT LIKE '%eng_%'
  AND LOWER(w.campaign) NOT LIKE '%pls%'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15  
  
 UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Facebook_RU_Acq
,1 AS Is_Facebook_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'Paid FB - ALS' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.medium) LIKE '%cpc%' 
	OR LOWER(w.medium) LIKE '%cpm%')	
  AND (LOWER(campaign) LIKE '%pls_avvofb%'
	OR LOWER(campaign) LIKE '%pls_fb%'
	OR LOWER(campaign) LIKE '%pls_fbb%'
		)
  AND LOWER(w.source) NOT LIKE '%google%'		
  AND LOWER(w.campaign) NOT LIKE '%2016brandvideos_t_acq%'
  AND LOWER(w.campaign) NOT LIKE '%fbz_boosted%'
  AND LOWER(w.campaign) NOT LIKE '%lawyer%'
  AND LOWER(w.campaign) NOT LIKE '%pokemon%'
  AND LOWER(w.campaign) NOT LIKE '%eng_%'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
 
 UNION
 
 SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Facebook_RU_Acq
,0 AS Is_Facebook_ALS
,1 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email 
,1 AS Precedence
,'Display_RU_Acq' AS Channel
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%pls_%'
	OR LOWER(w.campaign) LIKE '%acq%')
	AND (LOWER(w.campaign) LIKE '%qa%'
		OR LOWER(w.campaign) LIKE '%lifecycle%'
		OR LOWER(w.campaign) LIKE '%form%'
		)
	AND LOWER(w.campaign) NOT LIKE '%fb%'
	AND LOWER(w.campaign) NOT LIKE '%_ret%'
-- note no traffic yet for forms or lifecycle
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
  
UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Facebook_RU_Acq
,0 AS Is_Facebook_ALS
,0 AS Is_Display_RU_Acq_A
,1 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,1 AS Precedence
,'Display_RU_Ret' AS Channel
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%pls_%'
	OR LOWER(w.campaign) LIKE '%_ret%')
	AND (LOWER(w.campaign) LIKE '%qa%'
		OR LOWER(w.campaign) LIKE '%lifecycle%'
		OR LOWER(w.campaign) LIKE '%form%'
		)
	AND LOWER(w.campaign) NOT LIKE '%fb%'
	AND LOWER(w.campaign) NOT LIKE '%acq%'
--note no traffic yet for forms or lifecycle
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

UNION

 SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Facebook_RU_Acq
,0 AS Is_Facebook_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,1 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email 
,1 AS Precedence
,'Display_ALS_Acq' AS Subchannel
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND LOWER(w.campaign) LIKE '%pls_%'
  AND (LOWER(w.campaign) LIKE '%_acq%'
	OR LOWER(w.campaign) LIKE '%acquisition%'
	OR LOWER(w.campaign) LIKE '%lookalike%')
	AND LOWER(w.campaign) NOT LIKE '%qa%'
	AND LOWER(w.campaign) NOT LIKE '%lifecycle%'
	AND LOWER(w.campaign) NOT LIKE '%form%'
	AND LOWER(w.campaign) NOT LIKE '%fb%'
-- note no traffic yet for forms or lifecycle
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
  
UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Facebook_RU_Acq
,0 AS Is_Facebook_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,1 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,1 AS Precedence
,'Display_ALS_Ret' AS Subchannel
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%pls_%'
	OR LOWER(w.campaign) LIKE '%_abandoners%')
  AND LOWER(w.campaign) NOT LIKE '%_acq%'
	AND LOWER(w.campaign) NOT LIKE '%acquisition%'
	AND LOWER(w.campaign) NOT LIKE '%lookalike%'
	AND LOWER(w.campaign) NOT LIKE '%qa%'
	AND LOWER(w.campaign) NOT LIKE '%lifecycle%'
	AND LOWER(w.campaign) NOT LIKE '%form%'
	AND LOWER(w.campaign) NOT LIKE '%fb%'
	AND LOWER(w.source) NOT LIKE '%taboola%'
--note no traffic yet for forms or lifecycle
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

UNION
 
SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Facebook_RU_Acq
,0 AS Is_Facebook_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,1 AS Is_Taboola
,0 AS Is_Email
,'Taboola' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-04-24'
  AND w.source = 'taboola'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Facebook_RU_Acq
,0 AS Is_Facebook_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,1 AS Is_Email
,'Email' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND LOWER(w.medium) LIKE '%email%' 
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
)


,first_visit AS (
SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Facebook_RU_Acq
,0 AS Is_Facebook_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
'Other' AS Channel
,2 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE persistent_session_id IN (SELECT DISTINCT persistent_session_id FROM channels)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

)

,channel_sort AS (
SELECT c.persistent_session_id
,c.Channel AS First_Touch_Channel
,SUM(c.Is_Affiliate_Partner) OVER(PARTITION BY c.persistent_session_id) Is_Affiliate_Partner
,SUM(c.Is_SEM_Brand) OVER(PARTITION BY c.persistent_session_id) Is_SEM_Brand
,SUM(c.Is_SEM_ALS) OVER(PARTITION BY c.persistent_session_id) Is_SEM_ALS
,SUM(c.Is_SEM_QA) OVER(PARTITION BY c.persistent_session_id) Is_SEM_QA
,SUM(c.Is_Facebook_RU_Acq) OVER(PARTITION BY c.persistent_session_id) Is_Facebook_RU_Acq
,SUM(c.Is_Facebook_ALS) OVER(PARTITION BY c.persistent_session_id) Is_Facebook_ALS
,SUM(c.Is_Display_RU_Acq_A) OVER(PARTITION BY c.persistent_session_id) Is_Display_RU_Acq_A
,SUM(c.Is_Display_RU_Acq_R) OVER(PARTITION BY c.persistent_session_id) Is_Display_RU_Acq_R
,SUM(c.Is_Display_ALS_A) OVER(PARTITION BY c.persistent_session_id) Is_Display_ALS_A 
,SUM(c.Is_Display_ALS_R) OVER(PARTITION BY c.persistent_session_id) Is_Display_ALS_R
,SUM(c.Is_Taboola) OVER(PARTITION BY c.persistent_session_id) Is_Taboola
,SUM(c.Is_Email) OVER(PARTITION BY c.persistent_session_id) Is_Email
,c.first_visit_timestamp
,ROW_NUMBER() OVER(PARTITION BY c.persistent_session_id ORDER BY c.first_visit_timestamp, c.Precedence) Channel_Order
FROM (SELECT *
		FROM channels ch
		
		UNION
		
		SELECT *
		FROM 
		first_visit fv
	)c
)



,als_transactions AS (
	select DISTINCT persistent_session_id
		,regexp_extract(url, 'thank_you\/([0-9]+)', 1) as order_id
	from src.page_view 
	where page_type = 'LS-Thankyou' 
	and event_date >= '2016-02-08'
  
)


SELECT w.persistent_session_id
,fv.first_visit_timestamp
,fv.First_Touch_Channel
,fv.Channel_Order
,CASE
	WHEN LOWER(w.referrer) LIKE '%facebook%'
	AND LOWER(w.url) LIKE '%logged_in=true%'
		THEN 1
	ELSE 0
END IsFacebookSignIn
,CASE
	WHEN LOWER(w.source) LIKE '%facebook%' 
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
JOIN channel_sort fv
	ON fv.persistent_session_id = w.persistent_session_id
	AND w.`timestamp` = fv.first_visit_timestamp
	AND fv.Channel_Order = 1
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
