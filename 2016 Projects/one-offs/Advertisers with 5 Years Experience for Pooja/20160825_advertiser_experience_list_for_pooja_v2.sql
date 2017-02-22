WITH license AS (

SELECT professional_Id
,MIN(license_date) first_license_date
FROM src.barrister_license
  GROUP BY 1
HAVING MIN(license_date) > '2011-08-25'  

)

, lawyers AS (
  
SELECT olaf.professional_id
,bl.first_license_date
,MIN(olaf.order_line_begin_date) order_line_begin_date_for_august_2016
FROM dm.order_line_accumulation_fact olaf
JOIN license bl
ON bl.professional_id = olaf.professional_id
WHERE olaf.order_line_begin_date >= '2016-08-01'
AND olaf.product_line_id in (2,7)
GROUP BY 1,2

  )
  


SELECT l.professional_id
,l.first_license_date
,STRLEFT(CAST(olaf.yearmonth AS STRING), 4) ad_year
,l.order_line_begin_date_for_august_2016
,pd.professional_county_name_1
,pd.professional_state_name_1
,SUM(order_line_package_price_amount_usd) sum_order_line_package_price_amount
,SUM(order_line_purchase_price_amount_usd) sum_order_line_purchase_price_amount
,SUM(order_line_price_adjusted_amount_usd) sum_order_line_price_adjusted_amount
,SUM(order_line_net_price_amount_usd) sum_order_line_net_price_amount
,AVG(order_line_package_price_amount_usd) avg_order_line_package_price_amount
,AVG(order_line_purchase_price_amount_usd) avg_order_line_purchase_price_amount
,AVG(order_line_price_adjusted_amount_usd) avg_order_line_price_adjusted_amount
,AVG(order_line_net_price_amount_usd) avg_order_line_net_price_amount
,MIN(order_line_package_price_amount_usd) MIN_order_line_package_price_amount
,MIN(order_line_purchase_price_amount_usd) MIN_order_line_purchase_price_amount
,MIN(order_line_price_adjusted_amount_usd) MIN_order_line_price_adjusted_amount
,MIN(order_line_net_price_amount_usd) MIN_order_line_net_price_amount
,MAX(order_line_package_price_amount_usd) MAX_order_line_package_price_amount
,MAX(order_line_purchase_price_amount_usd) MAX_order_line_purchase_price_amount
,MAX(order_line_price_adjusted_amount_usd) MAX_order_line_price_adjusted_amount
,MAX(order_line_net_price_amount_usd) MAX_order_line_net_price_amount
FROM lawyers l
JOIN dm.order_line_accumulation_fact olaf
ON l.professional_id = olaf.professional_id
LEFT JOIN dm.professional_dimension pd
ON pd.professional_id = l.professional_id
WHERE olaf.product_line_id in (2,7)
GROUP BY 1,2,3,4,5,6