SELECT c.*
--  ,u.registration_datetime
-- ,u.reg_time_posix
-- ,
--,u.windowstart
--,u.windowend
--,TIMESTAMP(u.windowstart) ts_start
--,TIMESTAMP(u.windowend) ts_end
FROM (
FLATTEN(
(SELECT VisitStartTime
,USEC_TO_TIMESTAMP(VisitStartTime) VST_timestamp
          ,trafficSource.campaign
          ,trafficSource.source
          ,trafficSource.medium
          ,CURRENT_TIMESTAMP() ts_Now
          ,TIMESTAMP('2014-02-09') ts_begin
          ,DATE(CURRENT_TIMESTAMP()) Timestamp_date
          ,MAX(IF(hits.customDimensions.index=61,hits.customDimensions.value, NULL)) WITHIN hits as Persistent_Session_ID
          --,TIMESTAMP('2014-02-09', "America/Los_Angeles") test
         -- ,STRING(CURRENT_TIMESTAMP()) timestamp_string
          --,STRING(CURRENT_TIMESTAMP(), "America/Los_Angeles") timestamp_convert_pst
          -- ,hits.customDimensions.value
          FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2014-2-09'),CURRENT_TIMESTAMP())
          WHERE hits.customDimensions.value IN ('4262c547-959d-4cd6-bac5-ad4666aac6cd', 'a2c3b456-740c-45cc-afd7-73fded93172a', '52330c39-9bb5-4cbb-86b3-b461a3ab2baa', 'd69e20b9-856a-4702-b981-fb7e07529df9'
          , 'e3899c5f-bc29-4474-9a01-77ec4e81c100', '88a1e67b-5a17-4280-baa9-d77dd15a699e', 'accb7b5b-e2d7-4aad-8703-c6a1d964297e', 'cfd113e7-ca8e-49a3-9f06-b09d19c9aa4b', '0247c728-ac94-4070-905c-f8664bb736b9'
          , '5011c03b-6919-4d51-8b18-9428691ee165')
      )
, persistent_session_id) 

)c
          /*JOIN (
          SELECT *
          ,PARSE_UTC_USEC(registration_datetime) AS reg_time_posix
          FROM Registered_Users_May_2016.user_data_3
          ) u
          ON c.persistent_session_id = u.ps_id */
          
          -- GROUP BY 1,3,4,5
