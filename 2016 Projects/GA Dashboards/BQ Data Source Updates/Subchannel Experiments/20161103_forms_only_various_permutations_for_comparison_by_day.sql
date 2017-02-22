SELECT Date
,EXACT_COUNT_DISTINCT(CASE
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
,EXACT_COUNT_DISTINCT(CASE
WHEN hits.customMetrics.index = 17
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberOfForms_CM_6
,SUM(CASE
		WHEN hits.customMetrics.index = 17
			THEN 1
		ELSE 0
	END) NumberOfForms_CM_7 -- this matches the custom metric but we still don't have a match on the goal
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) = 'form completion'
AND LOWER(hits.eventInfo.eventCategory) = 'forms'
THEN 1
ELSE 0
END) NumberOfForms_8
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) = 'form completion'
AND LOWER(hits.eventInfo.eventCategory) = 'forms'
AND hits.type = 'EVENT'
THEN 1
ELSE 0
END) NumberOfForms_9
--,SUM(totals.visits) Sessions		
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-10-01'),TIMESTAMP('2016-10-31'))		
WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) 		
GROUP BY 1
	
