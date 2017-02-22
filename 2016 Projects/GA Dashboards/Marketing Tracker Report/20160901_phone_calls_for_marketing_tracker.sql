select ci.event_date
                    ,COUNT(DISTINCT ci.caller) Daily_Phone_Contacts               
from src.contact_impression ci
WHERE ci.event_date >= '2014-01-01'
                AND ci.contact_type = 'phone'
                GROUP BY 1
