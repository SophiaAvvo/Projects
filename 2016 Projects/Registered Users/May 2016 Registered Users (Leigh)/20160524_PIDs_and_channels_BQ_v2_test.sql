SELECT DISTINCT m.Persistent_Session_ID
,m.Date AS FirstVisitDate
,m.Channel
FROM (SELECT DISTINCT fullVisitorID AS Persistent_Session_ID
                      ,VisitStartTime
                      ,Date
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

                       FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-5-18'),CURRENT_TIMESTAMP()) 
                       
                       ) main
  JOIN (
        SELECT fullVisitorID AS Persistent_Session_ID
          ,MIN(VisitStartTime) FirstVisit
          FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-5-18'),CURRENT_TIMESTAMP())
      ) filter  
  ON filter.fullVisitorID = main.fullVisitorID
  AND filter.firstVisit = main.VisitStartTime