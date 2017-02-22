SELECT hits.item.transactionid	
,Month(Date) AS Month
,CASE
WHEN (
REGEXP_MATCH(LOWER(trafficSource.medium), r'^(social|social-network|social-media|sm|social network|social media)$') /* system defined */ 
|| REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|twitter|gplus|linkedin|lnkd\.in|plus\.url\.google\.com|plus\.google\.com|googleplus|blogspot|disqus|reddit|reddit\.com|stumbleupon|yelp|vk\.com|livejournal|glassdoor|pinboard|spoke|wiki|youtube|weebly|tumblr|stackexchange|pinterest|instagram|netvibes|yammer|typepad|askville|hubpages|stackoverflow|tripadvisor|flavors\.me|quora|wordpress|topix|salespider|wordpress|slideshare|hootsuite|paper\.li)')
OR trafficSource.campaign CONTAINS 'FB_' 
OR trafficSource.campaign CONTAINS 'TW_'
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(pls_fb|pls_avvofb)')
OR REGEXP_MATCH(trafficSource.source, r'^(t.co|social)$')
OR REGEXP_MATCH(LOWER(trafficSource.source), r'(academia\.edu|deviantart|beforeitsnews|\.naver\.com|chicagonow|circleofmoms|dailystrength|diigo|getpocket|meetup|cafemom|ycombinator|okwave|oshiete|cstools|scoop\.it|foursquare|tinyurl|yuku|\Acare2|\Achicagonow)')
)
AND (CASE WHEN LOWER(trafficSource.source) CONTAINS 'search' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER)
THEN 'Social'
WHEN LOWER(trafficSource.medium) CONTAINS 'email'
THEN 'Email'
WHEN LOWER(trafficSource.medium) CONTAINS 'affiliate'
OR REGEXP_MATCH(trafficSource.source, r'(boomerater|lifecare)') 
THEN 'Affiliates'
WHEN (
trafficSource.campaign CONTAINS'Branded_Terms'
OR trafficSource.campaign CONTAINS 'Legal_Q_&_A_Search'
OR trafficSource.campaign CONTAINS 'Brand|RLSA'
OR trafficSource.campaign CONTAINS 'PLS|'
OR trafficSource.campaign IN ('brand', 'pls')
OR REGEXP_MATCH(trafficSource.campaign, r'(legalqa|plsremarketing|advisorremarketing)')
)
AND (CASE
WHEN trafficSource.source CONTAINS 'facebook'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) = CAST(0 AS INTEGER)
THEN 'Paid Search - Marketing'
WHEN REGEXP_MATCH(trafficSource.medium, r'^(cpc|ppc|paidsearch)$') 
&& (trafficSource.adwordsClickInfo.adNetworkType != 'Content' OR trafficSource.adwordsClickInfo.adNetworkType IS NULL)
AND (CASE 
WHEN LOWER(trafficSource.source) CONTAINS 'facebook' 
OR LOWER(trafficSource.source) CONTAINS 'twitter' 
OR LOWER(trafficSource.source) CONTAINS 'linkedin'
OR trafficSource.source CONTAINS 'Branded_Terms' 
OR trafficSource.source CONTAINS 'Legal_Q_&_A_Search' 
OR trafficSource.source CONTAINS 'Brand|RLSA'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) = CAST(0 AS INTEGER)
THEN 'Paid Search - AMM'
WHEN trafficSource.Medium IN ('video', 'mobile', 'mobile_video', 'mobile_tablet', 'content')
OR LOWER(trafficSource.Medium) CONTAINS 'display'
OR trafficSource.source CONTAINS 'Outbrain'
THEN 'Digital Brand'
WHEN (REGEXP_MATCH(trafficSource.medium, r'^(display|cpm|banner)$') 
|| trafficSource.adwordsClickInfo.adNetworkType = 'Content')
AND (CASE 
WHEN LOWER(trafficSource.campaign) CONTAINS 'display' 
OR trafficSource.campaign CONTAINS 'Network' 
OR LOWER(trafficSource.campaign) CONTAINS 'sgt'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) = CAST(0 AS INTEGER)
THEN 'Other Paid Marketing'
WHEN LOWER(trafficSource.campaign) CONTAINS 'display'
THEN 'Display - AMM'
WHEN LOWER(trafficSource.source) = '(direct)'
AND LOWER(trafficSource.medium) = '(none)'
THEN 'Direct'
WHEN LOWER(trafficSource.medium) = 'organic'
THEN 'Organic Search'
WHEN LOWER(trafficSource.medium) = 'referral'
THEN 'Referral'
WHEN REGEXP_MATCH(trafficSource.medium, r'^(cpv|cpa|cpp)$') 
THEN '(Other)'
ELSE '(Other)'
END AS Channel
,CASE
WHEN REGEXP_MATCH(LOWER(trafficSource.medium), r'(cpc|cpm)')
AND REGEXP_MATCH(LOWER(trafficSource.campaign), r'(fb_|acq|pls_avvofb|pls_fb_|pls_fbb|tw_)')
AND (CASE
WHEN REGEXP_MATCH(LOWER(trafficSource.source), r'(google|divisiond)')
THEN 1
WHEN REGEXP_MATCH(LOWER(trafficSource.campaign), r'(2016brandvideos_t_acq|fb_boosted|lawyer|pokemon|eng_)')
THEN 1
ELSE 0
END) = 0
THEN 'Paid Social Acquisition'
WHEN (
LOWER(trafficSource.campaign) IN ('2016brandvideos_t_acq', 'claim 2016')
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(ricampaign|2016brandvideos|relstudy|eng_|prenupforlove)')
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'^(fb_lawyer)')
)
AND (CASE 
WHEN REGEXP_MATCH(LOWER(trafficSource.medium), r'(display|content)')
THEN 1
ELSE 0
END) = 0 
THEN 'Paid Social Engagement'
WHEN (REGEXP_MATCH(LOWER(trafficSource.medium), r'^(social|social-network|social-media|sm|social network|social media)$')
|| REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|twitter|gplus|linkedin|lnkd\.in|plus\.url\.google\.com|plus\.google\.com|googleplus|blogspot|disqus|reddit|reddit\.com|stumbleupon|yelp|vk\.com|livejournal|glassdoor|pinboard|spoke|wiki|youtube|weebly|tumblr|stackexchange|pinterest|instagram|netvibes|yammer|typepad|askville|hubpages|stackoverflow|tripadvisor|flavors\.me|quora|wordpress|topix|salespider|wordpress|slideshare|hootsuite|paper\.li)')
OR LOWER(trafficSource.campaign) CONTAINS 'fb_' 
OR LOWER(trafficSource.campaign) CONTAINS 'tw_'
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(pls_fb|pls_avvofb)')
OR REGEXP_MATCH(LOWER(trafficSource.source), r'^(t.co|social)$')
OR REGEXP_MATCH(LOWER(trafficSource.source), r'(academia\.edu|deviantart|beforeitsnews|\.naver\.com|chicagonow|circleofmoms|dailystrength|diigo|getpocket|meetup|cafemom|ycombinator|okwave|oshiete|cstools|scoop\.it|foursquare|tinyurl|yuku|\Acare2|\Achicagonow)')
)
AND (CASE WHEN LOWER(trafficSource.source) CONTAINS 'search' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER)
THEN 'Organic Social'
WHEN (LOWER(trafficSource.medium) CONTAINS 'email'
OR LOWER(trafficSource.campaign) CONTAINS 'reset_password'
)
AND (CASE
WHEN REGEXP_MATCH(LOWER(trafficSource.campaign), r'(question_notify_digest|2015_client_choice_award|2014_client_choice_award|best_answer_pro|digest)')
THEN 1
WHEN REGEXP_MATCH(LOWER(trafficSource.campaign), r'(_pro)$')
THEN 1
ELSE 0
END) = 0
THEN 'Consumer Email'
WHEN LOWER(trafficSource.medium) CONTAINS 'email'
AND (LOWER(trafficSource.source) CONTAINS 'best_answer_pro'
OR LOWER(trafficSource.adContent) CONTAINS 'digest'
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(2015_client_choice_award|2014_client_choice_award|)')
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(_pro)$')
)
THEN 'Attorney Email'
WHEN LOWER(trafficSource.medium) CONTAINS 'affiliate'
OR REGEXP_MATCH(LOWER(trafficSource.source), r'(boomerater|lifecare)') 
THEN 'Affiliates'
WHEN (LOWER(trafficSource.campaign) CONTAINS 'branded_terms'
OR LOWER(trafficSource.campaign) IN ('brand|rlsa', 'brand')
)
AND (CASE 
WHEN LOWER(trafficSource.campaign) CONTAINS 'fb'
THEN 1
ELSE 0
END) = 0
THEN 'SEM Brand'
WHEN (LOWER(trafficSource.campaign) IN ('pls', 'plsremarketing')
OR LOWER(trafficSource.campaign) CONTAINS 'pls|')
AND (CASE
WHEN LOWER(trafficSource.campaign) CONTAINS '_forms'
THEN 1
ELSE 0
END) = 0
THEN 'SEM ALS'
WHEN (LOWER(trafficSource.campaign) CONTAINS 'legal_q_&_a_search'
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(legalqa)')
)
AND (CASE
WHEN LOWER(trafficSource.campaign) CONTAINS 'fb'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) = CAST(0 AS INTEGER)
THEN 'SEM Q&A'
WHEN LOWER(trafficSource.campaign) CONTAINS 'pls|'
AND LOWER(trafficSource.campaign) CONTAINS '_forms'
AND (CASE
WHEN LOWER(trafficSource.campaign) CONTAINS 'fb'
THEN 1
ELSE 0
END) = 0
THEN 'SEM Forms'
WHEN REGEXP_MATCH(LOWER(trafficSource.medium), r'^(cpc|ppc|paidsearch)$') 
&& (trafficSource.adwordsClickInfo.adNetworkType != 'Content' OR trafficSource.adwordsClickInfo.adNetworkType IS NULL)
AND (CASE 
WHEN LOWER(trafficSource.source) CONTAINS 'facebook' 
OR LOWER(trafficSource.source) CONTAINS 'twitter' 
OR LOWER(trafficSource.source) CONTAINS 'linkedin'
OR LOWER(trafficSource.source) CONTAINS 'branded_terms' 
OR LOWER(trafficSource.source) CONTAINS 'legal_q_&_a_search' 
OR LOWER(trafficSource.source) CONTAINS 'brand|rlsa'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) = CAST(0 AS INTEGER)
THEN 'Paid Search - AMM'
WHEN LOWER(trafficSource.medium) IN ('video', 'mobile', 'mobile_video', 'mobile_tablet', 'content')
OR LOWER(trafficSource.Medium) CONTAINS 'display'
OR LOWER(trafficSource.source) CONTAINS 'outbrain'
THEN 'Digital Brand'
WHEN REGEXP_MATCH(LOWER(trafficSource.Campaign), r'(_acq|acquisition|lookalike)')
AND LOWER(trafficSource.Campaign) CONTAINS 'pls_'
AND (CASE
WHEN REGEXP_MATCH(LOWER(trafficSource.campaign), r'(fb|q&a|lifecycle|form)')
THEN 1
ELSE 0
END) = 0
THEN 'Display - ALS - ACQ'
WHEN REGEXP_MATCH(LOWER(trafficSource.Campaign), r'(_abandoners|pls_)')
AND (CASE
WHEN REGEXP_MATCH(LOWER(trafficSource.campaign), r'(fb|_acq|acquisition|lookalike|q&a|lifecycle|form)')
THEN 1
WHEN LOWER(trafficSource.source) CONTAINS 'taboola'
THEN 1
ELSE 0
END) = 0
THEN 'Display - ALS - Ret'
WHEN REGEXP_MATCH(LOWER(trafficSource.Campaign), r'(pls_|acq)')
AND REGEXP_MATCH(LOWER(trafficSource.Campaign), r'(q&a|lifecycle|form)')
AND (CASE
WHEN REGEXP_MATCH(LOWER(trafficSource.campaign), r'(fb|_ret)')
THEN 1
ELSE 0
END) = 0
THEN 'Display - RU - Acq'
WHEN REGEXP_MATCH(LOWER(trafficSource.Campaign), r'(pls_|_ret)')
AND REGEXP_MATCH(LOWER(trafficSource.Campaign), r'(q&a|lifecycle|form)')
AND (CASE
WHEN REGEXP_MATCH(LOWER(trafficSource.campaign), r'(fb|acq)')
THEN 1
ELSE 0
END) = 0
THEN 'Display - RU - Ret'
WHEN LOWER(trafficSource.campaign) CONTAINS 'display'
THEN 'Display - AMM'
WHEN LOWER(trafficSource.source) = '(direct)'
AND LOWER(trafficSource.medium) = '(none)'
THEN 'Direct'
WHEN LOWER(trafficSource.medium) = 'organic'
THEN 'Organic Search'
WHEN LOWER(trafficSource.medium) = 'referral'
THEN 'Referral'
WHEN REGEXP_MATCH(LOWER(trafficSource.medium), r'^(cpv|cpa|cpp)$') 
THEN '(Other)'
ELSE '(Other)'
END Subchannel	
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-01-01'),TIMESTAMP('2016-11-30'))		
WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) 		
AND hits.eventInfo.eventCategory = 'ecommerce'		
		AND hits.eventInfo.eventAction = 'purchase avvo legal service'
GROUP BY 1,2,3,4