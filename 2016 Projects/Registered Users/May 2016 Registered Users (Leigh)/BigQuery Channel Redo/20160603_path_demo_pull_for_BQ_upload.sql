WITH UID_2_PID AS (

SELECT DISTINCT t.persistent_session_id ps_id
	,CAST(t.resolved_user_id AS INT) user_id
 from dm.traffic t
 JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
 ON ui.user_id = CAST(t.resolved_user_id aS INT)
 AND t.event_date <= to_date(ui.reg_time)
 
 )

SELECT r.*
,up.ps_id
,DATE_ADD(r.registration_day, -3) WindowStart
,DATE_ADD(r.registration_day, 1) WindowEnd
FROM UID_2_PID up
JOIN tmp_data_dm.sr_ru_path_and_demo r
ON up.user_id = r.user_id
WHERE r.registration_day >= '2014-02-01'