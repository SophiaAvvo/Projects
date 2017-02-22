/* Questions:
1. WHat is the demographic breakdown over time?
	- sharing names with us x
	- type of email address
	- email domain x
	- email domain size 
	- age x
	- gender x
	- top geo x
	- urbanicity x
	- income x
	- children x
	- marital status x
2. When do users in different demo groups register?
	- local time of day
	- weekday x
	- month x
3. What happened in their registration session? (get from datetime match)
	- number of total sessions that DAY x
	- whether logged in or out x
	- number of pages viewed x
	- types of pages viewed x
	- devices used: #, type
	0 actions taken
4. How many times had they visited before?
- number of persistent session IDs
- number of session IDs
- number of distinct days visited
- frequency
- time from first visit to registration

Notes: - asking Nadine about whether we can get IP address and tack on geo for every visit... 

Size Estimate: 10-15M rows as is
	
*/
WITH demo AS (select user_account_id user_id
	,g.geo_type
	,CASE
		WHEN g.geo_postal_code = 'Not Applicable'
			THEN NULL
		ELSE g.geo_postal_code
	END Postal_Code
	,g.geo_latitude
	,g.geo_longitude
	-- ,g.geo_state_code
	-- ,g.geo_county_name
	,CASE
		WHEN g.geo_population = -1
			THEN NULL
		ELSE g.geo_population
	END geo_population
	,to_date(ua.user_account_register_datetime) registration_day
	,ua.user_account_register_datetime registration_datetime
	,CASE
		WHEN user_account_name = 'Unknown'
			THEN 0
		ELSE 1
	END HasName
	,substr(ua.user_account_email_address,instr (ua.user_account_email_address,'@') +1) AS emaildomain
	,CASE
		WHEN ua.user_account_birth_year = '-1'
			THEN NULL
		ELSE ua.user_account_birth_year
	END BirthYear
	,CASE
		WHEN ua.user_account_last_login_datetime > ua.user_account_register_datetime
			THEN 1
		ELSE 0
	END ReturnOnceFlag
	,CASE
		WHEN ua.user_account_previous_to_last_login_datetime > ua.user_account_register_datetime
		AND DATEDIFF(ua.user_account_last_login_datetime, ua.user_account_previous_to_last_login_datetime) >= 1
			THEN 1
		ELSE 0
	END ReturnTwiceFlag
	,CASE
		WHEN EXTRACT(YEAR FROM ua.user_account_last_login_datetime) <> 1900
			THEN DATEDIFF(ua.user_account_last_login_datetime, ua.user_account_register_datetime)
		ELSE NULL
	END LastVisitToRegistration
	,ua.user_account_gender Gender
	,CASE
		WHEN ua.user_account_state_name = 'Not Applicable'
			THEN NULL
		ELSE ua.user_account_state_name
	END State
	,CASE
		WHEN ua.user_account_county_name = 'Not Applicable'
			THEN NULL
		ELSE ua.user_account_county_name
	END County
	,CASE
		WHEN ua.user_account_city_name = 'Not Applicable'
			THEN NULL
		ELSE ua.user_account_city_name
	END City
	,ua.user_account_household_income Income
	,ua.user_account_has_child_indicator Children
	,ua.user_account_marital_status MaritalStatus
	,CASE
		WHEN pd.professional_id IS NOT NULL
			THEN 'Lawyer'
		ELSE 'Consumer/Other'
	END LawyerConsumerTag
	,CASE
		wHEN ua.user_account_register_datetime >= '2015-05-01'
			THEN 'After Contacts/Weblogs Start'
		ELSE 'Before Contacts/Weblogs Start'
	END ContactsFilter
	-- ,from_unixtime(unix_timestamp(cast(ua.user_account_register_datetime as timestamp) - interval 1 days), 'yyyy-MM-dd HH:mm:ss') WindowStartTime
from  dm.user_account_dimension ua
	LEFT JOIN dm.geography_dimension g
		ON g.geo_id = ua.user_account_geography_id
	LEFT JOIN dm.professional_dimension pd
		On ua.user_account_id = CAST(pd.professional_user_account_id AS INT)
WHERE ua.user_account_register_datetime BETWEEN '2011-01-01' AND '2016-04-30'
	/*CROSS JOIN dm.date_dim dd
where dd.yearmonth >= 201401 */
	-- AND EXTRACT(DAY FROM user_account_register_datetime) = 11

)

,

UID_2_PID AS (

SELECT DISTINCT t.persistent_session_id ps_id
	,CAST(t.resolved_user_id AS INT) user_id
 from dm.traffic t
 JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
 ON ui.user_id = CAST(t.resolved_user_id aS INT)
 AND t.event_date <= to_date(ui.reg_time)
 
 )
 
,

review AS (select 
ci.created_by user_id
	,'Review' AS ActionType
	,sd.parent_specialty_name ParentPA
,min(created_at) FirstAction
-- , max(created_at) as LastActionTime
from src.barrister_professional_review ci
JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
	ON ui.user_id = ci.created_by
	AND ci.created_at <= from_unixtime(unix_timestamp(cast(ui.reg_time as timestamp) + interval 30 days), 'yyyy-MM-dd HH:mm:ss')
left join dm.specialty_dimension sd 
	on sd.specialty_id = ci.specialty_id

group by 1,2,3
-- ORDER BY 1
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

emails AS (
select 
CAST(ci.user_id AS INT)
,'Email' AS ActionType
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
from src.contact_impression ci
JOIN UID_2_PID up
	ON up.ps_id = ci.persistent_session_id
JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
	ON ui.user_id = up.user_id
	AND from_unixtime(ci.gmt_timestamp, 'yyyy-MM-dd HH:mm:ss') <= from_unixtime(unix_timestamp(cast(ui.reg_time as timestamp) + interval 30 days), 'yyyy-MM-dd HH:mm:ss')
AND ci.contact_type = 'email'
LEFT JOIN PA3 pa
	ON pa.professional_id = ci.professional_id

group by 1,2,3
  
 )
 
 ,

questions as
(
	select q.created_by AS user_id
	,'Ask a Question' as ActionType
	,sd.parent_specialty_name ParentPA
		,MIN(q.created_at) as FirstAction
		-- ,MAX(q.created_at) as LastAction
	from src.content_question q
	JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
		ON ui.user_id = q.created_by
		AND q.created_at <= from_unixtime(unix_timestamp(cast(ui.reg_time as timestamp) + interval 30 days), 'yyyy-MM-dd HH:mm:ss')
	left join dm.specialty_dimension sd on sd.specialty_id = q.specialty_id
	where q.approval_status_id in (1,2)
	   AND (q.created_by <> 1 OR q.updated_by <> 1)
	GROUP BY 1,2,3
)

,

content_vote AS (

select q.created_by AS user_id
	,regexp_extract(q.Obj_type, '::([A-Za-z]+)', 1) as ActionType
	,'Unknown' ParentPA
		,MIN(q.created_at) as FirstAction
		-- ,MAX(q.created_at) as LastAction
	from src.content_vote q
	JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
		ON ui.user_id = q.created_by
		AND q.created_at <= from_unixtime(unix_timestamp(cast(ui.reg_time as timestamp) + interval 30 days), 'yyyy-MM-dd HH:mm:ss')
	GROUP BY 1,2,3
)

, activities AS (

SELECT *
FROM review

UNION ALL 

SELECT *
FROM questions

UNION ALL 

SELECT *
FROM content_vote

UNION ALL

SELECT *
FROM emails

)

,

register_path AS (

SELECT *
,ROW_NUMBER() OVER(PARTITION BY a.user_id ORDER BY a.FirstAction) ActionRank
FROM activities a

)

SELECT d.*
,r.ActionType
,r.ParentPA
,r.FirstAction
,CASE
	WHEN r.FirstAction > d.registration_datetime
		THEN 'After Registration'
	ELSE 'Before Registration'
END RelativeTiming
,CASE
	WHEN r.ParentPA IN ('Family', 'Business')
		THEN r.ParentPA
	ELSE 'Other'
END AS ParentPA_Group
FROM demo d
LEFT JOIN register_path r
ON r.user_id = d.user_id
AND r.ActionRank = 1

