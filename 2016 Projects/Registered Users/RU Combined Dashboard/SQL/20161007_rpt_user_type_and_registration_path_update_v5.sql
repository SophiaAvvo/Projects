WITH UID_2_PID AS (

SELECT DISTINCT ua.user_account_id AS user_id
	,ua.user_account_register_datetime reg_date
	,t.persistent_session_id ps_id
	,from_unixtime(unix_timestamp(cast(ua.user_account_register_datetime as timestamp) - interval 1 days), 'yyyy-MM-dd HH:mm:ss') WindowStart
	,from_unixtime(unix_timestamp(cast(ua.user_account_register_datetime as timestamp) + interval 30 days), 'yyyy-MM-dd HH:mm:ss') WindowEnd
 from dm.user_account_dimension ua
 LEFT JOIN dm.traffic t
 ON ua.user_account_id = CAST(t.resolved_user_id aS INT)
-- WHERE ua.user_account_register_datetime >= '2011-01-01'
 
 )
 

/* start of emails section*/

,PA1 AS (
SELECT pfsp.PROFESSIONAL_ID
          ,sp.PARENT_SPECIALTY_NAME                  
		  ,SUM(pfsp.SPECIALTY_PERCENT) parent_pa_percent
                     FROM DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp
                       JOIN DM.SPECIALTY_DIMENSION sp ON sp.SPECIALTY_ID = pfsp.SPECIALTY_ID
                     WHERE pfsp.DELETE_FLAG = 'N' --AND pfsp.professional_Id < 1000
					 GROUP BY pfsp.PROFESSIONAL_ID
          ,sp.PARENT_SPECIALTY_NAME)

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
GROUP BY x.PROFESSIONAL_ID
			   
)

,PA4 AS (SELECT pa.professional_id
,CASE
			WHEN pa.ParentPracticeArea1 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea1
			WHEN pa.ParentPracticeArea2 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea2
			WHEN pa.ParentPracticeArea3 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea3
			ELSE pa.ParentPracticeArea1
		END ParentPA
FROM PA3 pa

)

,

emails AS (
select 
	CAST(ci.user_id AS INT) user_id
	,'Email' AS ActionType
	,pa.ParentPA
	,min(from_unixtime(ci.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss')) FirstAction
from src.contact_impression ci
JOIN UID_2_PID up
	ON up.user_id = CAST(ci.user_id AS INT)
	AND from_unixtime(ci.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss') BETWEEN up.WindowStart AND up.WindowEnd
AND ci.contact_type IN ('email', 'message')
LEFT JOIN PA4 pa
	ON pa.professional_id = ci.professional_id

group by CAST(ci.user_id AS INT) 
	,'Email'
	,pa.ParentPA
  
 )
 
 ,
 
 review AS (select 
ci.created_by AS user_id
	,'Review' AS ActionType
	,pa.ParentPA
,min(ci.created_at) AS FirstAction
from src.barrister_professional_review ci
JOIN UID_2_PID up
	ON up.user_id = ci.created_by
	AND ci.created_at BETWEEN up.WindowStart AND up.WindowEnd
left join PA4 pa
	ON pa.professional_id = ci.professional_id

group by ci.created_by
	,'Review'
	,pa.ParentPA

)

,

questions as
(
	select q.created_by AS user_id
	,'Ask a Question' as ActionType
	,sd.parent_specialty_name AS ParentPA
	,MIN(q.created_at) as FirstAction
	from src.content_question q
	JOIN UID_2_PID up
		ON up.user_id = q.created_by
		AND q.created_at BETWEEN up.WindowStart AND up.WindowEnd
	left join dm.specialty_dimension sd 
		on sd.specialty_id = q.specialty_id
	where q.approval_status_id in (1,2)
	   AND (q.created_by <> 1 OR q.updated_by <> 1)
	GROUP BY q.created_by
	,'Ask a Question'
	,sd.parent_specialty_name
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
		,min(a.transaction_time) FirstAction
	FROM als_transactions a
		JOIN UID_2_PID up
			ON up.ps_id = a.persistent_session_id
			AND a.transaction_time BETWEEN up.WindowStart AND up.WindowEnd
	left join src.ocato_advice_sessions oas 
		on cast(a.order_id as INT) = oas.id 
	left join dm.specialty_dimension sd 
		on sd.specialty_id = oas.specialty_id
	GROUP BY up.user_id
		,'ALS Purchase'
		,sd.parent_specialty_name
	
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
,ROW_NUMBER() OVER(PARTITION BY a.user_id ORDER BY a.FirstAction) AS ActionRank
FROM activities a
WHERE a.firstaction IS NOT NULL

)

SELECT uad.user_account_id AS user_id
,COALESCE(r.ActionType, 'Other/Unknown') AS registration_path
,COALESCE(r.ParentPA, 'Other/Unknown') AS registration_parent_pa
,COALESCE(r.FirstAction, 'Other/Unknown') AS registration_action_datetime
,CASE
	WHEN r.ParentPA IN ('Family', 'Business', 'Real Estate', 'Immigration', 'Estate Planning')
		THEN r.ParentPA
	ELSE 'Other/Unknown'
END AS registration_parent_pa_group
,CASE
	WHEN pd.professional_id IS NOT NULL
		THEN 'Lawyer'
	ELSE 'Consumer'
END lawyer_vs_consumer
,uad.user_account_register_datetime
FROM dm.user_account_dimension uad
LEFT JOIN register_path r
	ON r.user_id = uad.user_account_id
AND r.ActionRank = 1
LEFT JOIN dm.professional_dimension pd
		On uad.user_account_id = CAST(pd.professional_user_account_id AS INT)
WHERE uad.user_account_id <> -1
