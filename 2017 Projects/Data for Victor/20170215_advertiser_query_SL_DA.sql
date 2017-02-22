SELECT DISTINCT professional_id
,order_line_begin_date
FROM order_line_accumulation_fact olaf
WHERE olaf.product_line_id IN (2, 7, 18)
AND olaf.yearmonth = 201702