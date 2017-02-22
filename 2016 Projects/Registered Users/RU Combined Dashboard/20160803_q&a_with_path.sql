with answertime as
(
	SELECT Q.ID as question_id
		, to_date(q.created_at) as question_date
		-- , D.YEAR||' Q'||D.QTR_NBR_IN_YEAR AS YEAR_QTR
        , round((min(unix_timestamp(A.created_at)-unix_timestamp(Q.created_at)))/60,0) as answertime_mins
	FROM src.content_question q
	-- JOIN DM.DATE_DIM D ON to_date(Q.created_at) = D.ACTUAL_DATE
	LEFT JOIN 
	(
		select distinct id as answer_id
			, created_at
			, question_id
		from src.content_answer 
		where approval_status_id in (1,2)
	) A ON Q.id=A.question_id
	WHERE to_date(q.created_at) >= '2013-01-01'
      and q.approval_status_id in (1,2)
	group by 1,2
)

, questions2 as
(
	select distinct q.id as question_id
		, sd.specialty_name as specialty
		, sd.parent_specialty_name as parent_specialty
		, a.id as answer_id
		, q.created_by as asker
		, p.professional_id
		, to_date(a.created_at) as answer_date
		, dd.year_month as answer_year_month
		, to_date(q.created_at) as question_date
		, dd1.year_month as question_year_month
	from src.content_question q
	left join dm.specialty_dimension sd on sd.specialty_id = q.specialty_id
	LEFT JOIN 
	(
		select distinct id 
			, created_at
			, created_by
			, question_id
		from src.content_answer 
		where approval_status_id in (1,2)
	) A ON Q.id=A.question_id
	left join dm.professional_dimension p on p.professional_user_account_id = cast(a.created_by as string)
	left join dm.date_dim dd on to_date(dd.actual_date)=to_date(a.created_at)
	left join dm.date_dim dd1 on to_date(dd1.actual_date)=to_date(q.created_at)
	where to_date(q.created_at) >= '2013-01-01' 
       and q.approval_status_id in (1,2)
)

, returned_asker as
(
	select x1.asker
	from
	(
		select distinct x.asker
		from questions2 x
		join
		(
		   select distinct d.year_month     
		   from DM.DATE_DIM d
		   where d.actual_date = to_date(now()- interval 1 month)
		) dt on dt.year_month = x.question_year_month
	) x1
	left join
	(
		select distinct x.asker
		from questions2 x
		join
		(
		   select distinct d.year_month     
		   from DM.DATE_DIM d
		   where d.actual_date <= to_date(now()- interval 2 month)
			and d.actual_date >= to_date(now()- interval 4 month)
		) dt on dt.year_month = x.question_year_month
	) x2 on x1.asker = x2.asker
	left join
	(
		select distinct x.asker
		from questions2 x
		join
		(
		   select distinct d.year_month     
		   from DM.DATE_DIM d
		   where d.actual_date < to_date(now()- interval 4 month)
		) dt on dt.year_month = x.question_year_month
	) x3 on x1.asker = x3.asker
	where x2.asker is null and x3.asker is not null
)

,

UID_2_PID AS (

SELECT DISTINCT ua.user_account_id AS user_id
	,ua.user_account_register_datetime reg_date
	,t.persistent_session_id ps_id
	,from_unixtime(unix_timestamp(cast(ua.user_account_register_datetime as timestamp) - interval 1 days), 'yyyy-MM-dd HH:mm:ss') WindowStart
	,from_unixtime(unix_timestamp(cast(ua.user_account_register_datetime as timestamp) + interval 30 days), 'yyyy-MM-dd HH:mm:ss') WindowEnd
 from dm.user_account_dimension ua
 LEFT JOIN dm.traffic t
 ON ua.user_account_id = CAST(t.resolved_user_id aS INT)
WHERE ua.user_account_register_datetime >= '2011-01-01'
 
 )
 

/* start of emails section*/

,PA1 AS (
SELECT pfsp.PROFESSIONAL_ID
          ,sp.PARENT_SPECIALTY_NAME                  
		  ,SUM(pfsp.SPECIALTY_PERCENT) parent_pa_percent
                     FROM DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp
                       JOIN DM.SPECIALTY_DIMENSION sp ON sp.SPECIALTY_ID = pfsp.SPECIALTY_ID
                     WHERE pfsp.DELETE_FLAG = 'N' --AND pfsp.professional_Id < 1000
					 GROUP BY 1,2)

,

PA2 AS (SELECT p.professional_id
,p.parent_specialty_name
,parent_pa_percent
,ROW_NUMBER() OVER (PARTITION BY p.PROFESSIONAL_ID ORDER BY p.parent_pa_percent DESC) ppa_rank
FROM PA1 p

)

,

PA3 AS (
SELECT x.PROFESSIONAL_ID
		,MIN(CASE WHEN x.ppa_rank = 1 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea1
		,MIN(CASE WHEN x.ppa_rank = 2 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea2
		,MIN(CASE WHEN x.ppa_rank = 3 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea3		
FROM PA2 x
GROUP BY 1
			   
)

,

emails AS (
select 
	CAST(ci.user_id AS INT) user_id
	,'Email' AS ActionType
	,CASE
			WHEN pa.ParentPracticeArea1 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea1
			WHEN pa.ParentPracticeArea2 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea2
			WHEN pa.ParentPracticeArea3 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea3
			ELSE pa.ParentPracticeArea1
		END ParentPA
	,min(CASE 
		WHEN from_unixtime(ci.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss') BETWEEN up.WindowStart AND up.WindowEnd
			THEN from_unixtime(ci.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss')
		ELSE NULL
	END) FirstAction
from src.contact_impression ci
JOIN UID_2_PID up
	ON up.ps_id = ci.persistent_session_id
AND ci.contact_type = 'email'
LEFT JOIN PA3 pa
	ON pa.professional_id = ci.professional_id

group by 1,2,3
  
 )
 
 ,
 
 review AS (select 
ci.created_by user_id
	,'Review' AS ActionType
	,CASE
			WHEN pa.ParentPracticeArea1 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea1
			WHEN pa.ParentPracticeArea2 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea2
			WHEN pa.ParentPracticeArea3 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea3
			ELSE pa.ParentPracticeArea1
		END ParentPA
,min(CASE 
		WHEN ci.created_at BETWEEN up.WindowStart AND up.WindowEnd
			THEN ci.created_at
		ELSE NULL
	END) FirstAction
from src.barrister_professional_review ci
JOIN UID_2_PID up
	ON up.user_id = ci.created_by
left join PA3 pa
	ON pa.professional_id = ci.professional_id

group by 1,2,3

)

,

questions as
(
	select q.created_by AS user_id
	,'Ask a Question' as ActionType
	,sd.parent_specialty_name ParentPA
		,MIN(CASE 
		WHEN q.created_at BETWEEN up.WindowStart AND up.WindowEnd
			THEN q.created_at
		ELSE NULL
	END) as FirstAction
	from src.content_question q
	JOIN UID_2_PID up
	ON up.user_id = q.created_by
	left join dm.specialty_dimension sd on sd.specialty_id = q.specialty_id
	where q.approval_status_id in (1,2)
	   AND (q.created_by <> 1 OR q.updated_by <> 1)
	GROUP BY 1,2,3
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
		,sd.parent_specialty_name ParentPA
		,min(CASE 
		WHEN a.transaction_time BETWEEN up.WindowStart AND up.WindowEnd
			THEN a.transaction_time
		ELSE NULL
	END) FirstAction
	FROM als_transactions a
		JOIN UID_2_PID up
			ON up.ps_id = a.persistent_session_id
	left join src.ocato_advice_sessions oas 
		on cast(a.order_id as INT) = oas.id 
	left join dm.specialty_dimension sd 
		on sd.specialty_id = oas.specialty_id
	GROUP BY 1,2,3
	
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

SELECT *
,ROW_NUMBER() OVER(PARTITION BY a.user_id ORDER BY a.FirstAction) ActionRank
FROM activities a
WHERE a.firstaction IS NOT NULL

)

select qs.question_id
	, qs.specialty as question_specialty
	, qs.parent_specialty as question_parent_specialty
	, qs.answer_id
	, qs.professional_id
	, qs.asker
	, case when ra.asker is null then "N" else "Y" end as asker_returned_3month_later
	, qs.answer_date
	, qs.question_date
	, qs.answer_year_month
	, qs.question_year_month
	, ast.answertime_mins
        , to_date(uad.user_account_register_datetime) as user_account_register_datetime
        , dt.year_month as registration_year_month
		,CASE
		WHEN pd.professional_id IS NOT NULL
			THEN 'Lawyer'
		ELSE 'Consumer/Other'
	END lawyer_vs_consumer
	,COALESCE(r.ActionType, 'Other/Unknown') registration_path
	,COALESCE(r.ParentPA, 'Other/Unknown') AS parent_pa_registration
	,CASE
		WHEN r.ParentPA IN ('Family', 'Business', 'Real Estate', 'Immigration', 'Estate Planning')
			THEN r.ParentPA
		ELSE 'Other/Unknown'
END AS ParentPA_Group_registration
from questions2 qs 
	left join answertime ast 
		on ast.question_id = qs.question_id
	left join returned_asker ra 
		on qs.asker = ra.asker
	left join dm.user_account_dimension uad 
		on uad.user_account_id = qs.asker
	join dm.date_dim dt 
		on to_date(dt.actual_date)=to_date(uad.user_account_register_datetime)
	LEFT JOIN dm.professional_dimension pd
		On uad.user_account_id = CAST(pd.professional_user_account_id AS INT)
	LEFT JOIN register_path r
		ON r.user_id = qs.asker
		AND r.ActionRank = 1		