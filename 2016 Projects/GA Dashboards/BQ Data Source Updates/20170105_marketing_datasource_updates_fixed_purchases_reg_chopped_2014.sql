/* 07/21/2016: Changed social definitions to include Mira's changes that she sent: keep "contains" _FB, add social as a source, add pls_fb|pls_avvofb to open-ended regex_match
Found "cafe" as a source filter in the oldest third of the script... also noticed one of the regex portions seemed redundant.  Think an update was missed in there, so replacing with logic from more recent stuff (figure we would have noticed if it was wrong)
added event_action = contact message to most recent logic, since this instant message ability started in June 2016
08/25/2016: added porch products for the three demand letter items
09/21/2016: attribution weights for phone call revenue, channel changes to Digital Brand.  
12/05/2016: added additional UNION section to update registration, purchase logic as of 10/01/2016
Note that this needs to be updated *from the Digital Marketing Channel Report* or else custom variable definitions will be lost... update from there and other reports will be fine
*/

SELECT 
Date AS Date
,Sessions AS Sessions
,Non_Phone_Contacts_Daily_Channel AS Non_Phone_Contacts_Daily_Channel
,Non_Phone_Contacts_Daily_Total AS Non_Phone_Contacts_Daily_Total
,Non_Phone_Contacts_Quarterly_Channel AS Non_Phone_Contacts_Quarterly_Channel
,Non_Phone_Contacts_Quarterly_Total AS Non_Phone_Contacts_Quarterly_Total
,Non_Phone_Contacts_Weekly_Channel AS Non_Phone_Contacts_Weekly_Channel
,Non_Phone_Contacts_Weekly_Total AS Non_Phone_Contacts_Weekly_Total
,Non_Phone_Contacts_Daily_Channel/Non_Phone_Contacts_Daily_Total Phone_Attribution_Weights_Daily
,Non_Phone_Contacts_Weekly_Channel/Non_Phone_Contacts_Weekly_Total Phone_Attribution_Weights_Weekly
,Non_Phone_Contacts_Quarterly_Channel/Non_Phone_Contacts_Quarterly_Total Phone_Attribution_Weights_Quarterly
,ClicksToLawyerWebsite AS ClicksToLawyerWebsite
,NumberQuestionsAsked AS NumberQuestionsAsked
,NumberQuestionsAnswered AS NumberQuestionsAnswered
,EmailSentToLawyers AS EmailSentToLawyers
,NumberOfReviews AS NumberOfReviews
,NumberOfClaims AS NumberOfClaims
,NumberOfEndorsements AS NumberOfEndorsements
,NumberOfRegistrations AS NumberOfRegistrations
,MobileClicksToCall AS MobileClicksToCall
,TotalCouponsUsed AS TotalCouponsUsed
,Channel AS Channel
,TotalAdvisorPurchases AS TotalAdvisorPurchases
,TotalDocReviewPurchases AS TotalDocReviewPurchases
,TotalOfflinePackagePurchases AS TotalOfflinePackagePurchases
,ChannelGroup AS ChannelGroup
,ChannelSortOrder AS ChannelSortOrder
, ChannelGroupSortOrder AS ChannelGroupSortOrder
FROM (SELECT Date AS Date
,Year AS Year
,Quarter AS Quarter
,Week AS Week
,Sessions AS Sessions
,Email_and_Web_Contacts AS Non_Phone_Contacts_Daily_Channel
,SUM(Email_and_Web_Contacts) OVER(PARTITION BY Date) Non_Phone_Contacts_Daily_Total
,SUM(Email_and_Web_Contacts) OVER(PARTITION BY Year, Quarter, Channel) AS Non_Phone_Contacts_Quarterly_Channel
,SUM(Email_and_Web_Contacts) OVER(PARTITION BY Year, Quarter) AS Non_Phone_Contacts_Quarterly_Total
,SUM(Email_and_Web_Contacts) OVER(PARTITION BY Year, Week, Channel) AS Non_Phone_Contacts_Weekly_Channel
,SUM(Email_and_Web_Contacts) OVER(PARTITION BY Year, Week) AS Non_Phone_Contacts_Weekly_Total
,ClicksToLawyerWebsite AS ClicksToLawyerWebsite
,NumberQuestionsAsked AS NumberQuestionsAsked
,NumberQuestionsAnswered AS NumberQuestionsAnswered
,EmailSentToLawyers AS EmailSentToLawyers
,NumberOfReviews AS NumberOfReviews
,NumberOfClaims AS NumberOfClaims
,NumberOfEndorsements AS NumberOfEndorsements
,NumberOfRegistrations AS NumberOfRegistrations
,MobileClicksToCall AS MobileClicksToCall
,TotalCouponsUsed AS TotalCouponsUsed
,Channel AS Channel
,TotalAdvisorPurchases AS TotalAdvisorPurchases
,TotalDocReviewPurchases AS TotalDocReviewPurchases
,TotalOfflinePackagePurchases AS TotalOfflinePackagePurchases
,CASE
WHEN Channel IN ('Other Paid Marketing', 'Paid Search - Marketing')
THEN 'Paid Marketing'
ELSE Channel
END ChannelGroup
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
WHEN Channel IN ('Other Paid Marketing', 'Paid Search - Marketing')
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
ELSE CAST(12 AS INTEGER)
END ChannelGroupSortOrder
FROM 
(SELECT date AS Date
,YEAR(Date) AS Year
,QUARTER(Date) AS Quarter
,WEEK(Date) AS Week
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
OR trafficSource.campaign CONTAINS 'network' 
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
END) NumberQuestionsAsked
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'create answer'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberQuestionsAnswered
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
END) NumberOfRegistrations
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) = 'initiate mobile phone'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) MobileClickstoCall
,SUM(CASE
WHEN LOWER(hits.transaction.transactionCoupon) IS NOT NULL
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) TotalCouponsUsed 
,INTEGER(EXACT_COUNT_DISTINCT(CASE 
WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
THEN hits.transaction.transactionid
ELSE NULL
END)) AS TotalAdvisorPurchases
,INTEGER(EXACT_COUNT_DISTINCT(CASE 
WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
AND LOWER(hits.product.v2ProductName) CONTAINS 'review'
THEN hits.transaction.transactionid
ELSE NULL
END)) AS TotalDocReviewPurchases
,INTEGER(EXACT_COUNT_DISTINCT(CASE 
WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
THEN CASE
WHEN LOWER(hits.product.v2ProductName) IS NULL THEN NULL
WHEN LOWER(hits.product.v2ProductName) CONTAINS 'display' THEN NULL
WHEN LOWER(hits.product.v2ProductName) IN('sponsored listing', 'pro', '(not set)') THEN NULL
WHEN LOWER(hits.product.v2ProductName) CONTAINS 'advice' THEN NULL
WHEN LOWER(hits.product.v2ProductName) CONTAINS 'review' THEN NULL
ELSE hits.transaction.transactionid
END
ELSE NULL
END)) AS TotalOfflinePackagePurchases 
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-10-01'),CURRENT_TIMESTAMP())
WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) 
GROUP BY 1,2,3,4,5
)
,

(SELECT date AS Date
,YEAR(Date) AS Year
,QUARTER(Date) AS Quarter
,WEEK(Date) AS Week
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
END) NumberQuestionsAsked
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'create answer'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberQuestionsAnswered
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
,COUNT(CASE
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/virtual/new-registration/')
AND hits.type = 'PAGE'
THEN hits.page.pagePath
ELSE NULL
END) NumberOfRegistrations
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) = 'initiate mobile phone'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) MobileClickstoCall
,SUM(CASE
WHEN LOWER(hits.transaction.transactionCoupon) IS NOT NULL
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) TotalCouponsUsed 
,INTEGER(SUM(CASE
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eCommerceACtion.action_type = '6'
AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
THEN hits.Product.ProductQuantity
ELSE CAST(0 AS INTEGER)
END)) TotalAdvisorPurchases
,INTEGER(SUM(CASE
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eCommerceACtion.action_type = '6'
AND LOWER(hits.product.v2ProductName) CONTAINS 'review'
THEN hits.Product.ProductQuantity
ELSE CAST(0 AS INTEGER)
END)) TotalDocReviewPurchases
,INTEGER(SUM(CASE
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eCommerceACtion.action_type = '6'
AND REGEXP_MATCH((LOWER(hits.product.v2ProductName)), r'^(apply|start|form|create|file)')
THEN hits.Product.ProductQuantity
ELSE CAST(0 AS INTEGER)
END)) TotalOfflinePackagePurchases 
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2015-10-18'),TIMESTAMP('2016-09-30'))
WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) 
GROUP BY 1,2,3,4,5
)
,
(SELECT date AS Date
,YEAR(Date) AS Year
,QUARTER(Date) AS Quarter
,WEEK(Date) AS Week
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
WHEN trafficSource.source = 'facebook'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) = CAST(0 AS INTEGER)
THEN 'Paid Search - Marketing'
WHEN REGEXP_MATCH(trafficSource.medium, r'^(cpc|ppc|paidsearch)$') 
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
WHEN REGEXP_MATCH(trafficSource.medium, r'^(display|cpm|banner)$') 
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
END) NumberQuestionsAsked
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'create answer'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberQuestionsAnswered
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact email'
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
,COUNT(CASE
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/virtual/new-registration/')
AND hits.type = 'PAGE'
THEN hits.page.pagePath
ELSE NULL
END) NumberOfRegistrations
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) = 'initiate mobile phone'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) MobileClickstoCall
,SUM(CASE
WHEN LOWER(hits.transaction.transactionCoupon) IS NOT NULL
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) TotalCouponsUsed
,INTEGER(SUM(CASE
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eCommerceAction.action_type = '6'
AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
THEN hits.Product.ProductQuantity
ELSE CAST(0 AS INTEGER)
END)) AS TotalAdvisorPurchases
,CAST(0 AS INTEGER)TotalDocReviewPurchases
,CAST(0 AS INTEGER)TotalOfflinePackagePurchases  

FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2015-01-27'),TIMESTAMP('2015-06-06'))
WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) 
GROUP BY 1,2,3,4,5
)

)