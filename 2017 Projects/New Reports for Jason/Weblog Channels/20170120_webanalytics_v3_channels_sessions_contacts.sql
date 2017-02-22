WITH cnt_emails as						
(						
select						
ci.session_id						
, count(*) as emails_and_messages						
from src.contact_impression ci														
WHERE ci.contact_type IN ('email', 'message')	
AND ci.event_date >= '2016-01-01'					
group by 1						
						
)					
						
						
,cnt_webcontacts as 						
(						
select						
ci.session_id						
, count(*) as website_clicks
from src.contact_impression ci														
WHERE ci.contact_type = 'website'
AND ci.event_date >= '2016-01-01'
group by 1						
						
)	

SELECT lpv_campaign
,lpv_source
,lpv_medium
,case  
when w.lpv_content = 'utm_content=sgt' or w.lpv_medium = 'utm_medium=sem%2F%3Futm_source%3Dgoogle%2F%3Futm_content%3Dsgt' or w.lpv_campaign = 'utm_campaign=sgt'
                    then 'GDN Network'
when w.lpv_source = '' 
and w.lpv_medium = '' 
and w.lpv_campaign = '' 
and w.lpv_content = '' 
AND w.lpv_referring_domain IN ('', 'N/A')
THEN 'Direct'
when w.lpv_source = '' 
and w.lpv_medium = '' 
and w.lpv_campaign = '' 
and w.lpv_content = '' 
/* AND w.lpv_referring_domain NOT IN ('', 'N/A') (redundant) */
AND w.lpv_page_type = 'Homepage'
	THEN 'SEO Brand'
when w.lpv_source IN ('elocal', 'pbx', 'marchex') then 'Marchex/eLocal/pbx Calls'
when (w.lpv_campaign in ('utm_campaign=brand', 'utm_campaign=Branded_Terms', 'utm_campaign=legalbroad', 'utm_campaign=Brand|RLSA') or w.lpv_content = 'utm_content=brand')
	AND LOWER(w.lpv_campaign) NOT LIKE '%fb%'
    then 'SEM Brand'
when w.lpv_source = '' 
and w.lpv_medium = '' 
and w.lpv_campaign = '' 
and w.lpv_content = '' 
/* AND w.lpv_referring_domain NOT IN ('', 'N/A')
AND w.lpv_page_type <> 'Homepage' (redundant) */
	THEN 'SEO Non-Brand'
WHEN (LOWER(w.lpv_campaign) LIKE 'legal_q_&_a_search' 
OR LOWER(w.lpv_campaign) LIKE '%pls|%'
OR LOWER(w.lpv_campaign) LIKE '%legalqa%'
OR LOWER(w.lpv_campaign) LIKE '%plsremarketing%'
OR LOWER(w.lpv_campaign) LIKE '%advisorremarketing%'
OR w.lpv_campaign = 'utm_campaign=pls')
AND (CASE 
WHEN LOWER(w.lpv_campaign) LIKE '%brand%'
THEN 1
WHEN LOWER(w.lpv_medium) = 'utm_medium=display' /* added 01/19 */
THEN 1
ELSE 0
END) = 0
THEN 'SEM Non-Brand'
WHEN w.lpv_medium IN ('utm_medium=cpc', 'utm_medium=sem', 'utm_medium=cpm', 'utm_medium=sem%3Fpromo_code%3DAVVO25')
AND (LoWER(w.lpv_source) LIKE '%google%'
	OR LoWER(w.lpv_source) LIKE '%bing%'
	OR LoWER(w.lpv_source) LIKE '%yahoo%')
AND (CASE 
WHEN LOWER(w.lpv_campaign) LIKE '%brand%'
THEN 1
ELSE 0
END) = 0
THEN 'SEM Non-Brand'
when w.lpv_content = 'utm_content=adblock' or (w.lpv_campaign = 'utm_campaign=adblock' and w.lpv_content != 'utm_content=brand') or w.lpv_content = 'utm_content=amm'
					or (w.lpv_campaign = 'utm_campaign=amm' and w.lpv_content != 'utm_content=brand')
                    then 'SEM Non-Brand'
when (w.lpv_medium in ('utm_medium=em', 'utm_medium=ema', 'utm_medium=emai', 'utm_medium=email', 'utm_medium=emailutm_content')
                    or w.lpv_source = 'utm_source=email'
OR LOWER(w.lpv_campaign) LIKE '%reset_password%'
)
AND (CASE
WHEN LOWER(w.lpv_campaign) LIKE '%client_choice_award%'
THEN 1
WHEN LOWER(w.lpv_campaign) LIKE '%best_answer_pro%'
THEN 1
WHEN LOWER(w.lpv_campaign) LIKE '%digest%'
THEN 1
WHEN LOWER(w.lpv_campaign) LIKE '%_pro'
THEN 1
ELSE 0
END) = 0
THEN 'Consumer Email'
WHEN w.lpv_medium in ('utm_medium=em', 'utm_medium=ema', 'utm_medium=emai', 'utm_medium=email', 'utm_medium=emailutm_content')
                    or w.lpv_source = 'utm_source=email'
AND (LOWER(w.lpv_source) LIKE '%best_answer_pro%'
		OR LOWER(w.lpv_campaign) LIKE '%digest%'
OR LOWER(w.lpv_campaign) LIKE '%client_choice_award%'
OR LOWER(w.lpv_campaign) LIKE '%_pro'
)
THEN 'Attorney Email'
when w.lpv_medium in ('utm_medium=affiliate', 'utm_medium=affiliates', 'utm_medium=affiliawww')
                    or w.lpv_source in ('utm_source=boomerater', 'utm_source=boomerater%20', 'utm_source=lifecare', 'utm_source=affiliates', 'utm_source=affiliate')
                    then 'Partners'	
WHEN (LOWER(w.lpv_medium) LIKE '%cpc%'
OR LOWER(w.lpv_medium) LIKE '%cpm%'
OR LOWER(w.lpv_medium) LIKE '%banner%'
OR LOWER(w.lpv_medium) LIKE '%display%')
AND (LOWER(w.lpv_campaign) LIKE '%fb_%'
OR LOWER(w.lpv_campaign) LIKE '%acq%'
OR LOWER(w.lpv_campaign) LIKE '%pls_avvofb%'
OR LOWER(w.lpv_campaign) LIKE '%pls_fb_%'
OR LOWER(w.lpv_campaign) LIKE '%pls_fbb%'
OR LOWER(w.lpv_campaign) LIKE '%tw_%'
OR LOWER(w.lpv_campaign) LIKE '%_abandoners%'
OR LOWER(w.lpv_campaign) LIKE '%pls_%')
AND (CASE
WHEN LOWER(w.lpv_campaign) LIKE '%2016brandvideos_t_acq%'
THEN 1
WHEN LOWER(w.lpv_campaign) LIKE '%ricampaign%'
THEN 1
WHEN LOWER(w.lpv_campaign) LIKE '%fb_boosted%'
THEN 1
WHEN LOWER(w.lpv_campaign) LIKE '%lawyer%'
THEN 1
WHEN LOWER(w.lpv_campaign) LIKE '%pokemon%'
THEN 1
WHEN LOWER(w.lpv_campaign) LIKE '%eng_%'
THEN 1
ELSE 0
END) = 0
THEN 'Display & Emerging'
WHEN LOWER(w.lpv_campaign) IN ('utm_campaign=2016brandvideos_t_acq', 'utm_campaign=claim 2016')
OR LOWER(w.lpv_campaign) LIKE '%ricampaign%'
OR LOWER(w.lpv_campaign) LIKE '%2016brandvideos%'
OR LOWER(w.lpv_campaign) LIKE '%relstudy%'
OR LOWER(w.lpv_campaign) LIKE '%eng_%'
OR LOWER(w.lpv_campaign) LIKE '%prenupforlove%'
OR LOWER(w.lpv_campaign) LIKE 'fb_lawyer%'
OR LOWER(w.lpv_medium) IN ('utm_medium=video', 'utm_medium=mobile', 'utm_medium=mobile_video', 'utm_medium=mobile_tablet', 'utm_content')
OR LOWER(w.lpv_medium) LIKE '%display%'
OR LOWER(w.lpv_source) LIKE '%outbrain%'
then 'Digital Engagement'
when w.lpv_campaign like 'utm_campaign=FB_%' or w.lpv_campaign like 'utm_campaign=pls_avvofb%' or w.lpv_campaign = 'utm_campaign=pls_fb%'
                    or w.lpv_source in ('utm_source=facebook', 'utm_source=twitter', 'utm_source=linkedin', 'utm_source=gplus', 'utm_source=plus',
                                                             'utm_source=googleplus', 'utm_source=youtube', 'utm_source=pinterest', 'utm_source=twitterfeed',
                                                             'utm_source=Facebook', 'utm_source=Twitter', 'utm_source=topix',
                                                             'utm_source=SocialProof', 'utm_source=thetwitter', 'utm_source=faceb', 'utm_source=social', 'utm_source=t.co')
                                           or w.lpv_medium in ('utm_medium=facebook', 'utm_medium=twitter')
										   
                    then 'Digital Engagement'
when (w.lpv_medium in ('utm_medium=display','utm_medium=video','utm_medium=mobile_video', 'utm_medium=mobile', 'utm_medium=content', 'utm_medium=mobile_tablet')
                    and w.lpv_source != 'utm_source=google' and w.lpv_source != 'utm_source=gsp')
                    or w.lpv_source = 'utm_source=Outbrain' or w.lpv_source = 'utm_source=preroll'
	THEN 'Digital Engagement'

WHEN LOWER(w.lpv_medium) = 'utm_medium=referral'
THEN 'Referral'
when w.lpv_medium in ('utm_medium=avvo_badge', 'utm_medium=avvo_badg', 'utm_medium=avvo_bad', 'utm_medium=avvo_ba', 'utm_medium=avvo_b')
                    then 'Other'
when w.lpv_source = 'utm_source=avvo' or w.lpv_source = 'utm_source=eboutique' then 'Other'
else 'Other' end channel_new
,event_date AS `Date`
,COUNT(DISTINCT w.session_id) sessions
,SUM(emails_and_messages) AS emails_and_messages_gross
,SUM(website_clicks) AS website_clicks
FROM dm.webanalytics_ad_attribution_v3 w
 LEFT JOIN cnt_emails em
	ON em.session_id = w.session_id
LEFT JOIN cnt_webcontacts wb
	ON wb.session_id = w.session_id
  where w.event_date >= '2015-01-01'
  GROUP BY 1,2,3,4,5