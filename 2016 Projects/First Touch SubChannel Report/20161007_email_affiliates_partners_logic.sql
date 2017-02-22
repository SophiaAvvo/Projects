SELECT DISTINCT persistent_session_id
,MIN(w.`timestamp`) AS first_visit_timestamp
,'Email' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND LOWER(w.medium) LIKE '%email%' 
  
UNION

SELECT DISTINCT persistent_session_id
,MIN(w.`timestamp`) AS first_visit_timestamp
,'Affiliates/Partners' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.medium) LIKE '%affiliate%' 
  OR LOWER(w.medium) LIKE '%boomerater%' 
	OR LOWER(w.medium) LIKE '%lifecare%'
