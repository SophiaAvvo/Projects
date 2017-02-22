/* get all ALS transactions and characterize them

Steps:

1. Identify als transactions and PIDs
2. Identify eligible users and PIDs; get total sessions
3. If tables have PID, join directly; if not, attribute to the "nearest" PID in time, and join after deduping
4. Get practice area for ALS and PVs, but not for other actions (Mira)

*/	
WITH eligible_users AS (
 SELECT persistent_session_id
  ,session_id
  ,resolved_user_id
  ,event_date
  ,COUNT(session_id) OVER(PARTITION BY persistent_session_id) total_sessions_count
  ,ROW_NUMBER() OVER(PARTITION BY persistent_session_id ORDER BY event_date, session_id) Num 
FROM dm.traffic t
WHERE event_date >= '2016-02-08' -- checked with Mira
--AND CAST(resolved_user_id aS INT) < 10000
AND lawyer_user_id = false
-- used row number and checked for duplicates with null/populated user id... all looks good

)

, users_detail AS (
SELECT eu.persistent_session_id
,eu.resolved_user_id
,eu.total_sessions_count
,t.lpv_page_type
,t.lpv_medium
,dc.device_category_name
,COUNT(CASE
		WHEN pv.page_type IN ('Attorney_Directory_Browse', 'Attorney_Search')
			THEN pv.render_instance_guid
		ELSE NULL
	END) Lawyer_SERP_PV_Count
,COUNT(CASE
		WHEN pv.page_type = 'Topics'
			THEN pv.render_instance_guid
		ELSE NULL
	END) Topics_PV_Count
,COUNT(CASE
		WHEN pv.page_type IN ('Attorney_Profile'
			,'Attorney_Profile_Aboutme'
			,'Attorney_Profile_Contact'
			,'Attorney_Profile_Endorsement'
			,'Attorney_Profile_Review'
			,'Attorney_Review')
			THEN pv.render_instance_guid
		ELSE NULL
	END) Profile_PV_Count		
,COUNT(CASE
		WHEN pv.page_type IN (
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
	END) ALS_PV_Count	
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
		END) Bankruptcy_and_Debt_Pageviews
	,SUM(CASE
			WHEN sd.parent_specialty_name NOT IN ('Bankruptcy & Debt', 'Family', 'Estate Planning', 'Criminal Defense', 'Unknown', 'Immigration', 'Business', 'Employment & Labor', 'Real Estate')
				THEN 1
			ELSE 0
		END) Other_PA_Pageviews
FROM eligible_users eu
JOIN dm.traffic t
ON t.persistent_session_id = eu.persistent_session_id
AND t.session_id = eu.session_id
AND Num = 1
LEFT JOIN dm.device_category_dim dc
	ON dc.device_category_id = t.lpv_device_category_id
LEFT JOIN src.page_view pv
	ON pv.persistent_session_id = eu.persistent_session_id
left join dm.specialty_dimension sd 
		on sd.specialty_id = pv.specialty_id
WHERE pv.campaign NOT IN ('sgt', 'Network') OR pv.campaign IS NULL
GROUP BY 1,2,3,4,5,6
)

,

PA1 AS (
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
	,ci.persistent_session_id 
	-- ,ParentPA
	,COUNT(render_instance_guid) EmailCount
	,MIN(event_date) FirstEmail
	,MAX(event_date) LastEmail	
from src.contact_impression ci
/*LEFT JOIN PA4 pa
	ON pa.professional_id = ci.professional_id */
WHERE ci.contact_type = 'email'
-- AND ci.event_date >= '2016-02-08'
group by 1,2-- ,3
  
 )
 
,
 
website AS (
select 
	CAST(ci.user_id AS INT) user_id
	,ci.persistent_session_id 
	-- ,ParentPA
	,COUNT(render_instance_guid) WebsiteClickCount
	,MIN(event_date) FirstWebsiteClick
	,MAX(event_date) LastWebsiteClick
from src.contact_impression ci
/* LEFT JOIN PA4 pa
	ON pa.professional_id = ci.professional_id */
WHERE ci.contact_type = 'email'
-- AND ci.event_date >= '2016-02-08'
group by 1,2--,3
  
)

,

 review1 AS (
 select 
ci.created_by AS user_id
,created_at
,eu.persistent_session_id
,ci.id
-- ,ci.professional_id
,ABS(DATEDIFF(eu.event_date, ci.created_at)) Diff
from src.barrister_professional_review ci
JOIN eligible_users eu
	ON ci.created_by = CAST(eu.resolved_User_id AS INT)
-- WHERE ci.created_at >= '2016-02-08'
 	
	
)

,

review2 AS (
SELECT *
,ROW_NUMBER() OVER(PARTITION BY persistent_session_id ORDER BY Diff) MinDaysDiff
FROM review1

)

,
 
 review3 AS (
 select r.user_id
,r.persistent_session_id
,COUNT(DISTINCT r.id) ReviewCount
,MIN(r.created_at) FirstReview
,MAX(r.created_at) LastReview
from review2 r
WHERE mindaysdiff = 1
group by 1,2--,3

)

,

questions1 as

(

SELECT q.created_by AS user_id
,q.created_at
,q.id
,eu.persistent_session_id
,ABS(DATEDIFF(eu.event_date, q.created_at)) Diff
FROM src.content_question q
JOIN eligible_users eu
	ON q.created_by = CAST(eu.resolved_User_id AS INT)
	where q.approval_status_id in (1,2)
	   AND (q.created_by <> 1 OR q.updated_by <> 1)
	
)

,questions2 AS (

SELECT *
,ROW_NUMBER() OVER(PARTITION BY persistent_session_id ORDER BY Diff) MinDaysDiff
FROM questions1

)

,

questions3 AS 
(
	select q.user_id
	,q.persistent_session_id
	-- ,sd.parent_specialty_name AS QA_ParentPA
	,COUNT(DISTINCT q.id) QuestionCount
	,MIN(to_date(q.created_at)) as FirstQuestion
	,MAX(to_date(q.created_at)) as LastQuestion
	from questions2 q
	GROUP BY 1,2

)

,

first_als_transaction AS (
SELECT pv.persistent_session_id
,op.name First_Purchase_Name
,CASE
	WHEN op.name LIKE '%advice session%'
		THEN 'Advisor'
	WHEN op.name LIKE '%review%'
		THEN 'Doc Review'
	ELSE 'Offline'
END First_Purchase_Type
,sd.parent_specialty_name AS First_Purchase_PA
,ROW_NUMBER() OVER(PARTITION BY persistent_session_id ORDER BY gmt_timestamp) Num
from src.page_view  pv
	left join src.ocato_advice_sessions oas 
	on cast(regexp_extract(url, 'thank_you\/([0-9]+)', 1) as INT) = oas.id 
left join src.ocato_offers oo 
	on oas.offer_id = oo.id 
left join src.ocato_packages op 
	on oo.package_id = op.id
left join dm.specialty_dimension sd 
		on sd.specialty_id = oas.specialty_id
where page_type = 'LS-Thankyou' 
	and event_date >= '2016-02-08'
	
)

,

 als_transactions AS (
	select pv.persistent_session_id
	,fp.first_purchase_name
	,fp.first_purchase_type
	,fp.first_purchase_pa
	-- ,sd.parent_specialty_name AS ALS_ParentPA
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
	,MIN(pv.event_date) First_Purchase_Date
	,MAX(pv.event_date) Last_Purchase_Date
	,COUNT(oas.id) Total_Purchases
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
		END) Bankruptcy_and_Debt_Purchases
		--,regexp_extract(url, 'thank_you\/([0-9]+)', 1) as order_id
from src.page_view  pv
LEFT JOIN first_als_transaction fp
	ON fp.persistent_session_id = pv.persistent_session_id
	AND fp.Num = 1
	left join src.ocato_advice_sessions oas 
	on cast(regexp_extract(url, 'thank_you\/([0-9]+)', 1) as INT) = oas.id 
left join src.ocato_offers oo 
	on oas.offer_id = oo.id 
left join src.ocato_packages op 
	on oo.package_id = op.id
left join dm.specialty_dimension sd 
		on sd.specialty_id = oas.specialty_id
where page_type = 'LS-Thankyou' 
	and event_date >= '2016-02-08'
GROUP BY 1,2,3,4
  
)


SELECT ud.*
,CASE
	WHEN ud.resolved_user_id IS NOT NULL
		THEN 1
	ELSE 0
END IsRegisteredUser
,CASE
	WHEN ud.resolved_user_id IS NOT NULL
		THEN 'Core'
	WHEN ud.Lawyer_SERP_PV_Count + Profile_PV_Count + ALS_PV_Count >= 1
		THEN 'Core'
	ELSE 'Casual'
END Casual_vs_Core
,CASE
	WHEN ud.resolved_user_id IS NOT NULL
		THEN 1
	WHEN ud.Lawyer_SERP_PV_Count + Profile_PV_Count + ALS_PV_Count >= 1
		THEN 1
	ELSE 0
END IsCore
,CASE
	WHEN ud.resolved_user_id IS NOT NULL
		THEN 0
	WHEN ud.Lawyer_SERP_PV_Count + Profile_PV_Count + ALS_PV_Count >= 1
		THEN 0
	ELSE 1
END IsCasual
,CASE
	WHEN als.total_purchases IS NOT NULL
		THEN 'ALS Customer'
	ELSE 'Control'
END Customer_vs_Control
,CASE
	WHEN als.total_purchases IS NOT NULL
		THEN 'ALS Customer'
	WHEN ud.resolved_user_id IS NOT NULL
		THEN 'Core - Non-Customer'
	WHEN ud.Lawyer_SERP_PV_Count + Profile_PV_Count + ALS_PV_Count >= 1
		THEN 'Core - Non-Customer'
	ELSE 'Casual - Non-Customer'
END Cohort_Pie
,CASE
	WHEN als.total_purchases IS NOT NULL
		THEN 1
	ELSE 0
END IsALSCustomer
,CASE
	WHEN als.total_purchases IS NULL
		THEN 0
	ELSE 1
END IsControlGroup
,als.advice_purchases
,als.doc_review_purchases
,als.other_offline_purchases
,als.total_purchases
,als.first_purchase_date
,als.last_purchase_date
,als.first_purchase_type
,als.first_purchase_pa
,als.first_purchase_name
,Real_Estate_Purchases
,Employment_and_Labor_Purchases
	,Business_Purchases
	,Immigration_Purchases
	,Unknown_PA_Purchases	
	,Criminal_Defense_Purchases
	,Estate_Planning_Purchases
	,Family_Purchases
	,Bankruptcy_and_Debt_Purchases
,q.QuestionCount
,q.FirstQuestion
,q.LastQuestion
,CASE
	WHEN q.FirstQuestion < als.first_purchase_date
		THEN 'Q&A Before ALS Purchase'
	WHEN q.FirstQuestion >= als.first_purchase_date
		THEN 'Q&A After ALS Purchase'
	WHEN q.FirstQuestion IS NULL
		THEN 'No Question Asked'
END First_Question_Timing
,e.EmailCount
,e.FirstEmail
,e.LastEmail
,CASE
	WHEN e.FirstEmail < als.first_purchase_date
		THEN 'Emailed Before ALS Purchase'
	WHEN e.FirstEmail >= als.first_purchase_date
		THEN 'Emailed After ALS Purchase'
	WHEN e.FirstEmail IS NULL
		THEN 'No Email'
END First_Email_Timing
,w.WebsiteClickCount
,w.FirstWebsiteClick
,w.LastWebsiteClick
,CASE
	WHEN w.FirstWebsiteClick < als.first_purchase_date
		THEN 'Clicked Before ALS Purchase'
	WHEN w.FirstWebsiteClick >= als.first_purchase_date
		THEN 'Clicked After ALS Purchase'
	WHEN w.FirstWebsiteClick IS NULL
		THEN 'No Website Clicks'
END First_Website_Click_Timing
,r.ReviewCount
,r.FirstReview
,r.LastReview
,CASE
	WHEN r.FirstReview < als.first_purchase_date
		THEN 'Reviewed Before ALS Purchase'
	WHEN r.FirstReview >= als.first_purchase_date
		THEN 'Reviewed After ALS Purchase'
	WHEN r.FirstReview IS NULL
		THEN 'No Reviews'
END First_Review_Timing
,CASE
	WHEN r.LastReview >= als.first_purchase_date
		THEN 'Still Active'
	WHEN e.LastEmail >= als.first_purchase_date
		THEN 'Still Active'
	WHEN w.LastWebsiteClick >= als.first_purchase_date
		THEN 'Still Active'
	WHEN q.LastQuestion >= als.first_purchase_date
		THEN 'Still Active'
	ELSE 'No Signs of Life'
END Active_After_Purchase
FROM users_detail ud
LEFT JOIN als_transactions als
ON als.persistent_session_id = ud.persistent_session_id
LEFT JOIN emails e
	ON e.persistent_session_id = ud.persistent_session_id
LEFT JOIN website w
	ON w.persistent_session_id = ud.persistent_session_id
LEFT JOIN review3 r
	ON r.persistent_session_id = ud.persistent_session_id
LEFT JOIN questions3 q
	ON q.persistent_session_id = ud.persistent_session_id
WHERE (CASE WHEN als.persistent_session_id IS NOT NULL THEN 1 WHEN STRRIGHT(ud.persistent_session_id, 1) IN ('1', 'a') THEN 1 ELSE 0 END) = 1
	

