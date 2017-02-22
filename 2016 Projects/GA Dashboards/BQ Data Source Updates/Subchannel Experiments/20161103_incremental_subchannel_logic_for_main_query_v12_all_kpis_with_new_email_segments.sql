SELECT Date
,CASE
	WHEN REGEXP_MATCH(LOWER(trafficSource.medium), r'(cpc|cpm)')
	AND REGEXP_MATCH(LOWER(trafficSource.campaign), r'(fb_|acq|pls_avvofb|pls_fb|pls_fbb|tw_)')
	AND (CASE
			WHEN LOWER(trafficSource.source) CONTAINS 'google'
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
WHEN (REGEXP_MATCH(LOWER(trafficSource.medium), r'^(social|social-network|social-media|sm|social network|social media)$') /* system defined */ 
|| REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|twitter|gplus|linkedin|lnkd\.in|plus\.url\.google\.com|plus\.google\.com|googleplus|blogspot|disqus|reddit|reddit\.com|stumbleupon|yelp|vk\.com|livejournal|glassdoor|pinboard|spoke|wiki|youtube|weebly|tumblr|stackexchange|pinterest|instagram|netvibes|yammer|typepad|askville|hubpages|stackoverflow|tripadvisor|flavors\.me|quora|wordpress|topix|salespider|wordpress|slideshare|hootsuite|paper\.li)')
OR trafficSource.campaign CONTAINS 'FB_' 
OR trafficSource.campaign CONTAINS 'TW_'
OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(pls_fb|pls_avvofb)')
OR REGEXP_MATCH(trafficSource.source, r'^(t.co|social)$')
OR REGEXP_MATCH(LOWER(trafficSource.source), r'(academia\.edu|deviantart|beforeitsnews|\.naver\.com|chicagonow|circleofmoms|dailystrength|diigo|getpocket|meetup|cafemom|ycombinator|okwave|oshiete|cstools|scoop\.it|foursquare|tinyurl|yuku|\Acare2|\Achicagonow)')
)
AND (CASE WHEN LOWER(trafficSource.source) CONTAINS 'search' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) -- exclude
THEN 'Organic Social'
WHEN (trafficSource.medium CONTAINS 'email'
		OR trafficSource.campaign CONTAINS 'reset_password'
	)
	AND (CASE
			WHEN REGEXP_MATCH(trafficSource.campaign, r'(question_notify_digest|2015_client_choice_award|2014_client_choice_award|best_answer_pro|digest)')
				THEN 1
			WHEN REGEXP_MATCH(trafficSource.campaign, r'(_pro)$')
				THEN 1
			ELSE 0
		END) = 0
THEN 'Consumer Email'
WHEN trafficSource.medium CONTAINS 'email'
	AND (trafficSource.source CONTAINS 'best_answer_pro'
		OR trafficSource.adContent CONTAINS 'Digest'
		OR REGEXP_MATCH(trafficSource.campaign, r'(2015_client_choice_award|2014_client_choice_award|)')
		OR REGEXP_MATCH(trafficSource.campaign, r'(_pro)$')
		)
	THEN 'Attorney Email'
WHEN LOWER(trafficSource.medium) CONTAINS 'affiliate'
OR REGEXP_MATCH(trafficSource.source, r'(boomerater|lifecare)') 
THEN 'Affiliates'
WHEN (trafficSource.campaign CONTAINS 'Branded_Terms'
	OR trafficSource.campaign IN ('Brand|RLSA', 'brand')
	)
	AND (CASE 
			WHEN trafficSource.campaign CONTAINS 'FB'
				THEN 1
			ELSE 0
		END) = 0 -- exclude
	THEN 'SEM Brand'	
WHEN (trafficSource.campaign IN ('pls', 'plsremarketing')
	OR trafficSource.campaign CONTAINS 'PLS|')
	AND (CASE
			WHEN trafficSource.campaign CONTAINS '_Forms' -- exclude
				THEN 1
			ELSE 0
		END) = 0
	THEN 'SEM ALS'
WHEN (trafficSource.campaign CONTAINS 'Legal_Q_&_A_Search'
	OR REGEXP_MATCH(trafficSource.campaign, r'(legalqa)')
)
AND (CASE
WHEN trafficSource.campaign CONTAINS 'FB'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) = CAST(0 AS INTEGER)
THEN 'SEM Q&A'
WHEN trafficSource.campaign CONTAINS 'PLS|'
	AND trafficSource.campaign CONTAINS '_Forms'
	AND (CASE
			WHEN trafficSource.campaign CONTAINS 'FB'
				THEN 1
			ELSE 0
		END) = 0
	THEN 'SEM Forms'
WHEN REGEXP_MATCH(trafficSource.medium, r'^(cpc|ppc|paidsearch)$') 
&& (trafficSource.adwordsClickInfo.adNetworkType != 'Content' OR trafficSource.adwordsClickInfo.adNetworkType IS NULL)
AND (CASE 
WHEN LOWER(trafficSource.source) CONTAINS 'facebook' 
OR LOWER(trafficSource.source) CONTAINS 'twitter' 
OR LOWER(trafficSource.source) CONTAINS 'linkedin'
OR trafficSource.source CONTAINS 'Branded_Terms' 
OR trafficSource.source CONTAINS 'Legal_Q_&_A_Search' 
OR trafficSource.source CONTAINS 'Brand|RLSA'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) = CAST(0 AS INTEGER)
THEN 'Paid Search - AMM'
WHEN trafficSource.Medium IN ('video', 'mobile', 'mobile_video', 'mobile_tablet', 'content')
OR LOWER(trafficSource.Medium) CONTAINS 'display'
OR trafficSource.source CONTAINS 'Outbrain'
THEN 'Digital Brand'
WHEN REGEXP_MATCH(trafficSource.Campaign, r'(_acq|acquisition|lookalike)')
	AND trafficSource.Campaign CONTAINS 'pls_'
	AND (CASE
		WHEN REGEXP_MATCH(trafficSource.campaign, r'(FB|Q&A|lifecycle|form)')
			THEN 1
		ELSE 0
	END) = 0
	THEN 'Display - ALS - ACQ'	
WHEN REGEXP_MATCH(trafficSource.Campaign, r'(_Abandoners|pls_)')
	AND (CASE
		WHEN REGEXP_MATCH(trafficSource.campaign, r'(FB|_acq|acquisition|lookalike|Q&A|lifecycle|form)')
			THEN 1
		WHEN trafficSource.Source CONTAINS 'taboola'
			THEN 1
		ELSE 0
	END) = 0
	THEN 'Display - ALS - Ret'
WHEN REGEXP_MATCH(trafficSource.Campaign, r'(PLS_|ACQ)') -- note that this logic seems to overlap
	AND REGEXP_MATCH(trafficSource.Campaign, r'(Q&A|lifecycle|form)')
	AND (CASE
		WHEN REGEXP_MATCH(trafficSource.campaign, r'(FB|_RET)')
			THEN 1
		ELSE 0
	END) = 0
	THEN 'Display - RU - Acq'
WHEN REGEXP_MATCH(trafficSource.Campaign, r'(PLS_|_RET)')
	AND REGEXP_MATCH(trafficSource.Campaign, r'(Q&A|lifecycle|form)')
	AND (CASE
		WHEN REGEXP_MATCH(trafficSource.campaign, r'(FB|ACQ)')
			THEN 1
		ELSE 0
	END) = 0
	THEN 'Display - RU - Ret'	
WHEN LOWER(trafficSource.campaign) CONTAINS 'display'
THEN 'Display - AMM'
WHEN LOWER(trafficSource.source) = '(direct)'
AND LOWER(trafficSource.medium) = '(none)'
THEN 'Direct'
WHEN LOWER(trafficSource.medium) = 'organic'
THEN 'Organic Search'
WHEN LOWER(trafficSource.medium) = 'referral'
THEN 'Referral'
WHEN REGEXP_MATCH(trafficSource.medium, r'^(cpv|cpa|cpp)$') 
THEN '(Other)'
ELSE '(Other)'	
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
END) NumberQuestionsAsked_Goal
,SUM(CASE
WHEN hits.customMetrics.index = 2
THEN 1
ELSE 0
END) NumberQuestionsAsked_CM
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'create answer'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberQuestionsAnswered_Goal
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
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) = 'new registration'
AND LOWER(hits.eventInfo.eventCategory) = 'users'
AND hits.type = 'EVENT'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberOfRegistrations_Goal
,SUM(CASE
WHEN hits.customMetrics.index = 3
THEN 1
ELSE 0
END) NumberOfRegistrations_CM
,EXACT_COUNT_DISTINCT(CASE
WHEN LOWER(hits.eventInfo.eventAction) = 'form completion'
AND LOWER(hits.eventInfo.eventCategory) = 'forms'
AND hits.type = 'EVENT'
THEN CONCAT(fullVisitorId,string(VisitId))
ELSE NULL
END) NumberOfForms_Goal
,EXACT_COUNT_DISTINCT(CASE
		WHEN hits.eventInfo.eventCategory = 'ecommerce'
		AND hits.eventInfo.eventAction = 'purchase avvo legal service'
		THEN hits.transaction.transactionId
		ELSE NULL
	END) TotalPurchases_Goal
,SUM(CASE
		WHEN hits.customMetrics.index IN (10, 11)
			THEN CAST(1 AS INTEGER)
		ELSE CAST(0 AS INTEGER)
	END) TotalEmailSubscriptions
,SUM(CASE
		WHEN hits.customMetrics.index = 10
			THEN 1
		ELSE 0
	END) OnsiteEmailSubscriptions
,SUM(CASE
		WHEN hits.customMetrics.index = 11
			THEN 1
		ELSE 0
	END) OffsiteEmailSubscriptions
,EXACT_COUNT_DISTINCT(CASE
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eventInfo.eventAction = 'purchase avvo legal service'
AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
THEN hits.transaction.transactionid
ELSE NULL
END) TotalAdvisorPurchases
,EXACT_COUNT_DISTINCT(CASE
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eventInfo.eventAction = 'purchase avvo legal service'
AND LOWER(hits.product.v2ProductName) CONTAINS 'review'
THEN hits.transaction.transactionid
ELSE NULL
END) TotalDocReviewPurchases
,EXACT_COUNT_DISTINCT(CASE
WHEN hits.eventInfo.eventCategory = 'ecommerce'
AND hits.eventInfo.eventAction = 'purchase avvo legal service'
AND REGEXP_MATCH((LOWER(hits.product.v2ProductName)), r'^(apply|start|form|create|file|modify)')
THEN hits.transaction.transactionid
ELSE NULL
END) TotalOfflinePackagePurchases
,EXACT_COUNT_DISTINCT(CASE
		WHEN hits.eventInfo.eventCategory = 'ecommerce'
		AND hits.eventInfo.eventAction = 'purchase avvo legal service'
		THEN hits.transaction.transactionid
		ELSE NULL
	END) TotalPurchases5_Goal
-- ,MAX(IF(hits.customMetrics.index=11,hits.customMetrics.value, NULL)) WITHIN hits AS custom_metric_11	
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-10-01'),TIMESTAMP('2016-10-31'))
WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) 
GrOUP BY 1,2