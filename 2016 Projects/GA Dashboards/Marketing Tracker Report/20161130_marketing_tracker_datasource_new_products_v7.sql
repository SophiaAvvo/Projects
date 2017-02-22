/* 07/21/2016: Changed social definitions to include Mira's changes that she sent: keep "contains" _FB, add social as a source, add pls_fb|pls_avvofb to open-ended regex_match
Found "cafe" as a source filter in the oldest third of the script... also noticed one of the regex portions seemed redundant.  Think an update was missed in there, so replacing with logic from more recent stuff (figure we would have noticed if it was wrong)
added event_action = contact message to most recent logic, since this instant message ability started in June 2016
*/

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
	,MobileClicksToCall AS MobileClicksToCall
	,TotalCouponsUsed AS TotalCouponsUsed
    ,Channel AS Channel
	,TotalAdvisorPurchases AS TotalAdvisorPurchases
	,TotalDocReviewPurchases AS TotalDocReviewPurchases
	,TotalOfflinePackagePurchases AS TotalOfflinePackagePurchases
    ,BankruptcyDebtAdvicePurchases AS als_advice_bankruptcy_and_debt
    ,BusinessAdvicePurchases AS als_advice_business
    ,CriminalDefenseAdvicePurchases AS als_advice_criminal_defense
    ,DivorceSeparationAdvicePurchases AS als_advice_divorce_and_separation
	,EmploymentLaborAdvicePurchases AS als_advice_employment_and_labor
	,als_advice_estate_planning AS als_advice_estate_planning
	,FamilyAdvicePurchases AS als_advice_family
    ,ImmigrationAdvicePurchases AS als_advice_immigration
    ,LandlordTenantAdvicePurchases AS als_advice_landlord_and_tenant
	,RealEstateAdvicePurchases AS als_advice_real_estate
    ,FifteenMinuteAdvicePurchases AS als_advice_15_minute
    ,FamilyGreenCardReviewPurchases AS als_doc_review_family_green_card
	,als_doc_review_app_us_citizenship AS als_doc_review_app_us_citizenship
	,BusinessContractReviewPurchases AS als_doc_review_business_contract
	,als_doc_review_commercial_lease_agreement AS als_doc_review_commercial_lease_agreement
	,als_doc_review_consulting_agreement AS als_doc_review_consulting_agreement
    ,ContractorAgreementReviewPurchases AS als_doc_review_contractor_agreement
	,EmploymentContractReviewPurchases AS als_doc_review_employment_contract
	,als_doc_review_eviction_notice AS als_doc_review_eviction_notice
	,als_doc_review_last_will_and_testament AS als_doc_review_last_will_and_testament
	,als_doc_review_lease_notice AS als_doc_review_lease_notice
	,als_doc_review_living_trust AS als_doc_review_living_trust
	,als_doc_review_living_will AS als_doc_review_living_will
	,NDAReviewPurchases AS als_doc_review_non_disclosure_agreement
	,ParentingPlanReviewPurchases AS als_doc_review_parenting_plan
	,als_doc_review_power_of_attorney AS als_doc_review_power_of_attorney
	,PrenupReviewPurchases AS als_doc_review_prenuptial_agreement
	,als_doc_review_residential_lease_agreement AS als_doc_review_residential_lease_agreement
	,als_doc_review_residential_purchase_and_sale_agreement AS als_doc_review_residential_purchase_and_sale_agreement
	,SeparationAgreementReviewPurchases AS als_doc_review_separation_agreement
	,VendorAgreementReviewPurchases AS als_doc_review_vendor_agreement		
	,als_doc_review_termination_letter AS als_doc_review_termination_letter
	,als_doc_review_employment_offer_letter AS als_doc_review_employment_offer_letter
	,als_offline_family_green_card AS als_offline_family_green_card
	,USCitizenshipAppPurchases AS als_offline_apply_for_us_citizenship
	,BizContractPackagePurchases AS als_offline_create_a_business_contract
	,ParentingPlanPackagePurchases AS als_offline_create_a_parenting_plan
	,als_offline_create_a_commercial_lease_agreement AS als_offline_create_a_commercial_lease_agreement
	,als_offline_create_a_last_will_individual AS als_offline_create_a_last_will_individual
	,als_offline_create_a_lease_notice AS als_offline_create_a_lease_notice
	,als_offline_create_a_living_trust_individual AS als_offline_create_a_living_trust_individual
	,als_offline_create_a_living_trust_bundle_couple AS als_offline_create_a_living_trust_bundle_couple
	,als_offline_create_a_living_will AS als_offline_create_a_living_will
	,als_offline_create_a_power_of_attorney_individual AS als_offline_create_a_power_of_attorney_individual
	,als_offline_create_a_residential_lease_agreement AS als_offline_create_a_residential_lease_agreement
	,als_offline_create_an_estate_plan_bundle_couple AS als_offline_create_an_estate_plan_bundle_couple
	,als_offline_create_an_estate_plan_bundle_individual AS als_offline_create_an_estate_plan_bundle_individual
	,als_offline_create_an_eviction_notice AS als_offline_create_an_eviction_notice
    ,UncontestedDivorceFilingPurchases AS als_offline_file_for_uncontested_divorce
	,CorpPackagePurchases AS als_offline_form_c_or_s_corp
	,LLCPackagePurchases AS als_offline_start_a_single_member_llc
	,TotalAdvisorPurchases*10.0
		+(als_doc_review_power_of_attorney 
			+ als_doc_review_living_will)*30.0
		+ (FamilyGreenCardReviewPurchases
			+ als_doc_review_app_us_citizenship
			+ als_offline_create_a_power_of_attorney_individual
			+ als_doc_review_consulting_agreement
			+ ContractorAgreementReviewPurchases
			+ als_doc_review_employment_offer_letter
			+ als_doc_review_eviction_notice
			+ als_doc_review_last_will_and_testament
			+ als_doc_review_lease_notice
			+ NDAReviewPurchases
			+ ParentingPlanReviewPurchases
			+ PrenupReviewPurchases
			+ als_doc_review_residential_lease_agreement
			+ als_doc_review_termination_letter)*40.0
		+ (als_offline_create_a_living_will
			+ BusinessContractReviewPurchases
			+ EmploymentContractReviewPurchases
			+ als_doc_review_living_trust
			+ SeparationAgreementReviewPurchases
			+ VendorAgreementReviewPurchases)*50.0
		+ als_offline_create_a_lease_notice*60.0
		+ (BizContractPackagePurchases
			+ als_offline_create_a_last_will_individual
			+ als_offline_create_an_eviction_notice)*80.0
		+ als_offline_create_a_residential_lease_agreement*100.0
		+ (USCitizenshipAppPurchases
			+ ParentingPlanPackagePurchases
			+ LLCPackagePurchases)*125.0
		+ (als_doc_review_commercial_lease_agreement
			+ als_doc_review_residential_purchase_and_sale_agreement)*150.0
		+ (als_offline_create_an_estate_plan_bundle_individual
			+ UncontestedDivorceFilingPurchases
			+ CorpPackagePurchases)*200.0
		+ als_offline_create_an_estate_plan_bundle_couple*225.0
		+ (als_offline_create_a_commercial_lease_agreement
			+ als_offline_create_a_living_trust_individual)*250.0
		+ als_offline_create_a_living_trust_bundle_couple*300.0
		+ als_offline_family_green_card*400.0
	AS MarketingFees
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
(SELECT                date AS Date
                       ,CASE
                          WHEN (
                          REGEXP_MATCH(LOWER(trafficSource.medium), r'^(social|social-network|social-media|sm|social network|social media)$') /* system defined */ 
                          || REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|twitter|gplus|linkedin|lnkd\.in|plus\.url\.google\.com|plus\.google\.com|googleplus|blogspot|disqus|reddit|reddit\.com|stumbleupon|yelp|vk\.com|livejournal|glassdoor|pinboard|spoke|wiki|youtube|weebly|tumblr|stackexchange|pinterest|instagram|netvibes|yammer|typepad|askville|hubpages|stackoverflow|tripadvisor|flavors\.me|quora|wordpress|topix|salespider|wordpress|slideshare|hootsuite|paper\.li)')
			                     OR trafficSource.campaign CONTAINS 'FB_'  
			                     OR trafficSource.campaign CONTAINS 'TW_'
								 OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(pls_fb|pls_avvofb)')
								 OR REGEXP_MATCH(trafficSource.source, r'^(t.co|social)$')
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
									   OR trafficSource.campaign IN ('brand', 'pls')
									   OR REGEXP_MATCH(trafficSource.campaign, r'(legalqa|plsremarketing|advisorremarketing)')
									   )
								 AND (CASE
										WHEN trafficSource.source CONTAINS 'facebook'
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
                                WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/virtual/new-registration/')
                                AND hits.type = 'PAGE'
                                  THEN hits.page.pagePath
                                ELSE NULL
                              END) NumberOfRegistrations
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) = 'initiate mobile phone'
                                  THEN CAST(1 AS INTEGER)
                                ELSE CAST(0 AS INTEGER)
                              END) MobileClickstoCall						
						,SUM(CASE
                                WHEN LOWER(hits.transaction.transactionCoupon) IS NOT NULL
                                  THEN CAST(1 AS INTEGER)
                                ELSE CAST(0 AS INTEGER)
                              END) TotalCouponsUsed							  
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
            WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
              THEN hits.transaction.transactionid
               ELSE NULL
              END)) AS TotalAdvisorPurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
            WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'review'
              THEN hits.transaction.transactionid
               ELSE NULL
              END)) AS TotalDocReviewPurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
            WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
              THEN CASE
                  WHEN LOWER(hits.product.v2ProductName) IS NULL THEN NULL
                  WHEN LOWER(hits.product.v2ProductName) = 'display ad' THEN NULL
                  WHEN LOWER(hits.product.v2ProductName) = 'sponsored listing' THEN NULL
                  WHEN LOWER(hits.product.v2ProductName) = '(not set)' THEN NULL
                  WHEN LOWER(hits.product.v2ProductName) CONTAINS 'advice' THEN NULL
                  WHEN LOWER(hits.product.v2ProductName) CONTAINS 'review' THEN NULL
                  ELSE hits.transaction.transactionid
                  END
               ELSE NULL
              END)) AS TotalOfflinePackagePurchases 
			                 ,INTEGER(EXACT_COUNT_DISTINCT(CASE 
								WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
                                AND LOWER(hits.product.v2ProductName) = '15-minute advice session'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS FifteenMinuteAdvicePurchases
                       ,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'labor')
									THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS EmploymentLaborAdvicePurchases
                        ,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'bankruptcy')
									THEN hits.transaction.transactionid  
								ELSE NULL
								END)) AS BankruptcyDebtAdvicePurchases
                        ,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'immigration')
									THEN hits.transaction.transactionid  
								ELSE NULL
								END)) AS ImmigrationAdvicePurchases
                        ,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
                                AND LOWER(hits.product.v2ProductName) = 'criminal defense advice session'
                                  THEN hits.transaction.transactionid
								WHEN (LOWER(hits.product.v2ProductName) CONTAINS '15-minute'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'advice'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'criminal defense')
									THEN hits.transaction.transactionid  
								ELSE NULL
								END)) AS CriminalDefenseAdvicePurchases
			                   ,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
								AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
                                AND LOWER(hits.product.v2ProductName) CONTAINS 'divorce'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS DivorceSeparationAdvicePurchases
                        ,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'review'							
                                AND LOWER(hits.product.v2ProductName) CONTAINS 'family green card'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS FamilyGreenCardReviewPurchases
                        ,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
                                AND LOWER(hits.product.v2ProductName) = 'document review: contractor agreement'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS ContractorAgreementReviewPurchases
                        ,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
                                AND LOWER(hits.product.v2ProductName) = 'real estate advice session'
                                  THEN hits.transaction.transactionid
								WHEN (LOWER(hits.product.v2ProductName) CONTAINS '15-minute'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'advice'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'real estate')
									THEN hits.transaction.transactionid  
								ELSE NULL
								END)) AS RealEstateAdvicePurchases
						,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
                                AND LOWER(hits.product.v2ProductName) = 'landlord & tenant advice session'
                                  THEN hits.transaction.transactionid
								WHEN (LOWER(hits.product.v2ProductName) CONTAINS '15-minute'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'advice'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'landlord')
									THEN hits.transaction.transactionid  
								ELSE NULL
								END)) AS LandlordTenantAdvicePurchases
                        ,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
                                AND LOWER(hits.product.v2ProductName) = 'business advice session'
                                  THEN hits.transaction.transactionid
							WHEN (LOWER(hits.product.v2ProductName) CONTAINS '15-minute'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'advice'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'business')
									THEN hits.transaction.transactionid	  
								ELSE NULL
								END)) AS BusinessAdvicePurchases
                        ,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
                                AND LOWER(hits.product.v2ProductName) = 'file for uncontested divorce'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS UncontestedDivorceFilingPurchases

                        ,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
                                AND LOWER(hits.product.v2ProductName) = 'family advice session'
                                  THEN hits.transaction.transactionid
								WHEN (LOWER(hits.product.v2ProductName) CONTAINS '15-minute'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'advice'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'family')
									THEN hits.transaction.transactionid  
								ELSE NULL
								END)) AS FamilyAdvicePurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
				AND hits.product.v2ProductName = 'Apply for US citizenship'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS USCitizenshipAppPurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'vendor'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS VendorAgreementReviewPurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'business'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS BusinessContractReviewPurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'non-disclosure'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS NDAReviewPurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
				AND hits.product.v2ProductName = 'Document review: Employment contract'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS EmploymentContractReviewPurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'llc'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS LLCPackagePurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'form'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'corp'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS CorpPackagePurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'create'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'business'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS BizContractPackagePurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'prenuptial'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS PrenupReviewPurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'document review'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'parenting'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS ParentingPlanReviewPurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
				AND hits.product.v2ProductName = 'Document review: Separation agreement'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS SeparationAgreementReviewPurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'create'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'parenting'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS ParentingPlanPackagePurchases
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND LOWER(hits.product.v2Productname) = 'estate planning advice session'
                                  THEN hits.transaction.transactionid
							WHEN (LOWER(hits.product.v2ProductName) CONTAINS '15-minute'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'advice'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'estate planning')
									THEN hits.transaction.transactionid	  
								ELSE NULL
								END)) AS als_advice_estate_planning
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN LOWER(hits.product.v2ProductName) CONTAINS '15-minute'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'advice'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'child custody'
									THEN hits.transaction.transactionid
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_advice_child_custody
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN LOWER(hits.product.v2ProductName) CONTAINS '30'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'advice'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'business'
									THEN hits.transaction.transactionid
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_advice_business_30									
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN LOWER(hits.product.v2ProductName) CONTAINS '30'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'advice'
									AND LOWER(hits.product.v2ProductName) CONTAINS 'child custody'
									THEN hits.transaction.transactionid
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_advice_child_custody_30								
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND LOWER(hits.product.v2Productname) = 'application review: us citizenship'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_doc_review_app_us_citizenship
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Document review: Commercial lease agreement'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_doc_review_commercial_lease_agreement
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Document review: Consulting agreement'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_doc_review_consulting_agreement
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Document review: Eviction notice'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_doc_review_eviction_notice
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Document review: Last will and testament'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_doc_review_last_will_and_testament
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Document review: Lease notice'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_doc_review_lease_notice
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Document review: Living trust'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_doc_review_living_trust
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Document review: Living will'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_doc_review_living_will
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Document review: Power of attorney'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_doc_review_power_of_attorney
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Document review: Residential lease agreement'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_doc_review_residential_lease_agreement
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Document review: Residential purchase and sale agreement'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_doc_review_residential_purchase_and_sale_agreement
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Document review: termination letter'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_doc_review_termination_letter
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Document review: employment offer letter'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_doc_review_employment_offer_letter
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Apply for a family green card'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_offline_family_green_card
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Create a commercial lease agreement'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_offline_create_a_commercial_lease_agreement
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Create a last will and testament (individual)'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_offline_create_a_last_will_individual
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Create a lease notice'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_offline_create_a_lease_notice
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Create a living trust (individual)'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_offline_create_a_living_trust_individual
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Create a living trust bundle (couple)'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_offline_create_a_living_trust_bundle_couple
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Create a living will '
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_offline_create_a_living_will
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Create a power of attorney (individual)'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_offline_create_a_power_of_attorney_individual
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Create a residential lease agreement'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_offline_create_a_residential_lease_agreement
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Create an estate plan bundle (couple)'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_offline_create_an_estate_plan_bundle_couple
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Create an estate plan bundle (individual)'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_offline_create_an_estate_plan_bundle_individual
			,INTEGER(EXACT_COUNT_DISTINCT(CASE 
							WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
					AND hits.product.v2Productname = 'Create an eviction notice'
                                  THEN hits.transaction.transactionid
								ELSE NULL
								END)) AS als_offline_create_an_eviction_notice
						
                       FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2015-10-18'),CURRENT_TIMESTAMP())
                       WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER) 
                      GROUP BY 1,2
                      )
                      
                      ,
                      
(SELECT                date AS Date
                      ,CASE
                          WHEN (
                          REGEXP_MATCH(LOWER(trafficSource.medium), r'^(social|social-network|social-media|sm|social network|social media)$') /* system defined */ 
                          || REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|twitter|gplus|linkedin|lnkd\.in|plus\.url\.google\.com|plus\.google\.com|googleplus|blogspot|disqus|reddit|reddit\.com|stumbleupon|yelp|vk\.com|livejournal|glassdoor|pinboard|spoke|wiki|youtube|weebly|tumblr|stackexchange|pinterest|instagram|netvibes|yammer|typepad|askville|hubpages|stackoverflow|tripadvisor|flavors\.me|quora|wordpress|topix|salespider|wordpress|slideshare|hootsuite|paper\.li)')
			                     OR trafficSource.campaign CONTAINS 'FB_'  
			                     OR trafficSource.campaign CONTAINS 'TW_'
								 OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(pls_fb|pls_avvofb)')
								 OR REGEXP_MATCH(trafficSource.source, r'^(t.co|social)$')
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
									   OR trafficSource.campaign IN ('brand', 'pls')
									   OR REGEXP_MATCH(trafficSource.campaign, r'(legalqa|plsremarketing|advisorremarketing)')
									   )
								 AND (CASE
										WHEN trafficSource.source = 'facebook'
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
                       ,COUNT(CASE
                                WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/virtual/new-registration/')
                                AND hits.type = 'PAGE'
                                  THEN hits.page.pagePath
                                ELSE NULL
                              END) NumberOfRegistrations
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) = 'initiate mobile phone'
                                  THEN CAST(1 AS INTEGER)
                                ELSE CAST(0 AS INTEGER)
                              END) MobileClickstoCall
						,SUM(CASE
								WHEN LOWER(hits.transaction.transactionCoupon) IS NOT NULL
                                  THEN CAST(1 AS INTEGER)
                                ELSE CAST(0 AS INTEGER)
                              END) TotalCouponsUsed
			,SUM(CASE
				WHEN hits.eventInfo.eventCategory = 'ecommerce'
				AND hits.eCommerceACtion.action_type = '6'
				AND LOWER(hits.product.v2ProductName) CONTAINS 'advice session'
					THEN hits.Product.ProductQuantity
				ELSE CAST(0 AS INTEGER)
			    END) TotalAdvisorPurchases
			,CAST(0 AS INTEGER)TotalDocReviewPurchases
			,CAST(0 AS INTEGER)TotalOfflinePackagePurchases							  
			                 ,SUM(CASE
                                WHEN hits.eventInfo.eventCategory = 'ecommerce'
                                AND hits.eCommerceAction.action_type = '6'
                                AND LOWER(hits.product.v2ProductName) = '15-minute advice session'
                                  THEN hits.Product.ProductQuantity
                                ELSE CAST(0 AS INTEGER)
                              END) FifteenMinuteAdvicePurchases			
            ,CAST(0 AS INTEGER)EmploymentLaborAdvicePurchases
            ,CAST(0 AS INTEGER)BankruptcyDebtAdvicePurchases
            ,CAST(0 AS INTEGER)ImmigrationAdvicePurchases
            ,CAST(0 AS INTEGER)CriminalDefenseAdvicePurchases
			,CAST(0 AS INTEGER)DivorceSeparationAdvicePurchases
            ,CAST(0 AS INTEGER)FamilyGreenCardReviewPurchases
            ,CAST(0 AS INTEGER)ContractorAgreementReviewPurchases
            ,CAST(0 AS INTEGER)RealEstateAdvicePurchases
			,CAST(0 AS INTEGER)LandlordTenantAdvicePurchases
            ,CAST(0 AS INTEGER)BusinessAdvicePurchases
            ,CAST(0 AS INTEGER)UncontestedDivorceFilingPurchases
            ,CAST(0 AS INTEGER)FamilyAdvicePurchases
			,CAST(0 AS INTEGER)USCitizenshipAppPurchases
			,CAST(0 AS INTEGER)VendorAgreementReviewPurchases
			,CAST(0 AS INTEGER)BusinessContractReviewPurchases
			,CAST(0 AS INTEGER)NDAReviewPurchases
			,CAST(0 AS INTEGER)EmploymentContractReviewPurchases
			,CAST(0 AS INTEGER)LLCPackagePurchases
			,CAST(0 AS INTEGER)CorpPackagePurchases
			,CAST(0 AS INTEGER)BizContractPackagePurchases
			,CAST(0 AS INTEGER)PrenupReviewPurchases
			,CAST(0 AS INTEGER)ParentingPlanReviewPurchases
			,CAST(0 AS INTEGER)SeparationAgreementReviewPurchases
			,CAST(0 AS INTEGER)ParentingPlanPackagePurchases
			,CAST(0 AS INTEGER) als_advice_estate_planning
			,CAST(0 AS INTEGER) als_doc_review_app_us_citizenship
			,CAST(0 AS INTEGER) als_doc_review_commercial_lease_agreement
			,CAST(0 AS INTEGER) als_doc_review_consulting_agreement
			,CAST(0 AS INTEGER) als_doc_review_eviction_notice
			,CAST(0 AS INTEGER) als_doc_review_last_will_and_testament
			,CAST(0 AS INTEGER) als_doc_review_lease_notice
			,CAST(0 AS INTEGER) als_doc_review_living_trust
			,CAST(0 AS INTEGER) als_doc_review_living_will
			,CAST(0 AS INTEGER) als_doc_review_power_of_attorney
			,CAST(0 AS INTEGER) als_doc_review_residential_lease_agreement
			,CAST(0 AS INTEGER) als_doc_review_residential_purchase_and_sale_agreement
			,CAST(0 AS INTEGER) als_doc_review_termination_letter
			,CAST(0 AS INTEGER) als_doc_review_employment_offer_letter
			,CAST(0 AS INTEGER) als_offline_family_green_card
			,CAST(0 AS INTEGER) als_offline_create_a_commercial_lease_agreement
			,CAST(0 AS INTEGER) als_offline_create_a_last_will_individual
			,CAST(0 AS INTEGER) als_offline_create_a_lease_notice
			,CAST(0 AS INTEGER) als_offline_create_a_living_trust_individual
			,CAST(0 AS INTEGER) als_offline_create_a_living_trust_bundle_couple
			,CAST(0 AS INTEGER) als_offline_create_a_living_will
			,CAST(0 AS INTEGER) als_offline_create_a_power_of_attorney_individual
			,CAST(0 AS INTEGER) als_offline_create_a_residential_lease_agreement
			,CAST(0 AS INTEGER) als_offline_create_an_estate_plan_bundle_couple
			,CAST(0 AS INTEGER) als_offline_create_an_estate_plan_bundle_individual
			,CAST(0 AS INTEGER) als_offline_create_an_eviction_notice			
                       FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2014-05-27'),TIMESTAMP('2015-06-06'))
                       WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER)   
                      GROUP BY 1,2
                      )

                                      , 
         
                       
                       (SELECT date AS Date
                       ,CASE
                          WHEN (REGEXP_MATCH(LOWER(trafficSource.medium), r'(social|social-network|social-media|sm|social network|social media)') 
                          || REGEXP_MATCH(LOWER(trafficSource.source), r'(academia\.edu|deviantart|beforeitsnews|\.naver\.com|chicagonow|circleofmoms|dailystrength|diigo|getpocket|meetup|cafemom|ycombinator|okwave|oshiete|cstools|scoop\.it|foursquare|tinyurl|yuku|\Acare2|\Achicagonow)')
                          || REGEXP_MATCH(LOWER(trafficSource.source), r'(facebook|twitter|gplus|linkedin|lnkd\.in|plus\.url\.google\.com|plus\.google\.com|googleplus|blogspot|disqus|reddit|reddit\.com|stumbleupon|yelp|vk\.com|livejournal|glassdoor|pinboard|spoke|wiki|youtube|weebly|tumblr|stackexchange|pinterest|instagram|netvibes|yammer|typepad|askville|hubpages|stackoverflow|tripadvisor|flavors\.me|quora|wordpress|topix|salespider|wordpress|slideshare|hootsuite|paper\.li)')
								OR trafficSource.campaign CONTAINS 'FB_'  
			                     OR trafficSource.campaign CONTAINS 'TW_'
								 OR REGEXP_MATCH(LOWER(trafficSource.campaign), r'(pls_fb|pls_avvofb)')
								 OR REGEXP_MATCH(trafficSource.source, r'^(t.co|social)$')
								)
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
									   OR trafficSource.campaign IN ('brand', 'pls')
									   OR REGEXP_MATCH(trafficSource.campaign, r'(legalqa|plsremarketing|advisorremarketing)')
									   )
								 AND (CASE
										WHEN trafficSource.source = 'facebook'
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
                       ,COUNT(CASE
                                WHEN REGEXP_MATCH(LOWER(hits.page.pagePath), r'^/virtual/new-registration/')
                                AND hits.type = 'PAGE'
                                  THEN hits.page.pagePath
                                ELSE NULL
                              END) NumberOfRegistrations
                       ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) = 'initiate mobile phone'
                                  THEN CAST(1 AS INTEGER)
                                ELSE CAST(0 AS INTEGER)
                              END) MobileClickstoCall
			,CAST(0 AS INTEGER) TotalCouponsUsed							  
			,CAST(0 AS INTEGER)TotalAdvisorPurchases
			,CAST(0 AS INTEGER)TotalDocReviewPurchases
			,CAST(0 AS INTEGER)TotalOfflinePackagePurchases	
			,CAST(0 AS INTEGER)FifteenMinuteAdvicePurchases
            ,CAST(0 AS INTEGER)EmploymentLaborAdvicePurchases
            ,CAST(0 AS INTEGER)BankruptcyDebtAdvicePurchases
            ,CAST(0 AS INTEGER)ImmigrationAdvicePurchases
            ,CAST(0 AS INTEGER)CriminalDefenseAdvicePurchases
			,CAST(0 AS INTEGER)DivorceSeparationAdvicePurchases
            ,CAST(0 AS INTEGER)FamilyGreenCardReviewPurchases
            ,CAST(0 AS INTEGER)ContractorAgreementReviewPurchases
            ,CAST(0 AS INTEGER)RealEstateAdvicePurchases
			,CAST(0 AS INTEGER)LandlordTenantAdvicePurchases
            ,CAST(0 AS INTEGER)BusinessAdvicePurchases
            ,CAST(0 AS INTEGER)UncontestedDivorceFilingPurchases
            ,CAST(0 AS INTEGER)FamilyAdvicePurchases
			,CAST(0 AS INTEGER)USCitizenshipAppPurchases
			,CAST(0 AS INTEGER)VendorAgreementReviewPurchases
			,CAST(0 AS INTEGER)BusinessContractReviewPurchases
			,CAST(0 AS INTEGER)NDAReviewPurchases
			,CAST(0 AS INTEGER)EmploymentContractReviewPurchases
			,CAST(0 AS INTEGER)LLCPackagePurchases
			,CAST(0 AS INTEGER)CorpPackagePurchases
			,CAST(0 AS INTEGER)BizContractPackagePurchases
			,CAST(0 AS INTEGER)PrenupReviewPurchases
			,CAST(0 AS INTEGER)ParentingPlanReviewPurchases
			,CAST(0 AS INTEGER)SeparationAgreementReviewPurchases
			,CAST(0 AS INTEGER)ParentingPlanPackagePurchases
			,CAST(0 AS INTEGER) als_advice_estate_planning
			,CAST(0 AS INTEGER) als_doc_review_app_us_citizenship
			,CAST(0 AS INTEGER) als_doc_review_commercial_lease_agreement
			,CAST(0 AS INTEGER) als_doc_review_consulting_agreement
			,CAST(0 AS INTEGER) als_doc_review_eviction_notice
			,CAST(0 AS INTEGER) als_doc_review_last_will_and_testament
			,CAST(0 AS INTEGER) als_doc_review_lease_notice
			,CAST(0 AS INTEGER) als_doc_review_living_trust
			,CAST(0 AS INTEGER) als_doc_review_living_will
			,CAST(0 AS INTEGER) als_doc_review_power_of_attorney
			,CAST(0 AS INTEGER) als_doc_review_residential_lease_agreement
			,CAST(0 AS INTEGER) als_doc_review_residential_purchase_and_sale_agreement
			,CAST(0 AS INTEGER) als_doc_review_termination_letter
			,CAST(0 AS INTEGER) als_doc_review_employment_offer_letter
			,CAST(0 AS INTEGER) als_offline_family_green_card
			,CAST(0 AS INTEGER) als_offline_create_a_commercial_lease_agreement
			,CAST(0 AS INTEGER) als_offline_create_a_last_will_individual
			,CAST(0 AS INTEGER) als_offline_create_a_lease_notice
			,CAST(0 AS INTEGER) als_offline_create_a_living_trust_individual
			,CAST(0 AS INTEGER) als_offline_create_a_living_trust_bundle_couple
			,CAST(0 AS INTEGER) als_offline_create_a_living_will
			,CAST(0 AS INTEGER) als_offline_create_a_power_of_attorney_individual
			,CAST(0 AS INTEGER) als_offline_create_a_residential_lease_agreement
			,CAST(0 AS INTEGER) als_offline_create_an_estate_plan_bundle_couple
			,CAST(0 AS INTEGER) als_offline_create_an_estate_plan_bundle_individual
			,CAST(0 AS INTEGER) als_offline_create_an_eviction_notice
                       FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2014-02-09'),TIMESTAMP('2014-05-26'))
                       WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER)

                       GROUP BY 1,2  )