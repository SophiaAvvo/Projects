WITH Ad1 AS (
SELECT pm.professional_id
,MIN(to_date(ns.created_at)) FirstAdDate
,to_date(COALESCE(ns.stopped_at, ns.expires_at, now())) LastAdDate
FROM src.nrt_subscription ns
JOIN dm.historical_ad_customer_professional_map pm
ON pm.ad_id = ns.ad_id
AND pm.professional_id BETWEEN 10000 AND 12000
AND ns.created_at >= '2015-01-01'
  AND pm.product_line_item_id IN (1,5)
GROUP BY 1,3
-- ORDER BY 3,1
  
)

, Ad2 AS (
SELECT a.professional_id
,FirstAdDate
,MAX(LastAdDate) LastAdDate
FROM ad1 a/*src.nrt_subscription ns
JOIN dm.historical_ad_customer_professional_map pm
ON pm.ad_id = ns.ad_id
AND pm.professional_id BETWEEN 10000 AND 12000
AND ns.created_at >= '2015-01-01'
  AND pm.product_line_item_id IN (1,5) */
GROUP BY 1,2
-- ORDER BY 3,1
  
)

,

Ad3 AS(

SELECT *
,CASE WHEN a2.lastaddate BETWEEN a1.firstaddate AND a1.lastaddate THEN to_date(DATE_ADD(a2.lastaddate, 1)) ELSE a1.firstaddate END actualstartdate -- when there's a partially overlapping window, move start date to one day after last end date
,CASE WHEN a2.firstaddate <= a1.firstaddate AND a2.lastaddate > a1.lastaddate THEN 1 -- when exists another interval that forms a superset of the current one, flag row for deletion
ELSE 0
END DeleteFlag
FROM ad2 a1
LEFT JOIN ad2 a2
ON a1.professional_id = a2.professional_id
AND (CASE WHEN a1.firstaddate = a2.firstaddate AND a2.lastaddate = a1.lastaddate THEN 1 ELSE 0 END) = 0  -- don't join identical pairs
AND (CASE WHEN a2.firstaddate > a1.firstaddate AND a2.lastaddate <= a1.lastaddate THEN 1 ELSE 0 END) = 0 -- don't join a smaller window to a larger one
AND (CASE WHEN a2.firstaddate > a1.lastaddate THEN 1 ELSE 0 END) = 0 -- don't join when the window fully postdates 
AND (CASE WHEN a2.lastaddate < a1.firstaddate THEN 1 ELSE 0 END) = 0 -- don't join when the window is the reverse of consecutive

-- ORDER BY a1.professional_id, a1.firstaddate
  
)

,SELECT 
FROM Ad3 a
LEFT JOIN dm.date_dim d
ON d.

/*
SELECT *
,CASE WHEN a1.firstadddate
-- ,MAX(LastAdDate) OVER(PARTITION BY a.professional_id, FirstAdDate) MaxAdDate
FROM AD1 a1
LEFT JOIN AD1 a2
ON a2.professional_id = a1.professional_id
-- AND a2.firstaddate >= a1.firstaddate
-- AND a2.lastaddate <> a1.lastaddate
ORDER BY a1.professional_id, a1.firstaddate, a2.firstaddate */