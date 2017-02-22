/* Timing out.  Make table out of eligible_users script so it doesn't have to run so many times.  Ask Nadine to put in the queue.  
Timing out again.  Making second table for first_als_transaction.  */

/* WITH first_als_transaction AS (
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
,pv.event_date AS first_purchase_date
,ROW_NUMBER() OVER(PARTITION BY persistent_session_id ORDER BY gmt_timestamp) Num
from src.page_view pv
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

als_prep AS (
SELECT DISTINCT pv.persistent_session_id
,cast(regexp_extract(url, 'thank_you\/([0-9]+)', 1) as INT) order_id
from src.page_view pv
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
	,MIN(oas.created_at) First_Purchase_Date
	,MAX(oas.created_at) Last_Purchase_Date
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
from als_prep pv
LEFT JOIN first_als_transaction fp
	ON fp.persistent_session_id = pv.persistent_session_id
	AND fp.Num = 1
	left join src.ocato_advice_sessions oas 
	on pv.order_id = oas.id 
left join src.ocato_offers oo 
	on oas.offer_id = oo.id 
left join src.ocato_packages op 
	on oo.package_id = op.id
left join dm.specialty_dimension sd 
		on sd.specialty_id = oas.specialty_id
GROUP BY 1,2,3,4
  
) */

/*,

eligible_users AS (
 SELECT t.persistent_session_id
  ,t.session_id
  ,resolved_user_id
  ,event_date AS first_postlaunch_visit_date
  ,t.lpv_page_type
	,t.lpv_medium
	,dc.device_category_name
  ,CASE
	WHEN als.persistent_session_id IS NOT NULL
		THEN 1
	ELSE 0
END Is_ALS_Customer
	,als.first_purchase_date
  ,ROW_NUMBER() OVER(PARTITION BY t.persistent_session_id ORDER BY event_date, t.session_id) Num 
  ,COUNT(t.session_id) OVER(PARTITION BY t.persistent_session_id) session_check
FROM dm.traffic t
LEFT JOIN first_als_transaction als
	ON als.persistent_session_id = t.persistent_session_id
	AND als.Num = 1
LEFT JOIN dm.device_category_dim dc
	ON dc.device_category_id = t.lpv_device_category_id
WHERE event_date >= '2016-02-08' -- checked with Mira
--AND CAST(resolved_user_id aS INT) < 10000
AND lawyer_user_id = false
-- used row number and checked for duplicates with null/populated user id... all looks good

) */

WITH user_visits AS (
SELECT eu.persistent_session_id
,eu.resolved_user_id
,eu.first_postlaunch_visit_date
,eu.lpv_page_type
,eu.lpv_medium
,eu.device_category_name
,eu.first_purchase_date
,eu.Is_ALS_Customer
,'Pre-ALS-Launch' AS Timeframe
,COUNT(DISTINCT t.event_date) days_visited
,COUNT(t.session_id) AS total_sessions_count
FROM tmp_data_dm.sr_als_eligible_users eu
	LEFT JOIN dm.traffic t
		ON eu.persistent_session_id = t.persistent_session_id
		AND t.event_date < '2016-02-08'
		-- AND eu.Num = 1
		-- AND (eu.session_check >=2 OR eu.is_als_customer = 1)
GrOUP BY 1,2,3,4,5,6,7,8,9
		
UNION ALL
		
SELECT eu.persistent_session_id
,eu.resolved_user_id
,eu.first_postlaunch_visit_date
,eu.lpv_page_type
,eu.lpv_medium
,eu.device_category_name
,eu.first_purchase_date
,eu.Is_ALS_Customer
,'Post-Launch-&-Pre-Purchase' AS Timeframe
,COUNT(DISTINCT t.event_date) days_visited
,COUNT(t.session_id) AS total_sessions_count
FROM tmp_data_dm.sr_als_eligible_users eu
	LEFT JOIN dm.traffic t
		ON eu.persistent_session_id = t.persistent_session_id
		AND t.event_date >= '2016-02-08'
		-- AND eu.Num = 1
		-- AND (eu.session_check >=2 OR eu.is_als_customer = 1)
		AND (eu.first_purchase_date > t.event_date OR eu.is_als_customer = 0)
GrOUP BY 1,2,3,4,5,6,7,8,9		
		
UNION ALL
		
SELECT eu.persistent_session_id
,eu.resolved_user_id
,eu.first_postlaunch_visit_date
,eu.lpv_page_type
,eu.lpv_medium
,eu.device_category_name
,eu.first_purchase_date
,eu.Is_ALS_Customer
,'Purchase-Date-Plus' AS Timeframe
,COUNT(DISTINCT t.event_date) days_visited
,COUNT(t.session_id) AS total_sessions_count
FROM tmp_data_dm.sr_als_eligible_users eu
	LEFT JOIN dm.traffic t
		ON eu.persistent_session_id = t.persistent_session_id
		AND t.event_date >= '2016-02-08'
		AND eu.Is_ALS_Customer = 1
		AND t.event_date >= eu.first_purchase_date
		-- AND eu.Num = 1
GrOUP BY 1,2,3,4,5,6,7,8,9		
		)

, users_detail AS (

SELECT eu.persistent_session_id
,'Pre-ALS-Launch' AS Timeframe
,SUM(CASE
		WHEN pv.page_type IN ('Attorney_Directory_Browse', 'Attorney_Search')
			THEN 1
		ELSE 0
	END) Lawyer_SERP_PV_Count
,SUM(CASE
		WHEN pv.page_type = 'Topics'
			THEN 1
		ELSE 0
	END) Topics_PV_Count
,SUM(CASE
		WHEN pv.page_type IN ('Attorney_Profile'
			,'Attorney_Profile_Aboutme'
			,'Attorney_Profile_Contact'
			,'Attorney_Profile_Endorsement'
			,'Attorney_Profile_Review'
			,'Attorney_Review')
			THEN 1
		ELSE 0
	END) Profile_PV_Count		
,SUM(CASE
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
			THEN 1
		ELSE 0
	END) ALS_PV_Count
,SUM(CASE
		WHEN pv.page_type = 'Legal_Answers_Detail'
			THEN 1
		ELSE 0
	END) QA_Detail_PV_Count
,SUM(CASE
		WHEN pv.page_type IN (
'Legal_Ask_Launch'
,'Legal_Ask_Preview'
)
			THEN 1
		ELSE 0
	END) Ask_a_Lawyer_PV_Count
,COUNT(pv.render_instance_guid) Total_Pageviews_Count
,SUM(CASE
			WHEN sd.parent_specialty_name = 'Real Estate'
				THEN 1
			ELSE 0
		END) Real_Estate_Pageviews
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Employment & Labor'
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
FROM tmp_data_dm.sr_als_eligible_users eu
LEFT JOIN src.page_view pv -- okay to join to pageview this way because all our dimensions are elsewhere and we are aggregating all of this
	ON pv.persistent_session_id = eu.persistent_session_id
		-- AND eu.Num = 1 -- deduplicate eligible users
		-- AND (eu.session_check >=2 OR eu.is_als_customer = 1) -- eligible for inclusion
		AND pv.event_date < '2016-02-08' -- pre-launch

left join dm.specialty_dimension sd 
		on sd.specialty_id = pv.specialty_id
-- WHERE (pv.campaign NOT IN ('sgt', 'Network') OR pv.campaign IS NULL OR eu.is_als_customer = 1) -- exclude network traffic		
GROUP BY 1,2

UNION ALL 

SELECT eu.persistent_session_id
,'Post-Launch-&-Pre-Purchase' AS Timeframe
,SUM(CASE
		WHEN pv.page_type IN ('Attorney_Directory_Browse', 'Attorney_Search')
			THEN 1
		ELSE 0
	END) Lawyer_SERP_PV_Count
,SUM(CASE
		WHEN pv.page_type = 'Topics'
			THEN 1
		ELSE 0
	END) Topics_PV_Count
,SUM(CASE
		WHEN pv.page_type IN ('Attorney_Profile'
			,'Attorney_Profile_Aboutme'
			,'Attorney_Profile_Contact'
			,'Attorney_Profile_Endorsement'
			,'Attorney_Profile_Review'
			,'Attorney_Review')
			THEN 1
		ELSE 0
	END) Profile_PV_Count		
,SUM(CASE
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
			THEN 1
		ELSE 0
	END) ALS_PV_Count
,SUM(CASE
		WHEN pv.page_type = 'Legal_Answers_Detail'
			THEN 1
		ELSE 0
	END) QA_Detail_PV_Count
,SUM(CASE
		WHEN pv.page_type IN (
'Legal_Ask_Launch'
,'Legal_Ask_Preview'
)
			THEN 1
		ELSE 0
	END) Ask_a_Lawyer_PV_Count
,COUNT(pv.render_instance_guid) Total_Pageviews_Count
,SUM(CASE
			WHEN sd.parent_specialty_name = 'Real Estate'
				THEN 1
			ELSE 0
		END) Real_Estate_Pageviews
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Employment & Labor'
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
FROM tmp_data_dm.sr_als_eligible_users eu
LEFT JOIN src.page_view pv -- okay to join to pageview this way because all our dimensions are elsewhere and we are aggregating all of this
	ON pv.persistent_session_id = eu.persistent_session_id
		AND pv.event_date >= '2016-02-08'
		-- AND eu.Num = 1 -- deduplicate eligible users
		-- AND (eu.session_check >=2 OR eu.is_als_customer = 1) -- eligible for inclusion
		-- AND (CASE WHEN eu.is_als_customer = 1 THEN 1 WHEN STRRIGHT(eu.persistent_session_id, 1) IN ('1', 'a', '7', '3', 'e') THEN 1 ELSE 0 END) = 1	 -- winnowing control group done in temp table
		AND (eu.first_purchase_date > pv.event_date OR eu.is_als_customer = 0) -- pre-purchase
left join dm.specialty_dimension sd 
		on sd.specialty_id = pv.specialty_id
-- AND (pv.campaign NOT IN ('sgt', 'Network') OR pv.campaign IS NULL OR eu.is_als_customer = 1) -- exclude network traffic		
GROUP BY 1,2

UNION ALL

SELECT eu.persistent_session_id
,'Purchase-Date-Plus' AS Timeframe
,SUM(CASE
		WHEN pv.page_type IN ('Attorney_Directory_Browse', 'Attorney_Search')
			THEN 1
		ELSE 0
	END) Lawyer_SERP_PV_Count
,SUM(CASE
		WHEN pv.page_type = 'Topics'
			THEN 1
		ELSE 0
	END) Topics_PV_Count
,SUM(CASE
		WHEN pv.page_type IN ('Attorney_Profile'
			,'Attorney_Profile_Aboutme'
			,'Attorney_Profile_Contact'
			,'Attorney_Profile_Endorsement'
			,'Attorney_Profile_Review'
			,'Attorney_Review')
			THEN 1
		ELSE 0
	END) Profile_PV_Count		
,SUM(CASE
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
			THEN 1
		ELSE 0
	END) ALS_PV_Count
,SUM(CASE
		WHEN pv.page_type = 'Legal_Answers_Detail'
			THEN 1
		ELSE 0
	END) QA_Detail_PV_Count
,SUM(CASE
		WHEN pv.page_type IN (
'Legal_Ask_Launch'
,'Legal_Ask_Preview'
)
			THEN 1
		ELSE 0
	END) Ask_a_Lawyer_PV_Count
,COUNT(pv.render_instance_guid) Total_Pageviews_Count
,SUM(CASE
			WHEN sd.parent_specialty_name = 'Real Estate'
				THEN 1
			ELSE 0
		END) Real_Estate_Pageviews
	,SUM(CASE
			WHEN sd.parent_specialty_name = 'Employment & Labor'
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
FROM tmp_data_dm.sr_als_eligible_users eu
LEFT JOIN src.page_view pv -- okay to join to pageview this way because all our dimensions are elsewhere and we are aggregating all of this
	ON pv.persistent_session_id = eu.persistent_session_id
		AND pv.event_date >= '2016-02-08'
		-- AND eu.Num = 1 -- deduplicate eligible users
		AND eu.is_als_customer = 1 -- post-purchase only
		AND pv.event_date >= eu.first_purchase_date -- post-purchase
left join dm.specialty_dimension sd 
		on sd.specialty_id = pv.specialty_id
GROUP BY 1,2
)

,

message_prep AS (SELECT
  contact_type
  ,event_date
  ,user_id
  --,professional_id
  ,persistent_session_id
  --,COUNT(*) AS chat_messages
  ,SUM(CASE WHEN prev_event_date IS NULL THEN 1
            WHEN DATEDIFF(event_date, prev_event_date) >= 14 THEN 1
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
GROUP BY 1,2,3,4

UNION ALL

SELECT contact_type
,ci.event_date
,ci.user_id
,ci.persistent_session_id
,COUNT(DISTINCT CONCAT(CAST(ci.professional_id AS STRING), CAST(ci.gmt_timestamp AS STRING))) item_count
FROM src.contact_impression ci
WHERE ci.contact_type = 'email'
and ci.user_id is not null
GROUP BY 1,2,3,4
)



,

email_prep2 AS (
SELECT ep.contact_type
,ep.event_date
,ep.user_id
,ep.persistent_session_id
,ep.item_count
,eu.first_purchase_date
,eu.is_als_customer
,MIN(ep.event_date) OVER(PARTITION BY eu.persistent_session_id) AS FirstEmail
,MAX(ep.event_date) OVER(PARTITION BY eu.persistent_session_id) AS LastEmail
FROM tmp_data_dm.sr_als_eligible_users eu
JOIN message_prep ep
ON eu.persistent_session_id = ep.persistent_session_id

)

,

emails AS (
select 
	ci.persistent_session_id 
	,'Pre-ALS-Launch' AS Timeframe
	,FirstEmail
	,LastEmail	
	,SUM(item_count) EmailCount
from email_prep2 ci
WHERE ci.event_date < '2016-02-08'
group by 1,2,3,4

UNION ALL

select 
	ci.persistent_session_id 
	,'Post-Launch-&-Pre-Purchase' AS Timeframe
	,FirstEmail
	,LastEmail		
	,SUM(item_count) EmailCount
from email_prep2 ci
WHERE ci.event_date >= '2016-02-08'
AND (first_purchase_date > ci.event_date OR is_als_customer = 0) -- pre-purchase
group by 1,2,3,4

UNION ALL

select 
	ci.persistent_session_id 
	,'Purchase-Date-Plus' AS Timeframe
	,FirstEmail
	,LastEmail		
	,sum(item_count) EmailCount	
from email_prep2 ci
WHERE is_als_customer = 1
AND ci.event_date >= first_purchase_date
GROUP BY 1,2,3,4
 )
 
,

website_prep AS (
SELECT eu.persistent_session_id
,ci.render_instance_guid
,ci.event_date
,eu.first_purchase_date
,eu.is_als_customer
,MIN(ci.event_date) OVER(PARTITION BY eu.persistent_session_id) AS FirstWebsiteClick
,MAX(ci.event_date) OVER(PARTITION BY eu.persistent_session_id) AS LastWebsiteClick
from tmp_data_dm.sr_als_eligible_users eu
JOIN src.contact_impression ci
ON eu.persistent_session_id = ci.persistent_session_id
AND ci.contact_type = 'website'

)

,

website AS (
select 
	ci.persistent_session_id 
	,'Pre-ALS-Launch' AS Timeframe
	,FirstWebsiteClick
	,LastWebsiteClick	
	,COUNT(render_instance_guid) WebsiteClickCount
from website_prep ci
WHERE ci.event_date < '2016-02-08'
group by 1,2,3,4

UNION ALL

select 
	ci.persistent_session_id 
	,'Post-Launch-&-Pre-Purchase' AS Timeframe
	,FirstWebsiteClick
	,LastWebsiteClick		
	,COUNT(render_instance_guid) WebsiteClickCount
from website_prep ci
WHERE ci.event_date >= '2016-02-08'
AND (first_purchase_date > ci.event_date OR is_als_customer = 0) -- pre-purchase
group by 1,2,3,4

UNION ALL

select 
	ci.persistent_session_id 
	,'Purchase-Date-Plus' AS Timeframe
	,FirstWebsiteClick
	,LastWebsiteClick			
	,COUNT(render_instance_guid) WebsiteClickCount
from website_prep ci
WHERE is_als_customer = 1
AND ci.event_date >= first_purchase_date
GROUP BY 1,2,3,4
 )
 
,

 review1 AS (
 select 
ci.created_at
,eu.persistent_session_id
,ci.id
,eu.first_purchase_date
,eu.is_als_customer
,ABS(DATEDIFF(eu.first_postlaunch_visit_date, ci.created_at)) Diff
,MIN(ci.created_at) OVER(PARTITION BY eu.persistent_session_id) AS FirstReview
,MAX(ci.created_at) OVER(PARTITION BY eu.persistent_session_id) AS LastReview
from tmp_data_dm.sr_als_eligible_users eu
JOIN src.barrister_professional_review ci
	ON ci.created_by = CAST(eu.resolved_User_id AS INT)
	--AND eu.Num = 1 -- only need to join to the first session
-- AND (eu.session_check >=2 OR eu.is_als_customer = 1) 	
	
)

,

review2 AS (
SELECT *
,ROW_NUMBER() OVER(PARTITION BY persistent_session_id ORDER BY Diff) MinDaysDiff -- this is to deal with cases where multiple PIDs belong to the same user ID
FROM review1

)

,

review3 AS (
select 
	r.persistent_session_id 
	,'Pre-ALS-Launch' AS Timeframe
	,FirstReview
	,LastReview	
	,COUNT(DISTINCT r.id) ReviewCount
from review2 r
WHERE r.created_at < '2016-02-08'
AND mindaysdiff = 1
group by 1,2,3,4

UNION ALL

select 
	r.persistent_session_id 
	,'Post-Launch-&-Pre-Purchase' AS Timeframe
	,FirstReview
	,LastReview		
	,COUNT(DISTINCT r.id) ReviewCount
from review2 r
WHERE r.created_at >= '2016-02-08'
AND (first_purchase_date > r.created_at OR is_als_customer = 0) -- pre-purchase
AND mindaysdiff = 1
group by 1,2,3,4

UNION ALL

select 
	r.persistent_session_id 
	,'Purchase-Date-Plus' AS Timeframe
	,FirstReview
	,LastReview		
	,COUNT(DISTINCT r.id) ReviewCount
from review2 r
WHERE is_als_customer = 1
AND r.created_at >= first_purchase_date
AND mindaysdiff = 1
GROUP BY 1,2,3,4
 )

,

questions1 as

(

SELECT q.created_by AS user_id
,q.created_at
,q.id
,eu.persistent_session_id
,is_als_customer
,first_purchase_date
,ABS(DATEDIFF(eu.first_postlaunch_visit_date, q.created_at)) Diff
,MIN(q.created_at) OVER(PARTITION BY eu.persistent_session_id) AS FirstQuestion
,MAX(q.created_at) OVER(PARTITION BY eu.persistent_session_id) AS LastQuestion
FROM tmp_data_dm.sr_als_eligible_users eu
JOIN src.content_question q
	ON q.created_by = CAST(eu.resolved_User_id AS INT)
	--AND eu.Num = 1 -- only need to join to the first session
	--AND (eu.session_check >=2 OR eu.is_als_customer = 1)
	where q.approval_status_id in (1,2)
	   AND (q.created_by <> 1 OR q.updated_by <> 1)	   
	
)

,questions2 AS (

SELECT *
,ROW_NUMBER() OVER(PARTITION BY persistent_session_id ORDER BY Diff) MinDaysDiff
FROM questions1

)

,

questions3 AS (
select 
	q.persistent_session_id 
	,'Pre-ALS-Launch' AS Timeframe
	,FirstQuestion
	,LastQuestion
	,COUNT(DISTINCT q.id) QuestionCount
from questions2 q
WHERE q.created_at < '2016-02-08'
AND mindaysdiff = 1
group by 1,2,3,4

UNION ALL

select 
	q.persistent_session_id 
	,'Post-Launch-&-Pre-Purchase' AS Timeframe
	,FirstQuestion
	,LastQuestion	
	,COUNT(DISTINCT q.id) QuestionCount
from questions2 q
WHERE q.created_at >= '2016-02-08'
AND (first_purchase_date > q.created_at OR is_als_customer = 0) -- pre-purchase
AND mindaysdiff = 1
group by 1,2,3,4

UNION ALL

select 
	q.persistent_session_id 
	,'Purchase-Date-Plus' AS Timeframe
	,FirstQuestion
	,LastQuestion	
	,COUNT(DISTINCT q.id) QuestionCount
from questions2 q
WHERE is_als_customer = 1
AND q.created_at >= first_purchase_date
AND mindaysdiff = 1
group by 1,2,3,4
 )


SELECT ud.*
,uv.resolved_user_id
,uv.first_postlaunch_visit_date
,uv.lpv_page_type
,uv.lpv_medium
,uv.device_category_name
,uv.first_purchase_date
,uv.Is_ALS_Customer
,uv.days_visited
,uv.total_sessions_count
/*,CASE
	WHEN uv.resolved_user_id IS NOT NULL
		THEN 1
	ELSE 0
	WHEN uv.resolved_user_id IS NOT NULL
		THEN 'Core'
	WHEN SUM(ud.Lawyer_SERP_PV_Count) OVER(PARTITION BY ud.persistent_session_id) >= 1
		THEN 'Core'
	WHEN SUM(ud.Profile_PV_Count) OVER(PARTITION BY ud.persistent_session_id) >= 1
		THEN 'Core'
	WHEN SUM(ALS_PV_Count) OVER(PARTITION BY ud.persistent_session_id) >= 1
		THEN 'Core'
	ELSE 'Casual'
END Casual_vs_Core 
,CASE
	WHEN uv.resolved_user_id IS NOT NULL
		THEN 1
	WHEN SUM(ud.Lawyer_SERP_PV_Count) OVER(PARTITION BY ud.persistent_session_id) >= 1
		THEN 1
	WHEN SUM(ud.Profile_PV_Count) OVER(PARTITION BY ud.persistent_session_id) >= 1
		THEN 1
	WHEN SUM(ALS_PV_Count) OVER(PARTITION BY ud.persistent_session_id) >= 1
		THEN 1
	ELSE 0
END IsCore
,CASE
	WHEN uv.resolved_user_id IS NOT NULL
		THEN 1
	WHEN SUM(ud.Lawyer_SERP_PV_Count) OVER(PARTITION BY ud.persistent_session_id) >= 1
		THEN 1
	WHEN SUM(ud.Profile_PV_Count) OVER(PARTITION BY ud.persistent_session_id) >= 1
		THEN 1
	WHEN SUM(ALS_PV_Count) OVER(PARTITION BY ud.persistent_session_id) >= 1
		THEN 1
	ELSE 0
END IsCasual */
,CASE
	WHEN uv.Is_ALS_Customer = 1
		THEN 'ALS Customer'
	WHEN SUM(ud.ALS_PV_Count) OVER(PARTITION BY ud.persistent_session_id) >= 1
		THEN 'ALS Shopper'
	WHEN uv.resolved_user_id IS NOT NULL
		THEN 'Core - Non-Customer'
	WHEN SUM(ud.Lawyer_SERP_PV_Count) OVER(PARTITION BY ud.persistent_session_id) >= 1
		THEN 'Core - Non-Customer'
	WHEN SUM(ud.Profile_PV_Count) OVER(PARTITION BY ud.persistent_session_id) >= 1
		THEN 'Core - Non-Customer'
	WHEN SUM(ALS_PV_Count) OVER(PARTITION BY ud.persistent_session_id) >= 1
		THEN 'Core - Non-Customer'
	ELSE 'Casual - Non-Customer'
END Cohort_Pie
,CASE
	WHEN uv.Is_ALS_Customer = 1
		THEN 0
	ELSE 1
END IsControlGroup
,CASE
	WHEN ud.timeframe = 'Purchase-Date-Plus'
		THEN COALESCE(als.advice_purchases, 0)
	ELSE NULL
END AS advice_purchases
,CASE
	WHEN ud.timeframe = 'Purchase-Date-Plus'
		THEN COALESCE(als.doc_review_purchases, 0) 
	ELSE NULL
END AS doc_review_purchases
,CASE
	WHEN ud.timeframe = 'Purchase-Date-Plus'
		THEN COALESCE(als.other_offline_purchases, 0)
	ELSE NULL
END AS other_offline_purchases
,CASE
	WHEN ud.timeframe = 'Purchase-Date-Plus'
		THEN COALESCE(als.total_purchases, 0) 
	ELSE NULL
END AS total_purchases
,COALESCE(als.total_purchases, 0) AS total_purchases_for_filter
,als.last_purchase_date
,als.first_purchase_type
,als.first_purchase_pa
,als.first_purchase_name
,CASE
	WHEN ud.timeframe = 'Purchase-Date-Plus'
		THEN COALESCE(Real_Estate_Purchases, 0) 
	ELSE NULL
	END AS Real_Estate_Purchases	
,CASE
	WHEN ud.timeframe = 'Purchase-Date-Plus'
		THEN COALESCE(Employment_and_Labor_Purchases, 0)
	ELSE NULL
	END AS Employment_and_Labor_Purchases
,CASE
	WHEN ud.timeframe = 'Purchase-Date-Plus'
		THEN COALESCE(Business_Purchases, 0) 
	ELSE NULL
	END AS Business_Purchases	
	,CASE
		WHEN ud.timeframe = 'Purchase-Date-Plus'
			THEN COALESCE(Immigration_Purchases, 0) 
		ELSE NULL
	END AS Immigration_Purchases
	,CASE
		WHEN ud.timeframe = 'Purchase-Date-Plus'
			THEN COALESCE(Unknown_PA_Purchases, 0) 
		ELSE NULL
	END AS Unknown_PA_Purchases	
	,CASE
		WHEN ud.timeframe = 'Purchase-Date-Plus'
			THEN COALESCE(Criminal_Defense_Purchases, 0) 
		ELSE NULL
	END AS Criminal_Defense_Purchases	
	,CASE 
		WHEN ud.timeframe = 'Purchase-Date-Plus'
			THEN COALESCE(Estate_Planning_Purchases, 0) 
		ELSE NULL
	END AS Estate_Planning_Purchases
	,CASE
		WHEN ud.timeframe = 'Purchase-Date-Plus'
			THEN COALESCE(Family_Purchases, 0) 
		ELSE NULL
	END AS Family_Purchases
	,CASE
		WHEN ud.timeframe = 'Purchase-Date-Plus'
			THEN COALESCE(Bankruptcy_and_Debt_Purchases, 0) 
			ELSE NULL
		END AS Bankruptcy_and_Debt_Purchases
,COALESCE(q.QuestionCount, 0) QuestionCount
,q.FirstQuestion
,q.LastQuestion
,CASE
	WHEN MAX(q.FirstQuestion) OVER(PARTITION BY ud.persistent_session_id) < uv.first_purchase_date
		THEN 'Q&A Before ALS Purchase'
	WHEN MAX(q.FirstQuestion) OVER(PARTITION BY ud.persistent_session_id) >= uv.first_purchase_date
		THEN 'Q&A After ALS Purchase'
	WHEN MAX(q.FirstQuestion) OVER(PARTITION BY ud.persistent_session_id) IS NULL
		THEN 'No Question Asked'
END First_Question_Timing
,COALESCE(e.EmailCount, 0) EmailCount
,e.FirstEmail
,e.LastEmail
,CASE
	WHEN MAX(e.FirstEmail) OVER(PARTITION BY ud.persistent_session_id) < uv.first_purchase_date
		THEN 'Emailed Before ALS Purchase'
	WHEN MAX(e.FirstEmail) OVER(PARTITION BY ud.persistent_session_id) >= uv.first_purchase_date
		THEN 'Emailed After ALS Purchase'
	WHEN MAX(e.FirstEmail) OVER(PARTITION BY ud.persistent_session_id) IS NULL
		THEN 'No Email'
END First_Email_Timing
,COALESCE(w.WebsiteClickCount, 0) WebsiteClickCount
,w.FirstWebsiteClick
,w.LastWebsiteClick
,CASE
	WHEN MAX(w.FirstWebsiteClick) OVER(PARTITION BY ud.persistent_session_id) < uv.first_purchase_date
		THEN 'Clicked Before ALS Purchase'
	WHEN MAX(w.FirstWebsiteClick) OVER(PARTITION BY ud.persistent_session_id) >= uv.first_purchase_date
		THEN 'Clicked After ALS Purchase'
	WHEN MAX(w.FirstWebsiteClick) OVER(PARTITION BY ud.persistent_session_id) IS NULL
		THEN 'No Website Clicks'
END First_Website_Click_Timing
,COALESCE(r.ReviewCount, 0) ReviewCount
,r.FirstReview
,r.LastReview
,CASE
	WHEN MAX(r.FirstReview ) OVER(PARTITION BY ud.persistent_session_id) < uv.first_purchase_date
		THEN 'Reviewed Before ALS Purchase'
	WHEN MAX(r.FirstReview ) OVER(PARTITION BY ud.persistent_session_id) >= uv.first_purchase_date
		THEN 'Reviewed After ALS Purchase'
	WHEN MAX(r.FirstReview ) OVER(PARTITION BY ud.persistent_session_id) IS NULL
		THEN 'No Reviews'
END First_Review_Timing
,CASE
	WHEN MAX(r.LastReview) OVER(PARTITION BY ud.persistent_session_id) >= uv.first_purchase_date
		THEN 'Still Active'
	WHEN MAX(e.LastEmail) OVER(PARTITION BY ud.persistent_session_id) >= uv.first_purchase_date
		THEN 'Still Active'
	WHEN MAX(w.LastWebsiteClick) OVER(PARTITION BY ud.persistent_session_id) >= uv.first_purchase_date
		THEN 'Still Active'
	WHEN MAX(q.LastQuestion) OVER(PARTITION BY ud.persistent_session_id) >= uv.first_purchase_date
		THEN 'Still Active'
	ELSE 'No Signs of Life'
END Active_After_Purchase
FROM users_detail ud
	LEFT JOIN user_visits uv
		ON ud.persistent_session_id = uv.persistent_session_id
AND uv.Timeframe = ud.Timeframe		
LEFT JOIN tmp_data_dm.sr_als_transactions als
ON als.persistent_session_id = ud.persistent_session_id
-- AND ud.Timeframe = 'Purchase-Date-Plus'
LEFT JOIN emails e
	ON e.persistent_session_id = ud.persistent_session_id
	AND e.Timeframe = ud.Timeframe
LEFT JOIN website w
	ON w.persistent_session_id = ud.persistent_session_id
	AND w.Timeframe = ud.Timeframe
LEFT JOIN review3 r
	ON r.persistent_session_id = ud.persistent_session_id
	AND r.Timeframe = ud.Timeframe
LEFT JOIN questions3 q
	ON q.persistent_session_id = ud.persistent_session_id
	AND q.Timeframe = ud.Timeframe

	

