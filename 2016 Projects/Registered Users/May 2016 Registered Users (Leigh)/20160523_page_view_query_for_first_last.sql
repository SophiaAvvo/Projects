select p.user_id
	,CASE
    WHEN p.url LIKE '%/auth/google' 
    THEN 'Social Sign-In'
    WHEN p.url LIKE '%/auth/google' 
    THEN 'Social Sign-In'
    WHEN p.url LIKE '%/auth/google' 
    THEN 'Social Sign-In'
    WHEN p.url LIKE '%/auth/google' 
    THEN 'Social Sign-In'
    WHEN p.url LIKE '%/account/register%'
    THEN 'New Account'
    ELSE 
    ActionType
  ,q.Obj_type
	,sd.parent_specialty_name ParentPA
		,MIN(q.created_at) as FirstAction
		,MAX(q.created_at) as LastAction
	from src.page_view p
	JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
		ON ui.user_id = q.created_by
		AND q.created_at BETWEEN date_sub(ui.reg_time, -1) AND ui.reg_time
    left join dm.specialty_dimension sd 
	on sd.specialty_id = p.specialty_id    
	where q.event_date >= '2015-05-01' 
    AND ui.reg_time < '2016-05-01'
	GROUP BY 1,2,3,4
  LIMIT 10;

SELECT DISTINCT page_type
FROM src.page_view