/* Note: do not use "id" from Ocato_financial_event_logs or you will get every transaction listed
Note that marchex, elocal, and pbx are only in attribution tables and not in weblog
Get channel from session that they paid on
Steps:

- get distinct customer emails
- get purchase count
- get unique customer id */

WITH traffic AS (

SELECT t.persistent_session_id
	,MAX(t.resolved_user_id) AS user_id
	-- ,COUNT(DISTINCT t.session_id) total_sessions
FROM dm.traffic t
-- WHERE t.event_date >= '2016-02-08'
--AND t.resolved_user_id IS NOT NULL
GROUP BY t.persistent_session_id
)

,als_transactions AS (
	select regexp_extract(url, 'thank_you\/([0-9]+)', 1) as advice_session_id
		,MIN(persistent_session_id) AS persistent_session_id
	from src.page_view 
	where page_type IN ('LS-Thankyou', 'Advisor-thankyou')
	-- and event_date >= '2016-02-08'
	GROUP BY 1
)

,purchase_visit_timestamp AS (
SELECT w.persistent_session_id
	,regexp_extract(url, 'thank_you\/([0-9]+)', 1) as advice_session_id
	,MIN(w.`timestamp`) AS purchase_visit_timestamp
FROM src.page_view w
WHERE w.persistent_session_id IN (SELECT DISTINCT persistent_session_id FROM als_transactions)
AND w.page_type IN ('LS-Thankyou', 'Advisor-thankyou')
GROUP BY 1,2
)

,first_visit_timestamp AS (
SELECT w.persistent_session_id
	,MIN(w.`timestamp`) AS first_visit_timestamp
	,CAST(t.advice_session_id AS INT) advice_session_id
FROM src.page_view w
JOIN als_transactions t
	ON t.persistent_session_id = w.persistent_session_id
GROUP BY 1,2
)

,

first_visit_channel AS (
SELECT DISTINCT fv.persistent_session_id
,fv.advice_session_id
,fv.first_visit_timestamp
,w.source
,w.medium
,w.campaign
,w.content
,case  
when source IS NULL and medium IS NULL and campaign IS NULL and content IS NULL then 'Organic/Direct' 
when LOWER(medium) LIKE '%affilia%'
                    or LOWER(source) LIKE '%boomerater%'
					OR LOWER(source) IN ('lifecare', 'affiliates', 'affiliate')
                    then 'Marketing - Affiliates'
when LOWER(w.medium) LIKE '%email%' 
	OR LOWER(w.medium) IN ('em', 'ema', 'emai')
                    then 'Marketing - Email'
when LOWER(campaign) like '%fb_%' 
	or LOWER(campaign) like '%pls_avvofb%' 
	or LOWER(campaign) = '%pls_fb%'
    or LOWER(source) in ('facebook', 'twitter', 'linkedin', 'gplus', 'plus',
						'googleplus', 'youtube', 'pinterest', 'twitterfeed', 'topix',
                         'SocialProof', 'thetwitter', 'faceb', 'social')
    or LOWER(medium) in ('facebook', 'twitter')
                    then 'Marketing - Social'
when LOWER(content) = 'adblock' 
or (LOWER(campaign) = 'adblock' and LOWER(content) != 'brand') 
or LOWER(content) = 'amm'
or (LOWER(campaign) = 'amm' and LOWER(content) != 'brand') -- adblock switching to "amm" instead
                    then 'SEM - Adblock'
when LOWER(content) = 'sgt' 
or medium = 'sem%2F%3Futm_source%3Dgoogle%2F%3Futm_content%3Dsgt' 
OR medium = 'sem/?utm_source=google/?utm_content=sgt'
or LOWER(campaign) = 'sgt'
    then 'SEM - Network'
when (medium in ('display','video','mobile_video', 'mobile', 'content', 'mobile_tablet')
                    and source != 'google' and source != 'gsp')
                    or LOWER(source) = 'outbrain' 
					or LOWER(source) = 'preroll'
                    then 'Marketing - Digital Brand and Engagement'
when LOWER(campaign) in ('brand', 'legalbroad', '["brand","brand"]', 'brand,brand')  -- updated to include 
or LOWER(content) = 'brand'
OR LOWER(campaign) LIKE '%branded_terms%'
OR medium LIKE '%sem?promo_code=AVVO25%' -- confirmed with Mira
    then 'Marketing - SEM Brand'
when LOWER(medium) IN ('sem', 'cpc', '["cpc","cpc"]', 'cpc,cpc', 'sem,sem', '["sem","sem"]')
                    then 'Marketing - SEM Nonbrand'
when LOWER(campaign) like '%pls%'
                    then 'Marketing - Other Paid Marketing'
when LOWER(medium) in ('avvo_badge', 'avvo_badg', 'avvo_bad', 'avvo_ba', 'avvo_b', '["avvo_badge","avvo_badge"]', 'avvo_badge,avvo_badge' )
                    then 'Other - Avvo Badge'
when source IN ('avvo', 'avvo" target="_blank"', '["avvo","avvo"]', 'avvo,avvo', 'eboutique')
	then 'Other - Other'
else 'Marketing - Other Paid Marketing' 
end First_Visit_Channel
FROM first_visit_timestamp fv
	JOIN src.weblog w
		ON w.`timestamp` = fv.first_visit_timestamp
		AND w.persistent_session_id = fv.persistent_session_id
		and event_type in ('page_view', 'service_session_payment')
)

,first_channel_2 AS (
  SELECT *
,ROW_NUMBER() OVER(PARTITION BY fv.persistent_session_id ORDER BY CASE WHEN medium IS NOT NULL THEN 1 ELSE 2 END) AS DupeChecker -- because we occasionally see people who appear to come through both organic and a paid channel
FROM first_visit_channel fv
)

,

purchase_visit_channel AS (
SELECT DISTINCT pv.persistent_session_id
,pv.advice_session_id
,pv.purchase_visit_timestamp
,w.source
,w.medium
,w.campaign
,w.content
,case  
when source IS NULL and medium IS NULL and campaign IS NULL and content IS NULL then 'Organic/Direct' 
when LOWER(medium) LIKE '%affilia%'
                    or LOWER(source) LIKE '%boomerater%'
					OR LOWER(source) IN ('lifecare', 'affiliates', 'affiliate')
                    then 'Marketing - Affiliates'
when LOWER(w.medium) LIKE '%email%' 
	OR LOWER(w.medium) IN ('em', 'ema', 'emai')
                    then 'Marketing - Email'
when LOWER(campaign) like '%fb_%' 
	or LOWER(campaign) like '%pls_avvofb%' 
	or LOWER(campaign) = '%pls_fb%'
    or LOWER(source) in ('facebook', 'twitter', 'linkedin', 'gplus', 'plus',
						'googleplus', 'youtube', 'pinterest', 'twitterfeed', 'topix',
                         'SocialProof', 'thetwitter', 'faceb', 'social')
    or LOWER(medium) in ('facebook', 'twitter')
                    then 'Marketing - Social'
when LOWER(content) = 'adblock' 
or (LOWER(campaign) = 'adblock' and LOWER(content) != 'brand') 
or LOWER(content) = 'amm'
or (LOWER(campaign) = 'amm' and LOWER(content) != 'brand') -- adblock switching to "amm" instead
                    then 'SEM - Adblock'
when LOWER(content) = 'sgt' 
or medium = 'sem%2F%3Futm_source%3Dgoogle%2F%3Futm_content%3Dsgt' 
OR medium = 'sem/?utm_source=google/?utm_content=sgt'
or LOWER(campaign) = 'sgt'
    then 'SEM - Network'
when (medium in ('display','video','mobile_video', 'mobile', 'content', 'mobile_tablet')
                    and source != 'google' and source != 'gsp')
                    or LOWER(source) = 'outbrain' 
					or LOWER(source) = 'preroll'
                    then 'Marketing - Digital Brand and Engagement'
when LOWER(campaign) in ('brand', 'legalbroad', '["brand","brand"]', 'brand,brand')  -- updated to include 
or LOWER(content) = 'brand'
OR LOWER(campaign) LIKE '%branded_terms%'
OR medium LIKE '%sem?promo_code=AVVO25%' -- confirmed with Mira
    then 'Marketing - SEM Brand'
when LOWER(medium) IN ('sem', 'cpc', '["cpc","cpc"]', 'cpc,cpc', 'sem,sem', '["sem","sem"]')
                    then 'Marketing - SEM Nonbrand'
when LOWER(campaign) like '%pls%'
                    then 'Marketing - Other Paid Marketing'
when LOWER(medium) in ('avvo_badge', 'avvo_badg', 'avvo_bad', 'avvo_ba', 'avvo_b', '["avvo_badge","avvo_badge"]', 'avvo_badge,avvo_badge' )
                    then 'Other - Avvo Badge'
when source IN ('avvo', 'avvo" target="_blank"', '["avvo","avvo"]', 'avvo,avvo', 'eboutique')
	then 'Other - Other'
else 'Marketing - Other Paid Marketing' 
end Purchase_Visit_Channel
FROM purchase_visit_timestamp pv
	JOIN src.weblog w
		ON w.`timestamp` = pv.purchase_visit_timestamp
		AND w.persistent_session_id = pv.persistent_session_id
		and event_type in ('page_view', 'service_session_payment')
)

,purchase_channel_2 AS (
  SELECT *
,ROW_NUMBER() OVER(PARTITION BY pv.persistent_session_id ORDER BY CASE WHEN medium IS NOT NULL THEN 1 ELSE 2 END) AS DupeChecker -- because we occasionally see people who appear to come through both organic and a paid channel
FROM purchase_visit_channel pv
)

,

-- note that this is considered a more reliable source of data, but doesn't go back all the way
gross_purchases AS (
SELECT advice_session_id
,order_id
,offer_id
,MIN(created_at_pst) purchase_date_pst
FROM src.ocato_financial_event_logs ofel
WHERE event_type = 'purchase'
--AND ofel.created_at_pst >= '2016-02-08'
GROUP BY 1,2,3

)



,package_info AS (
select op.id as package_id, oo.id as offer_id, op.name as name --sd.specialty_name, sd.parent_specialty_name, os.name as state
from src.ocato_packages op
left join src.ocato_offers oo on oo.package_id = op.id
--left join dm.specialty_dimension sd on op.specialty_id = sd.specialty_id
--left join src.ocato_states os on oo.state_id = os.id
)

/* need this to identify whether the purchase is the first or a repeat
also convenient for double-checking totals */
,distinct_client_purchases AS (
SELECT oas.client_email_address
	,COUNT(DISTINCT oas.id) total_distinct_purchases
	,MIN(oas.created_at_pst) AS first_purchase_date
	,MIN(oas.id) AS first_advice_session_id
FROM src.ocato_advice_sessions oas
LEFT JOIN als_transactions als
	ON als.advice_session_id = oas.id
GROUP BY 1
)

,purchase_summary AS (
SELECT gp.advice_session_id
	,COALESCE(gp.purchase_date_pst, oas.created_at_pst) AS purchase_time_pst
	,COALESCE(oas.client_email_address, CAST(fv.persistent_session_id AS VARCHAR), CAST(gp.advice_session_id AS VARCHAR)) AS client_identifier
	,CASE
		WHEN oas.client_email_address IS NULL
			THEN 0
		ELSE 1
	END HasEmailAddress
	,MIN(COALESCE(gp.purchase_date_pst, oas.created_at_pst)) OVER(PARTITION BY COALESCE(oas.client_email_address, CAST(pv.persistent_session_id AS VARCHAR), CAST(gp.advice_session_id AS VARCHAR)) AS customer_first_purchase_date
	,MIN(gp.advice_session_id) OVER(PARTITION BY COALESCE(oas.client_email_address, CAST(pv.persistent_session_id AS VARCHAR), CAST(gp.advice_session_id AS VARCHAR)) AS first_advice_session_id	
	,CASE
		WHEN pac.name LIKE '%advice session%'
			THEN 1
		ELSE 0
	END IsAdvisor
	,CASE
		WHEN pac.name LIKE '%review:%'
			THEN 1
		ELSE 0
	END AS IsDocReview
	,CASE
		WHEN pac.name LIKE "%advice session%"
			THEN 0
		WHEN pac.name LIKE '%review:%'
			THEN 0
		ELSE 1
	END IsOffline
	,CASE
		WHEN pac.name LIKE "%advice session%"
			THEN 'Advice Session'
		WHEN pac.name LIKE '%review:%'
			THEN 'Document Review'
		ELSE 'Offline'
	END AS Purchase_Type
	,pv.Purchase_Visit_Channel
	,pv.source purchase_source
	,pv.medium purchase_medium
	,pv.campaign purchase_campaign
	,pv.content purchase_content
	,fc.First_Visit_Channel
FROM gross_purchases gp
LEFT JOIN src.ocato_advice_sessions oas
ON gp.advice_session_id = oas.id
LEFT JOIN package_info pac
ON pac.offer_id = gp.offer_id
LEFT JOIN distinct_client_purchases dcp
	ON dcp.client_email_address = oas.client_email_address
LEFT JOIN first_visit_channel fc
	ON fc.advice_session_id = gp.advice_session_id
	AND DupeChecker = 1 -- if someone appears to be both paid and organic, precedence given to paid channel	
LEFT JOIN purchase_channel_2 pv
	ON gp.advice_session_id = CAST(pv.advice_session_id AS INT)
	AND DupeChecker = 1 -- if someone appears to be both paid and organic, precedence given to paid channel


)

SELECT *
	,CASE
		WHEN first_advice_session_id = advice_session_id
			THEN 1
		ELSE 0
	END IsFirst
	,CASE
		WHEN first_advice_session_id <> advice_session_id
			THEN 1
		ELSE 0
	END IsRepeat
FROM purchase_summary

/*
SELECT client_email_address
,dd.month_begin_date
,SUM(IsFirst) AS First_Time_Purchaser_Count
,SUM(IsRepeat) AS 
FROM purchase_summary ps
	JOIN dm.date_dim dd
		ON dd.actual_date = to_date(ps.purchase_date_pst)
*/

/* Kenneth's methodology
select sum(case when transaction_count =1 then 1 else 0 end) as 'one_time',
  sum(case when transaction_count >1 then 1 else 0 end) as 'repeat_customer'
  from(
    select client_email_address, count(*) as transaction_count
    from (
      select distinct to_date(created_at) as event_date, client_email_address
      from src.ocato_advice_sessions) as table_a
group by client_email_address) as table_b 

*/


SELECT id AS advice_session_id
,client_email_address
,client_phone_number
,als.persistent_session_id
,t.user_id
,to_date(created_at_pst) order_date
FROM src.ocato_advice_sessions oas
	LEFT JOIN als_transactions als
		ON als.order_id = oas.id
	LEFT JOIN traffic t
		ON t.persistent_session_id = als.persistent_session_id
WHERE event_type <> 'purchase'
