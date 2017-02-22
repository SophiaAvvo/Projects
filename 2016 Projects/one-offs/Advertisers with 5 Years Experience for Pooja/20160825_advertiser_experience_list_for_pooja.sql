WITH license AS (

SELECT professional_Id
,MIN(license_date) first_license_date
FROM src.barrister_license
  GROUP BY 1
HAVING MIN(license_date) > '2011-08-25'  

)

SELECT olaf.professional_id
,bl.first_license_date
,MIN(olaf.order_line_begin_date) order_line_begin_date_for_august_2016
FROM dm.order_line_accumulation_fact olaf
JOIN license bl
ON bl.professional_id = olaf.professional_id
WHERE olaf.order_line_begin_date >= '2016-08-01'
AND olaf.product_line_id in (2,7)
GROUP BY 1,2
