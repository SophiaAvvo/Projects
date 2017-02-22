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
              WHERE d.actual_date BETWEEN '2000-01-01' AND to_date(now())
              AND   year_month > 0) cal
WHERE cal.actual_date >= pd.claim_date
AND cal.year_month <= 201603


, contacts as -- for all requested topics; this just gets total contacts
(
		select ct.professional_id
		  ,ct.year_month
			, sum(ct.website_visits) as website_visits
			, sum(ct.phone_contacts) as phone_contacts
			, sum(ct.email_contacts) as email_contacts
		from
		(
				select dt.year_month
					, ci.professional_id
					, count(*) as website_visits
					, 0 as phone_contacts
					, 0 as email_contacts
				from src.contact_impression ci
				join DM.DATE_DIM d 
				  on d.actual_date = ci.event_date
				join 		
				(
					   select distinct d.year_month     
					   from DM.DATE_DIM d
					   where d.actual_date >= '2015-01-01'
							and d.actual_date <= to_date(now())
					) dt 
					 on dt.year_month = d.year_month
				where ci.contact_type = 'website'
				group by 1,2
	
				union

				select dt.year_month
					, ci.professional_id
					, 0 as website_visits
					, count(*) as phone_contacts
					, 0 as email_contacts
				from src.contact_impression ci
				  join DM.DATE_DIM d 
				    on d.actual_date = ci.event_date
				  join ( -- this just acts as a filter
					       select distinct d.year_month     
					       from DM.DATE_DIM d
					       where d.actual_date >= '2015-01-01'
							   and d.actual_date <= to_date(now())
					     ) dt 
					   on dt.year_month = d.year_month
			   where ci.contact_type = 'phone'
			   group by 1,2
	
				union

				select dt.year_month
					, ci.professional_id
					, 0 as website_visits
				  , 0 as phone_contacts
					, count(*) as email_contacts
				from src.contact_impression ci
				  join DM.DATE_DIM d 
				    on d.actual_date = ci.event_date
				  join (
					       select distinct d.year_month     
					       from DM.DATE_DIM d
					       where d.actual_date >= '2015-01-01'
							   and d.actual_date <= o_date(now())
					     ) dt 
					    on dt.year_month = d.year_month
				where ci.contact_type = 'email'
				group by 1,2
		) ct
		group by 1,2 -- aggregate contacts of each type by professional ID
)

, adv as
(
	SELECT professional_id
  ,ad_start_month
  ,ad_end_month
  --,DATEDIFF(ad_end_month, cal2.month_begin_date) MonthsSinceAdvertiser
  ,ad2.year_month
  ,COUNT(cal2.year_month) CumulativeAdvMonths
FROM (
        SELECT professional_id
          ,ad_start_month
          ,ad_end_month
          ,DATEDIFF(ad_end_date, cal.month_begin_date)/30.0 MonthsSinceAdvertiser
          ,cal.year_month
        FROM (
            	select o.professional_id
            		, min(d1.year_month) as ad_start_month
            		,min(d1.actual_date) as ad_start_date
            		,max(d1.actual_date) as ad_end_date
            		, case when cast(max(d1.year_month) as string) = concat(cast(year(now()) as string), lpad(cast(month(now()) as string),2,'0')) then null
            				else max(d1.year_month) end as ad_end_month
            		--, case when cast(max(d1.year_month) as string) = concat(cast(year(now()) as string), lpad(cast(month(now()) as string),2,'0')) then null
            				--else max(d1.year_month) end as ad_end_month
            	from dm.order_line_accumulation_fact o
            	join dm.date_dim d1 
            	   on d1.actual_date = o.order_line_begin_date
            	where o.product_line_id in (2,7)
            	--AND o.professional_id < 1000
            	group by 1
            	) ad
        CROSS JOIN (SELECT DISTINCT year_month
                            ,d.month_begin_date
                            FROM dm.date_dim d
                            WHERE d.actual_date BETWEEN '2000-01-01' AND '2016-02-29'
                            AND   year_month > 0
                      ) cal
        WHERE cal.year_month >= CAST(ad.ad_start_month AS INT)
        AND (cal.year_month <= CAST(ad_end_month AS INT) OR ad_end_month IS NULL)
        ) ad2
CROSS JOIN (SELECT DISTINCT year_month
              FROM dm.date_dim d
              WHERE d.actual_date BETWEEN '2000-01-01' AND '2016-02-29'
              AND   year_month > 0) cal2
WHERE cal2.year_month >= ad2.ad_start_month
AND cal2.year_month <= ad2.year_month
AND ad2.year_month <= 201602
GROUP BY 1,2,3,4  
)

,views AS

(
  select CAST(regexp_extract(url, '-([0-9]+)', 1) AS INT) as professional_id
,d1.year_month
, count(distinct render_instance_guid) as distinct_pv
from src.page_view pv
join dm.date_dim d1 
            	   on d1.actual_date = pv.event_date
where event_date BETWEEN '2015-01-01' AND '2016-02-29' 
  and page_type = 'Attorney_Profile'
group by 1,2
--order by 1,2
  
)


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