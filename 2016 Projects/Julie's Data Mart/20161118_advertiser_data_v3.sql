WITH IsAdvertiser AS (
SELECT DISTINCT professional_id
FROM dm.mrr_professional_daily_all_products
	WHERE is_active = 'Y' -- denotes whether the person has DA/SL, MRR, or both 
AND etl_load_date BETWEEN DATE_ADD(now(), -30) AND now()
)

,ad_market AS (
SELECT gd.geo_county_id
,gd.geo_state_id
,amd.specialty_id
,SUM(sl_unsold_value) sum_sl_unsold_value
,SUM(sl_inventory) sum_sl_inventory
,SUM(da_inventory + sl_inventory) sum_total_inventory
,AVG(sl_unsold_value) avg_sl_unsold_value
FROM dm.market_intelligence_detail md
LEFT JOIN dm.ad_market_dimension amd
	ON amd.ad_market_id = md.ad_market_id
LEFT JOIN dm.geography_dimension gd
ON gd.sales_region_id = amd.ad_region_id
WHERE etl_load_date = (SELECT MAX(etl_load_date) FROM dm.market_intelligence_detail)
GROUP BY 1,2,3
)

,orders AS (
SELECT professional_id
,MAX(CASE
WHEN product_line_id = 7 
	THEN 1 
	ELSE 0 
END) AS Is_SL
,MAX(CASE
WHEN product_line_id = 2 
	THEN 1 
ELSE 0 
END) AS Is_DA
,SUM(CASE WHEN product_line_id = 2 THEN block_count ELSE 0 END) DA_blocks
,SUM(CASE WHEN product_line_id = 7 THEN block_count ELSE 0 END) SL_blocks
,SUM(block_count) total_blocks
FROM dm.order_line_accumulation_fact
WHERE product_line_id IN (2, 7)
AND YEAR(order_line_begin_date) = YEAR(now())
AND MONTH(order_line_begin_date) = MONTH(now())
GROUP BY 1
HAVING
)

/* gives claimed attorneys, total attorneys, and defines "market" 
Is there a way to get these by county/state "id" so we don't have to join on strings? */
, advertisers AS (
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
	,pa.Primary_Specialty_Id
	,gd.geo_county_id
	,gd.geo_state_id
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
	JOIN IsAdvertiser ia
	ON ia.professional_id = pfad.professional_id
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
					, COUNT(CASE WHEN ci.contact_type = 'website'
										THEN ci.render_instance_guid
									ELSE NULL
								END) AS all_website_clicks
					,COUNT (CASE
								WHEN ci.contact_type IN ('email', 'message')
									THEN ci.render_instance_guid
								ELSE NULL
							END) AS all_email_contacts
				from src.contact_impression ci
				where ci.contact_type IN ('website', 'email', 'message')
					AND event_date BETWEEN DATE_ADD(now(), -30) AND now()
				group by 1
		)

		
SELECT a.*
,ad.sum_sl_unsold_value
,ad.sum_sl_inventory
,ad.sum_total_inventory
,ad.avg_sl_unsold_value
,COALESCE(pv.profile_view_count, 0) AS profile_view_count
,COALESCE(i.Impressions, 0) aS impressions_count
,COALESCE(c.all_website_clicks, 0) AS website_clicks_count
,COALESCE(c.all_email_contacts, 0) AS email_contacts_count
,o.Is_SL
,o.Is_DA
,COALESCE(o.DA_blocks, 0) DA_blocks
,COALESCE(o.SL_blocks, 0) SL_blocks
,COALESCE(o.total_blocks, 0) total_blocks
,CASE
	WHEN Is_SL = 1 AND o.SL_blocks = 0
		THEN 1
	ELSE 0
END IsExclusiveSL
,CASE
	WHEN Is_DA = 1 AND o.DA_blocks = 0
		THEN 1
	ELSE 0
END IsExclusiveDA
FROM advertisers a
	LEFT JOIN profile_views pv
		ON pv.professional_id = a.professional_id
	LEFT JOIN impressions i
		ON i.professional_id = a.professional_id
	LEFT JOIN contacts c
		ON c.professional_id = a.professional_id
	LEFT JOIN orders o
		ON o.professional_id = a.professional_id
	LEFT JOIN ad_market ad
		ON a.geo_county_id = ad.geo_county_id
		AND a.geo_state_id = ad.geo_state_id
		AND a.Primary_Specialty_Id = ad.specialty_id	

-- join to ad_region_dimension to get county name

