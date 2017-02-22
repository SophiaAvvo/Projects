WITH UID_2_PID AS (

SELECT DISTINCT t.persistent_session_id ps_id
	,CAST(t.resolved_user_id AS INT) user_id
 from dm.traffic t
 JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
 ON ui.user_id = CAST(t.resolved_user_id aS INT)
 AND t.event_date <= to_date(ui.reg_time)
 
 )
 

/* start of emails section*/

,PA1 AS (
SELECT pfsp.PROFESSIONAL_ID
          ,sp.PARENT_SPECIALTY_NAME                  
		  ,SUM(pfsp.SPECIALTY_PERCENT) parent_pa_percent
                     FROM DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp
                       JOIN DM.SPECIALTY_DIMENSION sp ON sp.SPECIALTY_ID = pfsp.SPECIALTY_ID
                     WHERE pfsp.DELETE_FLAG = 'N' --AND pfsp.professional_Id < 1000
					 GROUP BY 1,2)

,

PA2 AS (SELECT p.professional_id
,p.parent_specialty_name
,parent_pa_percent
,ROW_NUMBER() OVER (PARTITION BY p.PROFESSIONAL_ID ORDER BY p.parent_pa_percent DESC) ppa_rank
FROM PA1 p

)

,

PA3 AS (
SELECT x.PROFESSIONAL_ID
                      ,MIN(CASE WHEN x.ppa_rank = 1 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea1
                      ,MIN(CASE WHEN x.ppa_rank = 2 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea2
                      ,MIN(CASE WHEN x.ppa_rank = 3 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea3

               FROM PA2 x
               GROUP BY 1
			   
)

,


WITH UID_2_PID AS (

SELECT DISTINCT t.persistent_session_id ps_id
	,CAST(t.resolved_user_id AS INT) user_id
 from dm.traffic t
 JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
 ON ui.user_id = CAST(t.resolved_user_id aS INT)
 AND t.event_date <= to_date(ui.reg_time)
 
 )
 
,

pv AS (
  
SELECT t.gmt_timestamp
  ,COALESCE(p.user_id, CAST(t.user_id AS INT)) MergedUID
  ,t.persistent_session_id
  --,t.persistent_session_id
  --,t.user_id
  --,p.user_id
  --,ROW_NUMBER() OVER(PARTITION BY t.persistent_session_id, t.gmt_timestamp ORDER BY t.user_id) IsDupe
FROM src.page_view t
LEFT JOIN UID_2_PID p
ON t.persistent_session_id = p.ps_id
WHERE t.page_type = 'Account_Register'
-- AND CAST(t.user_id aS INT) <> p.user_id
-- AND t.event_date >= '2016-01-01'
  

  
)
  
,

register_select AS (SELECT r.user_id
,p.persistent_session_id
,r.reg_time
,from_unixtime(p.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss') pv_time_string
,unix_timestamp(cast(r.reg_time as timestamp)) reg_gmt_time
,p.gmt_timestamp
-- ,unix_timestamp(cast(r.reg_time as timestamp)) - p.gmt_timestamp AS time_diff
,ROW_NUMBER() OVER(PARTITION BY r.user_id ORDER BY unix_timestamp(cast(r.reg_time as timestamp)) - p.gmt_timestamp) Time_Rank
FROM pv p
JOIN tmp_data_dm.sr_ru_user_id_and_reg_date r
ON r.user_id = p.MergedUID
AND p.gmt_timestamp BETWEEN unix_timestamp(cast(r.reg_time as timestamp) - interval 3 days)
AND unix_timestamp(cast(r.reg_time as timestamp) + interval 3 days)
AND r.reg_time >= '2016-05-01'
ORDER BY 1,7
                    
)

SELECT r.user_id
,r.persistent_session_id
,pv.page_type
,from_unixtime(pv.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss') pv_time_string
,ROW_NUMBER() OVER(PARTITION BY r.user_id ORDER BY pv.gmt_timestamp DESC) Page_Rank
FROM register_select r
JOIN src.page_view pv
ON pv.persistent_session_id = r.persistent_session_id
AND pv.page_type <> 'Account_Register'
AND pv.gmt_timestamp < r.gmt_timestamp
AND pv.gmt_timestamp > unix_timestamp(cast(r.reg_time as timestamp) - interval 1 days)
AND r.Time_Rank = 1
ORDER BY 1,5



SELECT 
FROM register_selectg

SELECT DISTINCT page_type
		,CASE
				WHEN STRLEFT(t.page_type, 2) = 'LS'
					THEN 'PLS_LP'
				WHEN STRLEFT(t.page_type, 7) = 'Advisor'
					THEN 'AdvisorLP'
			WHEN STRLEFT(t.page_type, 5) = 'Legal'
					THEN 'ContentLP'
				WHEN t.page_type = 'Topics'
					THEN 'ContentLP'
			WHEN STRLEFT(t.page_type, 8) IN ('Attorney', 'Professi')
					THEN 'DirectoryLP'
			WHEN STRLEFT(t.page_type, 3) = 'SEM'
					THEN 'SEM_LP'
			WHEN t.page_type = 'Homepage'
				THEN 'Homepage'
			WHEN 
			ELSE 'Unknown'
		END PageGroup
FROM src.page_view

/*

emails AS (
select 
CAST(ci.user_id AS INT)
,page_type AS ActionType
,CASE
	WHEN pa.ParentPracticeArea1 IN ('Family', 'Business', 'Immigration', 'Real Estate', 'Estate Planning')
		THEN pa.ParentPracticeArea1
	WHEN pa.ParentPracticeArea2 IN ('Family', 'Business', 'Immigration', 'Real Estate', 'Estate Planning')
		THEN pa.ParentPracticeArea2
	WHEN pa.ParentPracticeArea3 IN ('Family', 'Business', 'Immigration', 'Real Estate', 'Estate Planning')
		THEN pa.ParentPracticeArea3
	ELSE pa.ParentPracticeArea1
END ParentPA
,min(from_unixtime(ci.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss')) FirstActionTime
--, max(ci.created_at) as LastActionTime
from src.page_view ci
JOIN UID_2_PID up
	ON up.ps_id = ci.persistent_session_id
JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
	ON ui.user_id = up.user_id
	AND from_unixtime(ci.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss') <= from_unixtime(unix_timestamp(cast(ui.reg_time as timestamp) + interval 30 days), 'yyyy-MM-dd HH:mm:ss')
AND ci.contact_type = 'email'
LEFT JOIN PA3 pa
	ON pa.professional_id = ci.professional_id

group by 1,2,3
  
 ) */