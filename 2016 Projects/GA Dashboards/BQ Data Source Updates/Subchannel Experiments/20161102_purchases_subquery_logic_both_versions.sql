-- discontinued because I realized there's no type-level purchase information... 

SELECT Date
,SUM(x.transactions_Goal) AS Transactions_Goal
,SUM(x.transactions_CM) AS transactions_CM
,SUM(CASE
		WHEN )
FROM (
		SELECT Date
		,fullvisitorid
		,visitid
		,totals.transactions AS transactions_Goal
		-- hits.product.v2ProductName
		,SUM(CASE
		WHEN hits.customMetrics.index = 18
		THEN 1
		ELSE 0
		END) transactions_CM
		,SUM(totals.visits) Sessions
		FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-10-01'),TIMESTAMP('2016-10-31'))
		WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) 
		AND hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eventInfo.eventAction = 'purchase avvo legal service'
		GROUP BY 1,2,3,4
		ORDER BY Date