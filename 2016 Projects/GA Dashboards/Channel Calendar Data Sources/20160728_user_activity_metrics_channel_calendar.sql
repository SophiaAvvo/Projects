SELECT *
,CASE
        WHEN dayofweek(now()) = 1
        AND DATEDIFF(to_date(now()), d.actual_date) < 1
          THEN 'Exclude'
        WHEN dayofweek(now()) = 2
        AND DATEDIFF(to_date(now()), d.actual_date) < 2
          THEN 'Exclude'
        WHEN dayofweek(now()) = 3
        AND DATEDIFF(to_date(now()), d.actual_date) < 3
          THEN 'Exclude'
        WHEN dayofweek(now()) = 4
        AND DATEDIFF(to_date(now()), d.actual_date) < 4
          THEN 'Exclude'
        WHEN dayofweek(now()) = 5
        AND DATEDIFF(to_date(now()), d.actual_date) < 5
          THEN 'Exclude'
        WHEN dayofweek(now()) = 6
        AND DATEDIFF(to_date(now()), d.actual_date) < 6
          THEN 'Exclude' 
        WHEN dayofweek(now()) = 7
        AND DATEDIFF(to_date(now()), d.actual_date) < 7
          THEN 'Exclude'   
        ELSE 'Include'
        END CurrentWeekFilter
,CASE
            WHEN ch.Channel = 'Organic Search'
                THEN 1
            WHEN ch.Channel = 'Direct'
                THEN 2
            WHEN ch.Channel = 'Email'
                THEN 3
            WHEN ch.Channel = 'Social'
                THEN 4
            WHEN ch.Channel = 'Referral'
                THEN 5
            WHEN ch.Channel = 'Paid Search - Marketing'
                THEN 6
            WHEN ch.Channel = 'Digital Brand'
                THEN 7
            WHEN ch.Channel = '(Other)'
                THEN 8
            WHEN ch.Channel = 'Affiliates'
                THEN 9
            WHEN ch.Channel = 'Paid Search - AMM'
                THEN 10
            WHEN ch.Channel = 'Display - AMM'
                THEN 11
            WHEN ch.Channel = 'Other Paid Marketing'
                THEN 12
            ELSE 13
            END ChannelSortOrder
FROM dm.date_dim d
CROSS JOIN (SELECT '(Other)' AS Channel

            UNION 

            SELECT 'Affiliates'

            UNION 

            SELECT 'Direct'

            UNION

            SELECT 'Email'

            UNION 

            SELECT 'Organic Search'

            UNION 

            SELECT 'Paid Search - Marketing'

            UNION 
            
            SELECT 'Paid Search - AMM'

            UNION

            SELECT 'Other Paid Marketing'

            UNION 
            
            SELECT 'Display - AMM'

            UNION

            SELECT 'Referral'

            UNION 

            SELECT 'Social'

            UNION

            SELECT 'Digital Brand') ch
WHERE actual_date >= '2014-01-01' 
AND actual_date < to_date(now())