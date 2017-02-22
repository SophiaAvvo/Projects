select ci.event_date
,'(Other)' AS Channel
                    ,COUNT(ci.caller)/11.0 Daily_Normalized_Phone_Contacts
                    ,COUNT(ci.caller) Daily_Total_Phone_Contacts
from src.contact_impression ci
WHERE ci.event_date >= '2016-01-01'
                AND ci.contact_type = 'phone'
                GROUP BY 1

UNION

select ci.event_date
,'Affiliates'
                    ,COUNT(ci.caller)/11.0 Daily_Normalized_Phone_Contacts
                    ,COUNT(ci.caller) Daily_Total_Phone_Contacts
from src.contact_impression ci
WHERE ci.event_date >= '2016-01-01'
                AND ci.contact_type = 'phone'
                GROUP BY 1

UNION

select ci.event_date
,'Digital Brand'
                    ,COUNT(ci.caller)/11.0 Daily_Normalized_Phone_Contacts
                    ,COUNT(ci.caller) Daily_Total_Phone_Contacts
from src.contact_impression ci
WHERE ci.event_date >= '2016-01-01'
                AND ci.contact_type = 'phone'
                GROUP BY 1

UNION

select ci.event_date
,'Direct'
                    ,COUNT(ci.caller)/11.0 Daily_Normalized_Phone_Contacts
                    ,COUNT(ci.caller) Daily_Total_Phone_Contacts
from src.contact_impression ci
WHERE ci.event_date >= '2016-01-01'
                AND ci.contact_type = 'phone'
                GROUP BY 1

UNION

select ci.event_date
,'Email'
                    ,COUNT(ci.caller)/11.0 Daily_Normalized_Phone_Contacts
                    ,COUNT(ci.caller) Daily_Total_Phone_Contacts
from src.contact_impression ci
WHERE ci.event_date >= '2016-01-01'
                AND ci.contact_type = 'phone'
                GROUP BY 1

UNION

select ci.event_date
,'Organic Search'
                    ,COUNT(ci.caller)/11.0 Daily_Normalized_Phone_Contacts
                    ,COUNT(ci.caller) Daily_Total_Phone_Contacts
from src.contact_impression ci
WHERE ci.event_date >= '2016-01-01'
                AND ci.contact_type = 'phone'
                GROUP BY 1

UNION

select ci.event_date
,'Other Paid Marketing'
                    ,COUNT(ci.caller)/11.0 Daily_Normalized_Phone_Contacts
                    ,COUNT(ci.caller) Daily_Total_Phone_Contacts
from src.contact_impression ci
WHERE ci.event_date >= '2016-01-01'
                AND ci.contact_type = 'phone'
                GROUP BY 1

UNION

select ci.event_date
,'Paid Search - Marketing'
                    ,COUNT(ci.caller)/11.0 Daily_Normalized_Phone_Contacts
                    ,COUNT(ci.caller) Daily_Total_Phone_Contacts
from src.contact_impression ci
WHERE ci.event_date >= '2016-01-01'
                AND ci.contact_type = 'phone'
                GROUP BY 1

UNION 

select ci.event_date
,'Paid Search - AMM'
                    ,COUNT(ci.caller)/11.0 Daily_Normalized_Phone_Contacts
                    ,COUNT(ci.caller) Daily_Total_Phone_Contacts
from src.contact_impression ci
WHERE ci.event_date >= '2016-01-01'
                AND ci.contact_type = 'phone'
                GROUP BY 1

UNION

select ci.event_date
,'Referral'
                    ,COUNT(ci.caller)/11.0 Daily_Normalized_Phone_Contacts
                    ,COUNT(ci.caller) Daily_Total_Phone_Contacts
from src.contact_impression ci
WHERE ci.event_date >= '2016-01-01'
                AND ci.contact_type = 'phone'
                GROUP BY 1

UNION

select ci.event_date
,'Social'
                    ,COUNT(ci.caller)/11.0 Daily_Normalized_Phone_Contacts
                    ,COUNT(ci.caller) Daily_Total_Phone_Contacts
from src.contact_impression ci
WHERE ci.event_date >= '2016-01-01'
                AND ci.contact_type = 'phone'
                GROUP BY 1