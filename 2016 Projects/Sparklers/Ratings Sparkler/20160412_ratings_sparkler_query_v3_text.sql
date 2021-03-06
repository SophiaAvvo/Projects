WITH claim as -- duplicates across professional_id due to practice area and specialty percent
(
/* get every professional by day for all time since they have claimed */
SELECT professional_id
  ,first_name
  ,last_name
  ,email
  ,state
  ,county
  ,city
  ,avvo_rating
  ,ClaimYearMonth
  ,claim_date
  ,cal.year_month
  ,cal.actual_date
FROM (
        select distinct p.professional_id
        		, p.professional_first_name as first_name
        		, p.professional_last_name as last_name
        		, p.professional_email_address_name as email
        		, p.professional_state_name_1 as "state"
        		, p.professional_county_name_1 as county
        		, p.professional_city_name_1 as city
        		, p.professional_avvo_rating as avvo_rating
        		--, sd.specialty_name as pa
        		--, sd.parent_specialty_name as parent_pa
        		--, sb.specialty_percent
        		,CASE
                  WHEN EXTRACT(month FROM p.professional_claim_date) < 10
                    THEN CAST(CONCAT(CAST(EXTRACT(year FROM p.professional_claim_date) AS VARCHAR), '0', CAST(EXTRACT(month FROM p.professional_claim_date) AS VARCHAR)) AS INT)
                    ELSE CAST(CONCAT(CAST(EXTRACT(year FROM p.professional_claim_date) AS VARCHAR), CAST(EXTRACT(month FROM p.professional_claim_date) AS VARCHAR)) AS INT)
                  END ClaimYearMonth
               ,p.professional_claim_date AS claim_date
        	from dm.professional_dimension p
        		where p.professional_claim_date is not null
        		and p.professional_delete_indicator = 'Not Deleted'
        		and p.professional_practice_indicator = 'Practicing'
        		and p.professional_name = 'lawyer'
        		and p.industry_name = 'Legal'
        		AND p.professional_id < 10000
       ) pd
	CROSS JOIN (SELECT DISTINCT actual_date
				,d.year_month
              FROM dm.date_dim d
              WHERE d.actual_date BETWEEN '2000-01-01' AND '2016-02-29'
              AND   year_month > 0) cal
WHERE cal.actual_date >= pd.claim_date
AND cal.year_month <= 201603


select cl.*
	,pd.professional_avvo_rating
				,dd.actual_date
				, pd.source_system_begin_date as begin_date
				, pd.source_system_end_date as end_date
				-- , COUNT(DISTINCT cl.professional_id) professional_count
			from claim cl
			join dm.historical_professional_dimension pd
				ON cl.professional_id = pd.professional_id
			    AND professional_avvo_rating is not null
			    AND cl.actual_date >= pd.source_system_begin_date
			    AND (cl.actual_date <= pd.source_system_end_date OR pd.source_system_end_date IS NULL)
				-- and professional_id <= 100000
				
			-- group by 1,2 -- ,3
			ORDER BY dd.actual_date
				,pd.professional_avvo_rating
			
/* SELECT *			
from dm.historical_professional_dimension pd
			where professional_id=19061			*/