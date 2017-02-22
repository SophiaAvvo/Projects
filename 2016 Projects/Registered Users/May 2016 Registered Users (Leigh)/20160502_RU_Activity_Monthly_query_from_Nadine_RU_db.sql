with cnt_email as
(
select 
month_begin_date
, count(*) as cnt_emailcontacts
from src.contact_impression ci
join dm.date_dim dt on ci.event_date = dt.actual_date
where contact_type = 'email' and ci.user_id is not null
group by 1
)


,cnt_website as 
(
select
month_begin_date
, count(*) as cnt_webcontacts
from src.contact_impression ci
join dm.date_dim dt on ci.event_date = dt.actual_date
left join dm.traffic t on t.session_id = ci.session_id and t.event_date = ci.event_date
where contact_type = 'website' and (ci.user_id is not null or t.resolved_user_id is not null)
group by 1

)


, cnt_visit as 
(
select 
  month_begin_date
  , count(distinct(session_id)) as cnt_visit
from dm.traffic t
join dm.date_dim dt on t.event_date = dt.actual_date
where t.resolved_user_id is not null and t.resolved_user_id <> ''
group by 1
)

, cnt_ru as
(
select
  month_begin_date
  , count(*) as num_users
from dm.user_account_dimension uad
join dm.date_dim dt on to_date(dt.actual_date)=to_date(uad.user_account_register_datetime)
group by 1
)

  

, questions as
(
select 
   dt.month_begin_date
   ,count(distinct q.id) as num_questions
from src.content_question q
join dm.date_dim dt on to_date(dt.actual_date)=to_date(q.created_at)
where approval_status_id in (1,2)
group by 1

)


, askers as
(
select 
   dt.month_begin_date
   ,count(distinct q.created_by) as num_askers
from src.content_question q
join dm.date_dim dt on to_date(dt.actual_date)=to_date(q.created_at)
group by 1
)

, cnt_reviews as
(
select
 dt.month_begin_date
, COUNT(pfrv.id) as num_reviews
from src.barrister_professional_review pfrv							
	join DM.professional_dimension pf on pf.professional_id = pfrv.professional_id		
	join dm.date_dim dt on dt.actual_date = to_date(pfrv.created_at)
	where pfrv.approval_status_id = 2							
		-- and pfrv.DEL_FLAG = 'N'						
		and pf.professional_delete_indicator = 'Not Deleted'						
		and pf.professional_name = 'lawyer'						
		and pf.industry_name = 'Legal'
  group by 1
)

, cnt_reviewers as
(
select
 dt.month_begin_date 
, COUNT(distinct created_by) as num_reviewers
from src.barrister_professional_review pfrv							
	join DM.professional_dimension pf on pf.professional_id = pfrv.professional_id		
	join dm.date_dim dt on dt.actual_date = to_date(pfrv.created_at)
	where pfrv.approval_status_id = 2							
		-- and pfrv.DEL_FLAG = 'N'						
		and pf.professional_delete_indicator = 'Not Deleted'						
		and pf.professional_name = 'lawyer'						
		and pf.industry_name = 'Legal'
  group by 1
)
select 

uad.month_begin_date
, sum(cnt_emailcontacts) as cnt_emailcontacts
, sum(cnt_webcontacts) as cnt_webcontacts
, sum(cnt_visit) as cnt_visit
, sum(num_users) as num_users
, sum(num_questions) as num_questions
, sum(num_askers) as num_askers
, sum(num_reviews) as num_reviews
, sum(num_reviewers) as num_reviewers
from  cnt_ru uad 
left join questions q on q.month_begin_date = uad.month_begin_date
left join cnt_visit v on v.month_begin_date = uad.month_begin_date 
left join cnt_email em on em.month_begin_date = uad.month_begin_date
left join cnt_website wb on wb.month_begin_date = uad.month_begin_date
left join askers a on a.month_begin_date =  uad.month_begin_date
left join cnt_reviews rv on rv.month_begin_date =  uad.month_begin_date
left join cnt_reviewers rv2 on rv2.month_begin_date =  uad.month_begin_date
group by 1