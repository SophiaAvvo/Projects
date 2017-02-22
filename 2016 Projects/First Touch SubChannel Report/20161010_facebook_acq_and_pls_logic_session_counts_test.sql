SELECT COUNT(persistent_session_id)
,'Facebook' AS Channel
,campaign
-- ,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-02-08' -- ALS product launch
  AND (LOWER(w.campaign) LIKE 'fb_%' -- must *begin with* this; note some are lower case (rarely)
OR w.source LIKE '%facebook%'
OR w.campaign LIKE '%PLS|%'
OR w.campaign = 'pls'
OR w.campaign = 'plsremarketing')
GROUP BY 2,3
