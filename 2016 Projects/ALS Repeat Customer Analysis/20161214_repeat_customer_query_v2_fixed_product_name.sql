/* Note: do not use "id" from Ocato_financial_event_logs or you will get every transaction listed
Note that marchex, elocal, and pbx are only in attribution tables and not in weblog
Get channel from session that they paid on
Steps:

- get distinct customer emails
- get purchase count
- get unique customer id */

WITH traffic AS (
-- note this isn't being used now, but it will be used to tie in user_id when I add that (soon)
SELECT t.persistent_session_id
	,MAX(t.resolved_user_id) AS user_id
	-- ,COUNT(DISTINCT t.session_id) total_sessions
FROM dm.traffic t
WHERE t.resolved_user_id IS NOT NULL
GROUP BY t.persistent_session_id
)

-- this ensures that there's one persistent_session_id per purchase, and creates a link for further queries
,als_transactions AS (
	select regexp_extract(url, 'thank_you\/([0-9]+)', 1) as advice_session_id
		,MIN(persistent_session_id) AS persistent_session_id
	from src.weblog 
	where page_type IN ('LS-Thankyou', 'Advisor-thankyou')
	and event_type in ('page_view', 'service_session_payment')
	-- and event_date >= '2016-02-08'
	GROUP BY 1
)

-- gets the three things we will need to do a subsequent self-join to the weblog-based channel-sorting logic
,purchase_visit_timestamp AS (
SELECT w.persistent_session_id
	,regexp_extract(url, 'thank_you\/([0-9]+)', 1) as advice_session_id
	,MIN(w.`timestamp`) AS purchase_visit_timestamp
FROM src.weblog w
WHERE w.persistent_session_id IN (SELECT DISTINCT persistent_session_id FROM als_transactions)
AND w.page_type IN ('LS-Thankyou', 'Advisor-thankyou')
and event_type in ('page_view', 'service_session_payment')

GROUP BY 1,2
)

-- gets the three things we will need to do a subsequent self-join to the weblog-based channel-sorting logic
,first_visit_timestamp AS (
SELECT w.persistent_session_id
	,MIN(w.`timestamp`) AS first_visit_timestamp
	,CAST(t.advice_session_id AS INT) advice_session_id
FROM src.weblog w
JOIN als_transactions t
	ON t.persistent_session_id = w.persistent_session_id
WHERE event_type in ('page_view', 'service_session_payment')
GROUP BY 1,3
)

,
-- this gets the "First-touch" channel for a given purchaser, based on the first time we've seen them in our data
first_visit_channel AS (
SELECT DISTINCT fv.persistent_session_id
--,fv.advice_session_id
,fv.first_visit_timestamp
--,w.source
,w.medium
--,w.campaign
--,w.content
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

-- this gets rid of duplication due to either multiple weblog entries at that timestamp (fairly common) or a weblog entry with no channel info when one with channel info exists (uncommon)
,first_channel_2 AS (
  SELECT *
,ROW_NUMBER() OVER(PARTITION BY fv.persistent_session_id ORDER BY CASE WHEN medium IS NOT NULL THEN 1 ELSE 2 END) AS DupeChecker -- because we occasionally see people who appear to come through both organic and a paid channel
FROM first_visit_channel fv
)

,
-- gets the channel for the timestamp right at the time of ALS purchase
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

-- this gets rid of duplication due to either multiple weblog entries at that timestamp (fairly common) or a weblog entry with no channel info when one with channel info exists (uncommon)
-- note that this is partitioned by advice_session_id because it's a purchase-level item, whereas the first_channel is partitioned by persistent_session_id because it's at that level
,purchase_channel_2 AS (
  SELECT *
,ROW_NUMBER() OVER(PARTITION BY pv.advice_session_id ORDER BY CASE WHEN medium IS NOT NULL THEN 1 ELSE 2 END) AS DupeChecker -- because we occasionally see people who appear to come through both organic and a paid channel
FROM purchase_visit_channel pv
)

,

-- note that this is considered the most reliable source of data for advice sessions, so it's used as the basis for the final query joins
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


-- gets the package name so that we can sort by type
,package_info AS (
select op.id as package_id, oo.id as offer_id, op.name as name --sd.specialty_name, sd.parent_specialty_name, os.name as state
from src.ocato_packages op
left join src.ocato_offers oo on oo.package_id = op.id
--left join dm.specialty_dimension sd on op.specialty_id = sd.specialty_id
--left join src.ocato_states os on oo.state_id = os.id
)

-- now we knit all the data together, starting with gross purchases.  We coalesce several things to create the client identifier, from "best to worse"
-- user ID will be added in shortly, potentially, but the concern is that some purchases may have been made when the person was not logged in
-- note that ocato_advice_sessions also lists a phone number, which would be nice to use as a way of identifying same-buyer entities
,purchase_summary AS (
SELECT gp.advice_session_id
	,COALESCE(gp.purchase_date_pst, oas.created_at_pst) AS purchase_time_pst
	,COALESCE(oas.client_email_address, CAST(fc.persistent_session_id AS VARCHAR), CAST(gp.advice_session_id AS VARCHAR)) AS client_identifier
	,CASE
		WHEN oas.client_email_address IS NULL
			THEN 0
		ELSE 1
	END HasEmailAddress	
	,CASE
		WHEN pac.name LIKE '%advice session%'
			THEN 1
		WHEN pac.name IS NULL -- old advisor sessions don't have a product name
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
		WHEN pac.name IS NULL -- this is what old advisor sessions look like
			THEN 0
		ELSE 1
	END IsOffline
	,CASE
		WHEN pac.name LIKE "%advice session%"
			THEN 'Advice Session'
		WHEN pac.name IS NULL
			THEN 'Advice Session'
		WHEN pac.name LIKE '%review:%'
			THEN 'Document Review'
		ELSE 'Offline'
	END AS Purchase_Type
	,pac.name AS product_name
	,pv.Purchase_Visit_Channel
	,pv.source purchase_source
	,pv.medium purchase_medium
	,pv.campaign purchase_campaign
	,pv.content purchase_content
	,fc.First_Visit_Channel
	,fc.first_visit_timestamp
FROM gross_purchases gp
LEFT JOIN src.ocato_advice_sessions oas
ON gp.advice_session_id = oas.id
LEFT JOIN package_info pac
ON pac.offer_id = gp.offer_id	
LEFT JOIN purchase_channel_2 pv
	ON gp.advice_session_id = CAST(pv.advice_session_id AS INT)
	AND pv.DupeChecker = 1 -- if someone appears to be both paid and organic (channel info present in one entry on the same timestamp and not on another), precedence given to paid channel
LEFT JOIN first_channel_2 fc
	ON fc.persistent_session_id = pv.persistent_session_id
	AND fc.DupeChecker = 1 -- if someone appears to be both paid and organic, precedence given to paid channel

)

-- finally, get the windowed times of first purchase and total purchase counts, then identify whether the purchase is the first one for that client or not
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
	,DATEDIFF(purchase_time_pst, customer_first_visit_date) AS first_visit_to_purchase_days
	FROM (SELECT *
			,MIN(purchase_time_pst) OVER(PARTITION BY client_identifier) AS customer_first_purchase_date
			,MIN(first_visit_timestamp) OVER(PARTITION BY client_identifier) AS customer_first_visit_date
			,MIN(advice_session_id) OVER(PARTITION BY client_identifier) AS first_advice_session_id
			,COUNT(advice_session_id) OVER(PARTITION BY client_identifier) AS client_purchase_total
		FROM purchase_summary
) x

