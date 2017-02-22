/* We are using the deduplicator because transactions can duplicate across multiple fullvisitorids and visitorids.  So we will select the fullvisitorid that was the first to visit, for these edge cases.  */

		
		
		SELECT fullvisitorid
		,visitid
		,page_path
		,offer_id
		,product_count
		,transaction_id
		,first_found_visit_date
		,purchase_date
		,ROW_NUMBER() OVER(PARTITION BY transaction_id ORDER BY first_found_visit_date) DeDuplicator
		FROM (
				SELECT table_a.fullvisitorid AS fullvisitorid
						,table_a.visitid AS visitid
						,table_a.page_path AS page_path
						,table_a.offer_id AS offer_id
						,table_a.product_count AS product_count
						,table_a.transaction_id AS transaction_id
						,table_a.purchase_date AS purchase_date
					,table_b.first_found_visit_date AS first_found_visit_date
				FROM (SELECT fullvisitorid
						,visitid
						,Date AS purchase_date
						,hits.page.pagepath AS page_path
						,regexp_extract(hits.page.pagePath,r'offer_id=([0-9]+)') as offer_id
						,hits.product.ProductQuantity AS product_count
						,hits.transaction.transactionid AS transaction_id
						,MIN(visitstarttime) order_visit_time
						FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-10-18'),CURRENT_TIMESTAMP())
							where hits.product.v2ProductName not in ('sponsored listing', 'display ad')
							and (hits.page.pagePath like '%/legal-services/thank_you%'
							  OR hits.page.pagePath LIKE '%/advisor/thank_you%')
							AND hits.product.ProductQuantity IS NOT NULL
						GrOUP BY 1,2,3,4,5,6,7
					) table_a
					left join 
					  (select min(date) as first_found_visit_date
						,fullVisitorId
							FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-10-01'),CURRENT_TIMESTAMP())
							group by 2) table_b 
						on table_a.fullVisitorId = table_b.fullVisitorId

				) table_c
					LEFT JOIN (
								SELECT fullVisitorId -- 8790 as of 11/14
									, date
									,hits.transaction.transactionid AS transaction_id
									--, hits.page.pagePath as page_path
									, regexp_extract(hits.page.pagePath,r'offer_id=([0-9]+)') as offer_id
									, min(visitNumber) as visitNumber
									, min(visitId) as visitId
									FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-01-01'),TIMESTAMP('2016-08-31'))
									where hits.product.v2ProductName not in ('sponsored listing', 'display ad')
									and hits.page.pagePath like '%legal_services/thank_you/%'
									group by 1, 2, 3, 4--, 7
								) table_d
							ON table_d.fullVisitorID = table_c.fullVisitorID
							AND table_d.transaction_id = table_c.transaction_id
				