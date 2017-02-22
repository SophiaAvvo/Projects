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
WHERE t.event_date >= '2016-02-08'
--AND t.resolved_user_id IS NOT NULL
GROUP BY t.persistent_session_id
)

,als_transactions AS (
	select regexp_extract(url, 'thank_you\/([0-9]+)', 1) as advice_session_id
		,MAX(persistent_session_id) AS persistent_session_id
	from src.page_view 
	where page_type IN ('LS-Thankyou', 'Advisor-thankyou')
	and event_date >= '2016-02-08'
  
)

,purchase_visit_timestamp AS (
SELECT w.persistent_session_id
	,MIN(w.`timestamp`) AS purchase_visit_timestamp
FROM src.page_view w
WHERE w.persistent_session_id IN (SELECT DISTINCT persistent_session_id FROM als_transactions)
AND w.page_type IN ('LS-Thankyou', 'Advisor-thankyou')

)

,first_visit_timestamp AS (
SELECT w.persistent_session_id
	,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.page_view w
WHERE w.persistent_session_id IN (SELECT DISTINCT persistent_session_id FROM als_transactions)

)

,

first_visit_channel AS (
SELECT fv.persistent_session_id
,fv.first_visit_timestamp
,w.session_id
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
when LOWER(medium) in ('avvo_badge', 'avvo_badg', 'avvo_bad', 'avvo_ba', 'avvo_b', '["avvo_badge","avvo_badge"]', 'avvo_badge,avvo_badge', )
                    then 'Other - Avvo Badge'
when source IN ('avvo', 'avvo" target="_blank"', '["avvo","avvo"]', 'avvo,avvo', 'eboutique')
	then 'Other - Other'
else 'Marketing - Other Paid Marketing' 
end channel 
FROM first_visit_timestamp fv
	JOIN src.weblog w
		ON w.`timestamp` = fv.first_visit_timestamp
		AND w.persistent_session_id = fv.persistent_session_id
)

-- note that this is considered a more reliable source of data, but doesn't go back all the way
gross_purchases AS (
SELECT advice_session_id
,order_id
,offer_id
,MAX(created_at_pst) purchase_date
FROM src.ocato_financial_event_logs ofel
WHERE event_type = 'purchase'
AND ofel.created_at_pst >= '2016-02-08'
GROUP BY 1,2,3

)



,package_info AS (
select op.id as package_id, oo.id as offer_id, op.name as package_name, sd.specialty_name, sd.parent_specialty_name, os.name as state
from src.ocato_packages op
left join src.ocato_offers oo on oo.package_id = op.id
left join dm.specialty_dimension sd on op.specialty_id = sd.specialty_id
left join src.ocato_states os on oo.state_id = os.id
)

,distinct_client_purchases AS (
SELECT oas.client_email_address
	,COUNT(DISTINCT oas.id) total_distinct_purchases
	,MIN(oas.created_at) AS first_purchase_date
	,MIN(oas.id) AS first_advice_session_id
FROM src.ocato_advice_sessions oas

)

,purchase_summary AS (
SELECT oas.id AS advice_session_id
	,oas.client_email_address
    ,COALESCE(gp.purchase_date_pst, oas.created_at_pst) AS purchase_date_pst
    ,pi.package_name
	,CASE
		WHEN dcp.first_advice_session_id IS NOT NULL
			THEN 'First Purchase'
		ELSE 'Repeat Purchase'
	END First_or_Repeat
	,dcp.total_distinct_purchases
	,dcp.first_purchase_date AS customer_first_purchase_date
	,DATEDIFF(oas.created_at_pst, dcp.first_purchase_date) AS time_since_first_purchase
FROM src.ocato_advice_sessions oas
LEFT JOIN gross_purchases gp
ON gp.advice_session_id = oas.id
LEFT JOIN package_info pi
ON pi.offer_id = gp.offer_id
LEFT JOIN distinct_client_purchases dcp
	ON dcp.first_advice_session_id = oas.id
LIMIT 10;

)

,


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
