

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
		,regexp_extract(url, 'thank_you\/([0-9]+)', 1) as order_id
	from src.page_view 
	left join src.ocato_advice_sessions oas 
	on cast(als.order_id as INT) = oas.id 
left join src.ocato_offers oo 
	on oas.offer_id = oo.id 
left join src.ocato_packages op 
	on oo.package_id = op.id
	where page_type = 'LS-Thankyou' 
	and event_date >= '2016-02-08'
  
)

,control_group AS (
  SELECT persistent_session_id
  ,MIN(event_date)
,COUNT(session_id) sid_count
FROM src.page_view pv
LEFT JOIN dm.user_account_dimension
WHERE event_date >= '2016-02-08'
AND persistent_session_id NOT IN (SELECT DISTINCT persistent_session_id FROM als_transactions)
  GROUP BY 1
HAVING COUNT(session_id) >= 2

)

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

SELECT w.persistent_session_id
,MIN(w.event_date) first_visit
,w.referrer
,w.campaign
,w.source
,w.medium
,w.url
,w.event_date
,COUNT(DISTINCT w.session_id) Session_Count

,COUNT(CASE
		WHEN fv.first_visit_timestamp >= als.`timestamp`
			THEN als.order_id
		ELSE NULL
		END) Pre_Channel_Touch_Purchases
FROM src.weblog w
LEFT JOIN als_transactions als
	ON als.persistent_session_id = w.persistent_session_id
	-- AND fv.first_visit_timestamp < als.`timestamp`

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13