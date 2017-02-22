WITH UID_2_PID AS (
SELECT DISTINCT t.persistent_session_id
	,CAST(t.resolved_user_id AS INT) user_id
	-- ,case when lawyer_user_id = true then 'Lawyer' else '' end as Lawyer
 from dm.traffic t
 where t.resolved_user_id IS NOT NULL
 AND CAST(EXTRACT(year FROM t.event_date) AS INT) >= 2014

 )

WITH traffic AS (select COUNT(persistent_session_id) PIDCount
,COUNT(uad.user_id) UserCount
,dd.yearmonth
	/*, page_type
	, `timestamp`
	, rank() over (partition by persistent_session_id, event_date order by `timestamp`) as rank_one
	, rank() over (partition by persistent_session_id, event_date order by `timestamp` desc) as rank_two */
from src.page_view pv
JOIN UID_2_PID up
	ON up.persistent_session_id = pv.persistent_session_id
JOIN dm.user_account_dimension uad
	ON uad.user_account_id = pv.user_id
	AND pv.event_date BETWEEN DATE_ADD(uad.user_account_register_datetime, -7) AND DATE_ADD(uad.user_account_register_datetime, +7)
GROUP BY 3
)
--where event_date between '2016-05-01' and '2016-05-02'	
--order by persistent_session_id, `timestamp` 
--limit 1000;


SELECT CONCAT(EXTRACT(YEAR FROM user_account_register_datetime), EXTRACT(MONTH FROM user_account_register_datetime)) YearMonth
,COUNT(uad.user_account_id) UserRegCount
,t.UserCount UserTrafficCount
FROM dm.user_account_dimension uad
LEFT JOIN traffic t
	ON t.YearMonth = CONCAT(EXTRACT(YEAR FROM user_account_register_datetime), EXTRACT(MONTH FROM user_account_register_datetime))
GROUP BY 1
WHERE uad.user_account_register_datetime >= '2015-05-01'
