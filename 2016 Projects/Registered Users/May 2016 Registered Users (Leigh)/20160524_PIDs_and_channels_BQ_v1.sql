SELECT Persistent_Session_ID AS Persistent_Session_ID
    ,FirstVisitDate AS FirstVisitDate
    ,DaysVisited AS DaysVisited
    ,Sessions AS Sessions
    ,ClicksToLawyerWebsite AS ClicksToLawyerWebsite
    ,NumberQuestionsAsked AS NumberQuestionsAsked
    ,NumberQuestionsAnswered AS NumberQuestionsAnswered
    ,EmailSentToLawyers AS EmailSentToLawyers
    ,NumberOfReviews AS NumberOfReviews
    ,NumberOfClaims AS NumberOfClaims
    ,NumberOfEndorsements AS NumberOfEndorsements
    ,Channel AS Channel
,TotalAdvisorPurchases AS TotalAdvisorPurchases
, TotalDocReviewPurchases AS TotalDocReviewPurchases
, TotalOfflinePackagePurchases AS TotalOfflinePackagePurchases

		,CASE
			WHEN Channel IN ('Other Paid Marketing', 'Paid Search - Marketing')
				THEN 'Paid Marketing'
			ELSE Channel
		END ChannelGroup
        ,CASE
            WHEN Channel = 'Organic Search'
                THEN CAST(1 AS INTEGER)
            WHEN Channel = 'Direct'
                THEN CAST(2 AS INTEGER)
            WHEN Channel = 'Email'
                THEN CAST(3 AS INTEGER)
            WHEN Channel = 'Social'
                THEN CAST(4 AS INTEGER)
            WHEN Channel = 'Referral'
                THEN CAST(5 AS INTEGER)
            WHEN Channel = 'Paid Search - Marketing'
                THEN CAST(6 AS INTEGER)
            WHEN Channel = 'Digital Brand'
                THEN CAST(7 AS INTEGER)
            WHEN Channel = '(Other)'
                THEN CAST(8 AS INTEGER)
            WHEN Channel = 'Affiliates'
                THEN CAST(9 AS INTEGER)
            WHEN Channel = 'Paid Search - AMM'
                THEN CAST(10 AS INTEGER)
            WHEN Channel = 'Display - AMM'
                THEN CAST(11 AS INTEGER)
            WHEN Channel = 'Other Paid Marketing'
                THEN CAST(12 AS INTEGER)
            ELSE CAST(13 AS INTEGER)
            END ChannelSortOrder
      ,CASE
            WHEN Channel = 'Organic Search'
                THEN CAST(1 AS INTEGER)
            WHEN Channel = 'Direct'
                THEN CAST(2 AS INTEGER)
            WHEN Channel = 'Email'
                THEN CAST(3 AS INTEGER)
            WHEN Channel = 'Social'
                THEN CAST(4 AS INTEGER)
            WHEN Channel = 'Referral'
                THEN CAST(5 AS INTEGER)
            WHEN Channel IN ('Other Paid Marketing', 'Paid Search - Marketing')
                THEN CAST(6 AS INTEGER)
            WHEN Channel = 'Digital Brand'
                THEN CAST(7 AS INTEGER)
            WHEN Channel = '(Other)'
                THEN CAST(8 AS INTEGER)
            WHEN Channel = 'Affiliates'
                THEN CAST(9 AS INTEGER)
            WHEN Channel = 'Paid Search - AMM'
                THEN CAST(10 AS INTEGER)
            WHEN Channel = 'Display - AMM'
                THEN CAST(11 AS INTEGER)
            ELSE CAST(12 AS INTEGER)
            END ChannelGroupSortOrder
FROM 
(SELECT                fullVisitorID AS Persistent_Session_ID
                       ,CASE
                          WHEN (
                          REGEXP_MATCH(LOWER(trafficSource.medium), r'^(social|social-network|social-media|sm|social network|social media)$') /* system defined */ 
                          || REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|twitter|gplus|linkedin|lnkd\.in|plus\.url\.google\.com|plus\.google\.com|googleplus|blogspot|disqus|reddit|reddit\.com|stumbleupon|yelp|vk\.com|livejournal|glassdoor|pinboard|spoke|wiki|youtube|weebly|tumblr|stackexchange|pinterest|instagram|netvibes|yammer|typepad|askville|hubpages|stackoverflow|tripadvisor|flavors\.me|quora|wordpress|topix|salespider|wordpress|slideshare|hootsuite|paper\.li)')
			                     OR trafficSource.campaign CONTAINS 'FB_'
			                     OR trafficSource.campaign CONTAINS 'TW_'
			                     OR trafficSource.source = 't.co' 
                           OR REGEXP_MATCH(LOWER(trafficSource.source), r'(academia\.edu|deviantart|beforeitsnews|\.naver\.com|chicagonow|circleofmoms|dailystrength|diigo|getpocket|meetup|cafemom|ycombinator|okwave|oshiete|cstools|scoop\.it|foursquare|tinyurl|yuku|\Acare2|\Achicagonow)')
			                     )
                           AND (CASE WHEN LOWER(trafficSource.source) CONTAINS 'search' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER)
                            THEN 'Social'
                          WHEN LOWER(trafficSource.medium) CONTAINS 'email'
                            THEN 'Email'
                          WHEN LOWER(trafficSource.medium) CONTAINS 'affiliate'
                          OR REGEXP_MATCH(trafficSource.source, r'(boomerater|lifecare)') 
                            THEN 'Affiliates'
			                     WHEN (
										trafficSource.campaign CONTAINS'Branded_Terms'
									   OR trafficSource.campaign CONTAINS 'Legal_Q_&_A_Search'
									   OR trafficSource.campaign CONTAINS 'Brand|RLSA'
									   OR trafficSource.campaign CONTAINS 'PLS|'
									   OR trafficSource.campaign CONTAINS 'brand'
									   )
								 AND (CASE
										WHEN trafficSource.campaign CONTAINS 'FB_'
											THEN CAST(1 AS INTEGER)
										ELSE CAST(0 AS INTEGER)
										END) = CAST(0 AS INTEGER)
										THEN 'Paid Search - Marketing'
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
                          WHEN trafficSource.Medium IN ('video', 'mobile', 'mobile_video', 'mobile_tablet')
                          OR LOWER(trafficSource.Medium) CONTAINS 'display'
                            THEN 'Digital Brand'
			  WHEN (REGEXP_MATCH(trafficSource.medium, r'^(display|cpm|banner)$') 
			  || trafficSource.adwordsClickInfo.adNetworkType = 'Content')
			  AND (CASE 
                                  WHEN LOWER(trafficSource.campaign) CONTAINS 'display' 
                                  OR trafficSource.campaign CONTAINS 'Network' 
                                  OR LOWER(trafficSource.campaign) CONTAINS 'sgt'
                                    THEN CAST(1 AS INTEGER)
                                    ELSE CAST(0 AS INTEGER)
                                  END) = CAST(0 AS INTEGER)
                            THEN 'Other Paid Marketing'
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
                        END AS Channel
                        ,MIN(date) AS FirstVisitDate
                        ,EXACT_COUNT_DISTINCT(date) DaysVisited
,COUNT(totals.visits) AS Sessions
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact website'
THEN CAST(1 AS INTEGER)
ELSE CAST(0 AS INTEGER)
END) AS  ClicksToLawyerWebsite
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
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
					THEN hits.Product.ProductQuantity
				ELSE CAST(0 AS INTEGER)
			    END) TotalAdvisorPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'review'
					THEN hits.Product.ProductQuantity
				ELSE CAST(0 AS INTEGER)
			    END) TotalDocReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND REGEXP_MATCH((LOWER(hits.product.v2ProductName)), r'^(apply|start|form|create|file)')
					THEN hits.Product.ProductQuantity
				ELSE CAST(0 AS INTEGER)
			    END) TotalOfflinePackagePurchases
                       FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2015-10-18'),CURRENT_TIMESTAMP())
                       WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) 
                      GROUP BY 1,2
                      )
                      
                      ,
                      
(SELECT                fullVisitorID AS Persistent_Session_ID
                      ,CASE
                          WHEN (
                          REGEXP_MATCH(LOWER(trafficSource.medium), r'^(social|social-network|social-media|sm|social network|social media)$') /* system defined */ 
                          || REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|twitter|gplus|linkedin|lnkd\.in|plus\.url\.google\.com|plus\.google\.com|googleplus|blogspot|disqus|reddit|reddit\.com|stumbleupon|yelp|vk\.com|livejournal|glassdoor|pinboard|spoke|wiki|youtube|weebly|tumblr|stackexchange|pinterest|instagram|netvibes|yammer|typepad|askville|hubpages|stackoverflow|tripadvisor|flavors\.me|quora|wordpress|topix|salespider|wordpress|slideshare|hootsuite|paper\.li)')
			                     OR trafficSource.campaign CONTAINS 'FB_'
			                     OR trafficSource.campaign CONTAINS 'TW_'
			                     OR trafficSource.source = 't.co' 
                           OR REGEXP_MATCH(LOWER(trafficSource.source), r'(academia\.edu|deviantart|beforeitsnews|\.naver\.com|chicagonow|circleofmoms|dailystrength|diigo|getpocket|meetup|cafemom|ycombinator|okwave|oshiete|cstools|scoop\.it|foursquare|tinyurl|yuku|\Acare2|\Achicagonow)')
			                     )
                           AND (CASE WHEN LOWER(trafficSource.source) CONTAINS 'search' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER)
                            THEN 'Social'
                          WHEN LOWER(trafficSource.medium) CONTAINS 'email'
                            THEN 'Email'
                          WHEN LOWER(trafficSource.medium) CONTAINS 'affiliate'
                          OR REGEXP_MATCH(trafficSource.source, r'(boomerater|lifecare)') 
                            THEN 'Affiliates'
			                     WHEN (
										trafficSource.campaign CONTAINS'Branded_Terms'
									   OR trafficSource.campaign CONTAINS 'Legal_Q_&_A_Search'
									   OR trafficSource.campaign CONTAINS 'Brand|RLSA'
									   OR trafficSource.campaign CONTAINS 'PLS|'
									   OR trafficSource.campaign CONTAINS 'brand'
									   )
								 AND (CASE
										WHEN trafficSource.campaign CONTAINS 'FB_'
											THEN CAST(1 AS INTEGER)
										ELSE CAST(0 AS INTEGER)
										END) = CAST(0 AS INTEGER)
										THEN 'Paid Search - Marketing'
			                     WHEN REGEXP_MATCH(trafficSource.medium, r'^(cpc|ppc|paidsearch)$') 
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
                          WHEN trafficSource.Medium IN ('video', 'mobile', 'mobile_video', 'mobile_tablet')
                          OR LOWER(trafficSource.Medium) CONTAINS 'display'
                            THEN 'Digital Brand'
			  WHEN REGEXP_MATCH(trafficSource.medium, r'^(display|cpm|banner)$') 
			  AND (CASE 
                                  WHEN LOWER(trafficSource.campaign) CONTAINS 'display' 
                                  OR trafficSource.campaign CONTAINS 'Network' 
                                  OR LOWER(trafficSource.campaign) CONTAINS 'sgt'
                                    THEN CAST(1 AS INTEGER)
                                    ELSE CAST(0 AS INTEGER)
                                  END) = CAST(0 AS INTEGER) 
                            THEN 'Other Paid Marketing'
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
                        END AS Channel
                        ,MIN(date) AS FirstVisitDate
                        ,EXACT_COUNT_DISTINCT(date) DaysVisited
                       ,COUNT(totals.visits) AS Sessions
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact website'
                                  THEN CAST(1 AS INTEGER)
                                ELSE CAST(0 AS INTEGER)
                              END) AS  ClicksToLawyerWebsite
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
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
					THEN hits.Product.ProductQuantity
				ELSE CAST(0 AS INTEGER)
			    END) TotalAdvisorPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'review'
					THEN hits.Product.ProductQuantity
				ELSE CAST(0 AS INTEGER)
			    END) TotalDocReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND REGEXP_MATCH((LOWER(hits.product.v2ProductName)), r'^(apply|start|form|create|file)')
					THEN hits.Product.ProductQuantity
				ELSE CAST(0 AS INTEGER)

                       FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2014-05-27'),TIMESTAMP('2015-06-06'))
                       WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER)   
                      GROUP BY 1,2
                      )

                                      , 
         
                       
                       (SELECT fullVisitorID AS Persistent_Session_ID
                       ,CASE
                          WHEN (REGEXP_MATCH(LOWER(trafficSource.medium), r'(social|social-network|social-media|sm|social network|social media)') 
                          || REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|linkedin|twitter|\.blog|\Aplus\.|quora|salespider|spoke\.com|\Avk\.com|\Atopix\.com|\Awikihow|yammer|lnkd|livejournal|gplus|disqus|hubpages|instagram|netvibes|stumbleupon|blogspot|pinboard|tumblr|yelp|askville|stackoverflow|typepad|cstools|stackexchange|reddit|flavors|dailystrength|ycombinator|scoop|academia|weebly|paper|pinterest|slideshare|tripadvisor|wordpress|glassdoor|youtube|foursquare|tinyurl|yuku|blog\.naver|\Abeforeitsnews|\Acare2|\Achicagonow)')
                          || REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|twitter|gplus|linkedin|lnkd\.in|plus\.url\.google\.com|plus\.google\.com|googleplus|blogspot|disqus|reddit|reddit\.com|stumbleupon|yelp|vk\.com|livejournal|glassdoor|pinboard|spoke|wiki|youtube|weebly|tumblr|stackexchange|pinterest|instagram|netvibes|yammer|typepad|askville|hubpages|stackoverflow|tripadvisor|flavors\.me|quora|wordpress|topix|salespider|wordpress|slideshare|hootsuite|paper\.li)')
			  OR trafficSource.campaign CONTAINS 'FB_'
			  OR trafficSource.campaign CONTAINS 'TW_'
                          OR LEFT(LOWER(trafficSource.source), 4) = 'cafe'
			  OR trafficSource.source = 't.co' )
			  AND (CASE WHEN trafficSource.source CONTAINS 'search' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER)
                            THEN 'Social'
                          WHEN trafficSource.medium = 'email'
                          OR trafficSource.medium CONTAINS 'email'
                            THEN 'Email'
                          WHEN trafficSource.medium = 'affiliate'
			  OR trafficSource.source CONTAINS 'affiliate'
                          OR REGEXP_MATCH(trafficSource.source, r'(boomerater|lifecare)') 
                            THEN 'Affiliates'
			                     WHEN (
										trafficSource.campaign CONTAINS'Branded_Terms'
									   OR trafficSource.campaign CONTAINS 'Legal_Q_&_A_Search'
									   OR trafficSource.campaign CONTAINS 'Brand|RLSA'
									   OR trafficSource.campaign CONTAINS 'PLS|'
									   OR trafficSource.campaign CONTAINS 'brand'
									   )
								 AND (CASE
										WHEN trafficSource.campaign CONTAINS 'FB_'
											THEN CAST(1 AS INTEGER)
										ELSE CAST(0 AS INTEGER)
										END) = CAST(0 AS INTEGER)
										THEN 'Paid Search - Marketing'
			  WHEN REGEXP_MATCH(trafficSource.medium, r'^(cpc|ppc|paidsearch)$')
                          AND (CASE 
                                  WHEN trafficSource.source CONTAINS 'facebook' 
                                  OR trafficSource.source CONTAINS 'twitter' 
                                  OR trafficSource.source CONTAINS 'linkedin'
				  OR trafficSource.source CONTAINS 'Branded_Terms' 
                                  OR trafficSource.source CONTAINS 'Legal_Q_&_A_Search' 
                                  OR trafficSource.source CONTAINS 'Brand|RLSA'
                                    THEN CAST(1 AS INTEGER)
                                    ELSE CAST(0 AS INTEGER)
                                  END) = CAST(0 AS INTEGER)
                            THEN 'Paid Search - AMM'
                          WHEN trafficSource.Medium IN ('video', 'mobile', 'mobile_video', 'mobile_tablet')
                          OR trafficSource.Medium CONTAINS 'display'
                            THEN 'Digital Brand'
			  WHEN REGEXP_MATCH(trafficSource.medium, r'^(display|cpm|banner)$')
			  AND (CASE 
                                  WHEN trafficSource.campaign CONTAINS 'display' 
                                  OR trafficSource.campaign CONTAINS 'Network' 
                                  OR trafficSource.campaign CONTAINS 'sgt'
                                    THEN CAST(1 AS INTEGER)
                                    ELSE CAST(0 AS INTEGER)
                                  END) = CAST(0 AS INTEGER)
                            THEN 'Other Paid Marketing'
			  WHEN trafficSource.campaign CONTAINS 'display'
				THEN 'Display - AMM'
                          WHEN trafficSource.source = '(direct)'
                          AND trafficSource.medium = '(none)'
                            THEN 'Direct'
                          WHEN trafficSource.medium = 'organic'
                            THEN 'Organic Search'
                          WHEN trafficSource.medium = 'referral'
                            THEN 'Referral'
                          WHEN   REGEXP_MATCH(trafficSource.medium, r'^(cpv|cpa|cpp)$') 
                            THEN '(Other)'
                          ELSE '(Other)'
                        END AS Channel
                        ,MIN(date) AS FirstVisitDate
                        ,EXACT_COUNT_DISTINCT(date) DaysVisited
                        ,COUNT(totals.visits) AS Sessions
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact website'
                                  THEN CAST(1 AS INTEGER)
                                ELSE CAST(0 AS INTEGER)
                              END) AS  ClicksToLawyerWebsite
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
			,CAST(0 AS INTEGER)TotalAdvisorPurchases
			,CAST(0 AS INTEGER)TotalDocReviewPurchases
			,CAST(0 AS INTEGER)TotalOfflinePackagePurchases      
                       FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2014-02-09'),TIMESTAMP('2014-05-26'))
                       WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER)

                       GROUP BY 1,2  )