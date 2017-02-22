select ci.event_date
                    , ci.professional_id
                    ,COUNT(DISTINCT ci.caller) Daily_Phone_Contacts
                    ,COUNT(ci.gmt_timestamp) Total_Daily_Phone_Sessions                  
from src.contact_impression ci
/*JOIN src.barrister_licensing_authority_status st
ON st.id = ci.professional_id
AND st.license_status_type_id = 2 */
WHERE ci.event_date >= '2015-05-01'
                AND ci.contact_type = 'phone'
  -- AND ci.professional_id < 10000
                GROUP BY 1,2
