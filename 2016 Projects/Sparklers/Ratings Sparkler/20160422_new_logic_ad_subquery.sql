


SELECT ns.created_at AdSTartDate
,COALESCE(ns.stopped_at, ns.expires_at) AdStopDAte
,pm.professional_id
FROM src.nrt_subscription ns
JOIN dm.historical_ad_customer_professional_map pm
ON pm.ad_id = ns.ad_id
AND pm.professional_id BETWEEN 10000 AND 10100
AND ns.created_at >= '2015-01-01'
  AND pm.product_line_item_id IN (1,5)
ORDER BY pm.professional_id
  ,ns.created_at