/* invalidate metadata

INVALIDATE METADATA dm.professional_dimension
INVALIDATE METADATA dm.date_dim
INVALIDATE METADATA dm.professional_dimension
INVALIDATE METADATA dm.order_line_accumulation_fact
INVALIDATE METADATA src.page_view
INVALIDATE METADATA dm.historical_professional_dimension
*/

WITH profile as -- duplicates across professional_id due to practice area and specialty percent
(
/* get every professional by day for all time since they have claimed */
SELECT professional_id
  ,state
  ,county
  -- ,claim_date
  ,CASE
	WHEN claim_date IS NULL
		THEN 0
	WHEN claim_date > cal.actual_date
		THEN 0
	ELSE 1
  END IsClaimed
  ,cal.actual_date
  ,cal.month_begin_date
  ,CASE
	WHEN pd.claim_date IS NULL
		THEN 'N/A'
	WHEN pd.claim_date > cal.actual_date
		THEN 'N/A'
	WHEN DATEDIFF(cal.actual_date, pd.claim_date) < 365
		THEN '< 1 Year'
	WHEN DATEDIFF(cal.actual_date, pd.claim_date) BETWEEN 365 AND 729
		THEN '1-2 Years'
	WHEN DATEDIFF(cal.actual_date, pd.claim_date) BETWEEN 730 AND 1824
		THEN '2-5 Years'
	WHEN DATEDIFF(cal.actual_date, pd.claim_date) >= 1825
		THEN '>5 Years'
	ELSE NULL
	END TimeSinceClaim
FROM (
        select distinct p.professional_id
        		, p.professional_first_name as first_name
        		, p.professional_last_name as last_name
        		, p.professional_email_address_name as email
        		, p.professional_state_name_1 as "state"
        		, p.professional_county_name_1 as county
        		, p.professional_city_name_1 as city
        		, p.professional_avvo_rating as avvo_rating
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
				
        		-- AND p.professional_id < 100000 -- for testing
       ) pd
	CROSS JOIN (SELECT DISTINCT actual_date
				,d.year_month
				,d.month_begin_date
              FROM dm.date_dim d
              WHERE d.actual_date BETWEEN '2015-05-01' AND to_date(now() - Interval 1 day)
              AND   year_month > 0) cal

)


,

website AS (
  select ci.event_date
                    , ci.professional_id
                    ,COUNT(DISTINCT ci.persistent_session_id) Daily_Website_Visits
                    ,COUNT(ci.session_id) Total_Daily_Website_Sessions                
				from src.contact_impression ci
				WHERE ci.event_date >= '2015-05-01'
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
				WHERE ci.event_date >= '2015-05-01'
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
				WHERE ci.event_date >= '2015-05-01'
                AND ci.contact_type = 'email'
                GROUP BY 1,2
                                
)                                

,Ad1 AS (

SELECT pm.professional_id
,MIN(to_date(ns.created_at)) FirstAdDate
,to_date(COALESCE(ns.stopped_at, ns.expires_at, now())) LastAdDate
FROM src.nrt_subscription ns
JOIN dm.historical_ad_customer_professional_map pm
ON pm.ad_id = ns.ad_id
--AND pm.professional_id BETWEEN 10000 AND 11000
  AND pm.professional_id > 0
AND ns.created_at >= '2015-05-01'
  AND pm.product_line_item_id IN (1,5)
GROUP BY 1,3
-- ORDER BY 3,1
  
)

, Ad2 AS (
SELECT a.professional_id
,FirstAdDate
,MAX(LastAdDate) LastAdDate
FROM ad1 a/*src.nrt_subscription ns
JOIN dm.historical_ad_customer_professional_map pm
ON pm.ad_id = ns.ad_id
AND pm.professional_id BETWEEN 10000 AND 12000
AND ns.created_at >= '2015-01-01'
  AND pm.product_line_item_id IN (1,5) */
GROUP BY 1,2
-- ORDER BY 3,1
  
)


,

Ad3 AS(

SELECT DISTINCT a1.professional_id
-- ,a1.firstaddate
,CASE WHEN a2.lastaddate BETWEEN a1.firstaddate AND a1.lastaddate THEN to_date(DATE_ADD(a2.lastaddate, 1)) ELSE a1.firstaddate END AdStartDate -- when there's a partially overlapping window, move start date to one day after last end date
,a1.lastaddate AS AdEndDate
,CASE WHEN a2.firstaddate <= a1.firstaddate AND a2.lastaddate > a1.lastaddate THEN 1 -- when exists another interval that forms a superset of the current one, flag row for deletion
ELSE 0
END DeleteFlag
-- ,a2.firstaddate
-- ,a2.lastaddate
FROM ad2 a1
LEFT JOIN ad2 a2
ON a1.professional_id = a2.professional_id
AND (CASE WHEN a1.firstaddate = a2.firstaddate AND a2.lastaddate = a1.lastaddate THEN 1 ELSE 0 END) = 0  -- don't join identical pairs
AND (CASE WHEN a2.firstaddate > a1.firstaddate AND a2.lastaddate <= a1.lastaddate THEN 1 ELSE 0 END) = 0 -- don't join a smaller window to a larger one
AND (CASE WHEN a2.firstaddate > a1.lastaddate THEN 1 ELSE 0 END) = 0 -- don't join when the window fully postdates 
AND (CASE WHEN a2.lastaddate < a1.firstaddate THEN 1 ELSE 0 END) = 0 -- don't join when the window is the reverse of consecutive

-- ORDER BY 1,2
  
)

,

Ad4 AS (

SELECT DISTINCT a.professional_id -- do not add other fields or duplicates will emerge
,d.actual_date AS ad_date
FROM Ad3 a
JOIN dm.date_dim d
ON d.actual_date BETWEEN a.adstartdate AND a.adenddate
AND a.DeleteFlag = 0
)

,

Ad5 AS (

SELECT a.professional_id
	,a.ad_date
    ,a3.FirstAdDate
	,COUNT(a2.ad_date) CumulativeAdvDays
FROM Ad4 a
LEFT JOIN ad4 a2
ON a2.professional_id = a.professional_id
AND a2.ad_date < a.ad_date
LEFT JOIN (SELECT professional_id
           ,MIN(ad_date) FirstAdDate
           FROM ad4
           GROUP BY 1
           ) a3
ON a.professional_id = a3.professional_id
GROUP BY 1,2,3
)



,views AS

(
  /* Comments:
Up to dozens of renders per user/day, 
e.g. PSID 	222cb403-ecbb-4a5e-a1be-606d9b912682 for professional_id 4342738 on 04/20/2016 with 57 renders in a ~5 hour period
to query the "timestamp" field, needs to be enclosed in back-quotes, as it is a reserved word
some timestamp fields come back a few hours into the next day, even when grouping by event_date. looks like time zones aren't the same?
*/

SELECT event_date
,professional_id
,COUNT(DISTINCT persistent_session_id) DistinctUserCount
,SUM(RenderCount) RenderCount
FROM (
  SELECT event_date
,CAST(regexp_extract(url, '-([0-9]+)', 1) AS INT) as professional_id 
,persistent_session_id
,COUNT(distinct render_instance_guid) RenderCount
,MIN(`timestamp`) FirstRender
,MAX(`timestamp`) LastRender
FROM src.page_view
WHERE event_date >= '2015-05-01'
  and page_type = 'Attorney_Profile'
GROUP BY 1,2,3
-- ORDER BY 4 DESC
  ) a
GROUP BY 1,2
--order by 1,2
  
)

,
/* fix this part */
r1 AS (

select
  sd.professional_id
  ,(case when sd.displayable_score>10 then 10
  when sd.displayable_score<1 then 1 else
  sd.displayable_score end ) rating
  ,score_date
  ,ROW_NUMBER() OVER(PARTITION BY sd.professional_id ORDER BY score_date) Num
  from
  (
  select opsl.professional_id,opsl.score_date,round(sum(opsl.displayable_score)+5,1) displayable_score
  from
  src.history_barrister_professional_scoring_log  opsl
  join src.barrister_scoring_category_attribute  osca on
  opsl.scoring_category_attribute_id=osca.id
    AND opsl.score_date >= '2015-05-01'
    -- AND opsl.professional_id BETWEEN 10000 AND 10100
  join src.barrister_scoring_category  osc on
  osca.scoring_category_id=osc.id
  and osc.name='Overall'
  group by opsl.professional_id,opsl.score_date
  ) sd
  
  )
  
,
r2 AS (SELECT x.professional_id
,x.rating
,x.score_date AS ScoreDate1
,to_date(COALESCE(DATE_ADD(y.score_date, -1), now() - interval 1 day)) AS ScoreDate2
FROM r1 x
LEFT JOIN r1 y
ON x.professional_id = y.professional_id
AND x.Num = y.Num - 1
  -- ORDER BY 1,3,4   

)   

,
/* not all profiles have ratings */
r3 AS (
SELECT r.professional_id
,r.rating Rating
,d.actual_date RatingDate
FROM r2 r
JOIN dm.date_dim d
  ON d.actual_date BETWEEN r.scoredate1 AND r.scoredate2
 -- ORDER BY 1,3
  
)


select COUNT(DISTINCT cl.professional_id) ProfileCount
  ,cl.state
  ,cl.county
  ,cl.IsClaimed
  ,cl.actual_date
  ,cl.month_begin_date
  ,cl.TimeSinceClaim
	,r.rating
	,CASE
		WHEN r.rating IS NULL
			THEN 0
		ELSE 1
	END HasRating
	,v.RenderCount ProfileRenderCount
	,v.DistinctUserCount AS ProfileViewerCount
	,w.daily_website_visits
	,w.total_daily_website_sessions
	,p.daily_phone_contacts
	,p.total_daily_phone_sessions
	,e.daily_email_contacts
	,e.total_daily_email_sessions
	,CASE
		WHEN a.cumulativeadvdays IS NULL
			THEN 'N/A'
		WHEN a.cumulativeadvdays BETWEEN 0 AND 364
			THEN '< 1 Year'
		WHEN a.cumulativeadvdays BETWEEN 365 AND 729
			THEN '1-2 Years'
		WHEN a.cumulativeadvdays BETWEEN 730 AND 1824
			THEN '2-5 Years'
		WHEN a.cumulativeadvdays >= 1825
			THEN '>5 Years'
		ELSE NULL
	END CumulativeAdYears
	,CASE
		WHEN a.firstaddate IS NULL
			THEN 'N/A'
		WHEN a.firstaddate < cl.actual_date
			THEN 'N/A'
		WHEN DATEDIFF(cl.actual_date, a.firstaddate) BETWEEN 0 AND 364
			THEN '< 1 Year'
		WHEN DATEDIFF(cl.actual_date, a.firstaddate) BETWEEN 365 AND 729
			THEN '1-2 Years'
		WHEN DATEDIFF(cl.actual_date, a.firstaddate) BETWEEN 730 AND 1824
			THEN '2-5 Years'
		WHEN DATEDIFF(cl.actual_date, a.firstaddate) >= 1825
			THEN '>5 Years'
		ELSE NULL
	END TimeSinceFirstAd
	,CASE
		WHEN a.ad_date IS NOT NULL
			THEN 1
		ELSE 0
	END IsAdvertiser
			from profile cl
			LEFT join r3 r
				ON cl.professional_id = r.professional_id
				AND r.RatingDate = cl.actual_date
		    LEFT JOIN views v
				ON v.professional_id = cl.professional_id
				AND v.event_date = cl.actual_date
			LEFT JOIN website w
				ON w.professional_id = cl.professional_id
				AND w.event_date = cl.actual_date
			LEFT JOIN phone p
				ON p.professional_id = cl.professional_id
				AND p.event_date = cl.actual_date
			LEFT JOIN email e
				ON e.professional_id = cl.professional_id
				AND e.event_date = cl.actual_date				
			LEFT JOIN ad5 a
				ON a.professional_id = cl.professional_id
				AND a.ad_date = cl.actual_date
		    
			
				
			group by 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20 -- ,3
			-- ORDER BY cl.professional_id, cl.actual_date
			
/* SELECT *			
from dm.historical_professional_dimension pd
			where professional_id=19061			*/