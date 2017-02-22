SELECT Date AS Date
,y.Most_Recent_Date AS Most_Recent_Date
,Campaign AS Campaign
,Source AS Source
,Medium AS Medium
,Channel AS Channel
,LPV_Page_Type AS LPV_Page_Type
,CASE
wHEN LPV_Page_Type = 'Attorney_Directory_Launch'
THEN 'Find a Lawyer'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^Professional_')
THEN 'Lawyer Dashboard'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^(Attorney_Profile|Attorney_Review)')
THEN 'Lawyer Profile'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^(Attorney_Directory|Attorney_Search)')
THEN 'Lawyer SERP'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^Legal_Ask')
THEN 'Ask a Lawyer'
wHEN LPV_Page_Type = 'Legal_KB_Launch'
THEN 'Free Legal Advice'
wHEN LPV_Page_Type = 'Legal_Guides_Detail'
THEN 'Guide Detail'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^Legal_KB')
THEN 'KB SERP'
wHEN LPV_Page_Type = 'Legal_Answers_Detail'
THEN 'QA Detail'
wHEN LPV_Page_Type = 'Topics'
THEN 'Topics'
wHEN LPV_Page_Type = 'Homepage'
THEN 'Homepage'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^(LS-|SubCat|ALS )')
THEN 'LS'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^Advisor-')
THEN 'Advisor'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^SEM-')
THEN 'SEM'
ELSE 'Others'
END AS LPV_Page_Group
,CASE
wHEN LPV_Page_Type = 'Attorney_Directory_Launch'
THEN 'Directory'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^Professional_')
THEN 'Directory'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^(Attorney_Profile|Attorney_Review)')
THEN 'Directory'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^(Attorney_Directory|Attorney_Search)')
THEN 'Directory'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^Legal_Ask')
THEN 'Content'
wHEN LPV_Page_Type = 'Legal_KB_Launch'
THEN 'Content'
wHEN LPV_Page_Type = 'Legal_Guides_Detail'
THEN 'Content'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^Legal_KB')
THEN 'Content'
wHEN LPV_Page_Type = 'Legal_Answers_Detail'
THEN 'Content'
wHEN LPV_Page_Type = 'Topics'
THEN 'Content'
wHEN LPV_Page_Type = 'Homepage'
THEN 'Homepage'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^(LS-|SubCat|ALS )')
THEN 'Avvo Legal Services'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^Advisor-')
THEN 'Avvo Legal Services'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^SEM-')
THEN 'SEM'
ELSE 'Others'
END AS LPV_Content_Group
,CASE
wHEN LPV_Page_Type = 'Attorney_Directory_Launch'
THEN 'Directory (SERP)'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^Professional_')
THEN 'Other'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^(Attorney_Profile|Attorney_Review)')
THEN 'Profile'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^(Attorney_Directory|Attorney_Search)')
THEN 'Directory (SERP)'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^Legal_Ask')
THEN 'Q&A'
wHEN LPV_Page_Type = 'Legal_KB_Launch'
THEN 'Research'
wHEN LPV_Page_Type = 'Legal_Guides_Detail'
THEN 'Research'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^Legal_KB')
THEN 'Research'
wHEN LPV_Page_Type = 'Legal_Answers_Detail'
THEN 'Q&A'
wHEN LPV_Page_Type = 'Topics'
THEN 'Research'
wHEN LPV_Page_Type = 'Homepage'
THEN 'Other'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^(LS-|SubCat|ALS )')
THEN 'Other'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^Advisor-')
THEN 'Other'
WHEN REGEXP_MATCH(LPV_Page_Type, r'^SEM-')
THEN 'Other'
ELSE 'Other'
END AS LPV_JM_Group
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
, ALS_Purchases_Advisor + ALS_Purchases_Document_Review + ALS_Purchases_Offline AS ALS_Purchases_Total
FROM (
SELECT Date
,trafficSource.campaign AS Campaign
,trafficSource.source AS Source
,trafficSource.medium AS Medium
,CASE
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/(\?|$)') -- x
THEN 'Homepage'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/login') -- need to add logic for e.g. /messages/967870/login (someone logging into message an attorney)
THEN 'Account_Login' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/messages/[0-9]+/login') -- NEW LOGIC ADDED BY SROBINSON
THEN 'Account_Login' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/register') -- we have a handful of sessions that look like /claim_profile/claim_by_email/cf09a89dc093/register
THEN 'Account_Register'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/claim_profile/claim_by_email/[A-Za-z0-9]/register') --  NEW CASE ADDED BY SROBINSON
THEN 'Professional_Claim_Profile'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/settings') -- x
THEN 'Account_Settings' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/notifications') -- x NEW LOGIC ADDED BY SROBINSON
THEN 'Account_Settings' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/forgot_password') -- x
THEN 'Account_Forgot_Password'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/my_avvo/questions') -- x
THEN 'Account_Saved_Questions'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/saved_content/question_subscriptions') -- x
THEN 'Account_Saved_Subscriptions'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/notifications') -- there's also an /account/notifications, which is not the same thing, and belongs in "settings" (added)
THEN 'Account_Notifications' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/profile/dashboard') -- there's also an	/advisor.avvo.com/dashboard; ignoring for now
THEN 'Professional_Dashboard' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/profile/impression_stats') -- x
THEN 'Professional_Analytics_Impressions' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/profile/contact_stats') -- x
THEN 'Professional_Analytics_Contacts' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/support') -- x
THEN 'Support' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/find-a-lawyer(\?|/|$)') -- added a slash for variations ending in / or /all-practice-areas EDITED BY SROBINSON TO INCLUDE PAGES ENDING IN /
THEN 'Attorney_Directory_Launch' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+-lawyers?(/[^/]+)?(/[A-Za-z]{2}(/[^/]+)*)?\.html')
/* question-mark: either lawyer or lawyers, followed by some (optional) arbitrary text, then followed by a two-character segment (the state; this is what the {} indicates), 
then slash followed by by arbitrary text (the city), ending in .html.  Everything after "lawyer" is optional.
*/ 
THEN 'Attorney_Directory_Browse' -- x
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*-[0-9]+\.html') -- x
THEN 'Attorney_Profile' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/reviews\.html') -- x
THEN 'Attorney_Profile_Review' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/write_review\.html') -- x
THEN 'Attorney_Profile_Write_Review' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/endorsements\.html') -- x; also have variations like /attorneys/85012-az-jeffrey-silence-4178822/requested_endorsements/new; leave in Unknown for now
THEN 'Attorney_Profile_Endorsement' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/aboutme\.html') -- x
THEN 'Attorney_Profile_Aboutme'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/contact\.html') -- x
--star equals "zero or more" matches on previous character; dot = "any non-whitespace character" if not escaped
THEN 'Attorney_Profile_Contact' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/search/questions_answered_by_search/') -- EDITED BY SROBINSON; "question" should be plural ("questions"); the original version gives no landings in the last couple years
THEN 'Attorney_Profile_Answers' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/search/lawyer_search') -- x
THEN 'Attorney_Search' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/search/lawyer_name_search') -- DOES NOT EXIST; we have /search/professional_name_search (not high volume); need to categorize in types of pages
THEN 'Attorney_Search_by_Name' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/review-your-lawyer(\?|/|$)') -- EDITED BY SROBINSON TO INCLUDE PATHS ENDING IN /
THEN 'Attorney_Review' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/search/review_lawyer_search') -- NEW CODE ADDED BY SROBINSON (this is the page where you search for a lawyer to review) 	
THEN 'Attorney_Review' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/free-legal-advice(\?|/|$)') -- EDITED BY SROBINSON TO INCLUDE PATHS ENDING IN / (if there's nothing after the advice word, it goes here...)
THEN 'Legal_KB_Launch' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/free-legal-advice/') -- x (anything with stuff after the launch path goes here)
THEN 'Legal_KB_Search' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^\/]+-lawyer.*\.html') -- x
-- square-bracket means "any character"; in this case, we mean "anything except forward-slash", followed by -lawyer, followed by any text (or none), finish with .html
THEN 'Legal_KB_Browse' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-answers/') -- x
THEN 'Legal_Answers_Detail' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-guides/') -- x
THEN 'Legal_Guides_Detail' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/ask-a-lawyer(\?|/|$)') -- EDITED BY SROBINSON TO INCLUDE PATHS ENDING IN /
-- do not need to escape single-slash (added to deal with /ask-a-lawyer/ variation)
THEN 'Legal_Ask_Launch' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal_questions/preview') -- THIS IS RARELY GETTING TRAFFIC IN THE LAST MONTH; NEW VARIATION ADDED BELOW
THEN 'Legal_Ask_Preview' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/ask_question/preview') -- NEW CODE ADDED BY SROBINSON; MOST Q&A PREVIEW LANDINGS ARE GOING HERE
THEN 'Legal_Ask_Preview' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal/answer_questions_search(\?|$)') -- EDITED BY SROBINSON: questions was singular; should be plural; this needs a category in types of pages
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
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/topics/') -- x
THEN 'Topics' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-answers$') -- no landings in last 30 days
THEN 'Invalid Page -- Should Redirect' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/advisor/specialties') -- nothing is coming up for this in last 30 days
THEN 'Advisor -- Specialty' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/advisor/practice-area') -- new; added 01/16/2017
THEN 'Advisor -- Specialty'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/advisor/thank_you/') -- nothing is coming up for this in last 30 days
THEN 'Advisor -- Thank You' 
WHEN hits.page.hostName = 'advisor.avvo.com'
AND REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/advice_sessions/new') -- EDITED BY SROBINSON TO BE ABOVE THE HOMEPAGE VARIATION... while this is old data, all these were being classified as homepage
THEN 'Advisor -- Checkout'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/advisor')
THEN 'Advisor -- Homepage' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+/legal-services/[^/\?]+/?(\?|$)' )
THEN 'LS-Lawyer-Select'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+/legal-services/[^/]+/[^/\?]+/?(\?|$)' )   -- new; added 01/16/2017
THEN 'LS-Package-Details'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+/legal-services/[^/\?]+/?(\?|$)')   -- new; added 01/16/2017
THEN 'LS-Package-Details'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+/legal-services/[^/]+/.+') 
-- inside square bracket, ^ means "anything but the next character" 
THEN 'LS-Package-Details_Old' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+/legal-services/?(\?|$)' ) -- new logic added 01/16/2017
THEN 'LS-Storefront' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-services/[0-9]+')
THEN 'LS-Package-Details-Attorney-View' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-services/checkout') 
THEN 'LS-Checkout'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-services/thank_you') 
THEN 'LS-Thankyou'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-services/?(\?|$)' ) -- new logic as of 01/16/2017
THEN 'LS-Home' 
WHEN hits.page.pagePath = '/search' 
-- MODIFIED LOGIC FROM SROBINSON... we do not have a template name/site section (CD 19) matching the "no results" situation; GA web is inconsistent with BQ in terms of /search categorization, but this works
THEN 'Global Search'
,CASE
WHEN hits.page.hostName = 'lawyer-listings.avvo.com'
AND REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/adblock/' )
THEN 'SEM-Adblock' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/ammlp/lawyer-list') -- new logic to deal with the adblock nomenclature change
THEN 'SEM-Adblock'
WHEN hits.page.hostName = 'lawyer-listings.avvo.com'
AND REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/network/' )
THEN 'SEM-Network'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/ammlp/attorney-dir'  ) -- new logic
THEN 'SEM-Network'
ELSE 'Unknown'
END AS LPV_Page_Type
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
AND hits.page.pagepath = '/'
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
AND hits.page.pagepath <> '/'
THEN 'SEO Non-Brand'
WHEN (LOWER(trafficSource.campaign) CONTAINS 'legal_q_&_a_search' 
OR LOWER(trafficSource.campaign) CONTAINS 'pls|'
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(legalqa|plsremarketing|advisorremarketing)')
OR trafficSource.campaign = 'pls')
AND (CASE 
WHEN LOWER(trafficSource.campaign) CONTAINS 'fb'
THEN 1
ELSE 0
END) = 0
THEN 'SEM Non-Brand'
WHEN LOWER(trafficsource.medium) IN ('cpc', 'sem', 'cpm')
AND REGEXP_MATCH(LOWER(trafficsource.source), r'(google|bing|yahoo)')
AND (CASE
WHEN LOWER(trafficSource.campaign) CONTAINS 'brand'
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
WHERE hits.isEntrance = 1
GrOUP BY 1,2,3,4,5,6
) x
CROSS JOIN 
(SELECT MAX(Date) AS Most_Recent_Date FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2015-10-18'),CURRENT_TIMESTAMP())
) y
