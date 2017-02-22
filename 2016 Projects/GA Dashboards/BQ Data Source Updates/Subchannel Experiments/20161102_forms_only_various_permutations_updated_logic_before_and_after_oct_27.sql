SELECT EXACT_COUNT_DISTINCT(CASE
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^\/legal-forms\/sld\/.*\/finish')
AND hits.type = 'PAGE'
THEN CONCAT(FullVisitorID, STRING(VisitId))
ELSE NULL
END) NumberOfForms_Goal
,EXACT_COUNT_DISTINCT(CASE
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^\/legal-forms\/sld\/.*\/finish')
THEN CONCAT(FullVisitorID, STRING(VisitId))
ELSE NULL
END) NumberOfForms_Goal2a
,COUNT(CASE
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^\/legal-forms\/sld\/.*\/finish')
THEN CONCAT(FullVisitorID, STRING(VisitId))
ELSE NULL
END) NumberOfForms_Goal2b
,EXACT_COUNT_DISTINCT(CASE
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^\/legal-forms\/sld\/.*\/finish')
THEN VisitId
ELSE NULL
END) NumberOfForms_Goal2c
,EXACT_COUNT_DISTINCT(CASE
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^\/legal-forms\/sld\/.*\/finish')
THEN FullVisitorID
ELSE NULL
END) NumberOfForms_Goal2d
,EXACT_COUNT_DISTINCT(CASE
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^\/legal-forms\/sld\/.*\/finish')
THEN CONCAT(fullvisitorid, STRING(visitid), hits.page.pagePath)
ELSE NULL
END) NumberOfForms_Goal2e
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) = 'form completion'
AND LOWER(hits.eventInfo.eventCategory) = 'forms'
AND hits.type = 'EVENT'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberOfForms_Goal3
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) = 'form completion'
AND LOWER(hits.eventInfo.eventCategory) = 'forms'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberOfForms_Goal4
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) = 'form completion'
AND LOWER(hits.eventInfo.eventCategory) = 'forms'
AND hits.type = 'PAGE'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberOfForms_Goal5
--,SUM(totals.visits) Sessions		
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-10-01'),TIMESTAMP('2016-10-11'))		
WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) 		
--AND hits.eventInfo.eventCategory = 'ecommerce'		
		--AND hits.eventInfo.eventAction = 'purchase avvo legal service'
--GROUP BY 1
	
