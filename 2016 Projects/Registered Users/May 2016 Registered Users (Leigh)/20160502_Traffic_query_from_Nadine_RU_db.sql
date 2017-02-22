with first_visit as 
( select
 t.persistent_session_id
 , t.event_date as first_visit_date
 from dm.traffic t
 where t.first_persistent_session = true
 )

select
case when resolved_user_ID is null then 'Not Registered' else 'Registered User' end as Registered_User
,case when lawyer_user_id = true then 'Lawyer' else '' end as Lawyer
,case when t.first_persistent_session = true then 'First Visit' else '' end as First_Visit
--,fv.first_visit_date
,case when datediff(t.event_date,fv.first_visit_date) <= 30 then 'New User' 
      else 'Return User' end as User_Status
,dcd.device_category_name
,lpv_page_type
,lpv_medium
,lpv_content
,event_date 
,sum(cast(regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as int)) as pageviews
--, case when regexp_extract(page_type_summary, '"Find A Lawyer": ([0-9]+)', 1) = '0' then 'N' else 'Y' end as PV_Find_A_Lawyer
--, case when regexp_extract(page_type_summary, '"Lawyer Dashboard": ([0-9]+)', 1) = '0' then 'N' else 'Y' end as  PV_Lawyer_Dashboard
--, case when regexp_extract(page_type_summary, '"Lawyer Profile": ([0-9]+)', 1)= '0' then 'N' else 'Y' end as PV_Lawyer_Profile
--, case when regexp_extract(page_type_summary, '"Lawyer SERP": ([0-9]+)', 1)= '0' then 'N' else 'Y' end as PV_Lawyer_SERP
--, case when regexp_extract(page_type_summary, '"Ask A Lawyer": ([0-9]+)', 1)= '0' then 'N' else 'Y' end as PV_Ask_A_Lawyer
--, case when regexp_extract(page_type_summary, '"Free Legal Advice": ([0-9]+)', 1)= '0' then 'N' else 'Y' end as PV_Free_Legal_Advice
--, case when regexp_extract(page_type_summary, '"Guide Detail": ([0-9]+)', 1)= '0' then 'N' else 'Y' end as PV_Guide_Detail
--, case when regexp_extract(page_type_summary, '"KB SERP": ([0-9]+)', 1)= '0' then 'N' else 'Y' end as PV_KB_SERP
--, case when regexp_extract(page_type_summary, '"QA Detail": ([0-9]+)', 1)= '0' then 'N' else 'Y' end as PV_QA_Detail
--, case when regexp_extract(page_type_summary, '"Topics": ([0-9]+)', 1)= '0' then 'N' else 'Y' end as PV_Topics
--, case when regexp_extract(page_type_summary, '"Homepage": ([0-9]+)', 1)= '0' then 'N' else 'Y' end as PV_Homepage
--, case when regexp_extract(page_type_summary, '"Account": ([0-9]+)', 1)= '0' then 'N' else 'Y' end as PV_Account
--, case when regexp_extract(page_type_summary, '"Support": ([0-9]+)', 1)= '0' then 'N' else 'Y' end as PV_Support
--, case when regexp_extract(page_type_summary, '"Unknown": ([0-9]+)', 1)= '0' then 'N' else 'Y' end as PV_Unknown
--,regexp_extract(page_type_summary, '"Total": ([0-9]+)', 1) as PV_Total
/*,regexp_extract(page_type_summary, '"Find A Lawyer": ([0-9]+)', 1)as PV_Find_A_Lawyer
,regexp_extract(page_type_summary, '"Lawyer Dashboard": ([0-9]+)', 1) as PV_Lawyer_Dashboard
,regexp_extract(page_type_summary, '"Lawyer Profile": ([0-9]+)', 1) as PV_Lawyer_Profile
,regexp_extract(page_type_summary, '"Lawyer SERP": ([0-9]+)', 1) as PV_Lawyer_SERP
,regexp_extract(page_type_summary, '"Ask A Lawyer": ([0-9]+)', 1) as PV_Ask_A_Lawyer
,regexp_extract(page_type_summary, '"Free Legal Advice": ([0-9]+)', 1) as PV_Free_Legal_Advice
,regexp_extract(page_type_summary, '"Guide Detail": ([0-9]+)', 1) as PV_Guide_Detail
,regexp_extract(page_type_summary, '"KB SERP": ([0-9]+)', 1) as PV_KB_SERP
,regexp_extract(page_type_summary, '"QA Detail": ([0-9]+)', 1) as PV_QA_Detail
,regexp_extract(page_type_summary, '"Topics": ([0-9]+)', 1) as PV_Topics
,regexp_extract(page_type_summary, '"Homepage": ([0-9]+)', 1) as PV_Homepage
,regexp_extract(page_type_summary, '"Account": ([0-9]+)', 1) as PV_Account
,regexp_extract(page_type_summary, '"Support": ([0-9]+)', 1) as PV_Support
,regexp_extract(page_type_summary, '"Unknown": ([0-9]+)', 1) as PV_Unknown
*/
,count(distinct t.persistent_session_id) as visitors
,count(session_id) as visits
from dm.traffic t
left join dm.device_category_dim dcd on dcd.device_category_id = t.lpv_device_category_id
left join first_visit fv on fv.persistent_session_id = t.persistent_session_id
where t.event_date >= '2014-01-01'
group by 1,2,3,4,5,6,7,8,9
--,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23