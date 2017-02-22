WITH ad1 AS (SELECT pm.professional_id
,MIN(to_date(ns.created_at)) FirstAdDate
,MAX(to_date(COALESCE(ns.stopped_at, ns.expires_at, now()))) LastAdDate
FROM src.nrt_subscription ns
JOIN dm.historical_ad_customer_professional_map pm
ON pm.ad_id = ns.ad_id
AND ns.created_at >= '2015-05-01'
AND pm.professional_id > 0
  AND pm.product_line_item_id IN (1,5)
AND pm.professional_id BETWEEN 10000 AND 11000
  -- AND pm.professional_id < 10000
GROUP BY 1

)

SELECT *
,CASE
WHEN LastAdDate >= '2015-05-01'
THEN 'Y'
ELSE 'N'
END advertised_in_past_year
,CASE
WHEN LastAdDate <= '2015-05-01'
THEN 'Y'
ELSE 'N'
END advertised_over_year_ago
,CASE
WHEN LastAdDate IS NULL
THEN 'Y'
ELSE 'N'
END never_advertised
,CASE
WHEN p.professional_claim_date IS NULL
THEN 'N'
ELSE 'Y'
END is_claimed
FROM dm.professional_dimension p
LEFT JOIN ad1 a
ON a.professional_id = a.professional_id
