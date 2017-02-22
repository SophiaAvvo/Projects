WITH gross_purchases AS (
SELECT advice_session_id
,order_id
,offer_id
,MAX(created_at_pst) purchase_date_pst
,MAX(created_at) purchase_date
FROM src.ocato_financial_event_logs ofel
WHERE event_type = 'purchase'
AND ofel.created_at_pst >= '2016-02-08'
GROUP BY 1,2,3

)

,package_info AS (
select op.id as package_id, oo.id as offer_id, op.name as package_name, sd.specialty_name, sd.parent_specialty_name, os.name as state
from src.ocato_packages op
left join src.ocato_offers oo on oo.package_id = op.id
left join dm.specialty_dimension sd on op.specialty_id = sd.specialty_id
left join src.ocato_states os on oo.state_id = os.id
)

SELECT oas.id AS advice_session_id
	,oas.client_email_address
    ,COALESCE(gp.purchase_date_pst, oas.created_at_pst) AS purchase_date_pst
    ,gp.*
    ,pi.*
FROM src.ocato_advice_sessions oas
LEFT JOIN gross_purchases gp
ON gp.advice_session_id = oas.id
LEFT JOIN package_info pi
ON pi.offer_id = gp.offer_id
WHERE oas.id IN (12935, 11535, 11095, 11345,23355,29495,11035,12975,11335,22465)
LIMIT 10;