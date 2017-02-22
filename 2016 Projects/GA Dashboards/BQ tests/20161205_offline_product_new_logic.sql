SELECT hits.product.v2ProductName
  ,SUM(CASE 
          WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
          THEN CASE
                WHEN hits.product.v2ProductName IS NULL THEN 0
                  WHEN hits.product.v2ProductName = 'display ad' THEN 0
                  WHEN hits.product.v2ProductName = 'sponsored listing' THEN 0
                  WHEN hits.product.v2ProductName = '(not set)' THEN 0
                  WHEN hits.product.v2ProductName CONTAINS 'advice' THEN 0
                  WHEN hits.product.v2ProductName CONTAINS 'review' THEN 0
                  ELSE hits.product.ProductQuantity
                  END
           ELSE 0
           END) AS Offline_Sum
  ,EXACT_COUNT_DISTINCT(CASE 
            WHEN hits.eventInfo.eventAction = 'purchase avvo legal service'
              THEN CASE
                  WHEN hits.product.v2ProductName IS NULL THEN NULL
                  WHEN hits.product.v2ProductName = 'display ad' THEN NULL
                  WHEN hits.product.v2ProductName = 'sponsored listing' THEN NULL
                  WHEN hits.product.v2ProductName = '(not set)' THEN NULL
                  WHEN hits.product.v2ProductName CONTAINS 'advice' THEN NULL
                  WHEN hits.product.v2ProductName CONTAINS 'review' THEN NULL
                  ELSE hits.transaction.transactionid
                  END
               ELSE NULL
              END) AS Offline_Count_T
        FROM TABLE_DATE_RANGE ([75615261.ga_sessions_], TIMESTAMP('2016-11-20'),TIMESTAMP('2016-11-26'))
        GROUP BY 1
        ORDER BY 1