

with ad_inventory as
(
 /* the next query gets the same information from the current tables */
 -- starting in 2016, need to use src.hist_nrt_ad_inventory.
  -- can't use block_price_history because we're looking at both block and exclusive
  -- can't use nrt_ad_inventory because we need past months
  
select t3.year_month, t3.ad_market_id, t3.sl_inventory_type, sum(t3.sl_inventory) sl_inventory, sum(t3.sl_price) sl_price, sum(t3.sl_subscription_price) sl_subscription_price,
  t3.da_inventory_type, sum(t3.da_inventory) da_inventory, sum(t3.da_price) da_price
 from
(select t2.year_month, t2.ad_market_id,
  case when t2.insertion_ad = 1 then 'Exclusive' else 'Block' end sl_inventory_type,
  case when t2.insertion_ad = 1 and t2.ad_inventory_type = 'Sponsored Listing' then 3 when t2.insertion_ad = 0 and t2.ad_inventory_type = 'Sponsored Listing'
     then t2.sellable_count else 0 end sl_inventory,
  case when t2.ad_inventory_type = 'Sponsored Listing' then t2.list_price/100 else 0 end sl_price,
  case when t2.ad_inventory_type = 'Sponsored Listing' then t2.list_price/100 else 0 end sl_subscription_price,
  case when t2.insertion_ad = 1 then 'Exclusive' else 'Block' end da_inventory_type,
  case when t2.insertion_ad = 1 and t2.ad_inventory_type = 'Display' then 1 when t2.insertion_ad = 0 and t2.ad_inventory_type = 'Display'
    then t2.sellable_count else 0 end da_inventory,
  case when t2.ad_inventory_type = 'Display' then t2.list_price/100 else 0 end da_price
from
(select distinct amd.ad_market_id, t.year_month, h.ad_inventory_type, h.insertion_ad, h.list_price, h.sellable_count
from src.hist_nrt_ad_inventory h
join (
select year_month, ad_inventory_type, sales_region_id, specialty_id, max(max_update) mdate
from (
select md.year_month, hai.ad_inventory_type, hai.sales_region_id, hai.specialty_id, hai.max_update
from dm.month_dim md
  join (select ad_inventory_type, sales_region_id, specialty_id, extract(month from updated_at) month, extract(year from updated_at) year, max(updated_at) max_update
  from src.hist_nrt_ad_inventory
  group by 1, 2, 3, 4, 5) hai on hai.max_update <= md.month_end_date
  where md.year_month = (extract(year from now()))*100 +extract(month from now())
  and md.year_month = (extract(year from now()))*100 +extract(month from now()) ) mu
group by 1,2,3,4
) t on t.ad_inventory_type = h.ad_inventory_type and t.sales_region_id = h.sales_region_id and t.specialty_id = h.specialty_id and t.mdate = h.updated_at
join dm.ad_market_dimension amd on amd.ad_region_id = h.sales_region_id and amd.specialty_id = h.specialty_id
 where amd.ad_market_active_flag = 'Y'
)t2
where t2.year_month = 201607 -- updating to current month; originally this was run in april and the month was set to 201604
) t3
group by t3.year_month, t3.ad_market_id, t3.sl_inventory_type, t3.da_inventory_type
)

-- ad_revenue: by month and market id, what is the sold revenue and inventory for DA and SL
, ad_revenue as
(
select dto.YEAR_MONTH
                             , coalesce(admkt.ad_market_id, 0) ad_mkt_id
                             , SUM(case when pln.PRODUCT_LINE_ITEM_NAME = 'Sponsored Listing' and olaf.order_line_indicator_id  in (1,2,3) /*purchased*/ and olaf.BLOCK_COUNT = 0 then 1
                                                          when pln.PRODUCT_LINE_ITEM_NAME = 'Sponsored Listing' and olaf.order_line_indicator_id in (1,2,3) and olaf.BLOCK_COUNT > 0 then olaf.BLOCK_COUNT 
                                                          else 0 end) as sl_sold_inventory
                             , SUM(case when pln.PRODUCT_LINE_ITEM_NAME = 'Sponsored Listing' then olaf.order_line_net_price_amount_usd else 0 end) as sl_revenue
                             , SUM(case when pln.PRODUCT_LINE_ITEM_NAME = 'Display Medium Rectangle' and olaf.order_line_indicator_id in (1,2,3) and olaf.block_count = 0 then 1
                                   when pln.PRODUCT_LINE_ITEM_NAME = 'Display Medium Rectangle' and olaf.order_line_indicator_id in (1,2,3) and olaf.block_count > 0 then olaf.block_count 
                                   else 0 end) as da_sold_inventory
                             , SUM(case when pln.PRODUCT_LINE_ITEM_NAME = 'Display Medium Rectangle' then olaf.order_line_net_price_amount_usd else 0 end) as da_revenue
              from DM.order_line_accumulation_fact  olaf    
              join DM.DATE_DIM dto on dto.actual_date = olaf.ORDER_LINE_BEGIN_DATE
              left join DM.product_line_dimension  pln on pln.product_line_id = olaf.product_line_id
              left join DM.order_line_ad_market_fact  oladmkt on oladmkt.order_line_number  = olaf.order_line_number
              left join DM.ad_market_dimension  admkt on admkt.ad_market_id = oladmkt.ad_market_id 
             where dto.YEAR_MONTH =  (extract(year from now()-interval 1 months))*100 +extract(month from now() - interval 1 months) -- I believe this should be left alone... the current month is incomplete, so we use the previous, right?
                            and olaf.order_line_payment_date  <> '-1' -- exclude orders that do not have payment
                            and pln.product_line_item_name  in ('Sponsored Listing', 'Display Medium Rectangle')
              group by 1,2
)

-- temp1: combines market and specialty dimensions with above ad_revenue and ad_inventory
-- calculates value and sold_value for SL and DA separately
 , temp1 as (
SELECT md.year_month
				,adm.ad_market_id
                                ,admm.ad_mkt_key
				,lower(adm.ad_market_state_name) AS STATE
				,lower(adm.ad_market_county_name) AS county
				,lower(adm.ad_market_region_name) AS ad_region
				,sp.parent_specialty_name AS parent_sp
				,adm.ad_market_specialty_name AS specialty
                ,adm.specialty_id
				,CASE 
					WHEN adm.ad_market_block_flag = 'Y'
						THEN 'Block'
					ELSE 'Exclusive'
					END AS market_type
				-- Sponsored Listing
				,ai.sl_inventory_type
				,ai.sl_inventory
				,ai.sl_price
				,ai.sl_subscription_price
				,ai.sl_inventory * ai.sl_price AS sl_value
				,coalesce(ar.sl_sold_inventory, 0) AS sl_sold_inventory
				,coalesce(ar.sl_sold_inventory, 0) * ai.sl_price AS sl_sold_value
				,coalesce(ar.sl_revenue, 0) AS sl_revenue
				-- Display Ad
				,ai.da_inventory_type
				,ai.da_inventory
				,ai.da_price
				,ai.da_inventory * ai.da_price AS da_value
				,coalesce(ar.da_sold_inventory, 0) AS da_sold_inventory
				--                          , ai.da_inventory - coalesce(ar.da_sold_inventory, 0) as da_unsold_inventory
				,coalesce(ar.da_sold_inventory, 0) * ai.da_price AS da_sold_value
				,coalesce(ar.da_revenue, 0) AS da_revenue
				-- Total Ad
				,coalesce(ar.sl_revenue, 0) + coalesce(ar.da_revenue, 0) AS ad_revenue
			FROM DM.ad_market_dimension adm
			INNER JOIN DM.specialty_dimension sp ON sp.specialty_id = adm.specialty_id
			INNER JOIN DM.MONTH_DIM md ON md.year_month = 201607 -- originally this was set to 201501, but I don't think we need that.  We will be setting year_month to the current month, so I'm just pulling one month's worth of data here
				-- AND md.year_month <= (extract(year FROM now()) * 100) + extract(month FROM now())
			LEFT JOIN ad_inventory ai ON ai.ad_market_ID = adm.AD_MarkeT_ID
				AND ai.year_month = md.year_month
			LEFT JOIN ad_revenue ar ON ar.AD_MKT_ID = adm.AD_MarkeT_ID
				AND ar.year_month = md.year_month
                        LEFT JOIN DM.ad_mkt_dim admm on adm.ad_market_id = admm.ad_mkt_id
			WHERE adm.ad_market_active_flag = 'Y'
				AND sp.specialty_id >= 1
				-- AND sp.specialty_id <= 131
				)

-- temp2: includes everything from temp1
-- then calculates unsold_inventory and _value, revenue_opportunity, and monetization for SL and DA separately
,temp2 as (
select temp1.*
			,sl_inventory - coalesce(sl_sold_inventory, 0) AS sl_unsold_inventory
			,(sl_inventory - coalesce(sl_sold_inventory, 0)) * sl_price AS sl_unsold_value
			,sl_sold_value / sl_value AS sl_sell_through
			,sl_value - coalesce(sl_revenue, 0) AS sl_revenue_opportunity
			,coalesce(sl_revenue, 0) / sl_value AS sl_monetization
			,CASE 
				WHEN (coalesce(sl_revenue, 0) / sl_value) >= 0.8
					THEN 'High'
				WHEN (coalesce(sl_revenue, 0) / sl_value) >= 0.5
					THEN 'Medium'
				ELSE 'Low'
				END AS sl_monetization_status
			,da_inventory - coalesce(da_sold_inventory, 0) AS da_unsold_inventory
			,(da_inventory - coalesce(da_sold_inventory, 0)) * da_price AS da_unsold_value
			,da_sold_value / da_value AS da_sell_through
			,da_value - coalesce(da_revenue, 0) AS da_revenue_opportunity
			,coalesce(da_revenue, 0) / da_value AS da_monetization
			,CASE 
				WHEN (coalesce(da_revenue, 0) / da_value) >= 0.8
					THEN 'High'
				WHEN (coalesce(da_revenue, 0) / da_value) >= 0.5
					THEN 'Medium'
				ELSE 'Low'
				END AS da_monetization_status
		FROM temp1
		)

-- temp3: pulls in everything from temp2 (and therefore also temp1)
-- calculates total ad values and revenue opportunity
,temp3 as (
select temp2.*
		,sl_value + da_value AS ad_value
		,sl_sold_value + da_sold_value AS ad_sold_value
		,sl_unsold_value + da_unsold_value AS ad_unsold_value
		,sl_revenue_opportunity + da_revenue_opportunity AS ad_revenue_opportunity
from temp2
)

-- ad_market_detail: includes everything in temp3
-- calculates total sell-through and monetization
-- adds monetization status and market size buckets

/*,ad_market_detail as (
	SELECT temp3.*
	,ad_sold_value / ad_value AS ad_sell_through
	,ad_revenue / ad_value AS ad_monetization
	,CASE 
		WHEN (ad_revenue / ad_value) >= 0.8
			THEN 'High'
		WHEN (ad_revenue / ad_value) >= 0.5
			THEN 'Medium'
		ELSE 'Low'
		END AS ad_monetization_status
	,CASE 
		WHEN ad_value >= 5000
			THEN 'Huge'
		WHEN ad_value >= 1500
			THEN 'Big'
		WHEN ad_value >= 300
			THEN 'Medium'
		WHEN ad_value >= 25
			THEN 'Small'
		ELSE 'Tiny'
		END AS market_size
	FROM temp3
	) */

,


pa_ad_values AS (
-- want to calculate ad value and % unsold separately for block vs. exclusive markets
SELECT specialty AS PracticeArea
  ,specialty_id
  ,state
  ,county
  ,SUM(ad_value) total_ad_value
  ,SUM(ad_unsold_value) total_unsold_value  
    ,SUM(CASE
      WHEN market_type = 'Block'
         THEN ad_value
         ELSE 0
      END) Block_ad_value

FROM temp3 
WHERE year_month = 201607
GROUP BY 1,2,3,4

)

,

county_ad_values AS (
  SELECT state
  ,county
  ,SUM(ad_value) total_ad_value
  ,SUM(ad_unsold_value) total_unsold_value  
    ,SUM(CASE
      WHEN market_type = 'Block'
         THEN ad_value
         ELSE 0
      END) Block_ad_value
FROM temp3 
WHERE year_month = 201607
GROUP BY 1,2
  
)

,

pa_ad_calcs AS (
  SELECT state
   ,county
   ,PracticeArea
   ,specialty_id
   ,total_ad_value
   ,CAST(total_unsold_value AS DECIMAL)/CAST(total_ad_value AS DECIMAL) unsold_percent
   ,CASE
      WHEN Block_ad_value > 0
         THEN 1
      ELSE 0
    END BlockMarketFlag
  FROM pa_ad_values
  
)

,

county_ad_calcs AS (
  SELECT state
   ,county
   ,total_ad_value
   ,CAST(total_unsold_value AS DECIMAL)/CAST(total_ad_value AS DECIMAL) unsold_percent
   ,CASE
      WHEN Block_ad_value > 0
         THEN 1
      ELSE 0
    END BlockMarketFlag
  FROM county_ad_values
  
)

,

practice_area AS (

SELECT spl.*
  ,pfsp.professional_specialty_id
  ,pfsp.professional_id
  -- ,pfsp.specialty_id
  ,pfsp.specialty_percent*.01 specialty_percent
                     FROM 
                     (
                       SELECT DISTINCT sp.specialty_id
                       ,sp.specialty_name as practice_area
                     FROM DM.SPECIALTY_DIMENSION sp ) spl
                     LEFT JOIN DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp
                       ON spl.SPECIALTY_ID = pfsp.SPECIALTY_ID
                       AND pfsp.DELETE_FLAG = 'N'
  
)

,

deduped_pfad AS
(
SELECT pfad.PROFESSIONAL_ID
         ,pfad.is_claim
         ,pfad.is_unclaimed
         -- ,pfad.claim_date
         -- ,pfad.claim_method
         ,pfad.domain
         ,COALESCE(pfad.emaildomain, 'No Valid Email') emaildomain
          -- ,pfad.emailsuffix
          ,pfad.lowscoreemaildomain
         ,pfad.rating
         ,pfad.county
         ,pfad.state
         ,CASE
           WHEN toppa.ParentPracticeArea1 IN ("Criminal Defense","DUI & DWI","Divorce & Separation","Personal Injury","Family","Immigration","Car Accidents","Bankruptcy & Debt","Chapter 11 Bankruptcy","Chapter 13 Bankruptcy","Chapter 7 Bankruptcy","Workers Compensation","Child Custody","Employment & Labor","Real Estate","Estate Planning","Business","Lawsuits & Disputes","Motorcycle Accident") THEN 'Y'
           ELSE 'N'
         END AS PriorityPA1
         ,pfad.LawyerName
         ,pfad.LawyerName_Full
         ,pfad.prefix
         ,pfad.firstname
         ,pfad.lastname
         ,pfad.middlename
         ,pfad.suffix
         ,pfad.phone1
         ,pfad.phone2
         ,pfad.phone3
         ,pfad.email
         ,pfad.prof_name AS professional_name
         ,pfad.ind_name AS industry_name
         ,pfad.country AS professional_country_name_1
         ,REGEXP_REPLACE(toppa.PracticeArea1, ',', '') PracticeArea1
         ,REGEXP_REPLACE(toppa.PracticeArea2, ',', '') PracticeArea2
         ,REGEXP_REPLACE(toppa.PracticeArea2, ',', '') PracticeArea3
         ,REGEXP_REPLACE(toppa.ParentPracticeArea1, ',', '') ParentPracticeArea1
         ,REGEXP_REPLACE(toppa.ParentPracticeArea2, ',', '') ParentPracticeArea2
         ,REGEXP_REPLACE(toppa.ParentPracticeArea3, ',', '') ParentPracticeArea3
         ,CASE
           WHEN pfad.HasEmail = 1 THEN 'Ok Email'
           ELSE 'Bad Email'
         END Email_Status
         ,CASE
           WHEN pfad.HasPhone1 + pfad.HasPhone2 + pfad.HasPhone3 = 0 THEN 'Bad Phone'
           ELSE 'Ok Phone'
         END AS Phone_Status
         ,pfad.IsExcludedTitle
         ,customer_may_contact
  FROM (SELECT pd.*
              ,CASE
                 WHEN pd.phone1 IS NOT NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.phone1,pd.email,pd.lastname,pd.firstname,pd.state ORDER BY pd.is_claim DESC, pd.phone1 DESC,pd.email DESC,phone2 DESC,phone3 DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NonNullPhone1Check
               ,CASE
                 WHEN pd.phone1 IS NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.email,pd.firstname,pd.lastname,pd.state ORDER BY pd.is_claim DESC, pd.email DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NullPhone1Check
               ,CASE
                 WHEN pd.email IS NOT NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.email,pd.phone1,pd.lastname,pd.firstname,pd.state ORDER BY pd.is_claim DESC, pd.phone1 DESC,pd.email DESC,phone2 DESC,phone3 DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NonNullEmailCheck
               ,CASE
                 WHEN pd.email IS NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.phone1,pd.firstname,pd.lastname,pd.state ORDER BY pd.is_claim DESC, pd.phone1 DESC,phone2 DESC,phone3 DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NullEmailCheck
               ,CASE
                 WHEN pd.email IS NULL AND pd.phone1 IS NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.lastname,pd.firstname,pd.state ORDER BY pd.is_claim DESC, pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS DoubleNullCheck 
               ,CASE
                 WHEN pd.email IS NULL THEN 0
                 ELSE 1
               END AS HasEmail
               ,CASE
                 WHEN pd.phone1 IS NULL THEN 0
                 ELSE 1
               END AS HasPhone1
               ,CASE
                 WHEN pd.phone2 IS NULL THEN 0
                 ELSE 1
               END AS HasPhone2
               ,CASE
                 WHEN pd.county IS NULL THEN 0
                 ELSE 1
               END AS HasCounty
               ,CASE
                 WHEN pd.phone3 IS NULL THEN 0
                 ELSE 1
               END AS HasPhone3
               ,CASE
                 WHEN pd.MiddleInitial IS NULL THEN 0
                 ELSE 1
               END AS HasMiddleInitial
               -- ,(SUBSTR(UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3)) EmailSuffix
               ,CASE
                 WHEN (SUBSTR (UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3) IN ('.EDU','.GOV','.ORG', '.MIL')) THEN 1
                 WHEN INSTR(LOWER(pd.emaildomain), '.gov') > 0
                    THEN 1        
                 WHEN INSTR(LOWER(pd.emaildomain), '.org') > 0
                    THEN 1
                 WHEN INSTR(LOWER(pd.emaildomain), '.edu') > 0
                    THEN 1
                 WHEN INSTR(LOWER(pd.emaildomain), '.mil') > 0
                    THEN 1        
                 WHEN INSTR(LOWER(pd.emaildomain), '.co.us') > 0
                    THEN 1
                 WHEN INSTR(LOWER(pd.emaildomain), 'courts.') > 0
                    THEN 1
                 WHEN INSTR(LOWER(pd.emaildomain), '.state') > 0
                    THEN 1
                 WHEN STRLEFT(LOWER(pd.emaildomain), 3) = 'co.'
                 AND STRRIGHT(LOWER(pd.emaildomain), 3) = '.us'
                    THEN 1
                 WHEN INSTR(LOWER(pd.emaildomain), 'prosecutor') > 0 
                 AND INSTR(LOWER(pd.emaildomain), 'county') > 0
                    THEN 1       
                 ELSE 0
               END AS LowScoreEmailDomain
        FROM (SELECT pf.PROFESSIONAL_ID
                     -- ,pf.professional_claim_method_name claim_method
                     ,CASE
                       WHEN pf.PROFESSIONAL_CLAIM_DATE IS NULL THEN 0
                       ELSE 1
                     END AS is_claim
                     ,CASE
                       WHEN pf.PROFESSIONAL_CLAIM_DATE IS NULL THEN 1
                       ELSE 0
                     END AS is_unclaimed
                    --  ,pf.professional_claim_date claim_date
                     ,CASE
                       WHEN pf.PROFESSIONAL_COUNTY_NAME_1 = 'NOT APPLICABLE'
              THEN NULL
                       ELSE LOWER(TRIM(pf.PROFESSIONAL_COUNTY_NAME_1))
                     END county
                     ,CASE
                       WHEN pf.PROFESSIONAL_STATE_NAME_1 = 'NOT APPLICABLE'
              THEN NULL
                       ELSE LOWER(TRIM(pf.PROFESSIONAL_STATE_NAME_1))
                     END state
                     ,CASE
                       WHEN pf.PROFESSIONAL_CITY_NAME_1 = 'NOT APPLICABLE' THEN NULL
                       ELSE LOWER(TRIM(pf.PROFESSIONAL_CITY_NAME_1))
                     END city
                     ,PROFESSIONAL_PREFIX Prefix
                     ,PROFESSIONAL_FIRST_NAME AS FirstName
                     ,PROFESSIONAL_LAST_NAME AS LastName
                     ,PROFESSIONAL_MIDDLE_NAME AS MiddleName
                     ,PROFESSIONAL_SUFFIX AS Suffix
                     ,CASE
                       WHEN PROFESSIONAL_PHONE_NUMBER_1 LIKE '%Not%'
              THEN NULL
                       WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_1) < 10
              THEN NULL
                       ELSE PROFESSIONAL_PHONE_NUMBER_1
                     END AS phone1
                     ,CASE
                       WHEN PROFESSIONAL_PHONE_NUMBER_2 LIKE '%Not%' THEN NULL
                       WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_2) < 10 THEN NULL
                       WHEN PROFESSIONAL_PHONE_NUMBER_2 = PROFESSIONAL_PHONE_NUMBER_1
              THEN NULL
                       ELSE PROFESSIONAL_PHONE_NUMBER_2
                     END AS phone2
                     ,CASE
                       WHEN PROFESSIONAL_PHONE_NUMBER_3 LIKE '%Not%' THEN NULL
                       WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_3) < 10 THEN NULL
                       WHEN PROFESSIONAL_PHONE_NUMBER_3 = PROFESSIONAL_PHONE_NUMBER_1
              THEN NULL
                       WHEN PROFESSIONAL_PHONE_NUMBER_3 = PROFESSIONAL_PHONE_NUMBER_2
              THEN NULL
                       ELSE PROFESSIONAL_PHONE_NUMBER_3
                     END AS phone3
                     ,CASE
                       WHEN LTRIM (LOWER(PROFESSIONAL_EMAIL_ADDRESS_NAME)) LIKE 'info@%' THEN NULL
                       WHEN LTRIM (LOWER(PROFESSIONAL_EMAIL_ADDRESS_NAME)) LIKE 'contactus@%' THEN NULL
                       WHEN PROFESSIONAL_EMAIL_ADDRESS_NAME = ' ' THEN NULL
                       WHEN PROFESSIONAL_EMAIL_ADDRESS_NAME = 'Null' THEN NULL
                       ELSE PROFESSIONAL_EMAIL_ADDRESS_NAME
                     END AS email
                     ,LENGTH(TRIM(PROFESSIONAL_MIDDLE_NAME)) AS MiddleNameLength
                     ,pf.PROFESSIONAL_AVVO_RATING AS rating
                     ,concat(PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME) AS LawyerName

                     ,CASE
                       WHEN PROFESSIONAL_PREFIX IS NULL AND PROFESSIONAL_SUFFIX IS NULL AND PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_PREFIX IS NULL AND PROFESSIONAL_SUFFIX IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_PREFIX IS NULL AND PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                       WHEN PROFESSIONAL_PREFIX IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                       WHEN PROFESSIONAL_SUFFIX IS NULL AND PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_SUFFIX IS NULL THEN concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                       ELSE concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                     END AS LawyerName_Full
                     ,CASE
                       WHEN LOWER(PROFESSIONAL_PREFIX) IN ('chiefjustice','col','col.','colonel','hon','hon.','honorable','maj','maj.','maj. gen.','major','mr. judge','mr. justice','the honorable') THEN 1
                       WHEN professional_prefix IS NULL THEN 0
                       ELSE 0
                     END AS IsExcludedTitle
                     ,SUBSTR(TRIM(PROFESSIONAL_MIDDLE_NAME),1,1) MiddleInitial
                     ,pf.PROFESSIONAL_NAME AS prof_name
                     ,pf.INDUSTRY_NAME AS ind_name
                     ,pf.PROFESSIONAL_COUNTRY_NAME_1 AS country
                     ,substr(pf.professional_email_address_name,instr (professional_email_address_name,'@') +1) AS emaildomain
                     ,CASE
                       WHEN (parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST') IS NULL AND instr (pf.PROFESSIONAL_WEBSITE_URL,'http:') = 1) THEN pf.PROFESSIONAL_WEBSITE_URL
                       WHEN (parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST') IS NULL AND instr (pf.PROFESSIONAL_WEBSITE_URL,'http:') = 0) THEN substr (pf.PROFESSIONAL_WEBSITE_URL,instr (pf.PROFESSIONAL_WEBSITE_URL,'www.') +1)
                       WHEN (parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST') IS NOT NULL AND instr (pf.PROFESSIONAL_WEBSITE_URL,'www') = 0) THEN parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST')
                       ELSE substr (parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST'),instr (pf.PROFESSIONAL_WEBSITE_URL,'www.') -3)
                     END AS DOMAIN
              FROM DM.PROFESSIONAL_DIMENSION pf
              WHERE pf.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'
              AND   pf.PROFESSIONAL_PRACTICE_INDICATOR = 'Practicing'
              /*AND   (CASE WHEN pf.PROFESSIONAL_STATE_NAME_1 IS NULL THEN 1 ELSE 0 END) = 0
              AND   (CASE WHEN PROFESSIONAL_FIRST_NAME IS NULL THEN 1 ELSE 0 END) = 0
              AND   (CASE WHEN PROFESSIONAL_LAST_NAME IS NULL THEN 1 ELSE 0 END) = 0 */
              AND   pf.PROFESSIONAL_NAME = 'lawyer'
              AND   pf.INDUSTRY_NAME = 'Legal'
             ) pd
             
    ) pfad
    LEFT JOIN SRC.barrister_professional_status ps 
         ON ps.professional_id = pfad.PROFESSIONAL_ID
    LEFT JOIN (SELECT x.PROFESSIONAL_ID
                   ,MIN(CASE WHEN x.rt = 1 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea1
                      ,MIN(CASE WHEN x.rt = 2 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea2
                      ,MIN(CASE WHEN x.rt = 3 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea3
                      ,MIN(CASE WHEN x.rt = 1 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea1
                      ,MIN(CASE WHEN x.rt = 2 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea2
                      ,MIN(CASE WHEN x.rt = 3 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea3
               FROM (SELECT pfsp.PROFESSIONAL_ID
                            ,pfsp.SPECIALTY_PERCENT
                            ,sp.SPECIALTY_NAME
                            ,sp.PARENT_SPECIALTY_NAME
                            ,ROW_NUMBER() OVER (PARTITION BY pfsp.PROFESSIONAL_ID ORDER BY pfsp.SPECIALTY_PERCENT DESC) rt
                     FROM DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp
                       JOIN DM.SPECIALTY_DIMENSION sp ON sp.SPECIALTY_ID = pfsp.SPECIALTY_ID
                     WHERE pfsp.DELETE_FLAG = 'N') x
               GROUP BY 1) toppa ON toppa.PROFESSIONAL_ID = pfad.PROFESSIONAL_ID
     LEFT JOIN src.barrister_professional bp -- to get contact flag
        ON bp.id = pfad.professional_id
  WHERE ps.DECEASED = 'N'
  AND   ps.JUDGE = 'N'
  AND   ps.RETIRED = 'N'
  AND   ps.OFFICIAL = 'N'
  AND   ps.UNVERIFIED = 'N'
  AND   ps.SANCTIONED = 'N'
  AND   pfad.NonNullPhone1Check + pfad.NullPhone1Check + pfad.NonNullEmailCheck + pfad.NullEmailCheck + pfad.DoubleNullCheck = 5

  
)

/* test query
SELECT COUNT(*)
FROM deduped_pfad p
WHERE p.is_claim = 0
  AND p.customer_may_contact = 'Y'
  AND p.Phone_Status = 'Ok Phone' -- #3
   AND p.LowScoreEmailDomain = 0
  AND p.IsExcludedTitle = 0 -- #2
  */

,

pa_level_rollup AS (
  
  SELECT pd.professional_id
  ,pd.state
  ,pd.county
  ,SUM(pa.specialty_percent*pac.total_ad_value) weighted_pa_ad_value
  ,SUM(pa.specialty_percent*unsold_percent) weighted_pa_unsold_percent
  ,SUM(pa.specialty_percent*BlockMarketFlag) weighted_pa_block_market_flag
FROM deduped_pfad pd
LEFT JOIN practice_area pa
  ON pa.professional_id = pd.professional_id
LEFT JOIN pa_ad_calcs pac
  ON pac.state = pd.state
   AND pac.county = pd.county
   AND pac.specialty_id = pa.specialty_id 
WHERE pd.is_claim = 0
  AND pd.IsExcludedTitle = 0 -- #2
  -- AND pd.LowScoreEmailDomain = 0
  AND pd.customer_may_contact = 'Y'
  AND pd.Phone_Status = 'Ok Phone' -- #3
  GROUP BY 1,2,3
  
)

,
  
  
 full_rollup AS (
  
  SELECT pr.professional_id
   ,pr.state
   ,pr.county
   ,weighted_pa_ad_value
   ,weighted_pa_unsold_percent
   ,weighted_pa_block_market_flag
   ,ca.total_ad_value county_ad_value
   ,ca.unsold_percent county_unsold_percent
   ,ca.BlockMarketFlag county_block_market_flag
  FROM pa_level_rollup pr
    LEFT JOIN county_ad_calcs ca
       ON ca.county = pr.county
       AND ca.state = pr.state
       AND pr.weighted_pa_ad_value IS NULL
   
 )


,

weights_calc AS (
  
SELECT fr.*
   ,cr.Claim_Ratio -- #5
   ,cr.ProfCount CountyProfileCount
   ,COALESCE(fr.weighted_pa_ad_value, fr.county_ad_value) ad_value
   ,COALESCE(fr.weighted_pa_unsold_percent, county_unsold_percent) unsold_percent -- #6
   ,COALESCE(weighted_pa_block_market_flag, county_block_market_flag) block_market_percent
   ,CASE
      WHEN COALESCE(weighted_pa_block_market_flag, county_block_market_flag) > 0
         THEN 1
      ELSE 0
    END binary_block_market_flag
   ,CASE
      WHEN COALESCE(fr.weighted_pa_ad_value, fr.county_ad_value) >= 10000
         THEN 15
      WHEN COALESCE(fr.weighted_pa_ad_value, fr.county_ad_value) > 5000
         THEN 10
      WHEN COALESCE(fr.weighted_pa_ad_value, fr.county_ad_value) > 1000
         THEN 8
      WHEN COALESCE(fr.weighted_pa_ad_value, fr.county_ad_value) > 500
         THEN 5
      ELSE 0
    END MSRP_weight
   ,CASE
      WHEN cr.ProfCount < 25
         THEN -1
      WHEN cr.Claim_Ratio <= 0.25
         THEN 10
      WHEN cr.Claim_Ratio <= 0.5
          THEN 8
      WHEN cr.Claim_Ratio <= 1.0
          THEN 5
      WHEN cr.Claim_Ratio > 1.0
         THEN 1
      ELSE 0
      END C_NC_Weight
   ,CASE
       WHEN COALESCE(fr.weighted_pa_unsold_percent, county_unsold_percent) >= 0.75
          THEN 4
       WHEN COALESCE(fr.weighted_pa_unsold_percent, county_unsold_percent) >= 0.5
          THEN 3
       WHEN COALESCE(fr.weighted_pa_unsold_percent, county_unsold_percent) >= 0.25
          THEN 1
       ELSE 0
    END Pct_Unsold_Weight
  ,CASE
      WHEN COALESCE(weighted_pa_block_market_flag, county_block_market_flag) >= 0.75
          THEN 5
      WHEN COALESCE(weighted_pa_block_market_flag, county_block_market_flag) >= 0.5
          THEN 3
      WHEN COALESCE(weighted_pa_block_market_flag, county_block_market_flag) >= 0.25
          THEN 1
      ELSE 0
   END Block_Market_Weight
FROM full_rollup fr
  LEFT JOIN (SELECT cl.state
                ,cl.county
                ,SUM(cl.is_claim)/CAST(COUNT(CASE WHEN cl.is_claim = 0 THEN cl.professional_id ELSE NULL END) AS DECIMAL) Claim_Ratio
                ,COUNT(cl.professional_id) ProfCount
             FROM deduped_pfad cl
             GROUP BY 1,2 ) cr
      ON cr.state = fr.state
      AND cr.county = fr.county
  
  )
  
,

email_ds AS (SELECT ed.emaildomain
                ,SUM(ed.is_claim)/CAST(COUNT(ed.professional_id) AS DECIMAL) Claim_Percent_Email_Domain
                ,COUNT(ed.professional_id) EmailDomainSize
             FROM deduped_pfad ed
             -- WHERE ed.LowScoreEmailDomain = 0  
             GROUP BY 1
             
)

/* endorsements, reviews, and headshots added 07/13/2016 */

,

reviews AS
(
SELECT professional_id,
         COUNT(id) ReviewCount
		 --,SUM(recommended) RecommendedCount
         --,SUM(recommended) / COUNT(recommended)*1.0 PercentRecommended
         --,SUM(CAST(overall_rating AS DOUBLE))/COUNT(pr.id) AvgClientRating
  FROM src.barrister_professional_review pr
  WHERE pr.approval_status_id = 2
  GROUP BY professional_Id
)

,

endorsements AS (

SELECT eds.endorsee_id AS professional_id
                   ,COUNT(DISTINCT eds.id) AS PeerEndCount
                   FROM src.barrister_professional_endorsement eds
                   GROUP BY 1
                   
)

,headshot AS (

select m.professional_id
,min(to_date(m.created_at)) as headshot_date
from src.barrister_professional_media m
where m.media_use_type_id = 1 -- headshot
and m.record_flag <> 'I' -- not deleted
group by 1)



SELECT p.* -- #1,2
   ,w.Claim_Ratio -- #5
   ,w.CountyProfileCount
   ,w.ad_value
   ,w.unsold_percent
   ,w.block_market_percent
   ,w.binary_block_market_flag
   ,w.MSRP_weight
   ,w.C_NC_Weight
   ,w.Pct_Unsold_Weight
   ,w.Block_Market_Weight
   ,w.MSRP_weight + w.C_NC_weight + w.Pct_Unsold_Weight + w.Block_Market_Weight AS FinalScore
   ,ed.Claim_Percent_Email_Domain
   ,ed.EmailDomainSize
   ,e.PeerEndCount
   ,CASE 
	WHEN h.headshot_date IS NOT NULL 
		THEN 1
	ELSE 0
	END Has_Headshot
	,r.ReviewCount
   -- ,RANK() OVER(ORDER BY ed.EmailDomainSize DESC) EmailDomainRank
   --,ROW_NUMBER() OVER(PARTITION BY p.professional_Id ORDER BY w.MSRP_weight) AS IsDupe
   --,REGEXP_REPLACE(p.practicearea1, ',', '') PracticeAreaTest
FROM deduped_pfad p -- #1, #2
   LEFT JOIN weights_calc w -- #4,#5,#6,#7
      ON w.professional_id = p.professional_id
   LEFT JOIN email_ds ed
      ON ed.emaildomain = p.emaildomain
   LEFT JOIN reviews r
		ON r.professional_id = p.professional_id
	LEFT JOIN endorsements e
		ON e.professional_id = p.professional_id
	LEFT JOIN headshot h
		ON h.professional_id = p.professional_id
WHERE p.is_claim = 0
  AND p.customer_may_contact = 'Y'
  AND p.Phone_Status = 'Ok Phone' -- #3
  AND p.IsExcludedTitle = 0 -- #2
  -- AND p.LowScoreEmailDomain = 0
-- LIMIT 1000;  
  -- AND p.professional_id < 10000
-- ORDER BY IsDupe DESC


                     