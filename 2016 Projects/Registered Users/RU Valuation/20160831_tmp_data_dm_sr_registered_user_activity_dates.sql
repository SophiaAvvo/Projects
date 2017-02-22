CREATE TABLE tmp_data_dm.sr_registered_user_activity_dates AS (

SELECT uad.user_account_id
,uad.user_account_register_datetime
,md.month_begin_date AS user_action_month_begin
,md.month_end_date AS user_action_month_end
,md.month_name
,MIN(md.month_begin_date) OVER(PARTITION BY uad.user_account_id) AS User_Cohort_Registration_Month
,ROW_NUMBER() OVER(PARTITION BY uad.user_account_id ORDER BY md.month_begin_date) month_number
FROM dm.user_account_dimension uad
LEFT JOIN dm.professional_dimension pd
	ON uad.user_account_id = CAST(pd.professional_user_account_id AS INT)
CROSS JOIN dm.month_dim md
WHERE uad.user_account_register_datetime BETWEEN '2015-09-01' AND '2016-08-31'
AND md.month_end_date BETWEEN to_date(uad.user_account_register_datetime) AND now() -- it has to be on or before the last day of the first month; this is the start month
AND pd.professional_user_account_id IS NULL -- no lawyers

)