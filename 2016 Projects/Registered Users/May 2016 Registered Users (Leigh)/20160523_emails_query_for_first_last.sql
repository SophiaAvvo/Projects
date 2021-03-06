WITH PA1 AS (
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

select 
ci.user_id
,'Email' AS ActionType
,CASE
	WHEN pa.ParentPracticeArea1 IN ('Family', 'Business', 'Immigration', 'Real Estate', 'Estate Planning')
		THEN pa.ParentPracticeArea1
	WHEN pa.ParentPracticeArea2 IN ('Family', 'Business', 'Immigration', 'Real Estate', 'Estate Planning')
		THEN pa.ParentPracticeArea2
	WHEN pa.ParentPracticeArea3 IN ('Family', 'Business', 'Immigration', 'Real Estate', 'Estate Planning')
		THEN pa.ParentPracticeArea3
	ELSE 'Other'
END ParentPA
,min(event_date) FirstActionTime
, max(event_date) as LastActionTime
from src.contact_impression ci
JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
	ON ui.user_id = ci.created_by
	AND ci.created_at BETWEEN from_unixtime(unix_timestamp(cast(ui.reg_time as timestamp) - interval 1 days), 'yyyy-MM-dd HH:mm:ss') AND ui.reg_time
AND ui.reg_time < '2016-05-01'
AND ci.contact_type = 'email'
LEFT JOIN PA4 pa
	ON pa.professional_id = ci.professional_id

group by 1,2
  
