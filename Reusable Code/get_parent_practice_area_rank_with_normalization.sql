WITH PA1 AS (
SELECT pfsp.PROFESSIONAL_ID
          ,sp.PARENT_SPECIALTY_NAME                  
		  ,SUM(pfsp.SPECIALTY_PERCENT) parent_pa_percent
                     FROM DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp
                       JOIN DM.SPECIALTY_DIMENSION sp ON sp.SPECIALTY_ID = pfsp.SPECIALTY_ID
                     WHERE pfsp.DELETE_FLAG = 'N' AND pfsp.professional_Id < 1000
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
                      ,AVG(CASE WHEN x.ppa_rank = 1 THEN x.parent_pa_percent ELSE NULL END) AS PPA1Percent
                      ,AVG(CASE WHEN x.ppa_rank = 2 THEN x.parent_pa_percent ELSE NULL END) AS PPA2Percent
                      ,AVG(CASE WHEN x.ppa_rank = 3 THEN x.parent_pa_percent ELSE NULL END) AS PPA3Percent
                      ,SUM(CASE WHEN x.ppa_rank IN (1,2,3) THEN x.parent_pa_percent ELSE 0 END) AS Pct_Norml
					  ,MAX(x.ppa_rank) ParentPACount
					  ,MAX(x.parent_pa_percent) PrimarySpecialtyPercent
               FROM PA2 x
               GROUP BY 1
			   
)

PA4 AS (
SELECT p.professional_id
,p.ParentPracticeArea1
,p.ParentPracticeArea2
,p.ParentPracticeArea3
,PPA1Percent/Pct_Norml
,PPA2Percent/Pct_Norml
,PPA3Percent/Pct_Norml
FROM PA3 p

)
