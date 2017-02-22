
/* get all ALS transactions and characterize them */

/* Steps:

1. Identify als transactions and PIDs
2. Identify eligible users and PIDs; get total sessions
3. 

*/
WITH eligible_users AS (
  SELECT persistent_session_id
  ,resolved_user_id
  ,lawyer_user_id
  ,MIN(t.gmt_timestamp) first_visit_timestamp
  ,COUNT(session_id) total_sessions
FROM dm.traffic t
WHERE event_date >= '2016-02-08' -- checked with Mira
  GROUP BY 1,2,3
HAVING COUNT(session_id) >= 2
-- use row number and check for duplicates with null/populated user id

)

, users_detail AS (
SELECT eu.*
,t.lpv_page_type
,t.lpv_medium
,dc.device_category_name
,COUNT(CASE
		WHEN pv.page_type IN ('Attorney_Directory_Browse', 'Attorney_Search')
			THEN pv.render_instance_guid
		ELSE NULL
	END) Lawyer_SERP_Count
,COUNT(CASE
		WHEN pv.page_type = 'Topics'
			THEN pv.render_instance_guid
		ELSE NULL
	END) Topics_Pageviews_Count
,COUNT(CASE
		WHEN pv.page_type IN ('Attorney_Profile'
			,'Attorney_Profile_Aboutme'
			,'Attorney_Profile_Contact'
			,'Attorney_Profile_Endorsement'
			,'Attorney_Profile_Review'
			,'Attorney_Review')
			THEN pv.render_instance_guid
		ELSE NULL
	END) Profile_Pageviews_Count		
'LS-Checkout'
,'Advisor-checkout'
,',Advisor-homepage'
,'Advisor-specialty'
,'LS-Home'
,'LS-Package-Details'
,'LS-Storefront'
,'LS-Thankyou'
,'LS-Package-Details-Attorney-View'
)
			THEN pv.render_instance_guid
		ELSE NULL
	END) ALS_Pageviews_Count	
,COUNT(pv.render_instance_guid) Total_Pageviews_Count
,SUM(CASE
			WHEN sd.parent_specialty_name = 'Real Estate'
				THEN 1
			ELSE 0
		END) Real_Estate_Pageviews
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Emplyoment & Labor'
				THEN 1
			ELSE 0
		END) Employment_and_Labor_Pageviews
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Business'
				THEN 1
			ELSE 0
		END) Business_Pageviews
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Immigration'
				THEN 1
			ELSE 0
		END) Immigration_Pageviews
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Unknown'
				THEN 1
			ELSE 0
		END) Unknown_PA_Pageviews
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Criminal Defense'
				THEN 1
			ELSE 0
		END) Criminal_Defense_Pageviews
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Estate Planning'
				THEN 1
			ELSE 0
		END) Estate_Planning_Pageviews
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Family'
				THEN 1
			ELSE 0
		END) Family_Pageviews
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Bankruptcy & Debt'
				THEN 1
			ELSE 0
		END) Bankruptcy_&_Debt_Pageviews
	,SUM(CASE
			WHEN sd.parent_specialty_name NOT IN ('Bankruptcy & Debt', 'Family', 'Estate Planning', 'Criminal Defense', 'Unknown', 'Immigration', 'Business', 'Employment & Labor', 'Real Estate')
				THEN 1
			ELSE 0
		END) Other_PA_Pageviews
FROM eligible_users eu
JOIN dm.traffic t
ON t.persistent_sesion_id = eu.persistent_session_id
AND t.gmt_timestamp = eu.first_visit_timestamp
LEFT JOIN dm.device_category_dim dc
	ON dc.device_category_id = t.lpv_device_category_id
LEFT JOIN src.page_view pv
	ON pv.persistent_session_id = eu.persistent_session_id
WHERE pv.campaign NOT IN ('sgt', 'Network') OR pv.campaign IS NULL
	
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

,PA4 AS (SELECT x.professional_id
,CASE
			WHEN pa.ParentPracticeArea1 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea1
			WHEN pa.ParentPracticeArea2 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea2
			WHEN pa.ParentPracticeArea3 <> 'General Practice' AND pa.ParentPracticeArea1 IS NOT NULL
				THEN pa.ParentPracticeArea3
			ELSE pa.ParentPracticeArea1
		END ParentPA)
FROM PA3

,

emails AS (
select 
	CAST(ci.user_id AS INT) user_id
	,ci.persistent_session_id 
	,ParentPA
	,COUNT(render_instance_guid) EmailCount
	,MIN(event_date) FirstWebsiteClick
	,MAX(event_date) LastWebsiteClick	
from src.contact_impression ci
LEFT JOIN PA4 pa
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
	,ParentPA
	,COUNT(render_instance_guid) WebsiteClickCount
	,MIN(event_date) FirstWebsiteClick
	,MAX(event_date) LastWebsiteClick
from src.contact_impression ci
LEFT JOIN PA4 pa
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
	,ParentPA
,COUNT(ci.created_at) ReviewCount
,MIN(ci.created_at) FirstReview
,MAX(ci.created_at) LastReview
from src.barrister_professional_review ci
left join PA4 pa
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

,

 als_transactions AS (
	select DISTINCT persistent_session_id
	,sd.parent_specialty_name AS ALS_ParentPA
	,MIN(w.event_date) first_purchase
	,SUM(CASE 
		WHEN op.name LIKE '%advice session%'
			THEN 1
		ELSE 0
	END) Advice_Purchases
	,SUM(CASE 
		WHEN op.name LIKE '%review%'
			THEN 1
		ELSE 0
	END) Doc_Review_Purchases
	,SUM(CASE 
		WHEN op.name LIKE '%review%'
			THEN 0
		WHEN op.name LIKE '%advice session%'
			THEN 0
		WHEN op.name IS NOT NULL
			THEN 1
		ELSE 0
	END) Other_Offline_Purchases
	,MIN(als.event_date) First_Purchase_Date
	,MAX(als.event_date) Last_Purchase_Date
	,COUNT(als.order_id) Total_Purchases
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Real Estate'
				THEN 1
			ELSE 0
		END) Real_Estate_Purchases
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Emplyoment & Labor'
				THEN 1
			ELSE 0
		END) Employment_and_Labor_Purchases
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Business'
				THEN 1
			ELSE 0
		END) Business_Purchases
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Immigration'
				THEN 1
			ELSE 0
		END) Immigration_Purchases
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Unknown'
				THEN 1
			ELSE 0
		END) Unknown_PA_Purchases	
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Criminal Defense'
				THEN 1
			ELSE 0
		END) Criminal_Defense_Purchases
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Estate Planning'
				THEN 1
			ELSE 0
		END) Estate_Planning_Purchases
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Family'
				THEN 1
			ELSE 0
		END) Family_Purchases
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Bankruptcy & Debt'
				THEN 1
			ELSE 0
		END) Bankruptcy_&_Debt_Purchases
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
left join dm.specialty_dimension sd 
		on sd.specialty_id = oas.specialty_id
GROUP BY 
  
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