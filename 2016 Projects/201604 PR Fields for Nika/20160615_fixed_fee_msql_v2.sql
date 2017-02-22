select b.*
,a.*
,CASE WHEN a.symbolic_name IN ('ALWAYS', 'SOMETIMES')
      THEN 'Y'
      WHEN a.symbolic_name = 'NEVER'
      THEN 'N'
      ELSE 'Unknown'
      END AS Accepts_Fixed_Fee
-- ,NULL AS Contingency_Fee_Type
from professional_billing b 
LEFT join professional_billing_type bt 
on b.professional_id = bt.professional_id
LEFT join acceptance_type a
ON a.id = b.fixed_acceptance_type_id

where b.fixed_acceptance_type_id is not null
-- AND b.professional_id < 10000
-- AND t.id IS NULL