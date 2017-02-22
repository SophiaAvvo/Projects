SELECT DISTINCT t.persistent_session_id ps_id
	,t.resolved_user_id user_id
    ,ui.reg_time registration_datetime
    ,to_date(ui.reg_time) registration_date
    ,t.persistent_session_id
	,case when lawyer_user_id = true then 'Lawyer' else '' end as LawyerTag
 from dm.traffic t
 JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
 ON ui.user_id = CAST(t.resolved_user_id aS INT)
 AND t.event_date = to_date(ui.reg_time)
 where t.resolved_user_id IS NOT NULL
 AND t.event_date BETWEEN '2016-01-01' AND '2016-04-30'