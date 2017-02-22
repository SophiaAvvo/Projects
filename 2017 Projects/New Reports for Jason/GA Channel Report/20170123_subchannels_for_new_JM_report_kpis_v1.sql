SELECT Date AS Date
,y.Most_Recent_Date AS Most_Recent_Date
,Campaign AS Campaign
,Source AS Source
,Medium AS Medium
,Channel AS Channel
/*,SubChannel AS SubChannel*/
/*,CASE
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
END ChannelSortOrder */
,CASE
WHEN Channel IN ('Direct', 'SEO Brand', 'SEM Brand')
THEN 'Brand'
WHEN Channel CONTAINS 'Email'
THEN 'Email'
WHEN Channel IN ('Partners', 'Display & Emerging')
THEN 'Other Non-Brand'
WHEN Channel IN ('Referral', '(Other Advertising)')
THEN 'Referral & Other'
ELSE Channel
END Channel_Category
,device_type AS Device_Type
,Sessions AS Sessions
,Engaged_Sessions AS Engaged_Sessions
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
, ALS_Purchases_Advisor + ALS_Purchases_Document_Review + ALS_Purchases_Offline AS ALS_Purchases_Total
,TotalPurchases_Goal_Old_Test AS TotalPurchases_Goal_Old_Test
FROM (
SELECT Date
,trafficSource.campaign AS Campaign
,trafficSource.source AS Source
,trafficSource.medium AS Medium
,device.deviceCategory AS device_type
,CASE
WHEN LOWER(trafficsource.campaign) CONTAINS 'network'
OR LOWER(trafficsource.campaign) CONTAINS 'sgt'
THEN 'GDN Network'
WHEN trafficSource.source = '(direct)'
AND trafficSource.medium = '(not set)'
THEN 'Direct'
WHEN trafficSource.medium = '(none)'
THEN 'Direct'
WHEN trafficSource.medium = 'organic'
AND REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/(\?|$)') /* this is new as of 01/19 */
THEN 'SEO Brand'
WHEN (LOWER(trafficSource.campaign) CONTAINS 'branded_terms'
OR LOWER(trafficSource.campaign) IN ('brand|rlsa', 'brand')
)
AND (CASE 
WHEN LOWER(trafficSource.campaign) CONTAINS 'fb'
THEN 1
ELSE 0
END) = 0
THEN 'SEM Brand'
WHEN LOWER(trafficSource.medium) = 'organic'
THEN 'SEO Non-Brand'
WHEN (LOWER(trafficSource.campaign) CONTAINS 'legal_q_&_a_search' 
OR LOWER(trafficSource.campaign) CONTAINS 'pls|'
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(legalqa|plsremarketing|advisorremarketing)')
OR trafficSource.campaign = 'pls')
AND (CASE 
WHEN LOWER(trafficSource.campaign) CONTAINS 'brand' /* new as of 01/19; note that the facebook exclusion is removed */
THEN 1
ELSE 0
END) = 0
THEN 'SEM Non-Brand'
WHEN LOWER(trafficsource.medium) IN ('cpc', 'sem', 'cpm')
AND REGEXP_MATCH(LOWER(trafficsource.source), r'(google|bing|yahoo)')
AND (CASE
WHEN LOWER(trafficSource.campaign) CONTAINS 'brand' /* new as of 01/19; note that the facebook exclusion is removed */
THEN 1
ELSE 0
END) = 0
THEN 'SEM Non-Brand'
WHEN (LOWER(trafficSource.medium) CONTAINS 'email'
OR LOWER(trafficSource.campaign) CONTAINS 'reset_password'
)
AND (CASE
WHEN REGEXP_MATCH(LOWER(trafficSource.campaign), r'(client_choice_award|best_answer_pro|digest)')
THEN 1
WHEN REGEXP_MATCH(LOWER(trafficSource.campaign), r'(_pro)$')
THEN 1
ELSE 0
END) = 0
THEN 'Consumer Email'
WHEN LOWER(trafficSource.medium) CONTAINS 'email'
AND (LOWER(trafficSource.source) CONTAINS 'best_answer_pro'
OR LOWER(trafficSource.adContent) CONTAINS 'digest'
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(client_choice_award)')
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(_pro)$')
)
THEN 'Attorney Email'
WHEN LOWER(trafficSource.medium) CONTAINS 'affiliate'
OR REGEXP_MATCH(LOWER(trafficSource.source), r'(boomerater|lifecare)') 
THEN 'Partners'
WHEN REGEXP_MATCH(LOWER(trafficSource.medium), r'(cpc|cpm|banner|display)')
AND REGEXP_MATCH(LOWER(trafficSource.campaign), r'(fb_|acq|pls_avvofb|pls_fb_|pls_fbb|tw_|_abandoners|pls_)')
AND (CASE
WHEN REGEXP_MATCH(LOWER(trafficSource.campaign), r'(2016brandvideos_t_acq|ricampaign|fb_boosted|lawyer|pokemon|eng_)')
THEN 1
ELSE 0
END) = 0
THEN 'Display & Emerging'
WHEN 
LOWER(trafficSource.campaign) IN ('2016brandvideos_t_acq', 'claim 2016')
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(ricampaign|2016brandvideos|relstudy|eng_|prenupforlove)')
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'^(fb_lawyer)')
OR LOWER(trafficSource.medium) IN ('video', 'mobile', 'mobile_video', 'mobile_tablet', 'content')
OR LOWER(trafficSource.Medium) CONTAINS 'display'
OR LOWER(trafficSource.source) CONTAINS 'outbrain'
OR REGEXP_MATCH(LOWER(trafficSource.medium), r'^(social|social-network|social-media|sm|social network|social media)$')
|| REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|twitter|gplus|linkedin|lnkd\.in|plus\.url\.google\.com|plus\.google\.com|googleplus|blogspot|disqus|reddit|reddit\.com|stumbleupon|yelp|vk\.com|livejournal|glassdoor|pinboard|spoke|wiki|youtube|weebly|tumblr|stackexchange|pinterest|instagram|netvibes|yammer|typepad|askville|hubpages|stackoverflow|tripadvisor|flavors\.me|quora|wordpress|topix|salespider|wordpress|slideshare|hootsuite|paper\.li)')
OR LOWER(trafficSource.campaign) CONTAINS 'fb_' 
OR LOWER(trafficSource.campaign) CONTAINS 'tw_'
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(pls_fb|pls_avvofb)')
OR REGEXP_MATCH(LOWER(trafficSource.source), r'^(t.co|social)$')
OR REGEXP_MATCH(LOWER(trafficSource.source), r'(academia\.edu|deviantart|beforeitsnews|\.naver\.com|chicagonow|circleofmoms|dailystrength|diigo|getpocket|meetup|cafemom|ycombinator|okwave|oshiete|cstools|scoop\.it|foursquare|tinyurl|yuku|\Acare2|\Achicagonow)')
THEN 'Digital Engagement'
WHEN LOWER(trafficSource.medium) = 'referral'
THEN 'Referral'
WHEN REGEXP_MATCH(LOWER(trafficSource.medium), r'^(cpv|cpa|cpp|content-text)$') 
THEN '(Other Advertising)'
ELSE '(Other)'
END Channel
,COUNT(totals.visits) AS Sessions
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact website'
THEN CONCAT(fullVisitorId,string(VisitId))
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact email'
THEN CONCAT(fullVisitorId,string(VisitId))
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact message'
THEN CONCAT(fullVisitorId,string(VisitId))
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'create question'
THEN CONCAT(fullVisitorId,string(VisitId))
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'submit review'
THEN CONCAT(fullVisitorId,string(VisitId))
WHEN LOWER(hits.eventInfo.eventAction) = 'new registration'
AND LOWER(hits.eventInfo.eventCategory) = 'users'
AND hits.type = 'EVENT'
THEN CONCAT(fullVisitorId,string(VisitId))
WHEN LOWER(hits.eventInfo.eventAction) = 'form completion'
AND LOWER(hits.eventInfo.eventCategory) = 'forms'
AND hits.type = 'EVENT'
THEN CONCAT(fullVisitorId,string(VisitId))
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND (hits.eventInfo.eventAction = 'purchase avvo legal service'
OR hits.eCommerceACtion.action_type = '6')
THEN CONCAT(fullVisitorId,string(VisitId)) /* purchases */
WHEN hits.customMetrics.index IN (10, 11)
THEN CONCAT(fullVisitorId,string(VisitId)) /* email subscriptions */
ELSE NULL
END) Engaged_Sessions
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
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) TotalPurchases_Goal
,EXACT_COUNT_DISTINCT(CASE
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eCommerceACtion.action_type = '6'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) TotalPurchases_Goal_Old_Test
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
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eCommerceACtion.action_type = '6'
AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
THEN hits.transaction.transactionid
ELSE NULL
END) ALS_Purchases_Advisor
,EXACT_COUNT_DISTINCT(CASE
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eventInfo.eventAction = 'purchase avvo legal service'
AND LOWER(hits.product.v2ProductName) CONTAINS 'review'
THEN hits.transaction.transactionid
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eCommerceACtion.action_type = '6'
AND LOWER(hits.product.v2ProductName) CONTAINS 'review'
THEN hits.transaction.transactionid
ELSE NULL
END) ALS_Purchases_Document_Review
,EXACT_COUNT_DISTINCT(CASE
WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
AND hits.eventInfo.eventCategory = 'ecommerce'
THEN CASE
WHEN LOWER(hits.product.v2ProductName) IS NULL THEN NULL
WHEN LOWER(hits.product.v2ProductName) CONTAINS 'display' THEN NULL
WHEN LOWER(hits.product.v2ProductName) IN('sponsored listing', 'pro', '(not set)') THEN NULL
WHEN LOWER(hits.product.v2ProductName) CONTAINS 'advice' THEN NULL
WHEN LOWER(hits.product.v2ProductName) CONTAINS 'review' THEN NULL
ELSE hits.transaction.transactionid
END
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eCommerceACtion.action_type = '6'
THEN CASE
WHEN LOWER(hits.product.v2ProductName) IS NULL THEN NULL
WHEN LOWER(hits.product.v2ProductName) CONTAINS 'display' THEN NULL
WHEN LOWER(hits.product.v2ProductName) IN('sponsored listing', 'pro', '(not set)') THEN NULL
WHEN LOWER(hits.product.v2ProductName) CONTAINS 'advice' THEN NULL
WHEN LOWER(hits.product.v2ProductName) CONTAINS 'review' THEN NULL
ELSE hits.transaction.transactionid
END
ELSE NULL
END) AS ALS_Purchases_Offline
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2015-10-18'),CURRENT_TIMESTAMP())
GrOUP BY 1,2,3,4,5,6
) x
CROSS JOIN 
(SELECT MAX(Date) AS Most_Recent_Date FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], DATE_ADD(CURRENT_TIMESTAMP(), -2, "DAY") ,CURRENT_TIMESTAMP())
) y