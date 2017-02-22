SELECT DISTINCT persistent_session_id
,MIN(w.`timestamp`) AS first_visit_timestamp
,COUNT(DISTINCT session_id) session_count
,'Paid Social - FB - Acq' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.medium) LIKE '%cpc%' 
	OR LOWER(w.medium) LIKE '%cpm%')	
  AND (LOWER(campaign) LIKE '%fb_%' 
	OR LOWER(campaign) LIKE '%acq%'
		)
  AND LOWER(w.source) NOT LIKE '%google%'		
  AND LOWER(w.campaign) NOT LIKE '%2016brandvideos_t_acq%'
  AND LOWER(w.campaign) NOT LIKE '%fbZ_boosted%'
  AND LOWER(w.campaign) NOT LIKE '%lawyer%'
  AND LOWER(w.campaign) NOT LIKE '%pokemon%'
  AND LOWER(w.campaign) NOT LIKE '%eng_%'
  AND LOWER(w.campaign) NOT LIKE '%pls%'
  
 UNION

SELECT DISTINCT persistent_session_id
,MIN(w.`timestamp`) AS first_visit_timestamp
,'Paid Social - FB - ALS' AS Channel
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.medium) LIKE '%cpc%' 
	OR LOWER(w.medium) LIKE '%cpm%')	
  AND (LOWER(campaign) LIKE '%pls_avvofb%'
	OR LOWER(campaign) LIKE '%pls_fb%'
	OR LOWER(campaign) LIKE '%pls_fbb%'
		)
  AND LOWER(w.source) NOT LIKE '%google%'		
  AND LOWER(w.campaign) NOT LIKE '%2016brandvideos_t_acq%'
  AND LOWER(w.campaign) NOT LIKE '%fbZ_boosted%'
  AND LOWER(w.campaign) NOT LIKE '%lawyer%'
  AND LOWER(w.campaign) NOT LIKE '%pokemon%'
  AND LOWER(w.campaign) NOT LIKE '%eng_%'
 

