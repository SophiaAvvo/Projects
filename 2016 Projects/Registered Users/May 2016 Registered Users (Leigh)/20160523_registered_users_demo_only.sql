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
select user_account_id user_id
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
		WHEN ua.user_account_register_datetime >= '2013-01-01'
			THEN 'After Q&A Start'
		ELSE 'Before Q&A Start'
	END Q&AFilter
	,CASE
		WHEN ua.user_account_register_datetime >= '2014-01-01'
			THEN 'After Traffic Start'
		ELSE 'Before Traffic Start'
	END Q&AFilter
	,CASE
		wHEN ua.user_account_register_datetime >= '2015-05-01'
			THEN 'After Contacts Start'
		ELSE 'Before Contacts Start'
	END ContactsFilter
	,
from  dm.user_account_dimension ua
	LEFT JOIN dm.geography_dimension g
		ON g.geo_id = ua.user_account_geography_id
	LEFT JOIN dm.professional_dimension pd
		On ua.user_account_id = CAST(pd.professional_user_account_id AS INT)
WHERE to_date(ua.user_account_register_datetime) BETWEEN '2011-01-01' AND '2016-04-30'
	/*CROSS JOIN dm.date_dim dd
where dd.yearmonth >= 201401 */
	-- AND EXTRACT(DAY FROM user_account_register_datetime) = 11

