WITH ALS_all AS (
SELECT 'Distinct ALS Customers - All Time' AS Metric
,COUNT(DISTINCT client_email_address) AS total_count
,MIN(from_utc_timestamp(created_at,'PST')) first_action_date
,MAX(from_utc_timestamp(created_at,'PST')) last_action_date
FROM src.ocato_advice_sessions oas
WHERE YEAR(from_utc_timestamp(created_at,'PST')) <> 1900
-- LIMIT 10;

)

,

callers_prep AS (
SELECT ci.caller
,ci.`timestamp`
FROM src.contact_impression ci
where contact_type = 'phone'
AND ci.event_date >= '2015-05-01'

UNION

SELECT wa.caller
,wa.`timestamp`
FROM dm.webanalytics wa
WHERE contact_type = 'phone'
AND event_type = 'contact_impression'
AND event_date < '2015-05-01'


)

,

callers_all AS (
SELECT 'Distinct Callers' AS Metric
,COUNT(DISTINCT caller) total_count
,MIN(`timestamp`) first_action_date
,MAX(`timestamp`) last_action_date
FROM callers_prep cp
GROUP BY 1)

,

emailers_prep AS (
SELECT ci.user_id
,ci.`timestamp`
FROM src.contact_impression ci
where contact_type IN ('email', 'message')
AND ci.event_date >= '2015-05-01'

UNION

SELECT wa.user_id
,wa.`timestamp`
FROM dm.webanalytics wa
WHERE contact_type = 'email'
AND event_date < '2015-05-01'
AND event_type = 'contact_impression'

)

,

emailers_all AS (
SELECT 'Distinct Emailers' AS Metric
,COUNT(DISTINCT user_id) total_count
,MIN(`timestamp`) first_action_date
,MAX(`timestamp`) last_action_date
FROM emailers_prep ep
GROUP BY 1)


,

questions_all AS (
select 'Distinct Askers - All Time' AS Metric
   ,count(distinct q.created_by) as total_count
   ,MIN(created_at) first_action_date
   ,MAX(created_at) last_action_date
from src.content_question q
WHERE YEAR(created_at) <> 1900
group by 1

)

SELECT *
FROM emailers_all

UNION ALL

SELECT *
FROM callers_all

UNION ALL

SELECT *
FROM questions_all

UNION ALL

SELECT *
FROM ALS_all

