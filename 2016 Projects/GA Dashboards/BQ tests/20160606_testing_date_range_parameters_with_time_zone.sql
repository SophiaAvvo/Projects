SELECT hits.customDimensions.value AS persistent_session_id
          ,VisitStartTime
          ,trafficSource.campaign
          ,trafficSource.source
          ,trafficSource.medium
          ,CURRENT_TIMESTAMP() ts_Now
          ,TIMESTAMP('2014-02-09') ts_begin
          ,DATE(CURRENT_TIMESTAMP()) Timestamp_date
          ,TIMESTAMP('2014-02-09', "America/Los_Angeles") test
         -- ,STRING(CURRENT_TIMESTAMP()) timestamp_string
          --,STRING(CURRENT_TIMESTAMP(), "America/Los_Angeles") timestamp_convert_pst
          -- ,hits.customDimensions.value
          FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2014-2-09'),CURRENT_TIMESTAMP())
          WHERE hits.customDimensions.index = 61
          AND hits.customDimensions.value = '5b4c8b04-25bf-4c1e-87ff-3ee819cc268a'
          -- GROUP BY 1,3,4,5
          LIMIT 1000;