/
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
when source IS NULL 
and medium IS NULL 
and campaign IS NULL 
and content IS NULL 
AND referrer IS NULL
	then 'Direct'
WHEN when source IS NULL 
and medium IS NULL 
and campaign IS NULL 
and content IS NULL
	THEN 'Organic'
when LOWER(medium) LIKE '%affilia%'
                    or LOWER(source) LIKE '%boomerater%'
					OR LOWER(source) IN ('lifecare', 'affiliates', 'affiliate')
                    then 'Partners'
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
