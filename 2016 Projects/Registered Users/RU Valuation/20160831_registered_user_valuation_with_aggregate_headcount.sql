with user_dates AS (

SELECT uad.user_account_id
,uad.user_account_register_datetime
,md.month_begin_date AS user_action_month_begin
,md.month_end_date AS user_action_month_end
,md.month_name
,MIN(md.month_begin_date) OVER(PARTITION BY uad.user_account_id) AS User_Cohort_Registration_Month
,ROW_NUMBER() OVER(PARTITION BY uad.user_account_id ORDER BY md.month_begin_date) month_number
FROM dm.user_account_dimension uad
LEFT JOIN dm.professional_dimension pd
	ON uad.user_account_id = CAST(pd.professional_user_account_id AS INT)
CROSS JOIN dm.month_dim md
WHERE uad.user_account_register_datetime BETWEEN '2015-09-01' AND '2015-10-31'
AND md.month_end_date BETWEEN to_date(uad.user_account_register_datetime) AND now() -- it has to be on or before the last day of the first month; this is the start month
AND pd.professional_user_account_id IS NULL -- no lawyers

)

,email_prep AS (

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

,cnt_email as
(
select 
ur.user_cohort_registration_month
,ur.user_action_month_begin
,count(ci.contact_item) as email_and_message_count
from email_prep ci
join dm.date_dim dt 
	on ci.event_date = dt.actual_date
	AND ci.user_id <> '-1'
JOIN user_dates ur 
	ON ur.user_account_id = CAST(ci.user_id AS INT)
	AND ur.user_action_month_begin = dt.month_begin_date
	AND ur.month_number <= 6
group by 1,2
)


,cnt_website as 
(
select
ur.user_cohort_registration_month
,ur.user_action_month_begin
, count(*) as website_click_count
from src.contact_impression ci
join dm.date_dim dt 
	on ci.event_date = dt.actual_date
	AND ci.user_id <> '-1'
JOIN user_dates ur 
	ON ur.user_account_id = CAST(ci.user_id AS INT)
	AND ur.user_action_month_begin = dt.month_begin_date
	AND ur.month_number <= 6	
left join dm.traffic t 
	on t.session_id = ci.session_id 
	and t.event_date = ci.event_date
	AND contact_type = 'website' 
	and (ci.user_id is not null or t.resolved_user_id is not null)
group by 1,2

)


, cnt_visit as 
(
select 
ur.user_cohort_registration_month
,ur.user_action_month_begin
  , count(distinct(session_id)) as session_count
from dm.traffic t
join dm.date_dim dt 
	on t.event_date = dt.actual_date
	AND t.resolved_user_id is not null and t.resolved_user_id <> ''	AND t.resolved_user_id <> '-1'
JOIN user_dates ur 
	ON ur.user_account_id = CAST(t.resolved_user_id AS INT)
	AND ur.user_action_month_begin = dt.month_begin_date
	AND ur.month_number <= 6
group by 1,2
)

, cnt_ru as
(
select
ur.user_cohort_registration_month
,ur.user_action_month_begin
,ur.month_number
,ur.month_name
,ur.user_action_month_begin
,ur.user_action_month_end
  , count(ur.user_account_id) as registered_users_count
from user_dates ur 
WHERE ur.month_number <= 6
group by 1,2,3,4,5,6
)

  

, questions as
(
select 
ur.user_cohort_registration_month
,ur.user_action_month_begin
   ,count(distinct q.id) as approved_question_count
from src.content_question q
join dm.date_dim dt 
	on to_date(dt.actual_date)=to_date(q.created_at)
	AND approval_status_id in (1,2)
	AND q.created_by <> -1
JOIN user_dates ur 
	ON ur.user_account_id = q.created_by
	AND ur.user_action_month_begin = dt.month_begin_date
	AND ur.month_number <= 6
group by 1,2

)


, askers as
(
select 
ur.user_cohort_registration_month
,ur.user_action_month_begin
   ,count(distinct q.created_by) as asker_count
from src.content_question q
join dm.date_dim dt 
	on to_date(dt.actual_date)=to_date(q.created_at)
	AND q.created_by <> -1
JOIN user_dates ur 
	ON ur.user_account_id = q.created_by
	AND ur.user_action_month_begin = dt.month_begin_date
	AND ur.month_number <= 6
group by 1,2
)

, cnt_reviews as
(
select
ur.user_cohort_registration_month
,ur.user_action_month_begin
, COUNT(pfrv.id) as approved_review_count
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
JOIN user_dates ur 
	ON ur.user_account_id = pfrv.created_by
	AND ur.user_action_month_begin = dt.month_begin_date
	AND ur.month_number <= 6
group by 1,2
)

, cnt_reviewers as
(
select
ur.user_cohort_registration_month
,ur.user_action_month_begin
, COUNT(distinct pfrv.created_by) as reviewer_count
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
JOIN user_dates ur 
	ON ur.user_account_id = pfrv.created_by
	AND ur.user_action_month_begin = dt.month_begin_date
	AND ur.month_number <= 6
group by 1,2
)

,

als_prep AS (
SELECT DISTINCT pv.persistent_session_id
,cast(regexp_extract(url, 'thank_you\/([0-9]+)', 1) as INT) order_id
,pv.event_date
from src.page_view pv
where page_type = 'LS-Thankyou' 
	and event_date >= '2016-02-08'
)

,UID_PID AS (
SELECT MAX(CAST(t.resolved_user_id AS INT)) user_id
,t.persistent_session_id
FROM dm.traffic t
WHERE t.event_date >= '2016-09-01'
GROUP BY 2
)

, als_purchases AS (
SELECT 
ur.user_cohort_registration_month
,ur.user_action_month_begin
,COUNT(DISTINCT als.order_id) AS als_purchase_count
FROM als_prep als
	join dm.date_dim dt 
		on dt.actual_date = als.event_date
JOIN UID_PID u
	ON u.persistent_session_id = als.persistent_session_id
JOIN user_dates ur 
	ON ur.user_account_id = u.user_id
	AND ur.user_action_month_begin = dt.month_begin_date
	AND ur.month_number <= 6
GROUP BY 1,2

)

select 

uad.user_cohort_registration_month
,uad.user_action_month_begin
,uad.user_action_month_end
,uad.month_number
,uad.MonthName
,uad.registered_users_count
,em.email_contacts_count 
,wb.website_click_count
,v.session_count
,q.approved_question_count
,a.asker_count
,rv.approved_review_count
,rv2.reviewer_count
,als.als_purchases
from cnt_ru uad 
left join questions q 
	ON q.user_cohort_registration_month = uad.user_cohort_registration_month
	AND q.user_action_month_begin = uad.user_action_month_begin
left join cnt_visit v 
	on v.user_cohort_registration_month = uad.user_cohort_registration_month
	AND v.user_action_month_begin = uad.user_action_month_begin
left join cnt_email em 
	on em.user_cohort_registration_month = uad.user_cohort_registration_month
	AND em.user_action_month_begin = uad.user_action_month_begin
left join cnt_website wb 
	on wb.user_cohort_registration_month = uad.user_cohort_registration_month
	AND wb.user_action_month_begin = uad.user_action_monthh	
left join askers a 
	on a.user_cohort_registration_month = uad.user_cohort_registration_month
	AND a.user_action_month_begin = uad.user_action_month_begin
left join cnt_reviews rv 
	on rv.user_cohort_registration_month = uad.user_cohort_registration_month
	AND rv.user_action_month_begin = uad.user_action_month_begin	
left join cnt_reviewers rv2 
	on rv2.user_cohort_registration_month = uad.user_cohort_registration_month
	AND rv2.user_action_month_begin = uad.user_action_month_begin
left join als_purchases als
	on als.user_cohort_registration_month = uad.user_cohort_registration_month
	AND als.user_action_month_begin = uad.user_action_month_begin

