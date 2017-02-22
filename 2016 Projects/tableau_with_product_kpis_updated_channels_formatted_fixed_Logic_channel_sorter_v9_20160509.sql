SELECT Date AS Date
    ,Sessions AS Sessions
    ,ClicksToLawyerWebsite AS ClicksToLawyerWebsite
    ,NumberQuestionsAsked AS NumberQuestionsAsked
    ,NumberQuestionsAnswered AS NumberQuestionsAnswered
    ,EmailSentToLawyers AS EmailSentToLawyers
    ,NumberOfReviews AS NumberOfReviews
    ,NumberOfClaims AS NumberOfClaims
    ,NumberOfEndorsements AS NumberOfEndorsements
    ,NumberOfRegistrations AS NumberOfRegistrations
    ,Channel AS Channel
    ,EmploymentLaborAdvicePurchases AS EmploymentLaborAdvicePurchases
    ,BankruptcyDebtAdvicePurchases AS BankruptcyDebtAdvicePurchases
    ,ImmigrationAdvicePurchases AS ImmigrationAdvicePurchases
    ,CriminalDefenseAdvicePurchases AS CriminalDefenseAdvicePurchases
    ,DivorceSeparationAdvicePurchases AS DivorceSeparationAdvicePurchases
    ,FamilyGreenCardReviewPurchases AS FamilyGreenCardReviewPurchases
    ,ContractorAgreementReviewPurchases AS ContractorAgreementReviewPurchases
    ,RealEstateAdvicePurchases AS RealEstateAdvicePurchases
    ,LandlordTenantAdvicePurchases AS LandlordTenantAdvicePurchases
    ,BusinessAdvicePurchases AS BusinessAdvicePurchases
    ,NullValuePurchases AS NullValuePurchases
    ,UncontestedDivorceFilingPurchases AS UncontestedDivorceFilingPurchases
    ,FifteenMinuteAdvicePurchases AS FifteenMinuteAdvicePurchases
    ,ThirtyMinuteAdvicePurchases AS ThirtyMinuteAdvicePurchases
    ,FamilyAdvicePurchases AS FamilyAdvicePurchases
,TotalAdvisorPurchases AS TotalAdvisorPurchases
, TotalDocReviewPurchases AS TotalDocReviewPurchases
, TotalOfflinePackagePurchases AS TotalOfflinePackagePurchases
, USCitizenshipAppPurchases AS USCitizenshipAppPurchases
, ConsultationReviewPurchases AS ConsultationReviewPurchases
			,VendorAgreementReviewPurchases AS VendorAgreementReviewPurchases
			,BusinessContractReviewPurchases AS BusinessContractReviewPurchases
			,NDAReviewPurchases AS NDAReviewPurchases
			,EmploymentContractReviewPurchases AS EmploymentContractReviewPurchases
			,LLCPackagePurchases AS LLCPackagePurchases
			,CorpPackagePurchases AS CorpPackagePurchases
			,BizContractPackagePurchases AS BizContractPackagePurchases
			,PrenupReviewPurchases AS PrenupReviewPurchases
			,ParentingPlanReviewPurchases AS ParentingPlanReviewPurchases
			,SeparationAgreementReviewPurchases AS SeparationAgreementReviewPurchases
			,ParentingPlanPackagePurchases AS ParentingPlanPackagePurchases
			,UncontestedDivorcePackagePurchases AS UncontestedDivorcePackagePurchases
        ,CASE
            WHEN Channel = 'Organic Search'
                THEN 1
            WHEN Channel = 'Direct'
                THEN 2
            WHEN Channel = 'Email'
                THEN 3
            WHEN Channel = 'Social'
                THEN 4
            WHEN Channel = 'Referral'
                THEN 5
            WHEN Channel = 'Paid Search - Marketing'
                THEN 6
            WHEN Channel = 'Digital Brand'
                THEN 7
            WHEN Channel = '(Other)'
                THEN 8
            WHEN Channel = 'Affiliates'
                THEN 9
            WHEN Channel = 'Paid Search - AMM'
                THEN 10
            WHEN Channel = 'Display - AMM'
                THEN 11
            WHEN Channel = 'Other Paid Marketing'
                THEN 12
            ELSE 13
            END ChannelSortOrder
      ,CASE
            WHEN Channel = 'Organic Search'
                THEN 1
            WHEN Channel = 'Direct'
                THEN 2
            WHEN Channel = 'Email'
                THEN 3
            WHEN Channel = 'Social'
                THEN 4
            WHEN Channel = 'Referral'
                THEN 5
            WHEN Channel = 'Paid Marketing'
                THEN 6
            WHEN Channel = 'Digital Brand'
                THEN 7
            WHEN Channel = '(Other)'
                THEN 8
            WHEN Channel = 'Affiliates'
                THEN 9
            WHEN Channel = 'Paid Search - AMM'
                THEN 10
            WHEN Channel = 'Display - AMM'
                THEN 11
            ELSE 12
            END ChannelGroupSortOrder
FROM 
(SELECT                date AS Date
                       ,CASE
                          /* social */
                          WHEN (
                          REGEXP_MATCH(LOWER(trafficSource.medium), r'^(social|social-network|social-media|sm|social network|social media)$') /* system defined */ 
                          /* custom defined */
                          || REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|twitter|gplus|linkedin|lnkd\.in|plus\.url\.google\.com|plus\.google\.com|googleplus|blogspot|disqus|reddit|reddit\.com|stumbleupon|yelp|vk\.com|livejournal|glassdoor|pinboard|spoke|wiki|youtube|weebly|tumblr|stackexchange|pinterest|instagram|netvibes|yammer|typepad|askville|hubpages|stackoverflow|tripadvisor|flavors\.me|quora|wordpress|topix|salespider|wordpress|slideshare|hootsuite|paper\.li)')
			                     OR trafficSource.campaign CONTAINS 'FB_'
			                     OR trafficSource.campaign CONTAINS 'TW_'
			                     OR trafficSource.source = 't.co' 
                           /* manually taken from QA checks - all done but regex not working */
                           /*OR (LOWER(trafficSource.campaign) CONTAINS '(not set)' AND LOWER(trafficSource.medium) CONTAINS 'referral' 
                           AND REGEXP_MATCH(LOWER(trafficSource.source), r'(academia\.edu|deviantart|beforeitsnews|\.naver\.com|chicagonow|circleofmoms|dailystrength|diigo|getpocket|meetup|cafemom|ycombinator|okwave|oshiete|cstools|scoop\.it|foursquare|tinyurl|yuku|\Acare2|\Achicagonow)')
                           )
                           ) */ 
                           OR REGEXP_MATCH(LOWER(trafficSource.source), r'(academia\.edu|deviantart|beforeitsnews|\.naver\.com|chicagonow|circleofmoms|dailystrength|diigo|getpocket|meetup|cafemom|ycombinator|okwave|oshiete|cstools|scoop\.it|foursquare|tinyurl|yuku|\Acare2|\Achicagonow)')
			                     )
                           AND (CASE WHEN LOWER(trafficSource.source) CONTAINS 'search' THEN 1 ELSE 0 END) = 0
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
									   OR trafficSource.campaign CONTAINS 'adblock'
									   )
								 AND (CASE
										WHEN trafficSource.campaign CONTAINS 'FB_'
											THEN 1
										ELSE 0
										END) = 0
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
                                    THEN 1
                                    ELSE 0
                                  END) = 0
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
                                    THEN 1
                                    ELSE 0
                                  END) = 0
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
,COUNT(totals.visits) AS Sessions
,SUM(CASE
WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact website'
THEN 1
ELSE 0
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
                                  THEN 1
                                ELSE 0
                              END) EmailSentToLawyers
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'submit review'
                                  THEN 1
                                ELSE 0
                              END) NumberOfReviews
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'complete claim'
                                  THEN 1
                                ELSE 0
                              END) NumberOfClaims
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'submit endorsement'
                                  THEN 1
                                ELSE 0
                              END) NumberOfEndorsements
                       ,COUNT(CASE
                                WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/virtual/new-registration/')
                                AND hits.type = 'PAGE'
                                  THEN hits.page.pagePath
                                ELSE NULL
                              END) NumberOfRegistrations
                       ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'employment & labor advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) EmploymentLaborAdvicePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'bankruptcy & debt advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) BankruptcyDebtAdvicePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'immigration advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) ImmigrationAdvicePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'criminal defense advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) CriminalDefenseAdvicePurchases
			                   ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'divorce & separation advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) DivorceSeparationAdvicePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'application review: family green card'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) FamilyGreenCardReviewPurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'document review: contractor agreement'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) ContractorAgreementReviewPurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'real estate advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) RealEstateAdvicePurchases
			,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'landlord & tenant advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) LandlordTenantAdvicePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'business advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) BusinessAdvicePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) IS NULL
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) NullValuePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'file for uncontested divorce'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) UncontestedDivorceFilingPurchases
			                 ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = '15-minute advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) FifteenMinuteAdvicePurchases
			                 ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = '30-minute advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) ThirtyMinuteAdvicePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'family advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) FamilyAdvicePurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) TotalAdvisorPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'review'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) TotalDocReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND REGEXP_MATCH((LOWER(hits.product.v2ProductName)), r'^(apply|start|form|create|file)')
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) TotalOfflinePackagePurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'citizenship'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) USCitizenshipAppPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'consultation'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) ConsultationReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'vendor'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) VendorAgreementReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'business'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) BusinessContractReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'non-disclosure'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) NDAReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'employment'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) EmploymentContractReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'llc'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) LLCPackagePurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'form'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'corp'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) CorpPackagePurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'create'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'business'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) BizContractPackagePurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'prenuptial'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) PrenupReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'parenting'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) ParentingPlanReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND (LOWER(hits.product.v2ProductName) CONTAINS 'seperation'
				OR LOWER(hits.product.v2ProductName) CONTAINS 'seperation')
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) SeparationAgreementReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'create'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'parenting'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) ParentingPlanPackagePurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'uncontested'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) UncontestedDivorcePackagePurchases
                       FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2015-10-18'),CURRENT_TIMESTAMP())
                       WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN 1 ELSE 0 END) = 0 
                      GROUP BY 1,2
                      )
                      
                      ,
                      
(SELECT                date AS Date
                      ,CASE
                          /* social */
                          WHEN (
                          REGEXP_MATCH(LOWER(trafficSource.medium), r'^(social|social-network|social-media|sm|social network|social media)$') /* system defined */ 
                          /* custom defined */
                          || REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|twitter|gplus|linkedin|lnkd\.in|plus\.url\.google\.com|plus\.google\.com|googleplus|blogspot|disqus|reddit|reddit\.com|stumbleupon|yelp|vk\.com|livejournal|glassdoor|pinboard|spoke|wiki|youtube|weebly|tumblr|stackexchange|pinterest|instagram|netvibes|yammer|typepad|askville|hubpages|stackoverflow|tripadvisor|flavors\.me|quora|wordpress|topix|salespider|wordpress|slideshare|hootsuite|paper\.li)')
			                     OR trafficSource.campaign CONTAINS 'FB_'
			                     OR trafficSource.campaign CONTAINS 'TW_'
			                     OR trafficSource.source = 't.co' 
                           /* manually taken from QA checks - all done but regex not working */
                           /*OR (LOWER(trafficSource.campaign) CONTAINS '(not set)' AND LOWER(trafficSource.medium) CONTAINS 'referral' 
                           AND REGEXP_MATCH(LOWER(trafficSource.source), r'(academia\.edu|deviantart|beforeitsnews|\.naver\.com|chicagonow|circleofmoms|dailystrength|diigo|getpocket|meetup|cafemom|ycombinator|okwave|oshiete|cstools|scoop\.it|foursquare|tinyurl|yuku|\Acare2|\Achicagonow)')
                           )
                           ) */ 
                           OR REGEXP_MATCH(LOWER(trafficSource.source), r'(academia\.edu|deviantart|beforeitsnews|\.naver\.com|chicagonow|circleofmoms|dailystrength|diigo|getpocket|meetup|cafemom|ycombinator|okwave|oshiete|cstools|scoop\.it|foursquare|tinyurl|yuku|\Acare2|\Achicagonow)')
			                     )
                           AND (CASE WHEN LOWER(trafficSource.source) CONTAINS 'search' THEN 1 ELSE 0 END) = 0
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
									   OR trafficSource.campaign CONTAINS 'adblock'
									   )
								 AND (CASE
										WHEN trafficSource.campaign CONTAINS 'FB_'
											THEN 1
										ELSE 0
										END) = 0
										THEN 'Paid Search - Marketing'
			                     WHEN REGEXP_MATCH(trafficSource.medium, r'^(cpc|ppc|paidsearch)$') 
                          AND (CASE 
                                  WHEN LOWER(trafficSource.source) CONTAINS 'facebook' 
                                  OR LOWER(trafficSource.source) CONTAINS 'twitter' 
                                  OR LOWER(trafficSource.source) CONTAINS 'linkedin'
				  OR trafficSource.source CONTAINS 'Branded_Terms' 
                                  OR trafficSource.source CONTAINS 'Legal_Q_&_A_Search' 
                                  OR trafficSource.source CONTAINS 'Brand|RLSA'
                                    THEN 1
                                    ELSE 0
                                  END) = 0
                            THEN 'Paid Search - AMM'
                          WHEN trafficSource.Medium IN ('video', 'mobile', 'mobile_video', 'mobile_tablet')
                          OR LOWER(trafficSource.Medium) CONTAINS 'display'
                            THEN 'Digital Brand'
			  WHEN REGEXP_MATCH(trafficSource.medium, r'^(display|cpm|banner)$') 
			  AND (CASE 
                                  WHEN LOWER(trafficSource.campaign) CONTAINS 'display' 
                                  OR trafficSource.campaign CONTAINS 'Network' 
                                  OR LOWER(trafficSource.campaign) CONTAINS 'sgt'
                                    THEN 1
                                    ELSE 0
                                  END) = 0 
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
                       ,COUNT(totals.visits) AS Sessions
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact website'
                                  THEN 1
                                ELSE 0
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
                                  THEN 1
                                ELSE 0
                              END) EmailSentToLawyers
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'submit review'
                                  THEN 1
                                ELSE 0
                              END) NumberOfReviews
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'complete claim'
                                  THEN 1
                                ELSE 0
                              END) NumberOfClaims
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'submit endorsement'
                                  THEN 1
                                ELSE 0
                              END) NumberOfEndorsements
                       ,COUNT(CASE
                                WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/virtual/new-registration/')
                                AND hits.type = 'PAGE'
                                  THEN hits.page.pagePath
                                ELSE NULL
                              END) NumberOfRegistrations
                       ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'employment & labor advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) EmploymentLaborAdvicePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'bankruptcy & debt advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) BankruptcyDebtAdvicePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'immigration advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) ImmigrationAdvicePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'criminal defense advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) CriminalDefenseAdvicePurchases
			                   ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'divorce & separation advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) DivorceSeparationAdvicePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'application review: family green card'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) FamilyGreenCardReviewPurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'document review: contractor agreement'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) ContractorAgreementReviewPurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'real estate advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) RealEstateAdvicePurchases
			,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'landlord & tenant advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) LandlordTenantAdvicePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'business advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) BusinessAdvicePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) IS NULL
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) NullValuePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'file for uncontested divorce'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) UncontestedDivorceFilingPurchases
			                 ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = '15-minute advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) FifteenMinuteAdvicePurchases
			                 ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = '30-minute advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) ThirtyMinuteAdvicePurchases
                        ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = 'family advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE 0
                              END) FamilyAdvicePurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) TotalAdvisorPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'review'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) TotalDocReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND REGEXP_MATCH((LOWER(hits.product.v2ProductName)), r'^(apply|start|form|create|file)')
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) TotalOfflinePackagePurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'citizenship'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) USCitizenshipAppPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'consultation'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) ConsultationReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'vendor'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) VendorAgreementReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'business'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) BusinessContractReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'non-disclosure'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) NDAReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'employment'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) EmploymentContractReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'llc'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) LLCPackagePurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'form'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'corp'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) CorpPackagePurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'create'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'business'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) BizContractPackagePurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'prenuptial'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) PrenupReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'parenting'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) ParentingPlanReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND (LOWER(hits.product.v2ProductName) CONTAINS 'seperation'
				OR LOWER(hits.product.v2ProductName) CONTAINS 'seperation')
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) SeparationAgreementReviewPurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'create'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'parenting'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) ParentingPlanPackagePurchases
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'uncontested'
					THEN hits.Product.ProductQuantity
				ELSE 0
			    END) UncontestedDivorcePackagePurchases   
                       FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2014-05-27'),TIMESTAMP('2015-06-06'))
                       WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN 1 ELSE 0 END) = 0   
                      GROUP BY 1,2
                      )

                                      , 
         
                       
                       (SELECT date AS Date
                       ,CASE
                          WHEN (REGEXP_MATCH(LOWER(trafficSource.medium), r'(social|social-network|social-media|sm|social network|social media)') 
                          || REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|linkedin|twitter|\.blog|\Aplus\.|quora|salespider|spoke\.com|\Avk\.com|\Atopix\.com|\Awikihow|yammer|lnkd|livejournal|gplus|disqus|hubpages|instagram|netvibes|stumbleupon|blogspot|pinboard|tumblr|yelp|askville|stackoverflow|typepad|cstools|stackexchange|reddit|flavors|dailystrength|ycombinator|scoop|academia|weebly|paper|pinterest|slideshare|tripadvisor|wordpress|glassdoor|youtube|foursquare|tinyurl|yuku|blog\.naver|\Abeforeitsnews|\Acare2|\Achicagonow)')
                          || REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|twitter|gplus|linkedin|lnkd\.in|plus\.url\.google\.com|plus\.google\.com|googleplus|blogspot|disqus|reddit|reddit\.com|stumbleupon|yelp|vk\.com|livejournal|glassdoor|pinboard|spoke|wiki|youtube|weebly|tumblr|stackexchange|pinterest|instagram|netvibes|yammer|typepad|askville|hubpages|stackoverflow|tripadvisor|flavors\.me|quora|wordpress|topix|salespider|wordpress|slideshare|hootsuite|paper\.li)')
			  OR trafficSource.campaign CONTAINS 'FB_'
			  OR trafficSource.campaign CONTAINS 'TW_'
                          OR LEFT(LOWER(trafficSource.source), 4) = 'cafe'
			  OR trafficSource.source = 't.co' )
			  AND (CASE WHEN trafficSource.source CONTAINS 'search' THEN 1 ELSE 0 END) = 0
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
									   OR trafficSource.campaign CONTAINS 'adblock'
									   )
								 AND (CASE
										WHEN trafficSource.campaign CONTAINS 'FB_'
											THEN 1
										ELSE 0
										END) = 0
										THEN 'Paid Search - Marketing'
			  WHEN REGEXP_MATCH(trafficSource.medium, r'^(cpc|ppc|paidsearch)$')
                          AND (CASE 
                                  WHEN trafficSource.source CONTAINS 'facebook' 
                                  OR trafficSource.source CONTAINS 'twitter' 
                                  OR trafficSource.source CONTAINS 'linkedin'
				  OR trafficSource.source CONTAINS 'Branded_Terms' 
                                  OR trafficSource.source CONTAINS 'Legal_Q_&_A_Search' 
                                  OR trafficSource.source CONTAINS 'Brand|RLSA'
                                    THEN 1
                                    ELSE 0
                                  END) = 0
                            THEN 'Paid Search - AMM'
                          WHEN trafficSource.Medium IN ('video', 'mobile', 'mobile_video', 'mobile_tablet')
                          OR trafficSource.Medium CONTAINS 'display'
                            THEN 'Digital Brand'
			  WHEN REGEXP_MATCH(trafficSource.medium, r'^(display|cpm|banner)$')
			  AND (CASE 
                                  WHEN trafficSource.campaign CONTAINS 'display' 
                                  OR trafficSource.campaign CONTAINS 'Network' 
                                  OR trafficSource.campaign CONTAINS 'sgt'
                                    THEN 1
                                    ELSE 0
                                  END) = 0
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
                        ,COUNT(totals.visits) AS Sessions
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'contact website'
                                  THEN 1
                                ELSE 0
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
                                  THEN 1
                                ELSE 0
                              END) EmailSentToLawyers
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'submit review'
                                  THEN 1
                                ELSE 0
                              END) NumberOfReviews
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'complete claim'
                                  THEN 1
                                ELSE 0
                              END) NumberOfClaims
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) CONTAINS 'submit endorsement'
                                  THEN 1
                                ELSE 0
                              END) NumberOfEndorsements
                       ,COUNT(CASE
                                WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/virtual/new-registration/')
                                AND hits.type = 'PAGE'
                                  THEN hits.page.pagePath
                                ELSE NULL
                              END) NumberOfRegistrations
                       ,0EmploymentLaborAdvicePurchases
                        ,0 AS BankruptcyDebtAdvicePurchases
                        ,0 AS ImmigrationAdvicePurchases
                        ,0 AS CriminalDefenseAdvicePurchases
			                 ,0 AS DivorceSeparationAdvicePurchases
                        ,0 AS FamilyGreenCardReviewPurchases
                        ,0 AS ContractorAgreementReviewPurchases
                        ,0 AS RealEstateAdvicePurchases
			                   ,0 AS LandlordTenantAdvicePurchases
                        ,0 AS BusinessAdvicePurchases
                        ,0 AS NullValuePurchases
                        ,0 AS UncontestedDivorceFilingPurchases
			,0 AS FifteenMinuteAdvicePurchases
                       ,0 AS ThirtyMinuteAdvicePurchases
                        ,0 AS FamilyAdvicePurchases
			,0 TotalAdvisorPurchases
			,0 TotalDocReviewPurchases
			,0 TotalOfflinePackagePurchases
			,0 USCitizenshipAppPurchases
			,0 ConsultationReviewPurchases
			,0 VendorAgreementReviewPurchases
			,0 BusinessContractReviewPurchases
			,0 NDAReviewPurchases
			,0 EmploymentContractReviewPurchases
			,0 LLCPackagePurchases
			,0 CorpPackagePurchases
			,0 BizContractPackagePurchases
			,0 PrenupReviewPurchases
			,0 ParentingPlanReviewPurchases
			,0 SeparationAgreementReviewPurchases
			,0 ParentingPlanPackagePurchases
			,0 UncontestedDivorcePackagePurchases       
                       FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2014-02-09'),TIMESTAMP('2014-05-26'))
                       WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN 1 ELSE 0 END) = 0

                       GROUP BY 1,2  )