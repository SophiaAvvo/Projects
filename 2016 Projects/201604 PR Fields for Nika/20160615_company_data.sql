SELECT *
FROM professional_company p
LEFT JOIN company c
ON p.company_id = c.id
-- WHERE company_size_id <> 1
LIMIT 100;