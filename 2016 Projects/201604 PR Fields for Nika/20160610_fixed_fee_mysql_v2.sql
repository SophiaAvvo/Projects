SELECT b.professional_id
,c.Contingency_Fee_Type
,h.Hourly_Fee_Type
FROM professional_billing b
LEFT JOIN (
select b.professional_id
,CONCAT(t.name, ": ", a.name) AS Contingency_Fee_Type
-- ,NULL AS Hourly_Fee_Type
from professional_billing b 
join professional_billing_type bt 
on b.professional_id = bt.professional_id
join acceptance_type a
ON a.id = b.fixed_acceptance_type_id
JOIN billing_type t
ON t.id = bt.billing_type_id
where b.fixed_acceptance_type_id is not null
-- AND b.professional_id < 10000
AND t.id = 4) c
ON c.professional_Id = b.professional_id
LEFT JOIN (
select b.professional_id
,CONCAT(t.name, ": ", a.name) AS Hourly_Fee_Type
-- ,NULL AS Contingency_Fee_Type
from professional_billing b 
join professional_billing_type bt 
on b.professional_id = bt.professional_id
join acceptance_type a
ON a.id = b.fixed_acceptance_type_id
JOIN billing_type t
ON t.id = bt.billing_type_id
where b.fixed_acceptance_type_id is not null
-- AND b.professional_id < 10000
AND t.id = 2 -- contingency; hourly is 2

) h
ON h.professional_id = b.professional_id
-- ORDER BY b.professional_id