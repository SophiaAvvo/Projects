SELECT y.user_id AS user_id
		,y.traffic_date AS traffic_date
		,y.reg_datetime AS reg_datetime
		,y.reg_date_sec AS reg_date_sec
		,y.day_before_reg_sec
		,y.persistent_session_id AS persistent_session_id
		,y.VisitStartTime AS VisitStartTime
		,y.diff_in_sec AS diff_in_sec
		,x.ChannelDate AS channel_date
		,x.FirstChannel AS first_channel
		,z.geo_type AS geo_type
		,z.postal_code AS postal_code
		,z.geo_latitude AS geo_latitude
		,z.geo_longitude AS geo_longitude
		,z.geo_population AS geo_population
		,z.registration_day AS registration_day
		,z.registration_datetime AS registration_datetime
		,z.has_name AS has_name
		,z.emaildomain AS email_domain
		,z.birthyear AS birth_year
		,z.returnonceflag AS return_once_flag
		,z.returntwiceflag AS return_twice_flag
		,z.lastvisittoregistration AS last_visit_to_registration
		,z.gender AS gender
		,z.state AS state
		,z.county AS county
		,z.city AS city
		,z.income AS income
		,z.children AS children
		,z.maritalstatus AS marital_status
		,z.lawyerconsumertag AS lawyer_consumer_tag
		,z.contactsfilter AS contacts_filter
		,z.actiontype AS action_type
		,z.parentpa AS parent_pa
		,z.firstaction AS first_action
		,z.relativetiming AS relative_timing
		,z.parentpa_group AS parent_pa_group
FROM (
SELECT Date AS ChannelDate
,Channel AS FirstChannel
,persistent_session_id
,VisitStartTime
FROM (
FLATTEN(
(
SELECT VisitStartTime
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
									   OR trafficSource.campaign IN ('brand', 'pls')
									   OR REGEXP_MATCH(trafficSource.campaign, r'(legalqa|plsremarketing|advisorremarketing)')
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
                      ,MAX(IF(hits.customDimensions.index=61,hits.customDimensions.value, NULL)) WITHIN hits as Persistent_Session_ID
                       FROM TABLE_DATE_RANGE([75615261.ga_sessions_], TIMESTAMP('2015-10-18'),CURRENT_TIMESTAMP())
                       
                       )
         , Persistent_Session_ID) 

)

,

(
FLATTEN(
(
SELECT VisitStartTime
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
									   OR trafficSource.campaign IN ('brand', 'pls')
									   OR REGEXP_MATCH(trafficSource.campaign, r'(legalqa|plsremarketing|advisorremarketing)')
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
                      ,MAX(IF(hits.customDimensions.index=61,hits.customDimensions.value, NULL)) WITHIN hits as Persistent_Session_ID
                       FROM TABLE_DATE_RANGE([75615261.ga_sessions_], TIMESTAMP('2014-05-27'),TIMESTAMP('2015-06-06'))
                       
                       )
         , Persistent_Session_ID) 
)

,

(

FLATTEN(
(
SELECT VisitStartTime
                      ,Date
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
									   OR trafficSource.campaign IN ('brand', 'pls')
									   OR REGEXP_MATCH(trafficSource.campaign, r'(legalqa|plsremarketing|advisorremarketing)')
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
                      ,MAX(IF(hits.customDimensions.index=61,hits.customDimensions.value, NULL)) WITHIN hits as Persistent_Session_ID
                       FROM TABLE_DATE_RANGE([75615261.ga_sessions_], TIMESTAMP('2014-02-09'),TIMESTAMP('2014-05-26'))
                       
                       )
         , Persistent_Session_ID) 
		
		)
GROUP BY 1,2,3,4
	)x
		

LEFT JOIN (SELECT user_id
		,traffic_date
		,reg_datetime
		,reg_date_sec
		,day_before_reg_sec
		,persistent_session_id
		,VisitStartTime
		,diff_in_sec
		,FROM Registered_Users_May_2016.windowed_vst_and_pid) y -- 49366 rows
ON y.persistent_session_id = x.persistent_session_id
AND y.VisitStartTime = x.VisitStartTime

JOIN (SELECT user_id
,geo_type
,postal_code
,geo_latitude
,geo_longitude
,geo_population
,registration_day
,registration_datetime
,has_name
,emaildomain
,birthyear
,returnonceflag
,returntwiceflag
,lastvisittoregistration
,gender
,state
,county
,city
,income
,children
,maritalstatus
,lawyerconsumertag
,contactsfilter
,actiontype
,parentpa
,firstaction
,relativetiming
,parentpa_group
FROM Registered_Users_May_2016.user_data_4) z
ON z.user_id = y.user_id

