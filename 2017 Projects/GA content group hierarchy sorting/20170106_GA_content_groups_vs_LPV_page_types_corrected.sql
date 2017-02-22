select *
from
(select
LPV_Page_Type
,ga_content_group
,first_value(pagepath) over (partition by PageGroup, ga_content_group) as url_example
,SUM(Sessions1) over (partition by PageGroup, ga_content_group) AS Sessions1
,SUM(Sessions2) over (partition by PageGroup, ga_content_group) AS Sessions2
from
(select
CASE
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
AND REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/amm/' )
THEN 'SEM-Adblock' /* to reflect update*/
WHEN hits.page.hostName = 'lawyer-listings.avvo.com'
AND REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/network/' )
THEN 'SEM-Network'
ELSE 'Unknown'
END AS LPV_Page_Type
,hits.page.pagePath as pagepath
,MAX(IF(hits.customDimensions.index=19,hits.customDimensions.value, NULL)) AS ga_content_group
,count(distinct concat(fullvisitorid, string(visitid)), 1000000) Sessions1
,COUNT(totals.visits) Sessions2
FROM TABLE_DATE_RANGE([75615261.ga_sessions_], DATE_ADD(CURRENT_TIMESTAMP(), -30, 'DAY'), DATE_ADD(CURRENT_TIMESTAMP(), -1, 'DAY'))
where hits.type = "PAGE"
and totals.visits = 1
and hits.isEntrance = 1
group by 1,2) table_a
group by 1, 2, pagepath, Sessions1, Sessions2) table_b
group by 1, 2, 3, 4,5
order by 1, 2
