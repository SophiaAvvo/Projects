,CASE
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/(\?|$)') /* x */
THEN 'Homepage'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/login') /* need to add logic for e.g. /messages/967870/login (someone logging into message an attorney) */
THEN 'Account_Login' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/messages/[0-9]+/login') /* NEW LOGIC ADDED BY SROBINSON */
THEN 'Account_Login' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/register') /* we have a handful of sessions that look like /claim_profile/claim_by_email/cf09a89dc093/register; creating new category */
THEN 'Account_Register'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/claim_profile/claim_by_email/[A-Za-z0-9]+/register') /* NEW CASE ADDED BY SROBINSON */
THEN 'Professional_Claim_Profile'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/settings') /* x */
THEN 'Account_Settings' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/notifications') /* x  NEW LOGIC ADDED BY SROBINSON */
THEN 'Account_Settings' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/forgot_password') /* x */
THEN 'Account_Forgot_Password'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/my_avvo/questions') /* x */
THEN 'Account_Saved_Questions'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/saved_content/question_subscriptions') /* x */
THEN 'Account_Saved_Subscriptions'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/notifications') /* there's also an /account/notifications, which is not the same thing, and belongs in "settings" (added) */
THEN 'Account_Notifications' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/profile/dashboard') /* there's also an/advisor.avvo.com/dashboard; ignoring for now */
THEN 'Professional_Dashboard' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/profile/impression_stats') /* x */
THEN 'Professional_Analytics_Impressions' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/profile/contact_stats') /* x */
THEN 'Professional_Analytics_Contacts' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/support') /* x */
THEN 'Support' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/find-a-lawyer(\?|/|$)') /* added a slash for variations ending in / or /all-practice-areas EDITED BY SROBINSON TO INCLUDE PAGES ENDING IN / */
THEN 'Attorney_Directory_Launch' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+-lawyers?(/[^/]+)?(/[A-Za-z]{2}(/[^/]+)*)?\.html')
/* question-mark: either lawyer or lawyers, followed by some (optional) arbitrary text, then followed by a two-character segment (the state; this is what the {} indicates), 
then slash followed by by arbitrary text (the city), ending in .html. Everything after "lawyer" is optional. */
THEN 'Attorney_Directory_Browse' /* x */
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*-[0-9]+\.html') /* x */
THEN 'Attorney_Profile' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/reviews\.html') /* x */
THEN 'Attorney_Profile_Review' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/write_review\.html') /* x */
THEN 'Attorney_Profile_Write_Review' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/endorsements\.html') /* x ; also have variations like /attorneys/85012-az-jeffrey-silence-4178822/requested_endorsements/new; leave in Unknown for now */
THEN 'Attorney_Profile_Endorsement' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/aboutme\.html') /* x */
THEN 'Attorney_Profile_Aboutme'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/attorneys/*.*/contact\.html') /* x */
/* star equals "zero or more" matches on previous character; dot = "any non-whitespace character" if not escaped */
THEN 'Attorney_Profile_Contact' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/search/questions_answered_by_search') /* EDITED BY SROBINSON; "question" should be plural ("questions"); the original version gives no landings in the last couple years */
THEN 'Attorney_Profile_Answers' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/search/lawyer_search') /* x */
THEN 'Attorney_Search' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/search/professional_name_search') /* DOES NOT EXIST; we have /search/professional_name_search (not high volume); need to categorize in types of pages */
THEN 'Attorney_Search_by_Name' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/review-your-lawyer(\?|/|$)') /* EDITED BY SROBINSON TO INCLUDE PATHS ENDING IN / */
THEN 'Attorney_Review' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/search/review_lawyer_search') /* NEW CODE ADDED BY SROBINSON (this is the page where you search for a lawyer to review)  */
THEN 'Attorney_Review' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/free-legal-advice(\?|/|$)') /* EDITED BY SROBINSON TO INCLUDE PATHS ENDING IN / (if there's nothing after the advice word, it goes here...) */
THEN 'Legal_KB_Launch' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/free-legal-advice/') /* x (anything with stuff after the launch path goes here) */
THEN 'Legal_KB_Search' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^\/]+-lawyer.*\.html') /* x */
/* square-bracket means "any character"; in this case, we mean "anything except forward-slash", followed by -lawyer, followed by any text (or none), finish with .html */
THEN 'Legal_KB_Browse' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-answers/') /* x */
THEN 'Legal_Answers_Detail' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-guides/') /* x */
THEN 'Legal_Guides_Detail' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/ask-a-lawyer(\?|/|$)') /* EDITED BY SROBINSON TO INCLUDE PATHS ENDING IN / 
do not need to escape single-slash (added to deal with /ask-a-lawyer/ variation) */
THEN 'Legal_Ask_Launch' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal_questions/preview') /* THIS IS RARELY GETTING TRAFFIC IN THE LAST MONTH; NEW VARIATION ADDED BELOW */
THEN 'Legal_Ask_Preview' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/ask_question/preview') /* NEW CODE ADDED BY SROBINSON; MOST Q&A PREVIEW LANDINGS ARE GOING HERE */
THEN 'Legal_Ask_Preview' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal/answer_questions_search(\?|$)') /* EDITED BY SROBINSON: questions was singular; should be plural; this needs a category in types of pages */
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
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/topics/') /* x */
THEN 'Topics' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-answers$') /* no landings in last 30 days */
THEN 'Invalid Page -- Should Redirect' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/advisor/specialties') /* nothing is coming up for this in last 30 days */
THEN 'Advisor -- Specialty' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/advisor/practice-area') /* new; added 01/16/2017 */
THEN 'Advisor -- Specialty'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/advisor/thank_you/') /* nothing is coming up for this in last 30 days */
THEN 'Advisor -- Thank You' 
WHEN hits.page.hostName = 'advisor.avvo.com'
AND REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/advice_sessions/new') /* EDITED BY SROBINSON TO BE ABOVE THE HOMEPAGE VARIATION... while this is old data, all these were being classified as homepage */
THEN 'Advisor -- Checkout'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/advisor')
THEN 'Advisor -- Homepage' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+/legal-services/[^/\?]+/?(\?|$)' )
THEN 'LS-Lawyer-Select' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+/legal-services/[^/]+/[^/\?]+/?(\?|$)' ) /* new; added 01/16/2017 */
THEN 'LS-Package-Details'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+/legal-services/[^/\?]+/?(\?|$)') /* new; added 01/16/2017 */
THEN 'LS-Package-Details'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+/legal-services/[^/]+/.+') 
/* inside square bracket, ^ means "anything but the next character" 
THEN 'LS-Package-Details_Old' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/[^/]+/legal-services/?(\?|$)' ) /* new logic added 01/16/2017 */
THEN 'LS-Storefront' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-services/[0-9]+')
THEN 'LS-Package-Details-Attorney-View' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-services/checkout') 
THEN 'LS-Checkout'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-services/thank_you') 
THEN 'LS-Thankyou'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/legal-services/?(\?|$)' ) /* new logic as of 01/16/2017 */
THEN 'LS-Home' 
WHEN hits.page.pagePath = '/search' 
/* MODIFIED LOGIC FROM SROBINSON... we do not have a template name/site section (CD 19) matching the "no results" situation; GA web is inconsistent with BQ in terms of /search categorization, but this works */
THEN 'Global Search'
WHEN hits.page.hostName = 'lawyer-listings.avvo.com'
AND REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/adblock/' )
THEN 'SEM-Adblock' 
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/ammlp/lawyer-list') /* new logic to deal with the adblock nomenclature change */
THEN 'SEM-Adblock'
WHEN hits.page.hostName = 'lawyer-listings.avvo.com'
AND REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/network/' )
THEN 'SEM-Network'
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/ammlp/attorney-dir' ) /* new logic */
THEN 'SEM-Network'
ELSE 'Unknown'
END AS LPV_Page_Type