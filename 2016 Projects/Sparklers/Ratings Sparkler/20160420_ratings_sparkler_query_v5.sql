WITH claim as -- duplicates across professional_id due to practice area and specialty percent
(
/* get every professional by day for all time since they have claimed */
SELECT professional_id
  --,first_name
  --,last_name
  --,email
  ,state
  ,county
  --,city
  -- ,avvo_rating
  --,ClaimYearMonth
  ,claim_date
  ,CASE
	WHEN claim_date IS NULL
		THEN 0
	ELSE 1
  END IsClaim
  --,cal.year_month
  ,cal.actual_date
  ,cal.month_begin_date
  ,DATEDIFF(pd.claim_date, cal.actual_date) DaysSinceClaim
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
        		where p.professional_delete_indicator = 'Not Deleted'
        		and p.professional_practice_indicator = 'Practicing'
        		and p.professional_name = 'lawyer'
        		and p.industry_name = 'Legal'
        		AND p.professional_id < 10000
       ) pd
	CROSS JOIN (SELECT DISTINCT actual_date
				,d.year_month
				,d.month_begin_date
              FROM dm.date_dim d
              WHERE d.actual_date BETWEEN '2000-01-01' AND to_date(now())
              AND   year_month > 0) cal
WHERE cal.year_month <= 201501

)


, contacts as -- for all requested topics; this just gets total contacts
(
		select ct.professional_id
		,ct.year_month
		,ct.actual_date
		,ct.month_begin_date
			, sum(ct.website_visits) as website_visits
			, sum(ct.phone_contacts) as phone_contacts
			, sum(ct.email_contacts) as email_contacts
		from
		(
				select dt.year_month
					,dt.actual_date
					,dt.month_begin_date
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
							,d.actual_date
							,d.month_begin_date
					   from DM.DATE_DIM d
					   where d.actual_date >= '2015-01-01'
							and d.actual_date <= to_date(now())
					) dt 
					 on dt.year_month = d.year_month
				where ci.contact_type = 'website'
				group by 1,2
	
				union

				select dt.year_month
				,dt.actual_date
					,dt.month_begin_date
					, ci.professional_id
					, 0 as website_visits
					, count(*) as phone_contacts
					, 0 as email_contacts
				from src.contact_impression ci
				  join DM.DATE_DIM d 
				    on d.actual_date = ci.event_date
				  join (
					   select distinct d.year_month  
							,d.actual_date
							,d.month_begin_date
					   from DM.DATE_DIM d
					   where d.actual_date >= '2015-01-01'
							and d.actual_date <= to_date(now())
					) dt  
					   on dt.year_month = d.year_month
			   where ci.contact_type = 'phone'
			   group by 1,2
	
				union

				select dt.year_month
				,dt.actual_date
					,dt.month_begin_date
					, ci.professional_id
					, 0 as website_visits
				  , 0 as phone_contacts
					, count(*) as email_contacts
				from src.contact_impression ci
				  join DM.DATE_DIM d 
				    on d.actual_date = ci.event_date
				  join (
					   select distinct d.year_month  
							,d.actual_date
							,d.month_begin_date
					   from DM.DATE_DIM d
					   where d.actual_date >= '2015-01-01'
							and d.actual_date <= to_date(now())
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
  ,DaysSinceAdvertiser
  -- ,ad2.year_month
  ,ad2.actual_date
  ,COUNT(cal2.actual_date) CumulativeAdvDays
FROM (
        SELECT professional_id
          ,ad_start_month
          ,ad_end_month
          ,DATEDIFF(ad_end_date, cal.actual_date) DaysSinceAdvertiser
          ,cal.year_month
		  ,cal.actual_date
        FROM (
            	select o.professional_id
            		-- , min(d1.year_month) as ad_start_month
            		,min(d1.actual_date) as ad_start_date
            		,max(d1.actual_date) as ad_end_date
            		-- , case when cast(max(d1.year_month) as string) = concat(cast(year(now()) as string), lpad(cast(month(now()) as string),2,'0')) then null
            			--	else max(d1.year_month) end as ad_end_month
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
		                    ,d.actual_date
                            ,d.month_begin_date
                            FROM dm.date_dim d
                            WHERE d.actual_date BETWEEN '2000-01-01' AND to_date(now())
                            AND   year_month > 0
                      ) cal
        WHERE cal.actual_date >= ad_start_date
        AND (cal.actual_date <= ad_end_date OR ad_end_date)
        ) ad2
CROSS JOIN (SELECT DISTINCT actual_date
              FROM dm.date_dim d
              WHERE d.actual_date BETWEEN '2000-01-01' AND to_date(now())
WHERE cal2.actual_date >= ad2.ad_start_date
AND cal2.actual_date <= ad2.ad_end_date
GROUP BY 1,2,3,4  
)

,views AS

(
  select CAST(regexp_extract(url, '-([0-9]+)', 1) AS INT) as professional_id
,d1.actual_date
, count(distinct render_instance_guid) as distinct_pv
from src.page_view pv
join dm.date_dim d1 
            	   on d1.actual_date = pv.event_date
where event_date BETWEEN '2015-01-01' AND '2016-02-29' 
  and page_type = 'Attorney_Profile'
group by 1,2
--order by 1,2
  
)

,

rating AS (
SELECT pd.professional_id
	, pd.source_system_begin_date as rating_begin_date
	, pd.source_system_end_date as rating_end_date
	, pd.professional_avvo_rating AS rating
	,cal.*
FROM dm.historical_professional_dimension pd
CROSS JOIN (SELECT DISTINCT actual_date
				,d.year_month
				,d.month_begin_date
              FROM dm.date_dim d

			WHERE d.actual_date BETWEEN '2000-01-01' AND to_date(now())
              AND   year_month > 0) cal
WHERE professional_avvo_rating is not null
			    AND cal.actual_date >= pd.source_system_begin_date
			    AND (cla.actual_date <= pd.source_system_end_date OR pd.source_system_end_date IS NULL)
				
)

select cl.*
	,r.rating
	,CASE
		WHEN r.rating IS NULL
			THEN 0
		ELSE 1
	END HasRating
	,r.rating_begin_date
	,r.rating_end_date
	,v.distinct_pv
	,c.website_visits
	,c.phone_contacts
	,c.email_contacts
	,adv.cumulativeadvdays
	,adv.ad_start_month
	,adv.ad_end_month
	,adv.DaysSinceAdvertiser
	,case when adv.professional_id is null then "N" else "Y" end as current_advertiser
			from claim cl
			LEFT join rating r
				ON cl.professional_id = r.professional_id
				AND r.actual_date = cl.actual_date
		    LEFT JOIN views v
				ON v.professional_id = cl.professional_id
				AND v.actual_date = cl.actual_date
			LEFT JOIN contacts c
				ON c.professional_id = cl.professional_id
				AND c.actual_date = cl.actual_date
			LEFT JOIN adv a
				ON a.professional_id = cl.professional_id
				AND a.actual_date = cl.actual_date
		    
				-- and professional_id <= 100000
				
			-- group by 1,2 -- ,3
			--ORDER BY dd.actual_date
				--,pd.professional_avvo_rating
			
/* SELECT *			
from dm.historical_professional_dimension pd
			where professional_id=19061			*/