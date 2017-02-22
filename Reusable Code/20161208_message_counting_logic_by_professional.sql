with message_prep AS (SELECT ci.professional_id
  ,dd.month_begin_date AS contact_month
  --,professional_id
  --,COUNT(*) AS chat_messages
  ,SUM(CASE WHEN prev_event_date IS NULL THEN 1
            WHEN DATEDIFF(event_date, prev_event_date) >= 14 THEN 1
            ELSE 0
       END) AS item_count
FROM
  (
  SELECT contact_type, event_date, FROM_UNIXTIME(gmt_timestamp) AS gmt_time, professional_id, user_id, persistent_session_id
    ,LAG(event_date) OVER (PARTITION BY contact_type, professional_id, user_id
                                  ORDER BY gmt_timestamp) AS prev_event_date
  FROM src.contact_impression ci
  JOIN dm.date_dim dd
	ON dd.actual_date = ci.event_date
	AND dd.year_month = 201611
  WHERE contact_type = 'message'
  ) msg
GROUP BY 1,2

UNION ALL

SELECT ci.professional_id
,dd.month_begin_date AS contact_month
,COUNT(*) AS item_count
FROM src.contact_impression ci
JOIN dm.date_dim dd
	ON dd.actual_date = ci.event_date
	AND dd.year_month = 201611
WHERE ci.contact_type = 'email'
and ci.user_id is not null
GROUP BY 1,2
)

,

cnt_email as
(
select 
contact_month
,profession
,SUM(item_count) as cnt_emailcontacts
from message_prep ci
group by 1,2
)


,cnt_website as 
(
select
month_begin_date AS contact_month
,rp.registration_path
,rp.lawyer_vs_consumer
, count(*) as cnt_webcontacts
from src.contact_impression ci
join dm.date_dim dt 
	on ci.event_date = dt.actual_date
	AND ci.user_id <> '-1'
WHERE dt.year_month = 201611
AND ci.contact_type = 'website'
group by 1,2,3

)

,cnt_phone AS (
select ci.professional_id
,month_begin_date AS contact_month
, count(*) as cnt_webcontacts
from src.contact_impression ci
join dm.date_dim dt 
	on ci.event_date = dt.actual_date
WHERE dt.year_month = 201611
AND ci.contact_type = 'phone'
group by 1,2
)

