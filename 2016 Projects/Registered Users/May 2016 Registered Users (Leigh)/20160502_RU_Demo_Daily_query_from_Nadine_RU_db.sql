select 
 uad.user_account_gender
, uad.user_account_state_name
, uad.user_account_household_income
, uad.user_account_has_child_indicator
, uad.user_account_marital_status
, count(*) as num_users
from  dm.user_account_dimension uad
where user_account_register_datetime >= '2011-01-01'
group by 1,2,3,4,5