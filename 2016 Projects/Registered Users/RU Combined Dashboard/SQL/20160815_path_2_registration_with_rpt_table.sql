WITH demo AS (select user_account_id user_id
	,g.geo_type
	,CASE
		WHEN g.geo_postal_code = 'Not Applicable'
			THEN NULL
		ELSE g.geo_postal_code
	END Postal_Code
	,g.geo_latitude
	,g.geo_longitude
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
			THEN 'Has Contacts Data'
		ELSE 'No Contacts Data'
	END ContactsFilter
from  dm.user_account_dimension ua
	LEFT JOIN dm.geography_dimension g
		ON g.geo_id = ua.user_account_geography_id
	LEFT JOIN dm.professional_dimension pd
		On ua.user_account_id = CAST(pd.professional_user_account_id AS INT)
WHERE ua.user_account_register_datetime >= '2011-01-01' -- updated 07/26/2016


)


SELECT d.*
,r.registration_path AS ActionType
,r.registration_parent_pa AS ParentPA
,r.registration_action_datetime AS FirstAction
,CASE
	WHEN r.registration_action_datetime > d.registration_datetime
		THEN 'After Registration'
	ELSE 'Before Registration'
END RelativeTiming
,r.registration_parent_pa_group AS ParentPA_Group
FROM demo d
LEFT JOIN dm.rpt_user_type_and_registration_path r
ON r.user_id = d.user_id
