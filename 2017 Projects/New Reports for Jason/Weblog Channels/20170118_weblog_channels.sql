select event_date
,Campaign AS lpv_campaign
,Source AS lpv_source
,Medium AS lpv_medium
,case  
when content = 'sgt' or medium = 'sem%2F%3Futm_source%3Dgoogle%2F%3Futm_content%3Dsgt' or campaign = 'sgt'
                    then 'GDN Network'
when source IS NULL 
and medium IS NULL 
and campaign IS NULL 
and content IS NULL 
AND (referring_domain IS NULL OR referring_domain IN ('', 'N/A') )
THEN 'Direct'
when source IS NULL 
and medium IS NULL 
and campaign IS NULL 
and content IS NULL
AND referring_domain NOT IN ('', 'N/A')
AND referring_domain IS NOT NULL
AND page_type = 'Homepage'
	THEN 'SEO Brand'
when source IN ('elocal', 'pbx', 'marchex') then 'Marchex/eLocal/pbx Calls'
when (campaign in ('brand', 'Branded_Terms', 'legalbroad', 'Brand|RLSA') or content = 'brand')
	AND LOWER(campaign) NOT LIKE '%fb%'
    then 'SEM Brand'
when source IS NULL 
and medium IS NULL 
and campaign IS NULL 
and content IS NULL 
AND referring_domain NOT IN ('', 'N/A')
AND referring_domain IS NOT NULL
AND page_type <> 'Homepage'
	THEN 'SEO Non-Brand'
WHEN (LOWER(campaign) LIKE 'legal_q_&_a_search' 
OR LOWER(campaign) LIKE '%pls|%'
OR LOWER(campaign) LIKE '%legalqa%'
OR LOWER(campaign) LIKE '%plsremarketing%'
OR LOWER(campaign) LIKE '%advisorremarketing%'
OR campaign = 'pls')
AND (CASE 
WHEN LOWER(campaign) LIKE '%fb%'
THEN 1
ELSE 0
END) = 0
THEN 'SEM Non-Brand'
WHEN medium IN ('cpc', 'sem', 'cpm', 'sem%3Fpromo_code%3DAVVO25')
AND (LoWER(source) LIKE '%google%'
	OR LoWER(source) LIKE '%bing%'
	OR LoWER(source) LIKE '%yahoo%')
AND (CASE 
WHEN LOWER(campaign) LIKE '%fb%'
THEN 1
ELSE 0
END) = 0
THEN 'SEM Non-Brand'
when (medium in ('em', 'ema', 'emai', 'email', 'emailutm_content')
                    or source = 'email'
OR LOWER(campaign) LIKE '%reset_password%'
)
AND (CASE
WHEN LOWER(campaign) LIKE '%client_choice_award%'
THEN 1
WHEN LOWER(campaign) LIKE '%best_answer_pro%'
THEN 1
WHEN LOWER(campaign) LIKE '%digest%'
THEN 1
WHEN LOWER(campaign) LIKE '%_pro'
THEN 1
ELSE 0
END) = 0
THEN 'Consumer Email'
WHEN medium in ('em', 'ema', 'emai', 'email', 'emailutm_content')
                    or source = 'email'
AND (LOWER(source) LIKE '%best_answer_pro%'
		OR LOWER(campaign) LIKE '%digest%'
OR LOWER(campaign) LIKE '%client_choice_award%'
OR LOWER(campaign) LIKE '%_pro'
)
THEN 'Attorney Email'
when medium in ('affiliate', 'affiliates', 'affiliawww')
                    or source in ('boomerater', 'boomerater%20', 'lifecare', 'affiliates', 'affiliate')
                    then 'Partners'	
WHEN (LOWER(medium) LIKE '%cpc%'
OR LOWER(medium) LIKE '%cpm%'
OR LOWER(medium) LIKE '%banner%'
OR LOWER(medium) LIKE '%display%')
AND (LOWER(campaign) LIKE '%fb_%'
OR LOWER(campaign) LIKE '%acq%'
OR LOWER(campaign) LIKE '%pls_avvofb%'
OR LOWER(campaign) LIKE '%pls_fb_%'
OR LOWER(campaign) LIKE '%pls_fbb%'
OR LOWER(campaign) LIKE '%tw_%'
OR LOWER(campaign) LIKE '%_abandoners%'
OR LOWER(campaign) LIKE '%pls_%')
AND (CASE
WHEN LOWER(campaign) LIKE '%2016brandvideos_t_acq%'
THEN 1
WHEN LOWER(campaign) LIKE '%ricampaign%'
THEN 1
WHEN LOWER(campaign) LIKE '%fb_boosted%'
THEN 1
WHEN LOWER(campaign) LIKE '%lawyer%'
THEN 1
WHEN LOWER(campaign) LIKE '%pokemon%'
THEN 1
WHEN LOWER(campaign) LIKE '%eng_%'
THEN 1
ELSE 0
END) = 0
THEN 'Display & Emerging'
WHEN LOWER(campaign) IN ('2016brandvideos_t_acq', 'claim 2016')
OR LOWER(campaign) LIKE '%ricampaign%'
OR LOWER(campaign) LIKE '%2016brandvideos%'
OR LOWER(campaign) LIKE '%relstudy%'
OR LOWER(campaign) LIKE '%eng_%'
OR LOWER(campaign) LIKE '%prenupforlove%'
OR LOWER(campaign) LIKE 'fb_lawyer%'
OR LOWER(medium) IN ('video', 'mobile', 'mobile_video', 'mobile_tablet', 'content')
OR LOWER(medium) LIKE '%display%'
OR LOWER(source) LIKE '%outbrain%'
then 'Digital Engagement'
when campaign like 'FB_%' or campaign like 'pls_avvofb%' or campaign = 'pls_fb%'
                    or source in ('facebook', 'twitter', 'linkedin', 'gplus', 'plus',
                                                             'googleplus', 'youtube', 'pinterest', 'twitterfeed',
                                                             'Facebook', 'Twitter', 'topix',
                                                             'SocialProof', 'thetwitter', 'faceb', 'social', 't.co')
                                           or medium in ('facebook', 'twitter')
										   
                    then 'Digital Engagement'
when (medium in ('display','video','mobile_video', 'mobile', 'content', 'mobile_tablet')
                    and source != 'google' and source != 'gsp')
                    or source = 'Outbrain' or source = 'preroll'
	THEN 'Digital Engagement'
when content = 'adblock' or (campaign = 'adblock' and content != 'brand') or content = 'amm'
					or (campaign = 'amm' and content != 'brand')
                    then 'SEM Non-Brand'
WHEN LOWER(medium) = 'referral'
THEN 'Referral'
when medium in ('avvo_badge', 'avvo_badg', 'avvo_bad', 'avvo_ba', 'avvo_b')
                    then 'Other'
when source = 'avvo' or source = 'eboutique' then 'Other'
else 'Other' end channel
,COUNT(DISTINCT session_id) sessions
FROM src.weblog
WHERE event_type in ('page_view', 'service_session_payment')
GrOUP BY 1,2,3,4,5