with email as
(
select 
ci.user_id
, max(event_date) as last_email_contact
from src.contact_impression ci
where contact_type = 'email'
group by 1
  
)

, website as 
(
select 
ci.user_id
, max(event_date) as last_website_contact
from src.contact_impression ci
where contact_type = 'website'
group by 1
)

, visit as 
(
select 
  t.resolved_user_id
  , if(t.lawyer_user_id, 'Lawyer', 'Consumer') as Lawyer1
  , max(t.event_date) as last_visit_date
from dm.traffic t
group by 1,2
)

select 
last_answer_date
, last_question_date
, last_review_date
, last_endorsee_date
, em.last_email_contact
, wb.last_website_contact
, case when lawyer1 = 'Lawyer' then 'Lawyer'
  else 'Consumer' end as Lawyer
, to_date(uad.user_account_register_datetime) as user_account_register_datetime
,sum(question_asked_count) as question_asked_count
, count(*) as num_users
from dm.rpt_register_user_metrics_report ru
left join email em on cast (em.user_id as int) = ru.user_id
left join website wb on cast (wb.user_id as int) = ru.user_id
left join visit v on cast (v.resolved_user_id as int) = ru.user_id
left join dm.user_account_dimension uad on uad.user_account_id = ru.user_id
group by 1,2,3,4,5,6,7,8