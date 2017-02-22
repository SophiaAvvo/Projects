WITH UID_2_PID AS (

SELECT DISTINCT ua.user_account_id AS user_id
	,ua.user_account_register_datetime reg_date
	,t.persistent_session_id ps_id
	,from_unixtime(unix_timestamp(cast(ua.user_account_register_datetime as timestamp) - interval 1 days), 'yyyy-MM-dd HH:mm:ss') WindowStart
	,from_unixtime(unix_timestamp(cast(ua.user_account_register_datetime as timestamp) + interval 30 days), 'yyyy-MM-dd HH:mm:ss') WindowEnd
 from dm.user_account_dimension ua
 LEFT JOIN dm.traffic t
 ON ua.user_account_id = CAST(t.resolved_user_id aS INT)
WHERE ua.user_account_register_datetime BETWEEN '2015-05-01' AND '2015-05-31'
 
 )
 
select 
CAST(ci.user_id AS INT) user_id
,'Email' AS ActionType
/*,CASE
	WHEN pa.ParentPracticeArea1 IN ('Family', 'Business', 'Immigration', 'Real Estate', 'Estate Planning')
		THEN pa.ParentPracticeArea1
	WHEN pa.ParentPracticeArea2 IN ('Family', 'Business', 'Immigration', 'Real Estate', 'Estate Planning')
		THEN pa.ParentPracticeArea2
	WHEN pa.ParentPracticeArea3 IN ('Family', 'Business', 'Immigration', 'Real Estate', 'Estate Planning')
		THEN pa.ParentPracticeArea3
	ELSE pa.ParentPracticeArea1
END ParentPA*/
,up.WindowStart
,up.WindowEnd
,min(CASE 
		WHEN from_unixtime(ci.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss') BETWEEN up.WindowStart AND up.WindowEnd
			THEN from_unixtime(ci.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss')
		ELSE NULL
	END) FirstActionTime

--, max(ci.created_at) as LastActionTime
from src.contact_impression ci
JOIN UID_2_PID up
	ON up.ps_id = ci.persistent_session_id
AND ci.contact_type = 'email'
AND up.user_id IN (1332908
,1336374
,1343922
,1359117
,1398198
,1411677
,1434155)
)
/*LEFT JOIN PA3 pa
	ON pa.professional_id = ci.professional_id */

group by 1,2,3,4