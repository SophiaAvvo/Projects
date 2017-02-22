SELECT DISTINCT event_type
,from_unixtime(w.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss') weblog_timestamp
,uad.user_account_register_datetime
,user_id
FROM src.weblog w
JOIN dm.user_account_dimension uad
ON uad.user_account_id = CAST(w.user_id AS INT)
AND uad.user_account_id < 1000
AND w.gmt_timestamp BETWEEN unix_timestamp(DATE_ADD(uad.user_account_register_datetime, -1)) AND unix_timestamp(DATE_ADD(uad.user_account_register_datetime, +1))
ORDER BY 4,2

SELECT *
FROM src.weblog
LIMIT 1000;

/* this took too long and was too complicated... */

WITH UID_2_PID AS (
SELECT DISTINCT t.persistent_session_id
	,CAST(t.resolved_user_id AS INT) user_id
	-- ,case when lawyer_user_id = true then 'Lawyer' else '' end as Lawyer
 from dm.traffic t
 where t.resolved_user_id IS NOT NULL

 )

,


weblog AS (SELECT DISTINCT event_type
,from_unixtime(w.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss') weblog_timestamp
,uad.user_account_register_datetime
,uad.user_account_id
,w.persistent_session_id
,w.url
FROM dm.user_account_dimension uad
LEFT JOIN UID_2_PID u
ON u.user_id = uad.user_account_id
LEFT JOIN src.weblog w
ON uad.user_account_id = CAST(w.user_id AS INT)
WHERE uad.user_account_register_datetime = '2016-02-14'
AND w.gmt_timestamp BETWEEN unix_timestamp(DATE_ADD(uad.user_account_register_datetime, -1)) AND unix_timestamp(DATE_ADD(uad.user_account_register_datetime, +1))

UNION
    
SELECT DISTINCT event_type
,from_unixtime(w.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss') weblog_timestamp
,uad.user_account_register_datetime
,uad.user_account_id
,w.persistent_session_id
,w.url
FROM dm.user_account_dimension uad
LEFT JOIN UID_2_PID u
ON u.user_id = uad.user_account_id
LEFT JOIN src.weblog w
ON u.persistent_session_id = w.persistent_session_id
WHERE uad.user_account_register_datetime = '2016-02-14'
AND w.gmt_timestamp BETWEEN unix_timestamp(DATE_ADD(uad.user_account_register_datetime, -1)) AND unix_timestamp(DATE_ADD(uad.user_account_register_datetime, +1))
)


SELECT *
FROM weblog

/* this was helpful */

WITH UID_2_PID AS (
SELECT DISTINCT TRIM(t.persistent_session_id) persistent_session_id
	,CAST(t.resolved_user_id AS INT) user_id
	-- ,case when lawyer_user_id = true then 'Lawyer' else '' end as Lawyer
 from dm.traffic t
 where t.resolved_user_id IS NOT NULL

 )

    
SELECT event_type
,from_unixtime(w.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss') weblog_timestamp
,uad.user_account_register_datetime
,uad.user_account_id
,w.persistent_session_id
,w.url
FROM dm.user_account_dimension uad
JOIN UID_2_PID u
ON u.user_id = uad.user_account_id
AND to_date(uad.user_account_register_datetime) = '2015-01-01'
JOIN src.weblog w
ON u.persistent_session_id = w.persistent_session_id
AND w.event_type IN ('ad_click'
,'ad_click_2'
,'ad_click_email'
,'ad_click_profile'
,'advisor_session_payment'
,'advisor-session-payment'
,'contact_impression'
,'contact_impression_2'
,'created_question'
,'cross_sell_click'
,'form_submit'
,'page_view'
,'question_topic_edit'
,'service_session_payment')

/*AND w.gmt_timestamp BETWEEN unix_timestamp(DATE_ADD(uad.user_account_register_datetime, -1))  AND unix_timestamp(uad.user_account_register_datetime) */
ORDER BY 4,2

SELECT MIN(from_unixtime(w.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss')) min_datetime
FROM src.weblog w

