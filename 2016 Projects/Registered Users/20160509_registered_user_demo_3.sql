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
		WHEN g.geo_population = '-1'
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
	,dd.month_begin_date
	,dd.month_end_date
	,dd.yearmonth
	,CASE 
		WHEN DATEDIFF(dd.month_begin_date, ua.user_account_registraton_datetime) < 30
			THEN '< 30 Days'
		WHEN DATEDIFF(dd.month_begin_date, ua.user_account_registraton_datetime) BETWEEN 30 AND 90
			THEN '1 - 3 Months'
		WHEN DATEDIFF(dd.month_begin_date, ua.user_account_registraton_datetime) < BETWEEN 91 AND 182
			THEN '3 - 6 Months'
		WHEN DATEDIFF(dd.month_begin_date, ua.user_account_registraton_datetime) < BETWEEN 183 AND 365
			THEN '6 - 12 Months'
		WHEN DATEDIFF(dd.month_begin_date, ua.user_account_registraton_datetime) > 365
			THEN '> 1 Year'
		END TimeSinceRegistration
from  dm.user_account_dimension ua
	LEFT JOIN dm.geography_dimension g
		ON g.geo_id = ua.user_account_geography_id
	CROSS JOIN dm.date_dim dd
where dd.yearmonth >= 201401
	AND EXTRACT(DAY FROM user_account_register_datetime) = 11

)

,

UID_2_PID AS (
SELECT DISTINCT t.persistent_session_id
	,t.resolved_user_id user_id
	,case when lawyer_user_id = true then 'Lawyer' else '' end as Lawyer
	,CONCAT(EXTRACT(year FROM t.event_date), EXTRACT(month FROM t.event_date)) YearMonth
 from dm.traffic t
 where t.resolved_user_id IS NOT NULL
 AND CAST(EXTRACT(year FROM t.event_date) AS INT)) >= 2014

 )

,
/* rolling up to the day level to avoid the need for multiple count distincts */
daily_traffic AS SELECT up.resolved_user_id user_id
		,t.event_date
		,COUNT(t.session_id) TotalSessions
		,COUNT(DISTINCT t.session_id) DistinctSessions
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
				WHEN t.device_category_id IN (2, 3, 6, 7)
					THEN cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) MobileDevicePVs
		,SUM(CASE
				WHEN t.device_category_id IN (4,5)
					THEN  cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) EntertainmentSystemPVs
		,SUM(CASE
				WHEN t.device_category_id = 2
					THEN  cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) DesktopPVs
		,SUM(CASE
				WHEN t.device_category_id IS NULL
					THEN cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) UnknownDevicePVs
		,SUM(CASE
				WHEN t.device_category_id = 8
					THEN  cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) OtherDevicePVs
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
			END) SEM_LP
		-- ,SUM() add something here about checkout?
		FROM dm.traffic t
	JOIN UID_2_PID up
		ON up.persistent_session_id = t.persistent_session_id
		ON d.user_id = up.resolved_user_id
	left join dm.device_category_dim dcd 
		on dcd.device_category_id = t.lpv_device_category_id
		--AND d.registration_date <= t.event_date





SELECT d.*
	,p.PIDCount
	
	,CASE
		WHEN TotalSessions = DistinctSessions
			THEN 1
		ELSE 0
	END SessionCountFlag
	,SUM(LoggedInPVs) LoggedInPVs
		,SUM(LoggedOutPVs)
		,SUM(CASE
				WHEN t.device_category_id IN (2, 3, 6, 7)
					THEN cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) MobileDevicePVs
		,SUM(CASE
				WHEN t.device_category_id IN (4,5)
					THEN  cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) EntertainmentSystemPVs
		,SUM(CASE
				WHEN t.device_category_id = 2
					THEN  cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) DesktopPVs
		,SUM(CASE
				WHEN t.device_category_id IS NULL
					THEN cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) UnknownDevicePVs
		,SUM(CASE
				WHEN t.device_category_id = 8
					THEN  cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)
				ELSE 0
			END) OtherDevicePVs
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
			END) SEM_LP
	,CASE
		WHEN t.event_date < t.
FROM demo d
	LEFT JOIN daily_traffic t
		ON d.user_id = t.user_id
		AND t.event_date BETWEEN d.month_begin_date AND d.month_end_date
	LEFT JOIN (SELECT user_id
					,p.yearmonth
					,COUNT(DISTINCT persistent_session_id) PIDCount
					FROM UID_2_PID) p
		ON d.user_id = p.user_id
		AND d.yearmonth = p.yearmonth
	LEFT JOIN ()				
		ON p.user_id = t.user_id
		
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
				
*/