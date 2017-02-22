CREATE TABLE tmp_data_dm.sr_als_transactions

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

als_prep AS (
SELECT DISTINCT pv.persistent_session_id
,cast(regexp_extract(url, 'thank_you\/([0-9]+)', 1) as INT) order_id
from src.page_view pv
where page_type = 'LS-Thankyou' 
	and event_date >= '2016-02-08'
)


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
  
