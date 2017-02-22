SELECT COUNT(DISTINCT session_id) Count
--,w.campaign
,'SEM - Brand' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-09-01' -- ALS product launch
AND w.event_date <= '2016-09-30'
  AND (LOWER(w.campaign) LIKE '%branded_terms%'
		OR LOWER(w.campaign) = 'brand|rlsa'
		OR LOWER(w.campaign) = 'brand'
	)
	AND LOWER(w.campaign) NOT LIKE "%fb%"
GROUP BY 2--,3
	
UNION

SELECT COUNT(DISTINCT session_id) Count
-- ,w.campaign
,'SEM - Q&A' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-09-01' -- ALS product launch
AND w.event_date <= '2016-09-30'
  AND (LOWER(w.campaign) LIKE '%legal_q_&_a_search%'
		OR LOWER(w.campaign) LIKE '%legalqa%'
		)
AND LOWER(w.campaign) NOT LIKE '%fb%'
GROUP BY 2--,3
  
UNION

SELECT COUNT(DISTINCT session_id) Count
--,w.campaign
,'SEM - ALS' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-09-01' -- ALS product launch
AND w.event_date <= '2016-09-30'
  AND (LOWER(w.campaign) LIKE '%pls|%'
		OR LOWER(w.campaign) = 'pls'
		OR LOWER(w.campaign) = 'plsremarketing'
	)
GROUP BY 2--,3

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


SELECT w.campaign
,'SEM - Brand' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-09-01' -- ALS product launch
AND w.event_date <= '2016-09-30'
  AND (LOWER(w.campaign) LIKE '%branded_terms%'
		OR LOWER(w.campaign) = 'brand|rlsa'
		OR LOWER(w.campaign) = 'brand'
	)
	AND LOWER(w.campaign) NOT LIKE "%fb%"

	
UNION

SELECT w.campaign
,'SEM - Q&A' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-09-01' -- ALS product launch
AND w.event_date <= '2016-09-30'
  AND (LOWER(w.campaign) LIKE '%legal_q_&_a_search%'
		OR LOWER(w.campaign) LIKE '%legalqa%'
		)
AND LOWER(w.campaign) NOT LIKE '%fb%'

  
UNION

SELECT w.campaign
,'SEM - ALS' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-09-01' -- ALS product launch
AND w.event_date <= '2016-09-30'
  AND (LOWER(w.campaign) LIKE '%pls|%'
		OR LOWER(w.campaign) = 'pls'
		OR LOWER(w.campaign) = 'plsremarketing'
	)
