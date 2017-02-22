    LEFT JOIN (SELECT x.PROFESSIONAL_ID
                   ,MIN(CASE WHEN x.rt = 1 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea1
                      ,MIN(CASE WHEN x.rt = 2 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea2
                      ,MIN(CASE WHEN x.rt = 3 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea3
                      ,MIN(CASE WHEN x.rt = 1 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea1
                      ,MIN(CASE WHEN x.rt = 2 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea2
                      ,MIN(CASE WHEN x.rt = 3 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea3
					  ,MAX(x.rt) SpecialtyCount
					  ,MAX(x.specialty_percent) PrimarySpecialtyPercent
               FROM (SELECT pfsp.PROFESSIONAL_ID
                            ,pfsp.SPECIALTY_PERCENT
                            ,sp.SPECIALTY_NAME
                            ,sp.PARENT_SPECIALTY_NAME
                            ,ROW_NUMBER() OVER (PARTITION BY pfsp.PROFESSIONAL_ID ORDER BY pfsp.SPECIALTY_PERCENT DESC) rt
                     FROM DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp
                       JOIN DM.SPECIALTY_DIMENSION sp ON sp.SPECIALTY_ID = pfsp.SPECIALTY_ID
                     WHERE pfsp.DELETE_FLAG = 'N') x
               GROUP BY 1) toppa ON toppa.PROFESSIONAL_ID = pfad.PROFESSIONAL_ID