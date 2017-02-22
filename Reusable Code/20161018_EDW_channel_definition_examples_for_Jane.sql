WITH channels AS (

SELECT persistent_session_id
,1 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'Affiliates/Partners' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.medium) LIKE '%affiliate%' 
  OR LOWER(w.medium) LIKE '%boomerater%' 
	OR LOWER(w.medium) LIKE '%lifecare%'
	)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15	

	
UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,1 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'SEM - Brand' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%branded_terms%'
		OR LOWER(w.campaign) = 'brand|rlsa%'
		OR LOWER(w.campaign) = 'brand'
	)
	AND LOWER(w.campaign) NOT LIKE "%fb%"
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	
UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,1 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'SEM - Q&A' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%legal_q_&_a_search%'
		OR LOWER(w.campaign) LIKE '%legalqa%'
		)
AND LOWER(w.campaign) NOT LIKE '%fb%'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
  
UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,1 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'SEM - ALS' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%pls|%'
		OR LOWER(w.campaign) = 'pls'
		OR LOWER(w.campaign) = 'plsremarketing'
	)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,1 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'Paid FB - RU' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.medium) LIKE '%cpc%' 
	OR LOWER(w.medium) LIKE '%cpm%')	
  AND (LOWER(campaign) LIKE '%fb_%' 
	OR LOWER(campaign) LIKE '%acq%'
		)
  AND LOWER(w.source) NOT LIKE '%google%'		
  AND LOWER(w.campaign) NOT LIKE '%2016brandvideos_t_acq%'
  AND LOWER(w.campaign) NOT LIKE '%fb_boosted%'
  AND LOWER(w.campaign) NOT LIKE '%lawyer%'
  AND LOWER(w.campaign) NOT LIKE '%pokemon%'
  AND LOWER(w.campaign) NOT LIKE '%eng_%'
  AND LOWER(w.campaign) NOT LIKE '%pls%'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15  
  
 UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,1 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'Paid FB - ALS' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
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
  AND LOWER(w.campaign) NOT LIKE '%fbz_boosted%'
  AND LOWER(w.campaign) NOT LIKE '%lawyer%'
  AND LOWER(w.campaign) NOT LIKE '%pokemon%'
  AND LOWER(w.campaign) NOT LIKE '%eng_%'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
 
 UNION
 
 SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,1 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email 
,'Display_RU_Acq' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%pls_%'
	OR LOWER(w.campaign) LIKE '%acq%')
	AND (LOWER(w.campaign) LIKE '%qa%'
		OR LOWER(w.campaign) LIKE '%lifecycle%'
		OR LOWER(w.campaign) LIKE '%form%'
		)
	AND LOWER(w.campaign) NOT LIKE '%fb%'
	AND LOWER(w.campaign) NOT LIKE '%_ret%'
-- note no traffic yet for forms or lifecycle
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
  
UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,1 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'Display_RU_Ret' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%pls_%'
	OR LOWER(w.campaign) LIKE '%_ret%')
	AND (LOWER(w.campaign) LIKE '%qa%'
		OR LOWER(w.campaign) LIKE '%lifecycle%'
		OR LOWER(w.campaign) LIKE '%form%'
		)
	AND LOWER(w.campaign) NOT LIKE '%fb%'
	AND LOWER(w.campaign) NOT LIKE '%acq%'
--note no traffic yet for forms or lifecycle
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

UNION

 SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,1 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email 
,'Display_ALS_Acq' AS Subchannel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND LOWER(w.campaign) LIKE '%pls_%'
  AND (LOWER(w.campaign) LIKE '%_acq%'
	OR LOWER(w.campaign) LIKE '%acquisition%'
	OR LOWER(w.campaign) LIKE '%lookalike%')
	AND LOWER(w.campaign) NOT LIKE '%qa%'
	AND LOWER(w.campaign) NOT LIKE '%lifecycle%'
	AND LOWER(w.campaign) NOT LIKE '%form%'
	AND LOWER(w.campaign) NOT LIKE '%fb%'
-- note no traffic yet for forms or lifecycle
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
  
UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,1 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'Display_ALS_Ret' AS Subchannel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%pls_%'
	OR LOWER(w.campaign) LIKE '%_abandoners%')
  AND LOWER(w.campaign) NOT LIKE '%_acq%'
	AND LOWER(w.campaign) NOT LIKE '%acquisition%'
	AND LOWER(w.campaign) NOT LIKE '%lookalike%'
	AND LOWER(w.campaign) NOT LIKE '%qa%'
	AND LOWER(w.campaign) NOT LIKE '%lifecycle%'
	AND LOWER(w.campaign) NOT LIKE '%form%'
	AND LOWER(w.campaign) NOT LIKE '%fb%'
	AND LOWER(w.source) NOT LIKE '%taboola%'
--note no traffic yet for forms or lifecycle
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

UNION
 
SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,1 AS Is_Taboola
,0 AS Is_Email
,'Taboola' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-04-24'
  AND w.source = 'taboola'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,1 AS Is_Email
,'Email' AS Channel
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND LOWER(w.medium) LIKE '%email%' 
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
)