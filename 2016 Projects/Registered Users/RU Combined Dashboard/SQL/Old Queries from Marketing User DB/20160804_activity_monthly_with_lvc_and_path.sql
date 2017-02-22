with UID_window AS (

SELECT DISTINCT ua.user_account_id AS user_id
	,ua.user_account_register_datetime reg_date
	--,t.persistent_session_id ps_id
	-- ,to_date(cast(ua.user_account_register_datetime as timestamp) - interval 1 days) WindowStart
	,to_date(cast(ua.user_account_register_datetime as timestamp) + interval 30 days) WindowEnd
 from dm.user_account_dimension ua
 
 )
 
 ,

emails AS (
select 
	CAST(ci.user_id AS INT) user_id
	,'Email' AS ActionType
	/*,CASE
			WHEN pa.ParentPracticeArea1 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea1
			WHEN pa.ParentPracticeArea2 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea2
			WHEN pa.ParentPracticeArea3 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea3
			ELSE pa.ParentPracticeArea1
		END ParentPA*/
	,min(from_unixtime(ci.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss')) FirstAction
from src.contact_impression ci
JOIN UID_window up
	ON up.user_id = CAST(ci.user_id AS INT)
	AND ci.event_date < up.WindowEnd
AND ci.contact_type = 'email'
/*LEFT JOIN PA3 pa
	ON pa.professional_id = ci.professional_id*/

group by 1,2--,3
  
 )
 
 ,
 
 review AS (select 
ci.created_by user_id
	,'Review' AS ActionType
	/*,CASE
			WHEN pa.ParentPracticeArea1 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea1
			WHEN pa.ParentPracticeArea2 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea2
			WHEN pa.ParentPracticeArea3 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea3
			ELSE pa.ParentPracticeArea1
		END ParentPA */
,min(ci.created_at) FirstAction
from src.barrister_professional_review ci
JOIN UID_window up
	ON up.user_id = ci.created_by
	AND ci.created_at < up.WindowEnd
/*left join PA3 pa
	ON pa.professional_id = ci.professional_id */

group by 1,2--,3

)

,

questions as
(
	select q.created_by AS user_id
	,'Ask a Question' as ActionType
	-- ,sd.parent_specialty_name ParentPA
		,MIN(q.created_at) as FirstAction
	from src.content_question q
	JOIN UID_window up
	ON up.user_id = q.created_by
	AND q.created_at < up.WindowEnd
	/*left join dm.specialty_dimension sd on sd.specialty_id = q.specialty_id */
	where q.approval_status_id in (1,2)
	   AND (q.created_by <> 1 OR q.updated_by <> 1)
	group by 1,2-- ,3
)

,als_transactions AS (
	select DISTINCT persistent_session_id
		,from_unixtime(pv.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss') transaction_time
		,regexp_extract(url, 'thank_you\/([0-9]+)', 1) as order_id
	from src.page_view pv
	where page_type = 'LS-Thankyou' 
  
)

,als_path AS (
	SELECT up.user_id
		,'ALS Purchase' AS ActionType
		-- ,sd.parent_specialty_name ParentPA
		,min(a.transaction_time) FirstAction
	FROM als_transactions a
JOIN dm.traffic t
	ON t.persistent_session_id = a.persistent_session_id
JOIN UID_window up
	ON up.user_id = CAST(t.resolved_user_id AS INT)
	AND a.transaction_time BETWEEN to_date(cast(up.reg_date as timestamp) - interval 1 days) AND up.WindowEnd	
	left join src.ocato_advice_sessions oas 
		on cast(a.order_id as INT) = oas.id 
	/*left join dm.specialty_dimension sd 
		on sd.specialty_id = oas.specialty_id*/
	group by 1,2-- ,3
	
)


, activities AS (

SELECT *
FROM review

UNION ALL 

SELECT *
FROM questions

UNION ALL

SELECT *
FROM emails

UNION ALL

SELECT *
FROM als_path

)

,

register_path AS (

SELECT user_id
,COALESCE(a.ActionType, 'Other/Unknown') AS ActionType
,ROW_NUMBER() OVER(PARTITION BY a.user_id ORDER BY a.FirstAction) ActionRank
FROM activities a
WHERE a.firstaction IS NOT NULL

)

,cnt_email as
(
select 
month_begin_date
,CASE
		WHEN pd.professional_id IS NOT NULL
			THEN 'Lawyer'
		ELSE 'Consumer/Other'
	END lawyer_vs_consumer
  ,rp.ActionType AS registration_path
, count(*) as cnt_emailcontacts
from src.contact_impression ci
join dm.date_dim dt on ci.event_date = dt.actual_date
	LEFT JOIN dm.professional_dimension pd
		On ci.user_id = pd.professional_user_account_id
	LEFT JOIN register_path rp
		ON rp.user_id = CAST(ci.user_id AS INT)
		AND rp.ActionRank = 1
where contact_type = 'email' and ci.user_id is not null
group by 1,2,3
)


,cnt_website as 
(
select
month_begin_date
,CASE
		WHEN pd.professional_id IS NOT NULL
			THEN 'Lawyer'
		ELSE 'Consumer/Other'
	END lawyer_vs_consumer
  ,rp.ActionType AS registration_path
, count(*) as cnt_webcontacts
from src.contact_impression ci
join dm.date_dim dt on ci.event_date = dt.actual_date
left join dm.traffic t on t.session_id = ci.session_id and t.event_date = ci.event_date
	LEFT JOIN dm.professional_dimension pd
		On ci.user_id = pd.professional_user_account_id
	LEFT JOIN register_path rp
		ON rp.user_id = CAST(ci.user_id AS INT)
		AND rp.ActionRank = 1
where contact_type = 'website' and (ci.user_id is not null or t.resolved_user_id is not null)
group by 1,2,3

)


, cnt_visit as 
(
select 
  month_begin_date
  ,CASE
		WHEN pd.professional_id IS NOT NULL
			THEN 'Lawyer'
		ELSE 'Consumer/Other'
	END lawyer_vs_consumer
  ,rp.ActionType AS registration_path
  , count(distinct(session_id)) as cnt_visit
from dm.traffic t
join dm.date_dim dt on t.event_date = dt.actual_date
	LEFT JOIN dm.professional_dimension pd
		On t.resolved_user_id = pd.professional_user_account_id
	LEFT JOIN register_path rp
		ON rp.user_id = CAST(t.resolved_user_id AS INT)
		AND rp.ActionRank = 1
where t.resolved_user_id is not null and t.resolved_user_id <> ''
group by 1,2,3
)

, cnt_ru as
(
select
  month_begin_date
  ,CASE
		WHEN pd.professional_id IS NOT NULL
			THEN 'Lawyer'
		ELSE 'Consumer/Other'
	END lawyer_vs_consumer
	,rp.ActionType as registration_path
  , count(*) as num_users
from dm.user_account_dimension uad
join dm.date_dim dt on to_date(dt.actual_date)=to_date(uad.user_account_register_datetime)
	LEFT JOIN dm.professional_dimension pd
		On uad.user_account_id = CAST(pd.professional_user_account_id AS INT)
	LEFT JOIN register_path rp
		ON rp.user_id = uad.user_account_id
		AND rp.ActionRank = 1
group by 1,2,3
)

  

, questions2 as
(
select 
   dt.month_begin_date
   ,CASE
		WHEN pd.professional_id IS NOT NULL
			THEN 'Lawyer'
		ELSE 'Consumer/Other'
	END lawyer_vs_consumer
  ,rp.ActionType AS registration_path
   ,count(distinct q.id) as num_questions
from src.content_question q
join dm.date_dim dt on to_date(dt.actual_date)=to_date(q.created_at)
	LEFT JOIN dm.professional_dimension pd
		On q.created_by = CAST(pd.professional_user_account_id AS INT)
	LEFT JOIN register_path rp
		ON rp.user_id = q.created_by
		AND rp.ActionRank = 1
where approval_status_id in (1,2)
group by 1,2,3

)


, askers as
(
select 
   dt.month_begin_date
   ,CASE
		WHEN pd.professional_id IS NOT NULL
			THEN 'Lawyer'
		ELSE 'Consumer/Other'
	END lawyer_vs_consumer
  ,rp.ActionType AS registration_path
   ,count(distinct q.created_by) as num_askers
from src.content_question q
join dm.date_dim dt on to_date(dt.actual_date)=to_date(q.created_at)
	LEFT JOIN dm.professional_dimension pd
		On q.created_by = CAST(pd.professional_user_account_id AS INT)
	LEFT JOIN register_path rp
		ON q.created_by = rp.user_id
		AND rp.ActionRank = 1
group by 1,2,3
)

, cnt_reviews as
(
select
 dt.month_begin_date
 ,CASE
		WHEN pd.professional_id IS NOT NULL
			THEN 'Lawyer'
		ELSE 'Consumer/Other'
	END lawyer_vs_consumer
  ,rp.ActionType AS registration_path
, COUNT(pfrv.id) as num_reviews
from src.barrister_professional_review pfrv							
	join DM.professional_dimension pf on pf.professional_id = pfrv.professional_id		
	join dm.date_dim dt on dt.actual_date = to_date(pfrv.created_at)
		LEFT JOIN dm.professional_dimension pd
		On pfrv.created_by = CAST(pd.professional_user_account_id AS INT)
	LEFT JOIN register_path rp
		ON rp.user_id = pfrv.created_by
		AND rp.ActionRank = 1
	where pfrv.approval_status_id = 2							
		-- and pfrv.DEL_FLAG = 'N'						
		and pf.professional_delete_indicator = 'Not Deleted'						
		and pf.professional_name = 'lawyer'						
		and pf.industry_name = 'Legal'
  group by 1,2,3
)

, cnt_reviewers as
(
select
 dt.month_begin_date 
  ,CASE
		WHEN pd.professional_id IS NOT NULL
			THEN 'Lawyer'
		ELSE 'Consumer/Other'
	END lawyer_vs_consumer 
  ,rp.ActionType AS registration_path
, COUNT(distinct created_by) as num_reviewers
from src.barrister_professional_review pfrv							
	join DM.professional_dimension pf on pf.professional_id = pfrv.professional_id		
	join dm.date_dim dt on dt.actual_date = to_date(pfrv.created_at)
		LEFT JOIN dm.professional_dimension pd
		On pfrv.created_by = CAST(pd.professional_user_account_id AS INT)
	LEFT JOIN register_path rp
		ON rp.user_id = pfrv.created_by
		AND rp.ActionRank = 1
	where pfrv.approval_status_id = 2							
		-- and pfrv.DEL_FLAG = 'N'						
		and pf.professional_delete_indicator = 'Not Deleted'						
		and pf.professional_name = 'lawyer'						
		and pf.industry_name = 'Legal'
  group by 1,2,3
)


select 

uad.month_begin_date
, uad.lawyer_vs_consumer
,uad.registration_path
, sum(cnt_emailcontacts) as cnt_emailcontacts
, sum(cnt_webcontacts) as cnt_webcontacts
, sum(cnt_visit) as cnt_visit
, sum(num_users) as num_users
, sum(num_questions) as num_questions
, sum(num_askers) as num_askers
, sum(num_reviews) as num_reviews
, sum(num_reviewers) as num_reviewers
from  cnt_ru uad 
left join questions2 q on q.month_begin_date = uad.month_begin_date
AND q.lawyer_vs_consumer = uad.lawyer_vs_consumer
AND q.registration_path = uad.registration_path
left join cnt_visit v on v.month_begin_date = uad.month_begin_date
AND v.lawyer_vs_consumer = uad.lawyer_vs_consumer
AND v.registration_path = uad.registration_path
left join cnt_email em on em.month_begin_date = uad.month_begin_date
AND em.lawyer_vs_consumer = uad.lawyer_vs_consumer
AND em.registration_path = uad.registration_path
left join cnt_website wb on wb.month_begin_date = uad.month_begin_date
AND wb.lawyer_vs_consumer = uad.lawyer_vs_consumer
AND wb.registration_path = uad.registration_path
left join askers a on a.month_begin_date =  uad.month_begin_date
AND uad.lawyer_vs_consumer = a.lawyer_vs_consumer
AND q.registration_path = uad.registration_path
left join cnt_reviews rv on rv.month_begin_date =  uad.month_begin_date
AND rv.lawyer_vs_consumer = uad.lawyer_vs_consumer
AND rv.registration_path = uad.registration_path
left join cnt_reviewers rv2 on rv2.month_begin_date =  uad.month_begin_date
AND rv2.lawyer_vs_consumer = uad.lawyer_vs_consumer
AND rv2.registration_path = uad.registration_path
group by 1,2,3