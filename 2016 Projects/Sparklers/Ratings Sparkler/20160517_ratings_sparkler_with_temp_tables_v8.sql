
WITH profile as -- duplicates across professional_id due to practice area and specialty percent
(

SELECT professional_id
  ,state
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

        		, p.professional_state_name_1 as "state"
        		, p.professional_county_name_1 as county

               ,p.professional_claim_date AS claim_date
        	from dm.professional_dimension p


				WHERE p.professional_delete_indicator = 'Not Deleted'
        		and p.professional_practice_indicator = 'Practicing'
        		and p.professional_name = 'lawyer'
        		and p.industry_name = 'Legal'

       ) pd
	CROSS JOIN (SELECT DISTINCT actual_date
				,d.year_month
				,d.month_begin_date
              FROM dm.date_dim d
              WHERE d.actual_date BETWEEN '2015-05-01' AND '2016-04-30'
              AND   year_month > 0) cal

)




select COUNT(DISTINCT cl.professional_id) ProfileCount
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
	,COALESCE(v.RenderCount, 0) ProfileRenderCount
	,COALESCE(v.DistinctUserCount, 0) AS ProfileViewerCount
	,COALESCE(w.daily_website_visits, 0) website_visitors
	,COALESCE(w.total_daily_website_sessions, 0) total_website_clicks
	,COALESCE(p.daily_phone_contacts, 0) phone_callers
	,COALESCE(p.total_daily_phone_sessions, 0) total_phone_calls
	,COALESCE(e.daily_email_contacts, 0) email_writers
	,COALESCE(e.total_daily_email_sessions) total_emails
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
			THEN 'Advertiser'
		ELSE 'Non-Advertiser'
	END IsAdvertiser
			from profile cl
			left join tmp_data_src.sr_sparklers_ratings_from_May_2015 r 
				ON cl.professional_id = r.professional_id
				AND r.RatingDate = cl.actual_date
		    LEFT JOIN srcmgd.tmp_profile_render_count v -- views
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
			LEFT JOIN tmp_data_src.sr_sparklers_ads_from_May_2015 a
				ON a.professional_id = cl.professional_id
				AND a.ad_date = cl.actual_date



			group by 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
