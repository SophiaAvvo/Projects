with email_prep AS (

SELECT CONCAT(user_id, event_date) contact_item
,ci.event_date 
,ci.user_id
FROM src.contact_impression ci
WHERE contact_type = 'message'
and ci.user_id is not null

UNION

SELECT CONCAT(ci.contact_type, CAST(ci.gmt_timestamp AS STRING)) contact_item
,ci.event_date
,ci.user_id
FROM src.contact_impression ci
WHERE ci.contact_type = 'email'
and ci.user_id is not null
)

,

message_prep AS (SELECT
  contact_type
  ,event_date
  ,user_id
  --,professional_id
  --,COUNT(*) AS chat_messages
  ,SUM(CASE WHEN prev_event_date IS NULL THEN 1
            WHEN DATEDIFF(event_date, prev_event_date) > 14 THEN 1
            ELSE 0
       END) AS item_count
FROM
  (
  SELECT contact_type, event_date, FROM_UNIXTIME(gmt_timestamp) AS gmt_time, professional_id, user_id, persistent_session_id
    ,LAG(event_date) OVER (PARTITION BY contact_type, professional_id, user_id
                                  ORDER BY gmt_timestamp) AS prev_event_date
  FROM src.contact_impression
  WHERE contact_type = 'message'
  ) msg
GROUP BY 1,2,3

UNION ALL

SELECT contact_type
,ci.event_date
,ci.user_id
,COUNT(DISTINCT CONCAT(CAST(ci.professional_id AS STRING), CAST(ci.gmt_timestamp AS STRING))) item_count
FROM src.contact_impression ci
WHERE ci.contact_type = 'email'
and ci.user_id is not null
GROUP BY 1,2,3
)

,

cnt_email as
(
select 
month_begin_date
,rp.registration_path
,rp.lawyer_vs_consumer
,SUM(item_count) as cnt_emailcontacts
from message_prep ci
join dm.date_dim dt on ci.event_date = dt.actual_date
LEFT JOIN dm.rpt_user_type_and_registration_path rp
	ON rp.user_id = CAST(ci.user_id AS INT)
group by 1,2,3
)


,cnt_website as 
(
select
month_begin_date
,rp.registration_path
,rp.lawyer_vs_consumer
, count(*) as cnt_webcontacts
from src.contact_impression ci
join dm.date_dim dt 
	on ci.event_date = dt.actual_date
	AND ci.user_id <> '-1'
left join dm.traffic t 
	on t.session_id = ci.session_id 
	and t.event_date = ci.event_date
	AND contact_type = 'website' 
	and (ci.user_id is not null or t.resolved_user_id is not null)
LEFT JOIN dm.rpt_user_type_and_registration_path rp
	ON rp.user_id = CAST(t.resolved_user_id AS INT)
group by 1,2,3

)


, cnt_visit as 
(
select 
  month_begin_date
  ,rp.registration_path
	,rp.lawyer_vs_consumer
  , count(distinct(session_id)) as cnt_visit
from dm.traffic t
join dm.date_dim dt 
	on t.event_date = dt.actual_date
	AND t.resolved_user_id is not null and t.resolved_user_id <> ''	AND t.resolved_user_id <> '-1'
LEFT JOIN dm.rpt_user_type_and_registration_path rp
	ON rp.user_id = CAST(t.resolved_user_id AS INT)
group by 1,2,3
)

, cnt_ru as
(
select
  month_begin_date
    ,rp.registration_path
	,rp.lawyer_vs_consumer
  , count(*) as num_users
from dm.user_account_dimension uad
join dm.date_dim dt 
	on to_date(dt.actual_date)=to_date(uad.user_account_register_datetime)
	AND uad.user_account_id <> -1
LEFT JOIN dm.rpt_user_type_and_registration_path rp
	ON rp.user_id = uad.user_account_id

group by 1,2,3
)

  

, questions as
(
select 
   dt.month_begin_date
     ,rp.registration_path
	,rp.lawyer_vs_consumer
   ,count(distinct q.id) as num_questions
from src.content_question q
join dm.date_dim dt 
	on to_date(dt.actual_date)=to_date(q.created_at)
	AND approval_status_id in (1,2)
	AND q.created_by <> -1
LEFT JOIN dm.rpt_user_type_and_registration_path rp
	ON rp.user_id = q.created_by
	
group by 1,2,3

)


, askers as
(
select 
   dt.month_begin_date
    ,rp.registration_path
	,rp.lawyer_vs_consumer
   ,count(distinct q.created_by) as num_askers
from src.content_question q
join dm.date_dim dt 
	on to_date(dt.actual_date)=to_date(q.created_at)
	AND q.created_by <> -1
LEFT JOIN dm.rpt_user_type_and_registration_path rp
	ON rp.user_id = q.created_by	
group by 1,2,3
)

, cnt_reviews as
(
select
 dt.month_begin_date
     ,rp.registration_path
	,rp.lawyer_vs_consumer
, COUNT(pfrv.id) as num_reviews
from src.barrister_professional_review pfrv							
	join DM.professional_dimension pf 
		on pf.professional_id = pfrv.professional_id
		AND pfrv.approval_status_id = 2							
		-- and pfrv.DEL_FLAG = 'N'						
		and pf.professional_delete_indicator = 'Not Deleted'						
		and pf.professional_name = 'lawyer'						
		and pf.industry_name = 'Legal'	
		AND pfrv.created_by <> -1
	join dm.date_dim dt 
		on dt.actual_date = to_date(pfrv.created_at)
	LEFT JOIN dm.rpt_user_type_and_registration_path rp
		ON rp.user_id = pfrv.created_by		
  group by 1,2,3
)

, cnt_reviewers as
(
select
 dt.month_begin_date 
     ,rp.registration_path
	,rp.lawyer_vs_consumer 
, COUNT(distinct created_by) as num_reviewers
from src.barrister_professional_review pfrv							
	join DM.professional_dimension pf 
		on pf.professional_id = pfrv.professional_id
		AND pfrv.approval_status_id = 2							
		-- and pfrv.DEL_FLAG = 'N'						
		and pf.professional_delete_indicator = 'Not Deleted'						
		and pf.professional_name = 'lawyer'						
		and pf.industry_name = 'Legal'	
		AND pfrv.created_by <> -1
	join dm.date_dim dt 
		on dt.actual_date = to_date(pfrv.created_at)
	LEFT JOIN dm.rpt_user_type_and_registration_path rp
		ON rp.user_id = pfrv.created_by

  group by 1,2,3
)
select 

uad.month_begin_date
     ,uad.registration_path
	,uad.lawyer_vs_consumer
, sum(cnt_emailcontacts) as cnt_emailcontacts
, sum(cnt_webcontacts) as cnt_webcontacts
, sum(cnt_visit) as cnt_visit
, sum(num_users) as num_users
, sum(num_questions) as num_questions
, sum(num_askers) as num_askers
, sum(num_reviews) as num_reviews
, sum(num_reviewers) as num_reviewers
from  cnt_ru uad 
left join questions q 
	on q.month_begin_date = uad.month_begin_date
	AND q.lawyer_vs_consumer = uad.lawyer_vs_consumer
	AND q.registration_path = uad.registration_path
left join cnt_visit v 
	on v.month_begin_date = uad.month_begin_date 
	AND v.lawyer_vs_consumer = uad.lawyer_vs_consumer
	AND v.registration_path = uad.registration_path	
left join cnt_email em 
	on em.month_begin_date = uad.month_begin_date
	AND em.lawyer_vs_consumer = uad.lawyer_vs_consumer
	AND em.registration_path = uad.registration_path
left join cnt_website wb 
	on wb.month_begin_date = uad.month_begin_date
	AND wb.lawyer_vs_consumer = uad.lawyer_vs_consumer
	AND wb.registration_path = uad.registration_path	
left join askers a 
	on a.month_begin_date =  uad.month_begin_date
	AND a.lawyer_vs_consumer = uad.lawyer_vs_consumer
	AND a.registration_path = uad.registration_path
left join cnt_reviews rv 
	on rv.month_begin_date =  uad.month_begin_date
	AND rv.lawyer_vs_consumer = uad.lawyer_vs_consumer
	AND rv.registration_path = uad.registration_path	
left join cnt_reviewers rv2 
	on rv2.month_begin_date =  uad.month_begin_date
	AND rv2.lawyer_vs_consumer = uad.lawyer_vs_consumer
	AND rv2.registration_path = uad.registration_path
group by 1,2,3