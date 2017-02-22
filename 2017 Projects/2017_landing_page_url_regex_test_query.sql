SELECT hits.page.pagePath as url_path
,CASE
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/account/register') -- 
THEN 'Account_Register'
ELSE 'Other'
END AS page_test
,SUM(totals.visits) sessions
FROM [75615261.ga_sessions_20170110]
WHERE hits.isEntrance = 1
AND hits.page.pagepath CONTAINS '/register'
GROUP BY 1,2