WITH IsAdvertiser AS (
SELECT DISTINCT professional_id
FROM dm.mrr_professional_daily_all_products
	WHERE is_active = 'Y' -- denotes whether the person has DA/SL, MRR, or both 
AND etl_load_date BETWEEN DATE_ADD(now(), -30) AND now()
)

,ad_market AS (
SELECT ard.ad_region_county_id
,ard.ad_region_state_id
,amd.specialty_id
,md.state
,md.county
,md.specialty
,CONCAT(md.state, ' - ', md.county, ' - ', md.specialty) AS County_Specialty
,SUM(sl_unsold_value) sum_sl_unsold_value
,SUM(sl_inventory) sum_sl_inventory
,SUM(da_inventory + sl_inventory) sum_total_inventory
,AVG(sl_unsold_value) avg_sl_unsold_value
FROM dm.market_intelligence_detail md
LEFT JOIN dm.ad_market_dimension amd
	ON amd.ad_market_id = md.ad_market_id
LEFT JOIN dm.ad_region_dimension ard
	ON ard.ad_region_id = amd.ad_region_id	
WHERE etl_load_date = (SELECT MAX(etl_load_date) FROM dm.market_intelligence_detail)
GROUP BY 1,2,3,4,5,6,7
)

/* gives claimed attorneys, total attorneys, and defines "market" 
Is there a way to get these by county/state "id" so we don't have to join on strings? */
, attorneys AS (
SELECT pfad.professional_id
	,pfad.county
	,pfad.state
	,CONCAT(pfad.state, ' - ', pfad.county, ' - ', pa.PracticeArea1) AS Market
	,pfad.IsClaimed
	,CASE
		WHEN pfad.IsClaimed = 0
			THEN 1
		ELSE 0
	END AS IsUnclaimed
	,TRIM(LOWER(pa.ParentPracticeArea1)) PrimaryParentPA
	,TRIM(LOWER(pa.PracticeArea1)) PrimaryPA
	,pa.SpecialtyCount
	,pa.PrimarySpecialtyPercent
	,pfad.professional_postal_code_1
	,amd.ad_region_id
	,pa.Primary_Specialty_Id
	,gd.geo_county_id
	,gd.geo_state_id
FROM (
	SELECT pd.professional_id
	,trim(LOWER(pd.professional_county_name_1)) AS county
	,TRIM(LOWER(pd.professional_state_name_1)) AS state
	,CASE
		WHEN pd.professional_claim_date IS NOT NULL
			THEN 1
		ELSE 0
	END IsClaimed
	,pd.professional_postal_code_1
	FROM dm.professional_dimension pd
	WHERE pd.professional_county_name_1 <> 'NOT APPLICABLE'
	AND pd.professional_state_name_1 <> 'NOT APPLICABLE'
	AND pd.professional_county_name_1 IS NOT NULL
	AND pd.professional_state_name_1 IS NOT NULL
	AND pd.professional_countY_name_1 <> ''
	AND pd.professional_state_name_1 <> ''
	) pfad
	JOIN (SELECT x.PROFESSIONAL_ID
                   ,MIN(CASE WHEN x.rt = 1 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea1
                      ,MIN(CASE WHEN x.rt = 1 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea1
					  ,MIN(CASE WHEN x.rt = 1 THEN x.specialty_id ELSE NULL END) AS Primary_Specialty_Id
					  ,MAX(x.rt) SpecialtyCount
					  ,MAX(x.specialty_percent) PrimarySpecialtyPercent
               FROM (SELECT pfsp.PROFESSIONAL_ID
                            ,pfsp.SPECIALTY_PERCENT
                            ,sp.SPECIALTY_NAME
                            ,sp.PARENT_SPECIALTY_NAME
							,sp.specialty_id
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
	
)

,page_views AS (
SELECT waa.ad_specialty_id
,ard.ad_region_county_id
,ard.ad_region_state_id
,SUM(waa.page_view) pageviews
FROM dm.webanalytics_ad_attribution_v3 waa
LEFT JOIN dm.ad_region_dimension ard 
ON ard.ad_region_id = waa.ad_region_id
WHERE event_date BETWEEN DATE_ADD(now(), -30) AND now()
GROUP BY 1,2,3
-- there can be multiple ad regions per county... see e.g. "essex"
)

,

searches AS (
SELECT ard.ad_region_county_id
,ard.ad_region_state_id
,specialty_id
,SUM(search_count) AS search_count
FROM src.nrt_ad_inventory nai
LEFT JOIN dm.ad_region_dimension ard
	ON ard.ad_region_id = nai.sales_region_id	
WHERE etl_load_date BETWEEN DATE_ADD(now(), -30) AND now()
GROUP BY 1,2,3
)

SELECT ad.county
,ad.state
,ad.Specialty
,ad.County_Specialty
,ad.sum_sl_unsold_value
,ad.sum_sl_inventory
,ad.sum_total_inventory
,ad.avg_sl_unsold_value
,a.total_attorney_count
,a.claimed_attorney_count
,s.search_count
,pv.pageviews AS pageview_count
,ROW_NUMBER() OVER(ORDER BY ad.sum_sl_unsold_value DESC) AS Unsold_Rank
		FROM ad_market ad
		LEFT JOIN (
		SELECT a.Primary_Specialty_id
		,a.geo_county_id
		,a.geo_state_id
		,COUNT(DISTINCT a.professional_id) total_attorney_count
		,SUM(a.IsClaimed) AS claimed_attorney_count
		FROM attorneys a
		GROUP BY 1,2,3
		) a
		ON a.geo_county_id = ad.ad_region_county_id
		AND a.geo_state_id = ad.ad_region_state_id
		AND a.Primary_Specialty_Id = ad.specialty_id
	LEFT JOIN searches s
		ON s.ad_region_county_id = ad.ad_region_county_id
		AND s.ad_region_state_id = ad.ad_region_state_id
		AND s.specialty_id = ad.specialty_id
	LEFT JOIN page_views pv
		ON pv.ad_region_county_id = ad.ad_region_county_id
		AND pv.ad_region_state_id = ad.ad_region_state_id
		AND pv.ad_specialty_id = ad.specialty_id

		

-- join to ad_region_dimension to get county name

