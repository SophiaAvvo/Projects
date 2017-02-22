SELECT up.*
,h.VisitStartTime
FROM 
(SELECT hits.customDimensions.value AS persistent_session_id
          ,VisitStartTime
          FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-2-09'),CURRENT_TIMESTAMP())
          WHERE hits.customDimensions.index = 61) h
          JOIN Registered_Users_May_2016.UID_PID_link up
          ON up.persistent_session_id = h.persistent_session_id
          WHERE h.VisitStartTime BETWEEN up.day_before_reg_sec AND up.reg_date_sec
          ORDER BY up.user_id
          ,h.visitStartTime