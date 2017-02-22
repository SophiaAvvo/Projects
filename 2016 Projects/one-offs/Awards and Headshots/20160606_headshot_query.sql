select m.professional_id
,CASE
WHEN pd.professional_claim_date IS NULL
THEN 'Not Claimed'
ELSE 'Claimed'
END Claim_Status
,pd.professional_practice_indicator
,min(to_date(m.created_at)) as headshot_date
from src.barrister_professional_media m
JOIN dm.professional_dimension pd
ON pd.professional_Id = m.professional_id
where media_use_type_id = 1 -- headshot
AND pd.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'
			  AND pd.PROFESSIONAL_NAME = 'lawyer'
              AND   pd.INDUSTRY_NAME = 'Legal'
and m.record_flag <> 'I' -- not deleted
group by 1,2,3
