SELECT *
FROM src.weblog w
WHERE (
  LOWER(w.campaign) LIKE 'FB_%' -- *starts with* "FB_"
OR w.source LIKE '%facebook%' -- or has the word facebook in it
  )
-- AND w.event_type = 'service_session_payment'
-- split into paid vs. unpaid
--AND w.event_date >= '2016-07-01'
--LIMIT 100;
