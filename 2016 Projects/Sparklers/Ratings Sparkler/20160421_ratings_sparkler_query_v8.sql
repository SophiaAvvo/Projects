WITH profile as -- duplicates across professional_id due to practice area and specialty percent
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
WHERE cal.year_month <= 201511

)


,

website AS (
  select ci.event_date
                    , ci.professional_id
                    ,COUNT(DISTINCT ci.persistent_session_id) Daily_Website_Visits
                    ,COUNT(ci.session_id) Total_Daily_Website_Sessions                
				from src.contact_impression ci
				WHERE ci.event_date >= '2015-01-01'
                AND ci.contact_type = 'website'
                GROUP BY 1,2
)

,

phone AS (
 
select ci.event_date
                    , ci.professional_id
                    ,COUNT(DISTINCT ci.persistent_session_id) Daily_Phone_Contacts
                    ,COUNT(ci.session_id) Total_Daily_Phone_Sessions                  
				from src.contact_impression ci
				WHERE ci.event_date >= '2015-01-01'
                AND ci.contact_type = 'phone'
                GROUP BY 1,2
  
)

,

email AS (
                
select ci.event_date
                    , ci.professional_id
                    ,COUNT(DISTINCT ci.persistent_session_id) Daily_Email_Contacts
                    ,COUNT(ci.session_id) Total_Daily_Email_Sessions                  
				from src.contact_impression ci
				WHERE ci.event_date >= '2015-01-01'
                AND ci.contact_type = 'email'
                GROUP BY 1,2
                                
)                                

, adv as
(
select DISTINCT o.professional_id
            		,d1.actual_date ad_date
            	from dm.order_line_accumulation_fact o
            	join dm.date_dim d1 
            	   on d1.actual_date >= o.order_line_begin_date
				   AND d1.actual_date <= (CASE WHEN o.order_line_end_date = '-1' THEN to_date(now()) ELSE o.order_line_end_date END)
					AND o.product_line_id in (2,7)

)

,adv2 AS (

SELECT a.professional_id
	,a.ad_date
	,COUNT(a2.ad_date) CumulativeAdvDays
	,MIN(a2.ad_date) FirstAdDate
FROM adv a
LEFT JOIN adv a2
ON a2.professional_id = a.professional_id
AND a2.ad_date >= a.ad_date
GROUP BY 1,2

)

,views AS

(
  select CAST(regexp_extract(url, '-([0-9]+)', 1) AS INT) as professional_id
,d1.actual_date
, count(distinct render_instance_guid) as distinct_pv
from src.page_view pv
join dm.date_dim d1 
            	   on d1.actual_date = pv.event_date
AND event_date >= '2015-01-01'
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
			    AND (cal.actual_date <= pd.source_system_end_date OR pd.source_system_end_date IS NULL)
				
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
	,r.rating
	,v.distinct_pv
	,w.daily_website_visits
	,w.total_daily_website_sessions
	,p.daily_phone_contacts
	,p.total_daily_phone_sessions
	,e.daily_email_contacts
	,e.total_daily_email_sessions
	,a.cumulativeadvdays
	,a.firstaddate
	,CASE
		WHEN a.ad_date IS NOT NULL
			THEN 1
		ELSE 0
	END IsCurrentAdvertiser
			from profile cl
			LEFT join rating r
				ON cl.professional_id = r.professional_id
				AND r.actual_date = cl.actual_date
		    LEFT JOIN views v
				ON v.professional_id = cl.professional_id
				AND v.actual_date = cl.actual_date
			LEFT JOIN website w
				ON w.professional_id = cl.professional_id
				AND w.event_date = cl.actual_date
			LEFT JOIN phone p
				ON p.professional_id = cl.professional_id
				AND p.event_date = cl.actual_date
			LEFT JOIN email e
				ON e.professional_id = cl.professional_id
				AND e.event_date = cl.actual_date				
			LEFT JOIN adv2 a
				ON a.professional_id = cl.professional_id
				AND a.ad_date = cl.actual_date
		    
				-- and professional_id <= 100000
				
			-- group by 1,2 -- ,3
			--ORDER BY dd.actual_date
				--,pd.professional_avvo_rating
			
/* SELECT *			
from dm.historical_professional_dimension pd
			where professional_id=19061			*/