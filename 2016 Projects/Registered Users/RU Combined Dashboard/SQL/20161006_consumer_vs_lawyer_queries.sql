SELECT COUNT(DISTINCT user_account_id) distinct_user_count
, if(t.lawyer_user_id, 'Lawyer', 'Consumer') traffic_lawyer
,CASE
WHEN pd.professional_user_account_id IS NOT NULL THEN 'Lawyer' ELSE 'Consumer' END prof_dim_lawyer
FROM dm.user_account_dimension uad
LEFT JOIN dm.traffic t
ON uad.user_account_id = CAST(t.resolved_user_id AS INT)
LEFT JOIN dm.professional_dimension pd
ON uad.user_account_id = CAST(pd.professional_user_account_id AS INT)
WHERE uad.user_account_register_datetime >= '2011-01-01'
GROUP BY 2,3

SELECT COUNT(DISTINCT user_account_id) distinct_user_count
, if(t.lawyer_user_id, 'Lawyer', 'Consumer') traffic_lawyer
FROM dm.user_account_dimension uad
LEFT JOIN dm.traffic t
ON uad.user_account_id = CAST(t.resolved_user_id AS INT)
WHERE uad.user_account_register_datetime >= '2011-01-01'
GROUP BY 2

SELECT COUNT(DISTINCT user_account_id) distinct_user_count
,CASE
WHEN pd.professional_user_account_id IS NOT NULL THEN 'Lawyer' ELSE 'Consumer' END prof_dim_lawyer
FROM dm.user_account_dimension uad
LEFT JOIN dm.professional_dimension pd
ON uad.user_account_id = CAST(pd.professional_user_account_id AS INT)
WHERE uad.user_account_register_datetime >= '2011-01-01'
GROUP BY 2

