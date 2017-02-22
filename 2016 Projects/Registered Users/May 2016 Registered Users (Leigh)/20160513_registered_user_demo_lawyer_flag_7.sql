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
from  dm.user_account_dimension ua
	LEFT JOIN dm.geography_dimension g
		ON g.geo_id = ua.user_account_geography_id
	LEFT JOIN dm.professional_dimension pd
		On ua.user_account_id = CAST(pd.professional_user_account_id AS INT)
WHERE ua.user_account_register_datetime >= '2011-01-01'
	/*CROSS JOIN dm.date_dim dd
where dd.yearmonth >= 201401 */
	-- AND EXTRACT(DAY FROM user_account_register_datetime) = 11

)

,

UID_2_PID AS (
SELECT DISTINCT t.persistent_session_id
	,CAST(t.resolved_user_id AS INT) user_id
	-- ,case when lawyer_user_id = true then 'Lawyer' else '' end as Lawyer
 from dm.traffic t
 where t.resolved_user_id IS NOT NULL
 AND CAST(EXTRACT(year FROM t.event_date) AS INT) >= 2014

 )

,
/* rolling up to the day level to avoid the need for multiple count distincts */
daily_traffic AS (
	
	SELECT up.user_id
		,t.event_date
		,COUNT(t.session_id) TotalSessions
		,COUNT(DISTINCT t.session_id) DistinctSessions
		,SUM(cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as DECIMAL)) TotalPVs
		,SUM(CASE
			WHEN t.resolved_user_id IS NOT NULL
				THEN cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
			ELSE 0
		END) LoggedInPVs
		,SUM(CASE
			WHEN t.resolved_user_id IS NULL
				THEN cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
			ELSE 0
		END) LoggedOutPVs
		,SUM(CASE
				WHEN t.lpv_device_category_id IN (2, 3, 6, 7)
					THEN cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) MobileDevicePVs
		,SUM(CASE
				WHEN t.lpv_device_category_id IN (4,5,8)
					THEN  cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) OtherDevicePVs
		,SUM(CASE
				WHEN t.lpv_device_category_id = 1
					THEN cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) DesktopPVs
		,SUM(CASE
				WHEN t.lpv_device_category_id IS NULL
					THEN cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) UnknownDevicePVs
		,SUM(CASE
				WHEN t.lpv_device_category_id IS NOT NULL
					THEN cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) KnownDevicePVs
		,SUM(CASE
				WHEN STRLEFT(t.lpv_page_type, 2) = 'LS'
					THEN 1
				ELSE 0
			END) NumPLS_LP
		,SUM(CASE
				WHEN STRLEFT(t.lpv_page_type, 7) = 'Advisor'
					THEN 1
				ELSE 0
			END) NumAdvisorLP
		,SUM(CASE
				WHEN STRLEFT(t.lpv_page_type, 5) = 'Legal'
					THEN 1
				WHEN t.lpv_page_type = 'Topics'
					THEN 1
				ELSE 0
			END) NumContentLP
		,SUM(CASE
				WHEN STRLEFT(t.lpv_page_type, 8) IN ('Attorney', 'Professi')
					THEN 1
				ELSE 0
			END) NumDirectoryLP
		,SUM(CASE
				WHEN STRLEFT(t.lpv_page_type, 3) = 'SEM'
					THEN 1
				ELSE 0
			END) NumSEM_LP
		,SUM(CAST(regexp_extract(page_type_summary, '"Find A Lawyer": ([0-9]+)', 1) AS INT)) as PV_Find_A_Lawyer
		,SUM(CAST(regexp_extract(page_type_summary, '"Lawyer Dashboard": ([0-9]+)', 1) AS INT)) as PV_Lawyer_Dashboard
		,SUM(CAST(regexp_extract(page_type_summary, '"Lawyer Profile": ([0-9]+)', 1) AS INT)) as PV_Lawyer_Profile
		,SUM(CAST(regexp_extract(page_type_summary, '"Lawyer SERP": ([0-9]+)', 1) AS INT)) as PV_Lawyer_SERP
		,SUM(CAST(regexp_extract(page_type_summary, '"Ask A Lawyer": ([0-9]+)', 1) AS INT)) as PV_Ask_A_Lawyer
		,SUM(CAST(regexp_extract(page_type_summary, '"Free Legal Advice": ([0-9]+)', 1) AS INT)) as PV_Free_Legal_Advice
		,SUM(CAST(regexp_extract(page_type_summary, '"Guide Detail": ([0-9]+)', 1) AS INT)) as PV_Guide_Detail
		,SUM(CAST(regexp_extract(page_type_summary, '"KB SERP": ([0-9]+)', 1) AS INT)) as PV_KB_SERP
		,SUM(CAST(regexp_extract(page_type_summary, '"QA Detail": ([0-9]+)', 1) AS INT)) as PV_QA_Detail
		,SUM(CAST(regexp_extract(page_type_summary, '"Topics": ([0-9]+)', 1) AS INT)) as PV_Topics
		,SUM(CAST(regexp_extract(page_type_summary, '"Homepage": ([0-9]+)', 1) AS INT)) as PV_Homepage
		,SUM(CAST(regexp_extract(page_type_summary, '"Account": ([0-9]+)', 1) AS INT)) as PV_Account
		,SUM(CAST(regexp_extract(page_type_summary, '"Support": ([0-9]+)', 1) AS INT)) as PV_Support
		,SUM(CAST(regexp_extract(page_type_summary, '"Unknown": ([0-9]+)', 1) AS INT)) as PV_Unknown
		-- ,SUM() add something here about checkout?
		FROM dm.traffic t
	JOIN UID_2_PID up
		ON up.persistent_session_id = t.persistent_session_id
		AND t.event_date >= '2014-01-01'
	left join dm.device_category_dim dcd 
		on dcd.device_category_id = t.lpv_device_category_id
		--AND d.registration_date <= t.event_date
	group by 1,2

)


SELECT d.*
		,t.event_date
		,CASE
			WHEN t.event_date < d.registration_day
				THEN 'Pre-Registration'
			WHEN t.event_date = d.registration_day
				THEN 'Day of Registration'
			WHEN t.event_date > d.registration_day
				THEN 'Post-Registration'
			END TimeWindow
		,CASE 
			WHEN d.registration_day > t.event_date
				THEN 'Not Yet Registered'
			WHEN DATEDIFF(t.event_date, d.registration_day) < 30
				THEN '< 30 Days'
			WHEN DATEDIFF(t.event_date, d.registration_day) BETWEEN 30 AND 90
				THEN '1 - 3 Months'
			WHEN DATEDIFF(t.event_date, d.registration_day) BETWEEN 91 AND 182
				THEN '3 - 6 Months'
			WHEN DATEDIFF(t.event_date, d.registration_day) BETWEEN 183 AND 364
				THEN '6 - 12 Months'
			WHEN DATEDIFF(t.event_date, d.registration_day) BETWEEN 365 AND 730
				THEN '1 - 2 Years'
			WHEN DATEDIFF(t.event_date, d.registration_day) BETWEEN 731 AND 1826
				THEN '2 - 5 Years'
			WHEN DATEDIFF(t.event_date, d.registration_day) > 1826
				THEN '> 5 Years'
			END TimeSinceRegistration
		,CASE
			WHEN TotalSessions = DistinctSessions
				THEN 1
			ELSE 0
		END IsBadSessionCount
		,DistinctSessions
		,TotalPVs
		,LoggedInPVs
		,LoggedOutPVs
		,MobileDevicePVs
		,DesktopPVs
		,KnownDevicePVs
		,UnknownDevicePVs
		,OtherDevicePVs
		,NumPLS_LP
		,NumAdvisorLP
		,NumContentLP
		,NumDirectoryLP
		,NumSEM_LP
		,PV_Find_A_Lawyer
		,PV_Lawyer_Dashboard
		,PV_Lawyer_Profile
		,PV_Lawyer_SERP
		,PV_Ask_A_Lawyer
		,PV_Free_Legal_Advice
		,PV_Guide_Detail
		,PV_KB_SERP
		,PV_QA_Detail
		,PV_Topics
		,PV_Homepage
		,PV_Account
		,PV_Support
		,PV_Unknown
		,TotalPVs/TotalSessions PVs_per_Session_uw
		,LoggedInPVs/TotalPVs LoggedInPVs_pct_uw
		,LoggedOutPVs/TotalPVs LoggedOutPVs_pct_uw
		,MobileDevicePVs/KnownDevicePVs Mobile_PVs_pct_uw
		,DesktopPVs/KnownDevicePVs Desktop_PVs_pct_uw
		,UnknownDevicePVs/TotalPVs Unknown_Device_PVs_pct_uw
		,OtherDevicePVs/KnownDevicePVs Other_Device_PVs_pct_uw
		,NumPLS_LP/TotalSessions PLS_LP_pct_uw
		,NumAdvisorLP/TotalSessions Adviser_LP_pct_uw
		,NumContentLP/TotalSessions Content_LP_pct_uw
		,NumDirectoryLP/TotalSessions Directory_LP_pct_uw
		,NumSEM_LP/TotalSessions SEM_LP_pct_uw
		,PV_Find_A_Lawyer/TotalPVs PV_Find_a_Lawyer_pct_uw
		,PV_Lawyer_Dashboard/TotalPVs PV_Lawyer_Dashboard_pct_uw
		,PV_Lawyer_Profile/TotalPVs PV_Laywer_Profile_pct_uw
		,PV_Lawyer_SERP/TotalPVs PV_Laywer_SERP_pct_uw
		,PV_Ask_A_Lawyer/TotalPVs PV_Ask_A_Lawyer_pct_uw
		,PV_Free_Legal_Advice/TotalPVs PV_Free_Legal_Advice_pct_uw
		,PV_Guide_Detail/TotalPVs PV_Guide_Detail_pct_uw
		,PV_KB_SERP/TotalPVs PV_KB_SERP_pct_uw
		,PV_QA_Detail/TotalPVs PV_QA_Detail_pct_uw
		,PV_Topics/TotalPVs PV_Topics_pct_uw
		,PV_Homepage/TotalPVs PV_Homepage_pct_uw
		,PV_Account/TotalPVs PV_Account_pct_uw
		,PV_Support/TotalPVs PV_Support_pct_uw
		,PV_Unknown/TotalPVs PV_Unknown_pct_uw
FROM demo d
	LEFT JOIN daily_traffic t
		ON t.user_id = d.user_id
	/*LeFT JOIN dm.date_dim dd
		ON dd.actual_date = t.event_date */
	-- group by 1,2,3	


		
/* Code graveyard: 

,SUM(CASE
				WHEN t.event_date < d.registration_date
					THEN cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) PreRegistrationPVs
		,SUM(CASE
				WHEN t.event_date = d.registration_date
					THEN cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) RegistrationDayPVs
		,SUM(CASE
				WHEN t.event_date > d.registration_date
					THEN cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) PostRegistrationPVs
			,MIN(CASE
					WHEN t.event_date < d.registration_date
						THEN t.event_date
					ELSE NULL
				END) First_Visit_Pre_Reg
			,MAX(CASE
					WHEN t.event_date < d.registration_date
						THEN t.event_date
					ELSE NULL
				END) Last_Visit_Pre_Reg
			,MIN(CASE
					WHEN t.event_date < d.registration_date
						THEN t.event_date
					ELSE NULL
				END) First_Visit_Pre_Reg
			,MAX(CASE
					WHEN t.event_date < d.registration_date
						THEN t.event_date
					ELSE NULL
				END) Last_Visit_Pre_Reg	
				
**********************************

traffic AS (

 SELECT up.resolved_user_id
	,MIN(t.event_date) DateFirstVisit
	,MAX(t.event_date) DateLastVisit
	,COUNT(DISTINCT t.event_date) DaysVisitedTotal
	,sum(cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)) as TotalPageviews
	,
 FROM dm.traffic t
	JOIN UID_2_PID up
		ON up.persistent_session_id = t.persistent_session_id
	LEFT JOIN demo d
		ON d.user_id = up.user_id
		AND d.registration_date = t.event_date
GROUP BY 1

)

*****************************************************

, prior_visits AS (
 SELECT up.resolved_user_id
	,MIN(t.event_date) DateFirstVisitPrior
	,MAX(t.event_date) DateLastVisitPrior
	,COUNT(DISTINCT t.event_date) PriorDaysVisited
	,sum(cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)) as TotalPageviews
	,
 FROM (SELECT DISTINCT t.persistent_session_id
		,t.event_date
		,t.resolved_user_id user_id
		,
		FROM dm.traffic t
	JOIN UID_2_PID up
		ON up.persistent_session_id = t.persistent_session_id
	JOIN demo d
		ON d.user_id = up.user_id
		AND d.registration_date < t.event_date
GROUP BY 1)

********************************************


SELECT d.*
	,p.PIDCount
	,CASE
		WHEN t.
	,SessionCountFlag
	,LoggedInPVs
		,LoggedOutPVs
		,MobileDevicePVs
		,EntertainmentSystemPVs
		,DesktopPVs
		,UnknownDevicePVs
		,OtherDevicePVs
		,NumPLS_LP
		,NumAdvisorLP
		,NumContentLP
		,NumDirectoryLP
		,NumSEM_LP
	,CASE
		WHEN t.event_date < t.
FROM demo d

	LEFT JOIN (SELECT user_id
					,COUNT(DISTINCT persistent_session_id) PIDCount
					FROM UID_2_PID) p
		ON d.user_id = p.user_id
	LEFT JOIN ()				
		ON p.user_id = t.user_id
		
*************************************************************************
		
,COUNT(t.event_date) DaysVisited
		,SUM(LoggedInPVs) LoggedInPVs
		,SUM(LoggedOutPVs) LoggedOutPVs
		,SUM(MobileDevicePVs) MobileDevicePVs
		,SUM(EntertainmentSystemPVs) EntertainmentSystemPVs
		,SUM(DesktopPVs) DesktopPVs
		,SUM(UnknownDevicePVs) UnknownDevicePVs
		,SUM(OtherDevicePVs) OtherDevicePVs
		,SUM(NumPLS_LP) NumPLS_LP
		,SUM(NumAdvisorLP) NumAdvisorLP
		,SUM(NumContentLP) NumContentLP
		,SUM(NumDirectoryLP) NumDirectoryLP
		,SUM(NumSEM_LP) NumSEM_LP
				
*/