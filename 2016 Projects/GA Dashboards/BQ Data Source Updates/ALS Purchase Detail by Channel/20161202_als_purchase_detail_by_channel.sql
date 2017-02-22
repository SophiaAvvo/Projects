/* 07/21/2016: Changed social definitions to include Mira's changes that she sent: keep "contains" _FB, add social as a source, add pls_fb|pls_avvofb to open-ended regex_match
Found "cafe" as a source filter in the oldest third of the script... also noticed one of the regex portions seemed redundant. Think an update was missed in there, so replacing with logic from more recent stuff (figure we would have noticed if it was wrong)
added event_action = contact message to most recent logic, since this instant message ability started in June 2016
*/
SELECT Date AS Date
,Channel
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
,af.package_category AS PackageCategory
,ProductName
,SUM(PurchaseCount) AS PurchaseCount
,SUM(af.provider_fee_in_cents*PurchaseCount)/100 AS ProviderFeeDollars
FROM 
(SELECT date AS Date
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
WHEN trafficSource.Medium IN ('video', 'mobile', 'mobile_video', 'mobile_tablet')
OR LOWER(trafficSource.Medium) CONTAINS 'display'
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
WHEN hits.product.v2Productname CONTAINS 'advice session'
THEN CASE
WHEN hits.product.v2ProductName CONTAINS 'Landlord & Tenant'
THEN '15-minute Landlord or tenant advice session'
WHEN LEFT(hits.product.v2ProductName, 2) IN ('15', '30')
THEN hits.product.v2ProductName
ELSE CONCAT('15-minute ', hits.product.v2ProductName)
END
ELSE hits.product.v2ProductName
END AS ProductName
,CASE
WHEN hits.product.v2ProductName LIKE '%advice session%'
THEN 'Advisor'
WHEN hits.product.v2ProductName LIKE '%review%'
THEN 'Doc Review'
ELSE 'Offline'
END ProductType
,EXACT_COUNT_DISTINCT(hits.transaction.transactionid) AS PurchaseCount
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2015-10-18'),CURRENT_TIMESTAMP())
WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER)
AND hits.product.v2ProductName IS NOT NULL
AND (CASE WHEN hits.product.v2ProductName CONTAINS 'sponsored' THEN 1 WHEN hits.product.v2ProductName CONTAINS 'display' THEN 1 
WHEN LENGTH(hits.product.v2ProductName) = 1 THEN 1 WHEN hits.product.v2ProductName IN ('pro', '(not set)', 'lawyer search', 'questions/show') THEN 1 ELSE 0 END) = 0
GROUP BY 1,2,3,4
) x
LEFT JOIN [75615261_dimensions.ALS_fees] af
ON af.package_name = x.ProductName 
GROUP BY 1,2,3,4,5,6,7