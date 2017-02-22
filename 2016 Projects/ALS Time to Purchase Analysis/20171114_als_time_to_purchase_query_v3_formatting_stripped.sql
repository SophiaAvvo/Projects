SELECT fullvisitorid AS fullvisitorid
,offer_id AS offer_id
,product_count AS product_count
,transaction_id AS transaction_id
,first_found_visit_date AS first_found_visit_date
,purchase_date AS purchase_date
,purchase_hour AS purchase_hour
,visit_number_at_purchase AS visit_number_at_purchase
FROM (
SELECT table_c.fullvisitorid
,table_c.offer_id
,table_c.product_count
,table_c.transaction_id
,table_c.first_found_visit_date
,DATE(table_c.purchase_date) AS purchase_date
,HOUR(SEC_TO_TIMESTAMP(table_c.order_visit_time)) purchase_hour
,table_c.visit_number_at_purchase
,ROW_NUMBER() OVER(PARTITION BY table_c.transaction_id ORDER BY first_found_visit_date) DeDuplicator
FROM (
SELECT table_a.fullvisitorid AS fullvisitorid
,table_a.offer_id AS offer_id
,table_a.product_count AS product_count
,table_a.transaction_id AS transaction_id
,table_a.purchase_date AS purchase_date
,table_a.visit_number_at_purchase AS visit_number_at_purchase
,table_a.order_visit_time AS order_visit_time
,table_b.first_found_visit_date AS first_found_visit_date
FROM (SELECT fullvisitorid
,regexp_extract(hits.page.pagePath,r'offer_id=([0-9]+)') as offer_id
,hits.product.ProductQuantity AS product_count
,hits.transaction.transactionid AS transaction_id
,MIN(visitstarttime) AS order_visit_time 
,MIN(Date) AS purchase_date
,MIN(VisitNumber) AS visit_number_at_purchase
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2015-10-18'),CURRENT_TIMESTAMP())
where hits.product.v2ProductName not in ('sponsored listing', 'display ad')
and (hits.page.pagePath like '%/legal-services/thank_you%'
OR hits.page.pagePath LIKE '%/advisor/thank_you%')
AND hits.product.ProductQuantity IS NOT NULL
GrOUP BY 1,2,3,4
) table_a
left join 
(select min(DATE(date)) as first_found_visit_date
,fullVisitorId
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2015-10-18'),CURRENT_TIMESTAMP())
group by 2) table_b 
on table_a.fullVisitorId = table_b.fullVisitorId
) table_c
) table_d
WHERE table_d.DeDuplicator = 1