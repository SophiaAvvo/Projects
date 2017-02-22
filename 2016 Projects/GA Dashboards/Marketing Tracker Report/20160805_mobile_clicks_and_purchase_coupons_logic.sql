SELECT COUNT(totals.visits) Sessions
 ,SUM(CASE
                                WHEN LOWER(hits.transaction.transactionCoupon) IS NOT NULL
                                  THEN CAST(1 AS INTEGER)
                                ELSE CAST(0 AS INTEGER)
                              END) TotalCouponsUsed
 ,SUM(CASE
                                WHEN LOWER(hits.eventInfo.eventAction) = 'initiate mobile phone'
                                  THEN CAST(1 AS INTEGER)
                                ELSE CAST(0 AS INTEGER)
                              END) MobileClickstoCall	
FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-07-03'),TIMESTAMP('2016-07-09'))
WHERE (CASE WHEN LOWER(trafficSource.campaign) CONTAINS 'network' OR LOWER(trafficSource.campaign) CONTAINS 'sgt' THEN CAST(1 AS INTEGER) ELSE CAST(0 AS INTEGER) END) = CAST(0 AS INTEGER)