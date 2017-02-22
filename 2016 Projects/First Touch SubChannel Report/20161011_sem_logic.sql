SELECT persistent_session_id
,MIN(w.`timestamp`) AS first_visit_timestamp
,'SEM - Brand' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%branded_terms%'
		OR LOWER(w.campaign) = 'brand|rlsa%'
		OR LOWER(w.campaign) = 'brand'
	)
	AND LOWER(w.campaign) NOT LIKE "%fb%"
GROUP BY 1,3
	
UNION

SELECT persistent_session_id
,MIN(w.`timestamp`) AS first_visit_timestamp
,'SEM - Q&A' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%legal_q_&_a_search%'
		OR LOWER(w.campaign) LIKE '%legalqa%'
		)
AND LOWER(w.campaign) NOT LIKE '%fb%'
GROUP BY 1,3
  
UNION

SELECT persistent_session_id
,MIN(w.`timestamp`) AS first_visit_timestamp
,'SEM - ALS' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%pls|%'
		OR LOWER(w.campaign) = 'pls'
		OR LOWER(w.campaign) = 'plsremarketing'
	)
GROUP BY 1,3