DROP TABLE tmp_data_dm.sr_als_eligible_users;
CREATE TABLE tmp_data_dm.sr_als_eligible_users

AS

WITH first_als_transaction AS (
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

 eligible_users AS (SELECT t.persistent_session_id
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

)

SELECT *
FROM eligible_users eu
WHERE Num = 1
AND (eu.session_check >=2 OR eu.is_als_customer = 1)
AND (CASE WHEN eu.is_als_customer = 1 THEN 1 WHEN STRRIGHT(eu.persistent_session_id, 1) IN ('1', 'a', '7', '3', 'e') THEN 1 ELSE 0 END) = 1	 -- winnowing control group 


