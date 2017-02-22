
WITH profile as -- duplicates across professional_id due to practice area and specialty percent
(

SELECT professional_id
  ,state
  -- ,county
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
	-- ,SanctionCheck
FROM (
        select distinct p.professional_id

        		, p.professional_state_name_1 as "state"
        		, p.professional_county_name_1 as county
				/*,CASE
					WHEN ps.sanctioned = 'Y'
						THEN 'Sanctioned'
					WHEN ps.sanctioned = 'N'
						THEN 'Not Sanctioned'
					END SanctionCheck */
               ,p.professional_claim_date AS claim_date
        	from dm.professional_dimension p
			/*LEFT JOIN src.barrister_professional_status ps
				ON ps.professional_id = p.professional_id */


				WHERE p.professional_delete_indicator = 'Not Deleted'
        		and p.professional_practice_indicator = 'Practicing'
        		and p.professional_name = 'lawyer'
        		and p.industry_name = 'Legal'

        		AND p.professional_id BETWEEN 100000 AND 101000-- for testing
       ) pd
	CROSS JOIN (SELECT DISTINCT actual_date
				,d.year_month
				,d.month_begin_date
              FROM dm.date_dim d
              WHERE d.actual_date BETWEEN '2015-05-01' AND to_date(now() - Interval 1 day)
              AND   year_month > 0) cal

)




, Ad2 AS (
SELECT a.professional_id
,FirstAdDate
,MAX(LastAdDate) LastAdDate
FROM srcmgd.tmp_professional_dates a
GROUP BY 1,2

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


,

/* ratings only get recalculated if the profile is changed/updated, so we have to go back for all time */
r2 AS (SELECT x.professional_id
,x.rating
,x.score_date AS ScoreDate1
,ScoreDate2
FROM srcmgd.tmp_professional_score_date x
JOIN (SELECT professional_id
				,rating
				,to_date(COALESCE(DATE_ADD(score_date, -1), now() - interval 1 day)) ScoreDate2
				,Num - 1 AS Iterator
			FROM srcmgd.tmp_professional_score_date
            
			) y
ON x.professional_id = y.professional_id
AND x.Num = y.Iterator
AND y.ScoreDate2 >= '2015-05-01'

  -- ORDER BY 1,3,4

)

,
/* now most profiles have ratings since we aren't date-restricting until the cross join */
r3 AS (
SELECT DISTINCT r.professional_id
,r.rating Rating
,d.actual_date RatingDate
FROM r2 r
JOIN dm.date_dim d
  ON d.actual_date BETWEEN r.scoredate1 AND r.scoredate2
  AND d.actual_date >= '2015-05-01'
 -- ORDER BY 1,3

)


select cl.professional_id--COUNT(DISTINCT cl.professional_id) ProfileCount
  ,cl.state
  --,cl.county
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
	/*,v.RenderCount ProfileRenderCount
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
	END IsAdvertiser */
	-- ,cl.SanctionCheck
			from profile cl
			LEFT join r3 r
				ON cl.professional_id = r.professional_id
				AND r.RatingDate = cl.actual_date
		    /*LEFT JOIN srcmgd.tmp_profile_render_count v -- views
				ON v.professional_id = cl.professional_id
				AND v.event_date = cl.actual_date
			LEFT JOIN srcmgd.tmp_website_count w
				ON w.professional_id = cl.professional_id
				AND w.event_date = cl.actual_date
			LEFT JOIN srcmgd.tmp_phone_count p
				ON p.professional_id = cl.professional_id
				AND p.event_date = cl.actual_date
			LEFT JOIN srcmgd.tmp_email_count e
				ON e.professional_id = cl.professional_id
				AND e.event_date = cl.actual_date
			LEFT JOIN ad5 a
				ON a.professional_id = cl.professional_id
				AND a.ad_date = cl.actual_date */



			-- group by 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19 -- ,20 -- ,3
			-- ORDER BY cl.professional_id, cl.actual_date
