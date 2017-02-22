WITH UID_2_PID AS (
SELECT DISTINCT t.persistent_session_id
	,CAST(t.resolved_user_id AS INT) user_id
	-- ,case when lawyer_user_id = true then 'Lawyer' else '' end as Lawyer
 from dm.traffic t
 where t.resolved_user_id IS NOT NULL
 AND CAST(EXTRACT(year FROM t.event_date) AS INT) >= 2014

 )
 
, pid_count AS (SELECT (user_id
         ,COUNT(t.persistent_session_id) PIDCount
  FROM UID_2_PID u
  GROUP BY 1

)

SELECT PIDCount
,COUNT(user_id) UserCount
FROM pid_count
GROUP BY 1