select *
from professional_billing b 
join professional_billing_type bt 
on b.professional_id = bt.professional_id
join acceptance_type a

ON a.id = b.fixed_acceptance_type_id
JOIN billing_type t
ON t.id = bt.billing_type_id
where b.fixed_acceptance_type_id is not null

AND b.professional_id < 10000
ORDER BY b.professional_id

