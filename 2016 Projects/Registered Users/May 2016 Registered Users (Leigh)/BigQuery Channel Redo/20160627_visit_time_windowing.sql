SELECT up.*
,h.VisitStartTime AS VisitStartTime
,up.reg_date_sec - VisitStartTime AS diff_in_sec
,CASE
  WHEN up.reg_date_sec - VisitStartTime < 0
    THEN 2
  ELSE 1
END Window
FROM 
FLATTEN(
(SELECT MAX(IF(hits.customDimensions.index=61,hits.customDimensions.value, NULL)) WITHIN hits as persistent_session_id
          ,VisitStartTime
          FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-5-09'),CURRENT_TIMESTAMP())
      )
     ,persistent_session_id) h
          JOIN Registered_Users_May_2016.UID_PID_link up
          ON up.persistent_session_id = h.persistent_session_id
          WHERE h.VisitStartTime BETWEEN up.day_before_reg_sec AND up.reg_date_sec
          ORDER BY up.user_id
          ,h.visitStartTime