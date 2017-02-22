SELECT CASE
	WHEN REGEXP_MATCH(LOWER(trafficSource.medium), r'(cpc|cpm)')
	AND REGEXP_MATCH(LOWER(trafficSource.campaign), r'(fb_|acq|pls_avvofb|pls_fb|pls_fbb|tw_)')
	AND (CASE
			WHEN LOWER(trafficSource.source) CONTAINS '%google%'
				THEN 1
			WHEN REGEXP_MATCH(LOWER(trafficSource.campaign), r'(2016brandvideos_t_acq|fb_boosted|lawyer|pokemon|eng_|pls)') -- exclude
				THEN 1
			ELSE 0
			END) = 0
		THEN 'Paid Social Acquisition'
WHEN (
	LOWER(trafficSource.campaign) IN ('2016brandvideos_t_acq', 'claim 2016')
	OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(ricampaign|2016brandvideos|relstudy|eng_|prenupforlove)')
	OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'^(FB_Lawyer)')
	)
	AND (CASE 
			WHEN REGEXP_MATCH(trafficSource.medium, r'(display|content)')
				THEN 1
			ELSE 0
		END) = 0 
	THEN 'Paid Social Engagement'		
	ELSE 'Other'
END Subchannel
,COUNT(totals.visits) AS Sessions
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact website'
THEN CAST(1 AS INTEGER)
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact email'
THEN CAST(1 AS INTEGER)
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact message'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) Email_and_Web_Contacts
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact website'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) AS ClicksToLawyerWebsite
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'create question'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberQuestionsAsked
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'create answer'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberQuestionsAnswered
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact email'
THEN CAST(1 AS INTEGER)
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact message'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) EmailSentToLawyers
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'submit review'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) NumberOfReviews
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'complete claim'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) NumberOfClaims
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'submit endorsement'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) NumberOfEndorsements
,COUNT(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'new registration'
AND LOWER(hits.eventInfo.eventCategory) = 'users'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) NumberOfRegistrations
,EXACT_COUNT_DISTINCT(CASE
WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^\/legal-forms\/sld\/.*\/finish')
AND hits.type = 'PAGE'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberOfForms
,SUM(CASE
		WHEN hits.customDimensions.index IN (10, 11)
			THEN CAST(1 AS INTEGER)
		ELSE CAST(0 AS INTEGER)
	END) EmailSubscriptions
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-09-01'),TIMESTAMP('2016-09-30'))
WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) 
GrOUP BY 1