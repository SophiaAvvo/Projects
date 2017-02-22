SELECT SUM(CASE
		WHEN hits.eventInfo.eventCategory = 'ecommerce'
		AND hits.eventInfo.eventAction = 'purchase avvo legal service'
		AND hits.eCommerceAction.action_type = '6'
		AND (CASE
				WHEN REGEXP_MATCH(LOWER(hits.product.v2ProductName), r'(null|sponsored listing|display ad|(not set))')
					THEN 1
				ELSE 0
			END) = 0
		THEN hits.Product.ProductQuantity
		ELSE 0
	END) TotalPurchases1
,SUM(CASE
		WHEN hits.eventInfo.eventCategory = 'ecommerce'
		AND hits.eventInfo.eventAction = 'purchase avvo legal service'
		AND (CASE
				WHEN REGEXP_MATCH(LOWER(hits.product.v2ProductName), r'(null|sponsored listing|display ad|(not set))')
					THEN 1
				ELSE 0
			END) = 0
		THEN hits.Product.ProductQuantity
		ELSE 0
	END) TotalPurchases2
	,SUM(CASE
		WHEN hits.eventInfo.eventCategory = 'ecommerce'
		AND hits.eventInfo.eventAction = 'purchase avvo legal service'
		AND hits.eCommerceAction.action_type = '6'
		THEN hits.Product.ProductQuantity
		ELSE 0
	END) TotalPurchases3
,SUM(CASE
		WHEN hits.eventInfo.eventCategory = 'ecommerce'
		AND hits.eventInfo.eventAction = 'purchase avvo legal service'
		THEN hits.Product.ProductQuantity
		ELSE 0
	END) TotalPurchases4
,EXACT_COUNT_DISTINCT(CASE
		WHEN hits.eventInfo.eventCategory = 'ecommerce'
		AND hits.eventInfo.eventAction = 'purchase avvo legal service'
		THEN CONCAT(fullVisitorId,string(VisitId))
		ELSE NULL
	END) TotalPurchases5_Goal
,SUM(CASE
		WHEN hits.eventInfo.eventCategory = 'ecommerce'
		AND hits.eventInfo.eventAction = 'purchase avvo legal service'
		AND hits.eCommerceAction.action_type = '6'
		THEN totals.transactions
		ELSE 0
	END) TotalPurchases6
,SUM(CASE
		WHEN hits.eventInfo.eventCategory = 'ecommerce'
		AND hits.eventInfo.eventAction = 'purchase avvo legal service'
		AND hits.type = 'EVENT'
		THEN totals.transactions
		ELSE 0
	END) TotalPurchases7
-- ,MAX(IF(hits.customMetrics.index=11,hits.customMetrics.value, NULL)) WITHIN hits AS custom_metric_11	
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-10-01'),TIMESTAMP('2016-10-31'))
WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) 
