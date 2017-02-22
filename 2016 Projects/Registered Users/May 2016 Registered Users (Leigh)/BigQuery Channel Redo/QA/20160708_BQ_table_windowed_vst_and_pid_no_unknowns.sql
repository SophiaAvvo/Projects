/* note that the times inseconds have already been converted to Unix time, which is in UTC, in Hadoop.  So no time zone conversion is necessary.  */

SELECT 	user_id
	,traffic_date
	,reg_datetime
	,reg_date_sec
	,day_before_reg_sec
	,persistent_session_id
	,VisitStartTime
	,diff_in_sec	
	,Num
FROM (
		SELECT user_id
		,traffic_date
		,reg_datetime
		,reg_date_sec
		,day_before_reg_sec
		,persistent_session_id
		,VisitStartTime
		,diff_in_sec
		,ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY diff_in_sec) Num
		FROM (	
				SELECT up.user_id AS user_id
				,up.traffic_date AS traffic_date
				,up.reg_datetime AS reg_datetime
				,up.reg_date_sec AS reg_date_sec
				,up.day_before_reg_sec AS day_before_reg_sec
				,h.persistent_session_id AS persistent_session_id
				,h.VisitStartTime AS VisitStartTime
				,up.reg_date_sec - VisitStartTime AS diff_in_sec
				/*,CASE
				  WHEN up.reg_date_sec - VisitStartTime < 0
				   THEN 2
				  ELSE 1
				END Window */ -- unnecessary since we aren't looking at anything after reg
				FROM 
				FLATTEN(
						(
							SELECT MAX(IF(hits.customDimensions.index=61,CASE WHEN hits.customDimensions.value = '(unknown)' THEN NULL ELSE hits.customDimensions.value END, NULL)) WITHIN hits as persistent_session_id
								  ,VisitStartTime
								  FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2014-2-09'),CURRENT_TIMESTAMP())
						)
					 ,persistent_session_id
					 ) h
					JOIN Registered_Users_May_2016.UID_PID_link up
						ON up.persistent_session_id = h.persistent_session_id
				WHERE h.VisitStartTime BETWEEN up.day_before_reg_sec AND up.reg_date_sec
				GROUP BY user_id
					,traffic_date
					,reg_datetime
					,reg_date_sec
					,day_before_reg_sec
					,persistent_session_id
					,VisitStartTime
					,diff_in_sec
			)
		)
WHERE Num = 1
ORDER BY user_id