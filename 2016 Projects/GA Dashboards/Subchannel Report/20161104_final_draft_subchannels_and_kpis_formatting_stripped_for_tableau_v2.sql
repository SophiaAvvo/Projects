SELECT Date AS Date
,Campaign AS Campaign
,Publisher AS Publisher
,Channel AS Channel
,SubChannel AS SubChannel
,CASE
WHEN Channel = 'Organic Search'
THEN CAST(1 AS INTEGER)
WHEN Channel = 'Direct'
THEN CAST(2 AS INTEGER)
WHEN Channel = 'Email'
THEN CAST(3 AS INTEGER)
WHEN Channel = 'Social'
THEN CAST(4 AS INTEGER)
WHEN Channel = 'Referral'
THEN CAST(5 AS INTEGER)
WHEN Channel = 'Paid Search - Marketing'
THEN CAST(6 AS INTEGER)
WHEN Channel = 'Digital Brand'
THEN CAST(7 AS INTEGER)
WHEN Channel = '(Other)'
THEN CAST(8 AS INTEGER)
WHEN Channel = 'Affiliates'
THEN CAST(9 AS INTEGER)
WHEN Channel = 'Paid Search - AMM'
THEN CAST(10 AS INTEGER)
WHEN Channel = 'Display - AMM'
THEN CAST(11 AS INTEGER)
WHEN Channel = 'Other Paid Marketing'
THEN CAST(12 AS INTEGER)
ELSE CAST(13 AS INTEGER)
END ChannelSortOrder
,CASE
WHEN Channel IN ('Email', 'Social', 'Paid Search - Marketing', 'Other Paid Marketing', 'Affiliates')
THEN 'Paid Marketing Channels'
ELSE 'Non-Paid Channels'
END ChannelType
,Sessions AS Sessions
,Email_and_Web_Contacts AS Email_and_Web_Contacts
,ClicksToLawyerWebsite AS ClicksToLawyerWebsite
,NumberQuestionsAsked_Goal AS NumberQuestionsAsked_Goal
,NumberQuestionsAsked_CM AS NumberQuestionsAsked_CM
,NumberQuestionsAnswered_Goal AS NumberQuestionsAnswered_Goal
,EmailSentToLawyers AS EmailSentToLawyers
,NumberOfReviews AS NumberOfReviews
,NumberOfClaims AS NumberOfClaims
,NumberOfEndorsements AS NumberOfEndorsements
,NumberOfRegistrations_Goal AS NumberOfRegistrations_Goal
,NumberOfRegistrations_CM AS NumberOfRegistrations_CM
,NumberOfForms_Goal AS NumberOfForms_Goal
,TotalPurchases_Goal AS TotalPurchases_Goal
,TotalEmailSubscriptions AS TotalEmailSubscriptions
,OnsiteEmailSubscriptions AS OnsiteEmailSubscriptions
,OffsiteEmailSubscriptions AS OffsiteEmailSubscriptions
,ALS_Purchases_Advisor AS ALS_Purchases_Advisor
,ALS_Purchases_Document_Review AS ALS_Purchases_Document_Review
,ALS_Purchases_Offline AS ALS_Purchases_Offline
, ALS_Purchases_Total AS ALS_Purchases_Total
FROM (
SELECT Date
,trafficSource.campaign AS Campaign
,trafficSource.source AS Publisher
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
,COUNT(totals.visits) AS Sessions
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact website'
THEN CAST(1 AS INTEGER)
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact email'
THEN CAST(1 AS INTEGER)
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact message'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) Email_and_Web_Contacts
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact website'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) AS ClicksToLawyerWebsite
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'create question'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberQuestionsAsked_Goal
,SUM(CASE
WHEN hits.customMetrics.index = 2
THEN 1
ELSE 0
END) NumberQuestionsAsked_CM
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'create answer'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberQuestionsAnswered_Goal
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact email'
THEN CAST(1 AS INTEGER)
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact message'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) EmailSentToLawyers
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'submit review'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) NumberOfReviews
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'complete claim'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) NumberOfClaims
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'submit endorsement'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) NumberOfEndorsements
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) = 'new registration'
AND LOWER(hits.eventInfo.eventCategory) = 'users'
AND hits.type = 'EVENT'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberOfRegistrations_Goal
,SUM(CASE
WHEN hits.customMetrics.index = 3
THEN 1
ELSE 0
END) NumberOfRegistrations_CM
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) = 'form completion'
AND LOWER(hits.eventInfo.eventCategory) = 'forms'
AND hits.type = 'EVENT'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberOfForms_Goal
,EXACT_COUNT_DISTINCT(CASE
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eventInfo.eventAction = 'purchase avvo legal service'
THEN hits.transaction.transactionId
ELSE NULL
END) TotalPurchases_Goal
,SUM(CASE
WHEN hits.customMetrics.index IN (10, 11)
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) TotalEmailSubscriptions
,SUM(CASE
WHEN hits.customMetrics.index = 10
THEN 1
ELSE 0
END) OnsiteEmailSubscriptions
,SUM(CASE
WHEN hits.customMetrics.index = 11
THEN 1
ELSE 0
END) OffsiteEmailSubscriptions
,EXACT_COUNT_DISTINCT(CASE
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eventInfo.eventAction = 'purchase avvo legal service'
AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
THEN hits.transaction.transactionid
ELSE NULL
END) ALS_Purchases_Advisor
,EXACT_COUNT_DISTINCT(CASE
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eventInfo.eventAction = 'purchase avvo legal service'
AND LOWER(hits.product.v2ProductName) CONTAINS 'review'
THEN hits.transaction.transactionid
ELSE NULL
END) ALS_Purchases_Document_Review
,EXACT_COUNT_DISTINCT(CASE
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eventInfo.eventAction = 'purchase avvo legal service'
AND REGEXP_MATCH((LOWER(hits.product.v2ProductName)), r'^(apply|start|form|create|file|modify)')
THEN hits.transaction.transactionid
ELSE NULL
END) ALS_Purchases_Offline
,EXACT_COUNT_DISTINCT(CASE
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eventInfo.eventAction = 'purchase avvo legal service'
THEN hits.transaction.transactionid
ELSE NULL
END) ALS_Purchases_Total
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2015-10-18'),CURRENT_TIMESTAMP())
WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) 
GrOUP BY 1,2,3,4,5
)