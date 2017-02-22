select dd.actual_date AS event_date
,Channel
                    ,COUNT(ci.call_id) OVER(PARTITION BY dd.rpt_wk_begin_date, Channel) Total_Phone_Contacts_Weekly
                    ,COUNT(ci.call_id) OVER(PARTITION BY ci.event_date, Channel) Total_Phone_Contacts_Daily
					,COUNT(ci.call_id) OVER(PARTITION BY dd.qtr_nbr_in_year, dd.rpt_year, Channel) Total_Phone_Contacts_Quarterly
from dm.date_dim dd
LEFT JOIN src.contact_impression ci
	ON dd.actual_date = ci.event_date
	AND ci.contact_type = 'phone'
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


