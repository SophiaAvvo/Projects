WITH IsAdvertiser AS (
SELECT DISTINCT professional_id
FROM dm.mrr_professional_daily_all_products
	WHERE is_active = 'Y' -- denotes whether the person has DA/SL, MRR, or both 
AND etl_load_date BETWEEN DATE_ADD(now(), -30) AND now()
)

/* gives claimed attorneys, total attorneys, and defines "market" 
Is there a way to get these by county/state "id" so we don't have to join on strings? */
, claimed_non_advertisers AS (
SELECT pfad.professional_id
	,pfad.county
	,pfad.state
	,CONCAT(pfad.state, ' - ', pfad.county, ' - ', pa.PracticeArea1) AS Market
	/*,pfad.IsClaimed
	,CASE
		WHEN pfad.IsClaimed = 0
			THEN 1
		ELSE 0
	END AS IsUnclaimed */
	,TRIM(LOWER(pa.ParentPracticeArea1)) PrimaryParentPA
	,TRIM(LOWER(pa.PracticeArea1)) PrimaryPA
	,pa.SpecialtyCount
	,pa.PrimarySpecialtyPercent
	,pfad.professional_postal_code_1
	,amd.ad_region_id
FROM (
	SELECT pd.professional_id
	,trim(LOWER(pd.professional_county_name_1)) AS county
	,TRIM(LOWER(pd.professional_state_name_1)) AS state
	/*,CASE
		WHEN pd.professional_claim_date IS NOT NULL
			THEN 1
		ELSE 0
	END IsClaimed */
	,pd.professional_postal_code_1
	FROM dm.professional_dimension pd
	WHERE pd.professional_county_name_1 <> 'NOT APPLICABLE'
	AND pd.professional_state_name_1 <> 'NOT APPLICABLE'
	AND pd.professional_county_name_1 IS NOT NULL
	AND pd.professional_state_name_1 IS NOT NULL
	AND pd.professional_countY_name_1 <> ''
	AND pd.professional_state_name_1 <> ''
	AND pd.professional_claim_date IS NOT NULL
	) pfad
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
               GROUP BY 1) pa 
		ON pa.PROFESSIONAL_ID = pfad.PROFESSIONAL_ID
left join 
(
               select * from dm.geography_dimension
               where geo_postal_code!='Not Applicable'
) gd on substr(pfad.professional_postal_code_1,1,5)=substr(gd.geo_postal_code,1,5)
left join dm.ad_market_dimension amd 
	on amd.ad_region_id = gd.sales_region_id
	and amd.ad_market_specialty_name= pa.PracticeArea1
LEFT JOIN IsAdvertiser ia
	ON ia.professional_id = pfad.professional_id
WHERE ia.professional_id IS NULL
	
)

,page_views AS (
SELECT ard.ad_region_id
,ard.ad_region_name
,ard.ad_region_county_id
,TRIM(LOWER(ard.ad_region_county_name)) county
,ard.ad_region_state_id
,TRIM(LOWER(ard.ad_region_state_name)) state
,TRIM(LOWER(waa.ad_specialty)) AS Specialty
,TRIM(LOWER(waa.ad_parent_specialty)) AS Parent_Specialty
,SUM(waa.page_view) pageviews
FROM dm.webanalytics_ad_attribution_v3 waa
LEFT JOIN dm.ad_region_dimension ard 
ON ard.ad_region_id = waa.ad_region_id
WHERE LOWER(ard.ad_region_county_name) = 'essex'
GROUP BY 1,2,3,4,5,6,7,8
)
	
,profile_views AS

(
  select CAST(regexp_extract(url, '-([0-9]+)', 1) AS INT) as professional_id
, count(distinct render_instance_guid) as profile_view_count
from src.page_view pv
where event_date BETWEEN DATE_ADD(now(), -30) AND now() 
  and page_type = 'Attorney_Profile'
group by 1

)

,impressions AS (
SELECT professional_id
,COUNT(DISTINCT pi.render_instance_guid) Impressions
FROM src.professional_impression pi
where event_date BETWEEN DATE_ADD(now(), -30) AND now()
GROUP BY pi.professional_id)

/* likely not appropriate due to inconsistencies in block market purchasing patterns */
,contacts AS (
select ci.professional_id
					, COUNT(ci.render_instance_guid) AS all_website_clicks
					, 0 AS all_email_contacts
				from src.contact_impression ci
				where ci.contact_type = 'website'
					AND event_date BETWEEN DATE_ADD(now(), -30) AND now()
				group by 1
	
				union

				select ci.professional_id
					, 0 AS all_website_clicks
					, COUNT(ci.render_instance_guid) AS all_email_contacts
				from src.contact_impression ci
				where ci.contact_type IN ('email', 'message')
					AND event_date BETWEEN DATE_ADD(now(), -30) AND now()
				group by 1,2
		)

		
SELECT a.*
,COALESCE(pv.profile_view_count, 0) AS profile_view_count
,COALESCE(i.Impressions, 0) aS impressions_count
,COALESCE(c.all_website_clicks, 0) AS website_clicks_count
,COALESCE(c.all_email_contacts, 0) AS email_contacts_count
FROM claimed_non_advertisers a
	LEFT JOIN profile_views pv
		ON pv.professional_id = a.professional_id
	LEFT JOIN impressions i
		ON i.professional_id = a.professional_id
	LEFT JOIN contacts c
		ON c.professional_id = a.professional_id

-- join to ad_region_dimension to get county name

