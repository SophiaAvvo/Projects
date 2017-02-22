select q.created_by AS user_id
	,regexp_extract(q.Obj_type, '::([A-Za-z]+)', 1) as ActionType
  ,q.Obj_type
	,'Unknown' ParentPA
		,MIN(q.created_at) as FirstAction
		,MAX(q.created_at) as LastAction
	from src.content_vote q
	JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
		ON ui.user_id = q.created_by
		AND q.created_at BETWEEN from_unixtime(unix_timestamp(cast(ui.reg_time as timestamp) - interval 1 days), 'yyyy-MM-dd HH:mm:ss') AND ui.reg_time
	where to_date(q.created_at) >= '2011-01-01' 
	GROUP BY 1,2,3,4
