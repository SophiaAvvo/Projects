
/* get all ALS transactions and characterize them */

/* Steps:

1. Identify als transactions and PIDs
2. Identify eligible users and PIDs; get total sessions
3. 

*/
WITH als_transactions AS (
	select DISTINCT persistent_session_id
	,MIN(w.event_date) first_purchase
	,SUM(CASE 
		WHEN op.name LIKE '%advice session%' AND fv.first_visit_timestamp < als.`timestamp`
			THEN 1
		ELSE 0
	END) Advice_Purchases
	,SUM(CASE 
		WHEN op.name LIKE '%review%' AND fv.first_visit_timestamp < als.`timestamp`
			THEN 1
		ELSE 0
	END) Doc_Review_Purchases
	,SUM(CASE 
		WHEN op.name LIKE '%review%'
			THEN 0
		WHEN op.name LIKE '%advice session%'
			THEN 0
		WHEN op.name IS NOT NULL AND fv.first_visit_timestamp < als.`timestamp`
			THEN 1
		ELSE 0
	END) Other_Offline_Purchases
	,MIN(als.event_date) First_Purchase_Date
	,MAX(als.event_date) Last_Purchase_Date
	,COUNT(als.order_id) Total_Purchases
		--,regexp_extract(url, 'thank_you\/([0-9]+)', 1) as order_id
from src.page_view  pv
	left join src.ocato_advice_sessions oas 
	on cast(regexp_extract(url, 'thank_you\/([0-9]+)', 1) as INT) = oas.id 
left join src.ocato_offers oo 
	on oas.offer_id = oo.id 
left join src.ocato_packages op 
	on oo.package_id = op.id
	where page_type = 'LS-Thankyou' 
	and event_date >= '2016-02-08'
  
)

,eligible_users AS (
  SELECT persistent_session_id
  ,resolved_user_id
  ,lawyer_user_id
  ,COUNT(session_id) total_sessions
FROM dm.traffic
WHERE event_date >= '2016-02-08' -- checked with Mira
  GROUP BY 1,2,3
HAVING COUNT(session_id) >= 2
-- use row number and check for duplicates with null/populated user id

)

,

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
	,ci.persistent_session_id 
	,CASE
			WHEN pa.ParentPracticeArea1 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea1
			WHEN pa.ParentPracticeArea2 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea2
			WHEN pa.ParentPracticeArea3 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea3
			ELSE pa.ParentPracticeArea1
		END ParentPA
	,COUNT(render_instance_guid) EmailCount
	,MIN(event_date) FirstWebsiteClick
	,MAX(event_date) LastWebsiteClick	
from src.contact_impression ci
LEFT JOIN PA3 pa
	ON pa.professional_id = ci.professional_id
WHERE ci.contact_type = 'email'
AND ci.event_date >= '2016-02-08'
group by 1,2,3
  
 )
 
,
 
website AS (
select 
	CAST(ci.user_id AS INT) user_id
	,ci.persistent_session_id 
	,CASE
			WHEN pa.ParentPracticeArea1 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea1
			WHEN pa.ParentPracticeArea2 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea2
			WHEN pa.ParentPracticeArea3 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea3
			ELSE pa.ParentPracticeArea1
		END ParentPA
	,COUNT(render_instance_guid) WebsiteClickCount
	,MIN(event_date) FirstWebsiteClick
	,MAX(event_date) LastWebsiteClick
from src.contact_impression ci
LEFT JOIN PA3 pa
	ON pa.professional_id = ci.professional_id
WHERE ci.contact_type = 'email'
AND ci.event_date >= '2016-02-08'
group by 1,2,3
  
)

,
 
 review AS (
 select 
ci.created_by AS user_id
,ci.persistent_session_id
	,CASE
			WHEN pa.ParentPracticeArea1 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea1
			WHEN pa.ParentPracticeArea2 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea2
			WHEN pa.ParentPracticeArea3 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea3
			ELSE pa.ParentPracticeArea1
		END ParentPA
,COUNT(ci.created_at) ReviewCount
,MIN(ci.created_at) FirstReview
,MAX(ci.created_at) LastReview
from src.barrister_professional_review ci
left join PA3 pa
	ON pa.professional_id = ci.professional_id
WHERE ci.event_date >= '2016-02-08'
group by 1,2,3

)

,

questions as
(
	select q.created_by AS user_id
	,'Ask a Question' as ActionType
	,sd.parent_specialty_name AS QA_ParentPA
	COUNT(q.id) QuestionCount
	,MIN(to_date(q.created_at)) as FirstQuestion
	,MAX(to_date(q.created_at)) as LastQuestion
	from src.content_question q
	left join dm.specialty_dimension sd 
		on sd.specialty_id = q.specialty_id
	where q.approval_status_id in (1,2)
	   AND (q.created_by <> 1 OR q.updated_by <> 1)
	GROUP BY 1,2,3
)


SELECT eu.*
,als.first_purchase
,als.advice_purchases
,als.doc_review_purchases
,als.other_offline_purchases
,als.total_purchases
,als.first_purchase_date
,als.last_purchase_date
,q.QuestionCount
,q.QA_ParentPA
,q.FirstQuestion
,q.LastQuestion
FROM eligible_users eu
LEFT JOIN als_transactions als
ON als.persistent_session_id = eu.persistent_session_id
LEFT JOIN 