WITH temp AS (SELECT uad.user_account_id AS user_id
,MIN(t.event_date) firstdate
,uad.user_account_register_datetime
FROM dm.traffic t
JOIN dm.user_account_dimension uad
ON uad.user_account_id = CAST(t.resolved_user_id AS INT)
WHERE uad.user_account_register_datetime >= '2014-02-01'
GROUP BY 1
-- ORDER BY 1,2,3
              )
              
,

temp2 AS (
SELECT tp.user_id
,tp.firstdate
,tp.user_account_register_datetime
,t.persistent_session_id
,ROW_NUMBER() OVER(PARTITION BY tp.user_id ORDER BY t.persistent_session_id) Num
FROM dm.traffic t
JOIN temp tp
ON tp.user_id = CAST(t.resolved_user_id AS INT)
AND tp.firstdate = t.event_date

)

SELECT *
FROM temp2
WHERE Num = 1

-- note that this was done in two pieces because of row limit