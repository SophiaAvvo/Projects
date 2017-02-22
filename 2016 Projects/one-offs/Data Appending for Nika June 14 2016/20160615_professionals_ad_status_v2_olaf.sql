WITH ad1 AS (SELECT professional_id
,MIN(order_line_begin_date) FirstAdDate
,MAX(order_line_begin_date) LastAdDate
FROM dm.order_line_accumulation_fact
WHERE product_line_id IN (2, 7)
GROUP BY 1
--ORDER BY professional_Id 
)

SELECT p.professional_id
,CASE
WHEN LastAdDate >= '2015-05-01'
THEN 'Y'
ELSE 'N'
END advertised_in_past_year
,CASE
WHEN LastAdDate < '2015-05-01'
THEN 'Y'
ELSE 'N'
END advertised_prior_to_last_year_only
,CASE
WHEN LastAdDate IS NULL
THEN 'Y'
ELSE 'N'
END never_advertised
,CASE
WHEN p.professional_claim_date IS NULL
THEN 'N'
ELSE 'Y'
END is_claimed
,a.FirstAdDate
,a.LastAdDate
FROM dm.professional_dimension p
LEFT JOIN ad1 a
ON a.professional_id = p.professional_id