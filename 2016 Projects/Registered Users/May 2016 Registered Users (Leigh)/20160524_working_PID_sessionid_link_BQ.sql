SELECT y.* 
FROM (SELECT hits.customDimensions.value AS PID
          ,MIN(VisitStartTime) FirstVisit
          FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-4-18'),CURRENT_TIMESTAMP())
          WHERE hits.customDimensions.index = 61
          GROUP BY 1
          ) y
          JOIN (SELECT persistent_session_id 
FROM Registered_Users_May_2016.user_id_PID_link_201101_to_201604
LIMIT 1000) x
ON y.PID = x.persistent_session_id
