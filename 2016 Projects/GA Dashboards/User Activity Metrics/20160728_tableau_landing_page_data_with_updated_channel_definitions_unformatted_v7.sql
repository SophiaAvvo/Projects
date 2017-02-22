SELECT date AS Date
,COUNT(totals.visits) AS Sessions
,CASE
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/(\?|$)') 
THEN 'Homepage'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/login')
THEN 'Account_Login' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/register') 
THEN 'Account_Register'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/settings')
THEN 'Account_Settings' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/forgot_password')
THEN 'Account_Forgot_Password'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/my_avvo/questions')
THEN 'Account_Saved_Questions'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/saved_content/question_subscriptions')
THEN 'Account_Saved_Subscriptions'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/notifications')
THEN 'Account_Notifications' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/profile/dashboard')
THEN 'Professional_Dashboard' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/profile/impression_stats')
THEN 'Professional_Analytics_Impressions' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/profile/contact_stats')
THEN 'Professional_Analytics_Contacts' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/support')
THEN 'Support' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/find-a-lawyer(\?|$)')
THEN 'Attorney_Directory_Launch' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+-lawyers?(/[^/]+)?(/[A-Za-z]{2}(/[^/]+)*)?\.html')
THEN 'Attorney_Directory_Browse' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*-[0-9]+\.html')
THEN 'Attorney_Profile' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/reviews\.html')
THEN 'Attorney_Profile_Review' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/write_review\.html')
THEN 'Attorney_Profile_Write_Review' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/endorsements\.html')
THEN 'Attorney_Profile_Endorsement' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/aboutme\.html')
THEN 'Attorney_Profile_Aboutme'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/contact\.html')
THEN 'Attorney_Profile_Contact' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/search/questions_answered_by_search/')
THEN 'Attorney_Profile_Answers' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/search/lawyer_search')
THEN 'Attorney_Search' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/search/lawyer_name_search')
THEN 'Attorney_Search_by_Name' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/review-your-lawyer(\?|$)')
THEN 'Attorney_Review' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/free-legal-advice(\?|$)')
THEN 'Legal_KB_Launch' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/free-legal-advice/')
THEN 'Legal_KB_Search' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^\/]+-lawyer.*\.html')
THEN 'Legal_KB_Browse' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-answers/')
THEN 'Legal_Answers_Detail' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-guides/')
THEN 'Legal_Guides_Detail' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/ask-a-lawyer(\?|$)')
THEN 'Legal_Ask_Launch' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal_questions/preview')
THEN 'Legal_Ask_Preview' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal/answer_question_search(\?|$)')
THEN 'Legal_Questions_To_Answer_Search' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/health-information(\?|$)')
THEN 'Health_KB_Launch' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/health-information/')
THEN 'Health_KB_Search' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/medical-advice/')
THEN 'Health_Answers_Detail' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/health-guides/')
THEN 'Health_Guides' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/ask-a-doctor(\?|$)')
THEN 'Health_Ask_Launch' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/topics/')
THEN 'Topics' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-answers$')
THEN 'Invalid Page -- Should Redirect' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/advisor/specialties')
THEN 'Advisor -- Specialty' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/advisor/thank_you/')
THEN 'Advisor -- Thank You' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/advisor')
THEN 'Advisor -- Homepage' 
WHEN hits.page.hostName = 'advisor.avvo.com'
AND REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/advice_sessions/new')
THEN 'Advisor -- Checkout'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+/legal-services/[^/]+/.+')
THEN 'LS-Package-Details' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+/legal-services')
THEN 'LS-Storefront' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-services/[0-9]+')
THEN 'LS-Package-Details-Attorney-View' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-services')
THEN 'LS-Home' 
WHEN hits.page.hostName = 'lawyer-listings.avvo.com'
AND REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/adblock/' )
THEN 'SEM-Adblock' 
WHEN hits.page.hostName = 'lawyer-listings.avvo.com'
AND REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/network/' )
THEN 'SEM-Network'
ELSE 'Unknown'
END AS PageGroup
,CASE
WHEN (
REGEXP_MATCH(LOWER(trafficSource.medium), r'^(social|social-network|social-media|sm|social network|social media)$') /* system defined */ 
|| REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|twitter|gplus|linkedin|lnkd\.in|plus\.url\.google\.com|plus\.google\.com|googleplus|blogspot|disqus|reddit|reddit\.com|stumbleupon|yelp|vk\.com|livejournal|glassdoor|pinboard|spoke|wiki|youtube|weebly|tumblr|stackexchange|pinterest|instagram|netvibes|yammer|typepad|askville|hubpages|stackoverflow|tripadvisor|flavors\.me|quora|wordpress|topix|salespider|wordpress|slideshare|hootsuite|paper\.li|pls_fb|pls_avvofb)')
OR trafficSource.campaign CONTAINS 'FB_' 
OR trafficSource.campaign CONTAINS 'TW_'
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
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2015-10-18'),CURRENT_TIMESTAMP())
WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN 1 ELSE 0 END) = 0
AND hits.isEntrance = 1
GROUP BY 1,3,4