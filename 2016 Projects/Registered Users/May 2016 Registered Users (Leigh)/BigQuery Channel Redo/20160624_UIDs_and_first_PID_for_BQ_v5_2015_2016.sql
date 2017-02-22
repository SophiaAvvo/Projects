WITH temp AS (SELECT uad.user_account_id AS user_id
,t.event_date AS traffic_date
,CAST(CAST(t.event_date AS TIMESTAMP) AS BIGINT) visit_date_sec
,uad.user_account_register_datetime reg_datetime
--- ,DATE_ADD(uad.user_account_register_datetime, -1) RegMinus24
,CAST(CAST(uad.user_account_register_datetime AS TIMESTAMP) AS BIGINT) reg_date_sec
,CAST(CAST(DATE_ADD(uad.user_account_register_datetime, -1) AS TIMESTAMP) AS BIGINT) day_before_reg_sec
,t.persistent_session_id
,CAST(CAST(uad.user_account_register_datetime AS TIMESTAMP) AS BIGINT) - CAST(CAST(t.event_date AS TIMESTAMP) AS BIGINT) Diff
,ABS(CAST(CAST(uad.user_account_register_datetime AS TIMESTAMP) AS BIGINT) - CAST(CAST(t.event_date AS TIMESTAMP) AS BIGINT)) AbsDiff
,CASE
	WHEN CAST(CAST(uad.user_account_register_datetime AS TIMESTAMP) AS BIGINT) - CAST(CAST(t.event_date AS TIMESTAMP) AS BIGINT) < 0
		THEN 2
	ELSE 1
END Divider -- want negative values to be stacked below all positive values
FROM dm.traffic t
JOIN dm.user_account_dimension uad
ON uad.user_account_id = CAST(t.resolved_user_id AS INT)
WHERE uad.user_account_register_datetime >= '2015-06-01'
AND uad.user_account_register_datetime < '2016-06-01'
-- ORDER BY 1,2
              )
              
,

/* note will need to use date in bigint since that is seconds, which is same as POSIX */
temp2 AS (
SELECT tp.user_id
,tp.traffic_date
,reg_datetime
,reg_date_sec
,day_before_reg_sec
,tp.persistent_session_id
-- ,CAST(reg_bigint AS TIMESTAMP) reg_reverse_ts -- converts back to previous value successfully
,ROW_NUMBER() OVER(PARTITION BY tp.user_id ORDER BY Divider, AbsDiff) Rank
FROM temp tp
)

SELECT user_id
,traffic_date
,reg_datetime
,reg_date_sec
,day_before_reg_sec
,persistent_session_id
FROM temp2
WHERE Rank = 1

-- note that this was done in two pieces because of row limit