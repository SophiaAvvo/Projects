SELECT u.user_id
,c.persistent_session_id
,c.channel_time
,u.geo_type
,u.postal_code
,u.geo_latitude
,u.geo_longitude
,u.geo_population
,u.registration_day
,u.registration_datetime
,u.has_name
,u.emaildomain
,u.birthyear
,u.returnonceflag
,u.returntwiceflag
,u.lastvisittoregistratoin AS lastvisittoregistration
,u.gender
,u.state
,u.county
,u.city
,u.income
,u.children
,u.maritalstatus
,u.lawyerconsumertag
,u.contactsfilter
,u.actiontype
,u.parentpa
,u.firstaction
,u.relativetiming
,u.parentpa_group
,u.windowstart
,u.windowend

FROM Registered_Users_May_2016.user_data_2 u
  JOIN (
        SELECT hits.customDimensions.value AS persistent_session_id
          ,MIN(VisitStartTime) channel_time
          FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2014-2-09'),CURRENT_TIMESTAMP())
          WHERE hits.customDimensions.index = 61
          GROUP BY 1
       ) c
   ON c.persistent_session_id = u.ps_id
   WHERE c.channel_time BETWEEN u.windowstart AND u.windowend