
-- replace with sr_review_sparkler_profile_calendar
 WITH /*claim as -- duplicates across professional_id due to practice area and specialty percent
(
SELECT professional_id
  ,first_name
  ,last_name
  ,email
  ,state
  ,county
  ,city
  -- ,avvo_rating
  ,ClaimYearMonth
 ,CASE
	WHEN pd.ClaimYearMonth IS NULL
		THEN 'N/A'
	WHEN pd.claimyearmonth > cal.year_month
		THEN 'N/A'
	WHEN pd.claimyearmonth = cal.year_month
		THEN 'Claim Month'
	WHEN pd.claimyearmonth < cal.year_month
		THEN 'Claimed'
	END Claim_Status
	,CASE
		WHEN ClaimYearMonth <= cal.year_month
			THEN 1
		ELSE 0
	END is_claimed
  ,cal.year_month
  ,cal.month_begin_date
  ,cal.month_end_date
  ,CASE
	WHEN cal.year_month <>  201505
		THEN 'Single Year'
	ELSE 'Extra Month'
	END is_contiguous_year
FROM (
        select distinct p.professional_id
        		, p.professional_first_name as first_name
        		, p.professional_last_name as last_name
        		, p.professional_email_address_name as email
        		, p.professional_state_name_1 as "state"
        		, p.professional_county_name_1 as county
        		, p.professional_city_name_1 as city
        		-- , p.professional_avvo_rating as avvo_rating
        		--, sd.specialty_name as pa
        		--, sd.parent_specialty_name as parent_pa
        		--, sb.specialty_percent
        		,CASE
                  WHEN p.professional_claim_date IS NULL
					THEN NULL
					WHEN EXTRACT(month FROM p.professional_claim_date) < 10
                    THEN CAST(CONCAT(CAST(EXTRACT(year FROM p.professional_claim_date) AS VARCHAR), '0', CAST(EXTRACT(month FROM p.professional_claim_date) AS VARCHAR)) AS INT)
                    ELSE CAST(CONCAT(CAST(EXTRACT(year FROM p.professional_claim_date) AS VARCHAR), CAST(EXTRACT(month FROM p.professional_claim_date) AS VARCHAR)) AS INT)
                  END ClaimYearMonth
        	from dm.professional_dimension p
        		where p.professional_delete_indicator = 'Not Deleted'
        		and p.professional_practice_indicator = 'Practicing'
        		and p.professional_name = 'lawyer'
        		and p.industry_name = 'Legal'
        		-- AND p.professional_id < 10000
       ) pd
	CROSS JOIN (SELECT DISTINCT year_month
	             ,d.month_begin_date
	             ,d.month_end_date
              FROM dm.date_dim d
              WHERE d.actual_date BETWEEN '2015-05-01' AND '2016-05-31'
              AND   year_month > 0) cal

) 

, */

PA1 AS (
SELECT pfsp.PROFESSIONAL_ID
          ,sp.PARENT_SPECIALTY_NAME                  
		  ,SUM(pfsp.SPECIALTY_PERCENT) parent_pa_percent
                     FROM DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp
                       JOIN DM.SPECIALTY_DIMENSION sp ON sp.SPECIALTY_ID = pfsp.SPECIALTY_ID
                     WHERE pfsp.DELETE_FLAG = 'N' --AND pfsp.professional_Id < 1000
					 GROUP BY 1,2)

,

PA2 AS (SELECT p.professional_id
,p.parent_specialty_name
,parent_pa_percent
,ROW_NUMBER() OVER (PARTITION BY p.PROFESSIONAL_ID ORDER BY p.parent_pa_percent DESC) ppa_rank
FROM PA1 p

)

,

PA3 AS (
SELECT x.PROFESSIONAL_ID
                      ,MIN(CASE WHEN x.ppa_rank = 1 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea1
                      ,MIN(CASE WHEN x.ppa_rank = 2 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea2
                      ,MIN(CASE WHEN x.ppa_rank = 3 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea3

               FROM PA2 x
               GROUP BY 1
			   
)

-- replace with tmp_data_dm.sr_review_sparkler_contacts
/*, contacts as -- for all requested topics; this just gets total contacts
(
		select ct.professional_id
		  ,ct.year_month
			, sum(ct.website_visitors_by_day) as website_visitors_by_day
			, SUM(ct.all_website_clicks) AS all_website_clicks
			, SUM(ct.callers_by_day) AS callers_by_day
			, sum(ct.all_phone_contacts) as all_phone_contacts
			, SUM(ct.emailers_by_day) AS emailers_by_day
			, sum(ct.all_email_contacts) as all_email_contacts
		from
		(
				select dt.year_month
					, ci.professional_id
					, count(DISTINCT CONCAT(ci.persistent_session_id, CAST(ci.event_date AS VARCHAR))) as website_visitors_by_day
					, COUNT(ci.session_id) AS all_website_clicks
					, 0 AS callers_by_day
					, 0 as all_phone_contacts
					, 0 as emailers_by_day
					, 0 AS all_email_contacts
				from src.contact_impression ci
				join DM.DATE_DIM d 
				  on d.actual_date = ci.event_date
				join 		
				(
					   select distinct d.year_month     
					   from DM.DATE_DIM d
					   where d.actual_date >= '2015-05-01'--to_date(now()- interval 6 month) -- **between six months ago
							and d.actual_date <= '2016-05-31'--to_date(now()) -- and now; - interval 1 month) -- **not sure why we'd use "one month ago"
					) dt 
					 on dt.year_month = d.year_month
				where ci.contact_type = 'website'
				group by 1,2
	
				union

				select dt.year_month
					, ci.professional_id
					, 0 as website_visitors_by_day
					, 0 AS all_website_clicks
					, COUNT(DISTINCT CONCAT(ci.caller, CAST(ci.event_date AS VARCHAR))) AS callers_by_day
					, COUNT(ci.gmt_timestamp) AS all_phone_contacts
					, 0 as emailers_by_day
					, 0 all_email_contacts
				from src.contact_impression ci
				  join DM.DATE_DIM d 
				    on d.actual_date = ci.event_date
				  join ( -- this just acts as a filter
					       select distinct d.year_month     
					       from DM.DATE_DIM d
					       where d.actual_date >= '2015-05-01'--to_date(now()- interval 6 month)
							   and d.actual_date <= '2016-05-31'--to_date(now())-- - interval 1 month)
					     ) dt 
					   on dt.year_month = d.year_month
			   where ci.contact_type = 'phone'
			   group by 1,2
	
				union

				select dt.year_month
					, ci.professional_id
					, 0 as website_visitors_by_day
					, 0 AS all_website_clicks
					, 0 AS callers_by_day
				  , 0 as all_phone_contacts
					, count(DISTINCT CONCAT(ci.persistent_session_id, CAST(ci.event_date AS VARCHAR))) as emailers_by_day
					, COUNT(ci.session_id) AS all_email_contacts
				from src.contact_impression ci
				  join DM.DATE_DIM d 
				    on d.actual_date = ci.event_date
				  join (
					       select distinct d.year_month     
					       from DM.DATE_DIM d
					       where d.actual_date >= '2015-05-01'--to_date(now()- interval 6 month)
							   and d.actual_date <= '2016-05-31'--to_date(now()) -- - interval 1 month)
					     ) dt 
					    on dt.year_month = d.year_month
				where ci.contact_type = 'email'
				group by 1,2
		) ct
-- WHERE professional_id < 100

		group by 1,2 -- aggregate contacts of each type by professional ID
-- ORDER BY year_month, professional_id
) 

, */

-- replace with tmp_data_dm.sr_review_sparkler_reviews
/*reviews as -- gets total cumulative endorsements
(
SELECT professional_id
  ,r2.year_month
	,MIN(ReviewYearMonth) FirstReviewMonth
  ,COUNT(DISTINCT Review_Id) CumulativeMonthlyReviews -- the count distinct keeps the second crossjoin out of the count
  ,SUM(NewReviewFlag) NewReviewCount 
  ,COUNT(cal2.year_month) CumulativeReviewMonths
FROM (      
      SELECT professional_id,
             Review_Id,
             ReviewYearMonth
             ,cal.year_month
             ,CASE
                 WHEN cal.year_month = ReviewYearMonth
                     THEN 1
                 ELSE 0
              END NewReviewFlag
      FROM (SELECT pr.professional_id
                   ,pr.id AS Review_Id
                   ,CASE
                     WHEN EXTRACT(MONTH FROM pr.created_at) < 10 THEN CAST(CONCAT (CAST(EXTRACT(YEAR FROM pr.created_at) AS VARCHAR),'0',CAST(EXTRACT(MONTH FROM pr.created_at) AS VARCHAR)) AS INT)
                     ELSE CAST(CONCAT (CAST(EXTRACT(YEAR FROM pr.created_at) AS VARCHAR),CAST(EXTRACT(MONTH FROM pr.created_at) AS VARCHAR)) AS INT)
                   END ReviewYearMonth
                   FROM src.barrister_professional_review pr
-- WHERE pr.professional_id = 2
            ) r
		-- This first cross join is to get a calendar that shows which reviews are associated with which months.  A review that was made in January will be associated with every month thereafter
        CROSS JOIN (SELECT DISTINCT year_month
                    FROM dm.date_dim d
                    WHERE d.actual_date BETWEEN '2000-01-01' AND '2016-05-31'
                    AND   year_month > 0) cal
      WHERE cal.year_month >= r.ReviewYearMonth
      )r2
CROSS JOIN (SELECT DISTINCT year_month
              FROM dm.date_dim d
              WHERE d.actual_date BETWEEN '2000-01-01' AND '2016-05-31'
              AND   year_month > 0) cal2
WHERE cal2.year_month >= r2.ReviewYearMonth
AND cal2.year_month <= r2.year_month 
AND r2.year_month <= 201605
GROUP BY 1,2--,3,4     
-- ORDER BY r2.year_month         

-- where to_date(eds.created_at)>='2015-01-01'
-- and to_date(eds.created_at)<='2015-12-31'

) */

-- replace with tmp_data_dm.sr_reviews_sparkler_olaf_adv
/*, adv as
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
                            WHERE d.actual_date BETWEEN '2000-01-01' AND '2016-05-31'
                            AND   year_month > 0
                      ) cal
        WHERE cal.year_month >= CAST(ad.ad_start_month AS INT)
        AND (cal.year_month <= CAST(ad_end_month AS INT) OR ad_end_month IS NULL)
        ) ad2
CROSS JOIN (SELECT DISTINCT year_month
              FROM dm.date_dim d
              WHERE d.actual_date BETWEEN '2000-01-01' AND '2016-05-31'
              AND   year_month > 0) cal2
WHERE cal2.year_month >= ad2.ad_start_month
AND cal2.year_month <= ad2.year_month
AND ad2.year_month <= 201605
GROUP BY 1,2,3,4  
)*/

,views1 AS

(
  select CAST(regexp_extract(url, '-([0-9]+)', 1) AS INT) as professional_id
,d1.year_month
,CONCAT(persistent_session_id, CAST(pv.event_date AS VARCHAR)) PID_day
, count(distinct render_instance_guid) as profile_render_count
from src.page_view pv
join dm.date_dim d1 
            	   on d1.actual_date = pv.event_date
where event_date BETWEEN '2015-05-01' AND '2016-05-31' 
  and page_type = 'Attorney_Profile'
group by 1,2,3
--order by 1,2
  
)

,views2 AS (SELECT professional_id
			,year_month
			,COUNT(DISTINCT PID_day) profile_viewer_count_by_day
			,SUM(profile_render_count) profile_render_count
FROM views1
GROUP BY 1,2

)

select cl.professional_id
		,ParentPracticeArea1
		,ParentPracticeArea2
		,ParentPracticeArea3
		,CASE
			WHEN 'Real Estate' IN (pa.ParentPracticeArea1, pa.ParentPracticeArea2, pa.ParentPracticeArea3)
				THEN 1
			ELSE 0
		END IsRealEstate
		,CASE
			WHEN 'Personal Injury' IN (pa.ParentPracticeArea1, pa.ParentPracticeArea2, pa.ParentPracticeArea3)
				THEN 1
			ELSE 0
		END IsPersonalInjury
		,CASE
			WHEN 'Immigration' IN (pa.ParentPracticeArea1, pa.ParentPracticeArea2, pa.ParentPracticeArea3)
				THEN 1
			ELSE 0
		END IsImmigration
		,CASE
			WHEN 'Criminal' IN (pa.ParentPracticeArea1, pa.ParentPracticeArea2, pa.ParentPracticeArea3)
				THEN 1
			ELSE 0
		END IsCriminalDefense
		,CASE
			WHEN 'Family' IN (pa.ParentPracticeArea1, pa.ParentPracticeArea2, pa.ParentPracticeArea3)
				THEN 1
			ELSE 0
		END IsFamily
		,CASE
			WHEN 'Estate Planning' IN (pa.ParentPracticeArea1, pa.ParentPracticeArea2, pa.ParentPracticeArea3)
				THEN 1
			ELSE 0
		END IsEstatePlanning
		,CASE
			WHEN 'Business' IN (pa.ParentPracticeArea1, pa.ParentPracticeArea2, pa.ParentPracticeArea3)
				THEN 1
			ELSE 0
		END IsBusiness
		, cl.first_name
		, cl.last_name
		, cl.state
		, cl.county
		, cl.city
		, cl.year_month
		, cl.month_begin_date
		, cl.month_end_date
		, cl.claimyearmonth
		, cl.is_claimed
		, cl.claim_status
		, CASE
			WHEN cl.claimyearmonth IS NULL
				THEN 0
			ELSE 1
			END IsClaimed
	, cl.is_contiguous_year
		, rt.avg_monthly_rating AS avvo_rating
	,CASE
		WHEN r.FirstReviewMonth = cl.year_month
			THEN 1
		ELSE 0
	END FirstReviewFlag
	, coalesce(r.CumulativeMonthlyReviews,0) as review_count
	,CASE
	   WHEN COALESCE(r.CumulativeMonthlyReviews, 0) >= 1
	     THEN 1
	   ELSE 0
	 END has_review
	,COALESCE(r.NewReviewCount, 0) AS new_reviews
	,COALESCE(r.CumulativeReviewMonths, 0) AS cumulative_review_months
	, coalesce(co.website_visitors_by_day,0) as website_visitors_by_day
	, coalesce(co.callers_by_day,0) as callers_by_day
	, coalesce(co.emailers_by_day,0) as emailers_by_day
	, coalesce(co.all_website_clicks,0) as all_monthly_website_clicks
	, coalesce(co.all_phone_contacts,0) as all_monthly_phone_contacts
	, coalesce(co.all_email_contacts,0) as all_monthly_email_contacts
	, CASE WHEN ad.professional_id IS NOT NULL
			then coalesce(co.website_visitors_by_day,0) + coalesce(co.all_phone_contacts,0) + coalesce(co.all_email_contacts,0)
		else coalesce(co.website_visitors_by_day,0) + coalesce(co.all_email_contacts,0) 
		end AS total_monthly_contacts
	, case when ad.professional_id is null then "N" else "Y" end as is_advertiser
	, COALESCE(ad.CumulativeAdvMonths, 0) AS cumulative_adv_months
	, COALESCE(ad.ad_start_month, 0) AS ad_start_month
	, COALESCE(ad.ad_end_month, 0) AS ad_end_month
	,COALESCE(profile_viewer_count_by_day, 0) AS profile_viewer_count_by_day
	,COALESCE(profile_render_count, 0) AS profile_render_count
from tmp_data_dm.sr_review_sparkler_profile_calendar cl
left join tmp_data_dm.sr_review_sparkler_contacts co 
  on co.professional_id = cl.professional_id
  AND co.year_month = cl.year_month
left join tmp_data_dm.sr_reviews_sparkler_olaf_adv ad 
  on ad.professional_id = cl.professional_id 
  AND ad.year_month = cl.year_month 
  left join tmp_data_dm.sr_review_sparkler_reviews r
  on r.professional_id = cl.professional_id
  AND r.year_month = cl.year_month
LEFT JOIN views2 vw
  ON vw.professional_id = cl.professional_id
  AND vw.year_month = cl.year_month
LEFT JOIN PA3 pa
	ON pa.professional_id = cl.professional_id
LEFT JOIN tmp_data_src.SR_sparklers_ratings_from_May_2015 rt
	ON rt.professional_id = cl.professional_id
	AND rt.year_month = cl.year_month
-- WHERE cl.year_month >= 201505
  /*ORDER BY cl.professional_id
    ,cl.year_month */
