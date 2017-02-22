WITH UID_2_PID AS (

SELECT DISTINCT t.persistent_session_id ps_id
	,CAST(t.resolved_user_id AS INT) user_id
	,ua.user_account_register_datetime reg_date
	,from_unixtime(unix_timestamp(cast(ua.user_account_register_datetime as timestamp) - interval 1 days), 'yyyy-MM-dd HH:mm:ss') WindowStart
	,from_unixtime(unix_timestamp(cast(ua.user_account_register_datetime as timestamp) + interval 30 days), 'yyyy-MM-dd HH:mm:ss') WindowEnd
 from dm.traffic t
 JOIN dm.user_account_dimension ua
 ON ua.user_account_id = CAST(t.resolved_user_id aS INT)
 -- AND t.event_date <= to_date(ua.user_account_register_datetime)
 /* got rid of this with the update... I think I was trying to make sure I only got data connected to their registration, but I'm not sure it's helpful */

 
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
/*LEFT JOIN PA3 pa
	ON pa.professional_id = ci.professional_id */

group by 1,2,3,4