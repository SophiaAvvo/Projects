SELECT u.user_id
,u.persistent_session_id
-- ,m.Channel
,u.firstdate AS Traffic_First_Visit_Date
,f.FirstVisitTime
-- ,m.Date AS GA_First_Visit_Date
FROM Registered_Users_May_2016.user_id_PID_link_201101_to_201604 u
  JOIN (
        SELECT hits.customDimensions.value AS persistent_session_id
          ,MIN(VisitStartTime) FirstVisitTime
          FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2014-2-09'),CURRENT_TIMESTAMP())
          WHERE hits.customDimensions.index = 61
          GROUP BY 1
       ) f
   ON u.persistent_session_id = f.Persistent_Session_ID