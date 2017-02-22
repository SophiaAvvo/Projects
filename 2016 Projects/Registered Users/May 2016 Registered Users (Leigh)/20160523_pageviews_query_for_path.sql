UID_2_PID AS (

SELECT DISTINCT t.persistent_session_id ps_id
	,CAST(t.resolved_user_id AS INT) user_id
 from dm.traffic t
 JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
 ON ui.user_id = CAST(t.resolved_user_id aS INT)
 AND t.event_date <= to_date(ui.reg_time)
 
 )