/* Steps:

- get 
- get purchase count
- get unique customer id */

WITH traffic AS (

SELECT t.persistent_session_id
	,MAX(t.resolved_user_id) AS user_id
	-- ,COUNT(DISTINCT t.session_id) total_sessions
FROM dm.traffic t
WHERE t.event_date >= '2016-02-08'
--AND t.resolved_user_id IS NOT NULL
GROUP BY t.persistent_session_id
)

,als_transactions AS (
	select regexp_extract(url, 'thank_you\/([0-9]+)', 1) as advice_session_id
		,MAX(persistent_session_id) AS persistent_session_id
	from src.page_view 
	where page_type IN ('LS-Thankyou', 'Advisor-thankyou')
	and event_date >= '2016-02-08'
  
)

gross_purchases AS (
SELECT id purchase_id
,advice_session_id
,order_id
,offer_id
,MAX(ocato_created_at_pst) purchase_date
FROM src.ocato_financial_event_logs ofel
WHERE event_type <> 'purchase'
AND ofel.created_at_pst >= '2016-02-08'
GROUP BY 1,2,3,4

)

,package_info AS (
select op.id as package_id, oo.id as offer_id, op.name as package_name, sd.specialty_name, sd.parent_specialty_name, os.name as state
from src.ocato_packages op
left join src.ocato_offers oo on oo.package_id = op.id
left join dm.specialty_dimension sd on op.specialty_id = sd.specialty_id
left join src.ocato_states os on oo.state_id = os.id
)

SELECT oas.id
	,oas.client_email_address
	,
FROM src.ocato_advice_sessions oas

/* Kenneth's methodology
select sum(case when transaction_count =1 then 1 else 0 end) as 'one_time',
  sum(case when transaction_count >1 then 1 else 0 end) as 'repeat_customer'
  from(
    select client_email_address, count(*) as transaction_count
    from (
      select distinct to_date(created_at) as event_date, client_email_address
      from src.ocato_advice_sessions) as table_a
group by client_email_address) as table_b 

*/


SELECT id AS advice_session_id
,client_email_address
,client_phone_number
,als.persistent_session_id
,t.user_id
,to_date(created_at_pst) order_date
FROM src.ocato_advice_sessions oas
	LEFT JOIN als_transactions als
		ON als.order_id = oas.id
	LEFT JOIN traffic t
		ON t.persistent_session_id = als.persistent_session_id
WHERE event_type <> 'purchase'
