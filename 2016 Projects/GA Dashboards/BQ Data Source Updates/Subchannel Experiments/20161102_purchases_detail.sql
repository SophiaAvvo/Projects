SELECT fullvisitorid
,visitor_id
,hits.transaction.transactionId
,COUNT(totals.visits) Sessions
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-10-01'),TIMESTAMP('2016-10-31'))
WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) 
AND hits.eventInfo.eventCategory = 'ecommerce'
		AND hits.eventInfo.eventAction = 'purchase avvo legal service'
GROUP BY 1,2,3