WITH calls AS (
SELECT event_date
,COUNT(DISTINCT ci.call_id) CallCount
FROM src.contact_impression ci
WHERE ci.event_date >= '2016-01-01'
	AND ci.contact_type = 'phone'
GROUP BY ci.event_date
)
	
select dd.actual_date AS event_date
,Channel
,ci.CallCount AS Total_Phone_Contacts_Daily
                    ,SUM(CallCount) OVER(PARTITION BY dd.rpt_wk_begin_date, Channel) Total_Phone_Contacts_Weekly
					,SUM(CallCount) OVER(PARTITION BY dd.qtr_nbr_in_year, dd.rpt_year, Channel) Total_Phone_Contacts_Quarterly
from dm.date_dim dd
LEFT JOIN calls ci
	ON dd.actual_date = ci.event_date
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
WHERE dd.actual_date >= '2016-01-01' AND dd.actual_date < now()
ORDER BY dd.actual_date, ch.Channel

