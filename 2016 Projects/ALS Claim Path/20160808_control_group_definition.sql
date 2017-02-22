

WITH als_transactions AS (
	select DISTINCT persistent_session_id
		,`timestamp`
		,event_date
		,regexp_extract(url, 'thank_you\/([0-9]+)', 1) as order_id
	from src.page_view 
	where page_type = 'LS-Thankyou' 
	and event_date >= '2016-02-08'
  
)

,control_group AS (
  SELECT persistent_session_id
,COUNT(session_id) sid_count
FROM src.page_view pv
WHERE event_date >= '2016-02-08'
AND persistent_session_id NOT IN (SELECT DISTINCT persistent_session_id FROM als_transactions)
  GROUP BY 1
HAVING COUNT(session_id) >= 2

)