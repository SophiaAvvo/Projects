WITH IsAdvertiser AS (
SELECT
   mrr.yearmonth AS year_month
  ,SUM(CASE WHEN (mca.customer_id IS NOT NULL) THEN 1 ELSE 0 END) AS advertisers
  ,SUM(CASE WHEN (mrr.mrr_current_total <> 0 OR mca.customer_id IS NOT NULL) THEN 1 ELSE 0 END) AS active_customers
FROM dm.mrr_customer_category_all_products mrr
  LEFT OUTER JOIN dm.mrr_customer_classification mca
          ON mrr.customer_id = mca.customer_id
         AND mrr.yearmonth = mca.yearmonth
WHERE mrr.mrr_customer_category NOT IN ('CHURNED', 'NOT BILLED')
  AND mrr.yearmonth >= 201511
GROUP BY 1

/* gives claimed attorneys, total attorneys, and defines "market" */
SELECT pd.professional_id
,pd.professional_county_name_1 AS county
,pd.professional_state_name_1 AS state
,pa.ParentPracticeArea1
,pa.PracticeArea1
,CONCAT(pd.professional_state_name_1, ' - ', pd.professional_county_name_1, ' - ', pa.PracticeArea1)
,CASE
	WHEN pd.professional_claim_date IS NOT NULL
		THEN 1
	ELSE 0
END IsClaimed
FROM dm.professional_dimension pd
	JOIN (SELECT x.PROFESSIONAL_ID
                   ,MIN(CASE WHEN x.rt = 1 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea1
                      ,MIN(CASE WHEN x.rt = 1 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea1
					  ,MAX(x.rt) SpecialtyCount
					  ,MAX(x.specialty_percent) PrimarySpecialtyPercent
               FROM (SELECT pfsp.PROFESSIONAL_ID
                            ,pfsp.SPECIALTY_PERCENT
                            ,sp.SPECIALTY_NAME
                            ,sp.PARENT_SPECIALTY_NAME
                            ,ROW_NUMBER() OVER (PARTITION BY pfsp.PROFESSIONAL_ID ORDER BY pfsp.SPECIALTY_PERCENT DESC) rt
                     FROM DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp
                       JOIN DM.SPECIALTY_DIMENSION sp ON sp.SPECIALTY_ID = pfsp.SPECIALTY_ID
                     WHERE pfsp.DELETE_FLAG = 'N') x
               GROUP BY 1) toppa 
		ON toppa.PROFESSIONAL_ID = pfad.PROFESSIONAL_ID
	WHERE pa.PracticeArea1 IS NOT NULL


webanalytics_ad_attribution_v3

-- join to ad_region_dimension to get county name

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