SELECT p.professional_Id
	,COUNT(CASE
				WHEN a.unsuccessful_session_reason_id IS NULL
					THEN p.id
				ELSE NULL
			END) Successful_Package_Purchases_Total
		,COUNT(p.id) Package_Purchases_Total
	,SUM(CASE
				WHEN a.unsuccessful_session_reason_id IS NULL
				THEN pk.advisor
				ELSE 0
			END) Successful_Advisor_Purchases_Total
	,COUNT(CASE
				WHEN a.unsuccessful_session_reason_id IS NULL
				AND pk.advisor = 0
					THEN p.id
				ELSE NULL
			END) Successful_Non_Advisor_Purchases_Total	
from src.ocato_providers p
       join src.ocato_advice_sessions a
			ON a.provider_id = p.id
			AND a.created_at < '2016-06-01'
		LEFT JOIN src.ocato_offers o
			ON o.id = a.offer_id
        LEFT JOIN src.ocato_packages pk
			ON pk.id = o.package_id			
GROUP BY p.professional_id