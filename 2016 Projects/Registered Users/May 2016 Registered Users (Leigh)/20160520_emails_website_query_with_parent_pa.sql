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
                      ,AVG(CASE WHEN x.ppa_rank = 1 THEN x.parent_pa_percent ELSE NULL END) AS PPA1Percent
                      ,AVG(CASE WHEN x.ppa_rank = 2 THEN x.parent_pa_percent ELSE NULL END) AS PPA2Percent
                      ,AVG(CASE WHEN x.ppa_rank = 3 THEN x.parent_pa_percent ELSE NULL END) AS PPA3Percent
                      ,SUM(CASE WHEN x.ppa_rank IN (1,2,3) THEN x.parent_pa_percent ELSE 0 END) AS Pct_Norml
					  ,MAX(x.ppa_rank) ParentPACount
					  ,MAX(x.parent_pa_percent) PrimarySpecialtyPercent
               FROM PA2 x
               GROUP BY 1
			   
)

,

PA4 AS (
SELECT p.professional_id
,p.ParentPracticeArea1
,p.ParentPracticeArea2
,p.ParentPracticeArea3
,PPA1Percent/Pct_Norml AS PA1_Weight
,PPA2Percent/Pct_Norml AS PA2_Weight
,PPA3Percent/Pct_Norml AS PA3_Weight
FROM PA3 p

)

select 
ci.user_id
	,CASE
		WHEN to_date(uad.user_account_register_datetime) < ci.event_date
			THEN 'Post-Registration'
		WHEN to_date(uad.user_account_register_datetime) = ci.event_date
			THEN 'Day of Registration'
		WHEN to_date(uad.user_account_register_datetime) > ci.event_date
			THEN 'Pre-Registration'
		ELSE 'Missing'
		END timewindow
	,SUM(CASE
		WHEN ParentPracticeArea1 = 'Family'
			THEN 1
		ELSE 0
	END) FamilyEmails
	,SUM(CASE
			WHEN ParentPracticeArea1 = 'Immigration'
				THEN 1
			ELSE 0
		END) ImmigrationEmails
	,SUM(CASE
			WHEN ParentPracticeArea1 = 'Business'
				THEN 1
			ELSE 0
		END) BusinessEmails
	,SUM(CASE
			WHEN ParentPracticeArea1 = 'Estate Planning'
				THEN 1
			ELSE 0
		END) EstatePlanningEmails
	,SUM(CASE
			WHEN ParentPracticeArea1 = 'Real Estate'
				THEN 1
			ELSE 0
		END) RealEstateEmails
	,COUNT(ci.professional_id) TotalEmails
	,AVG(CASE
			WHEN ParentPracticeArea1 = 'Family'
				THEN PA1_Weight
			WHEN ParentPracticeArea2 = 'Family'
				THEN PA2_Weight
			WHEN ParentPracticeArea3 = 'Family'
				THEN PA3_Weight
			ELSE 0
		END) AvgFamilyPercent
	,AVG(CASE
			WHEN ParentPracticeArea1 = 'Business'
				THEN PA1_Weight
			WHEN ParentPracticeArea2 = 'Business'
				THEN PA2_Weight
			WHEN ParentPracticeArea3 = 'Business'
				THEN PA3_Weight
			ELSE 0
		END) AvgBusinessPercent
	,AVG(CASE
			WHEN ParentPracticeArea1 = 'Immigration'
				THEN PA1_Weight
			WHEN ParentPracticeArea2 = 'Immigration'
				THEN PA2_Weight
			WHEN ParentPracticeArea3 = 'Immigration'
				THEN PA3_Weight
			ELSE 0
		END) AvgImmigrationPercent
	,AVG(CASE
			WHEN ParentPracticeArea1 = 'Estate Planning'
				THEN PA1_Weight
			WHEN ParentPracticeArea2 = 'Estate Planning'
				THEN PA2_Weight
			WHEN ParentPracticeArea3 = 'Estate Planning'
				THEN PA3_Weight
			ELSE 0
		END) AvgEstatePlanPercent
	,AVG(CASE
			WHEN ParentPracticeArea1 = 'Real Estate'
				THEN PA1_Weight
			WHEN ParentPracticeArea2 = 'Real Estate'
				THEN PA2_Weight
			WHEN ParentPracticeArea3 = 'Real Estate'
				THEN PA3_Weight
			ELSE 0
		END) AvgRealEstatePercent
,min(event_date) FirstEmailContact
, max(event_date) as last_email_contact
from src.contact_impression ci
JOIN dm.user_account_dimension uad
ON uad.user_account_id = CAST(ci.user_id AS INT)
AND ci.contact_type = 'email'
-- AND ci.event_date = '2016-02-14'
LEFT JOIN PA4 pa
	ON pa.professional_id = ci.professional_id

group by 1,2
  
