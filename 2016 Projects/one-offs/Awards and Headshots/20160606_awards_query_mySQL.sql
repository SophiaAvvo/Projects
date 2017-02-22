select pa.professional_id
,CASE
  WHEN pnp.professional_id IS NOT NULL
    THEN r.name
  ELSE 'Practicing'
  END Practice_Status
,CASE
  WHEN p.claimed_at IS NULL
    THEN 'Not Claimed'
  ELSE 'Claimed'
  END Claim_Status
,CASE
  WHEN a.scoring_weight > 0
    THEN 'Has Scoring Weight'
    ELSE 'No Scoring Weight'
 END Scoring_Weight
, count(a.id) as num_awards
from professional_award pa 
JOIN professional p
ON p.id = pa.professional_id
left join award a on a.id = pa.award_id
LEFT JOIN barrister.professional_not_practicing pnp
ON pnp.professional_id = pa.professional_id
LEFT JOIN barrister.not_practicing_reason r
ON r.id = pnp.not_practicing_reason_id
-- where a.scoring_weight >0
group by pa.professional_id
,CASE
  WHEN pnp.professional_id IS NOT NULL
    THEN r.name
  ELSE 'Practicing'
  END
,CASE
  WHEN p.claimed_at IS NULL
    THEN 'Not Claimed'
  ELSE 'Claimed'
  END 