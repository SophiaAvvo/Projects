/* QUestions to answer:
1. How many different PIDs are associated with each registered user?
2. How much time elapsed between the first PID visit and registration?
3. WHat percentage of days, sessions do registered users log in?
*/

select
 t.resolved_user_id
 ,t.persistent_session_id
 ,t.event_date
 ,t.lpv_device_category_id
 
 ,CASE
 WHEN t.first_persistent_session = true
 THEN 1
 ELSE 0
 END IsFirstVisit 
  ,COUNT(t.session_id) SessionCount
 from dm.traffic t
 where t.resolved_user_id IS NOT NULL
AND CAST(resolved_user_id AS INT) < 5000
GROUP BY 1,2,3,4,5
 
 