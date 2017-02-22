/* Note: do not use "id" from Ocato_financial_event_logs or you will get every transaction listed
Note that marchex, elocal, and pbx are only in attribution tables and not in weblog
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

,first_visit_timestamp AS (
SELECT w.persistent_session_id
	,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.persistent_session_id IN (SELECT DISTINCT persistent_session_id FROM als_transactions)

)

SELECT fv.persistent_session_id
,fv.first_visit_timestamp
,w.session_id
,w.source
,w.medium
,w.campaign
,w.content
,case  
when source IS NULL and medium IS NULL and campaign IS NULL and content IS NULL then 'Organic/Direct' 
when medium in ('utm_medium=affiliate', 'utm_medium=affiliates', 'utm_medium=affiliawww')
                    or source in ('utm_source=boomerater', 'utm_source=boomerater%20', 'utm_source=lifecare', 'utm_source=affiliates', 'utm_source=affiliate')
                    then 'Marketing - Affiliates'
when medium in ('utm_medium=em', 'utm_medium=ema', 'utm_medium=emai', 'utm_medium=email', 'utm_medium=emailutm_content')
                    or source = 'utm_source=email'
                    then 'Marketing - Email'
when campaign like 'utm_campaign=FB_%' or campaign like 'utm_campaign=pls_avvofb%' or campaign = 'utm_campaign=pls_fb%'
                    or source in ('utm_source=facebook', 'utm_source=twitter', 'utm_source=linkedin', 'utm_source=gplus', 'utm_source=plus',
                                                             'utm_source=googleplus', 'utm_source=youtube', 'utm_source=pinterest', 'utm_source=twitterfeed',
                                                             'utm_source=Facebook', 'utm_source=Twitter', 'utm_source=topix',
                                                             'utm_source=SocialProof', 'utm_source=thetwitter', 'utm_source=faceb', 'utm_source=social')
                                           or medium in ('utm_medium=facebook', 'utm_medium=twitter')
                    then 'Marketing - Social'
when content = 'utm_content=adblock' or (campaign = 'utm_campaign=adblock' and content != 'utm_content=brand') or content = 'utm_content=amm'
                                                                           or (campaign = 'utm_campaign=amm' and content != 'utm_content=brand')
                    then 'SEM - Adblock'
when content = 'utm_content=sgt' or medium = 'utm_medium=sem%2F%3Futm_source%3Dgoogle%2F%3Futm_content%3Dsgt' or campaign = 'utm_campaign=sgt'
                    then 'SEM - Network'
when (medium in ('utm_medium=display','utm_medium=video','utm_medium=mobile_video', 'utm_medium=mobile', 'utm_medium=content', 'utm_medium=mobile_tablet')
                    and source != 'utm_source=google' and source != 'utm_source=gsp')
                    or source = 'utm_source=Outbrain' or source = 'utm_source=preroll'
                    then 'Marketing - Digital Brand and Engagement'
when campaign in ('utm_campaign=brand', 'utm_campaign=Branded_Terms', 'utm_campaign=legalbroad') or content = 'utm_content=brand'
                    then 'Marketing - SEM Brand'
when medium = 'utm_medium=sem' or medium = 'utm_medium=cpc' or medium = 'utm_medium=sem%3Fpromo_code%3DAVVO25'
                    then 'Marketing - SEM Nonbrand'
when campaign like 'utm_campaign=pls%' or campaign like 'utm_campaign=PLS%' 
                    then 'Marketing - Other Paid Marketing'
when medium in ('utm_medium=avvo_badge', 'utm_medium=avvo_badg', 'utm_medium=avvo_bad', 'utm_medium=avvo_ba', 'utm_medium=avvo_b')
                    then 'Other - Avvo Badge'
when source = 'utm_source=avvo' or source = 'utm_source=eboutique' then 'Other - Other'
else 'Marketing - Other Paid Marketing' end channel 
FROM first_visit_timestamp fv
	JOIN src.weblog w
		ON w.`timestamp` = fv.first_visit_timestamp

,channels AS (

from dm.ad_attribution_v3_all
)

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
    ,gp.*
    ,pi.*
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
