WITH temp AS (SELECT uad.user_account_id AS user_id
,t.event_date firstdate
,CAST(CAST(t.event_date AS TIMESTAMP) AS BIGINT) date_bigint
,uad.user_account_register_datetime RegDatetime
,DATE_ADD(uad.user_account_register_datetime, -1) RegMinus24
,CAST(CAST(uad.user_account_register_datetime AS TIMESTAMP) AS BIGINT) reg_bigint
,t.persistent_session_id
,CAST(CAST(uad.user_account_register_datetime AS TIMESTAMP) AS BIGINT) - CAST(CAST(t.event_date AS TIMESTAMP) AS BIGINT) Diff
,ABS(CAST(CAST(uad.user_account_register_datetime AS TIMESTAMP) AS BIGINT) - CAST(CAST(t.event_date AS TIMESTAMP) AS BIGINT)) AbsDiff
,CASE
	WHEN CAST(CAST(uad.user_account_register_datetime AS TIMESTAMP) AS BIGINT) - CAST(CAST(t.event_date AS TIMESTAMP) AS BIGINT) < 0
		THEN 2
	ELSE 1
END Window
FROM dm.traffic t
JOIN dm.user_account_dimension uad
ON uad.user_account_id = CAST(t.resolved_user_id AS INT)
WHERE uad.user_account_register_datetime BETWEEN '2015-02-01' AND '2015-06-01'
-- ORDER BY 1,2
              )
              
,

/* note will need to use date in bigint since that is seconds, which is same as POSIX */
temp2 AS (
SELECT tp.user_id
,tp.firstdate
,RegDatetime
,RegMinus24
,t.persistent_session_id
,Diff
,AbsDiff
,Window
,CAST(reg_bigint AS TIMESTAMP) reg_reverse_ts -- converts back to previous value successfully
,ROW_NUMBER() OVER(PARTITION BY tp.user_id ORDER BY Window, AbsDiff) Rank
FROM dm.traffic t
JOIN temp tp
ON tp.user_id = CAST(t.resolved_user_id AS INT)
AND tp.firstdate = t.event_date
)

SELECT *
FROM temp2
WHERE Rank = 1

-- note that this was done in two pieces because of row limit