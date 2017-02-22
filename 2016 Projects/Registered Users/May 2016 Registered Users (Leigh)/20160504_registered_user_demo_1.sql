/* Questions:
1. WHat is the demographic breakdown over time?
	- sharing names with US
	- type of email address
	- email domain
	- email domain size
	- age
	- gender
	- top geo
	- urbanicity
	- income
	- children
	- marital status
2. When do users in different demo groups register?
	- local time of day
	- weekday
	- month
3. What happened in their registration session? (get from datetime match)
	- number of total sessions that DAY
	- number of pages viewed
	- types of pages viewed
	- actions taken
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
	END LengthofInterest
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
from  dm.user_account_dimension ua
	LEFT JOIN dm.geography_dimension g
		ON g.geo_id = ua.user_account_geography_id
where user_account_register_datetime >= '2011-01-01'

)

,

UID_2_PID AS (
SELECT DISTINCT t.persistent_session_id
	,t.resolved_user_id user_id
	,case when lawyer_user_id = true then 'Lawyer' else '' end as Lawyer
 from dm.traffic t
 where t.resolved_user_id IS NOT NULL

 )

,

traffic AS (

 SELECT up.resolved_user_id
	,MIN(t.event_date) DateFirstVisit
	,MAX(t.event_date) DateLastVisit
	,COUNT(DISTINCT t.event_date) DaysVisited
	,COUNT(t.resolved_user_id) LoginCount
	,sum(cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)) as pageviews	
 FROM dm.traffic t
	JOIN UID_2_PID up
		ON up.persistent_session_id = t.persistent_session_id
GROUP BY 1

)

SELECT t.*
	,d.*
	,p.PIDCount
FROM traffic t
	LEFT JOIN demo d
		ON d.user_id = t.user_id
	LEFT JOIN (SELECT user_id
					,COUNT(DISTINCT persistent_session_id) PIDCount
					FROM UID_2_PID) p
		ON p.user_id = t.user_id