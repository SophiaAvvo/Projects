SELECT pf.professional_id
,c.company_name
,c.start_date
,c.position_name
,c.title_name
,CASE
WHEN c.company_size_id = 1
THEN 'Unknown'
WHEN c.company_size_id = 2
THEN '1-10'
WHEN c.company_size_id = 3
THEN '11-50'
WHEN c.company_size_id = 4
THEN '51-100'
WHEN c.company_size_id = 5
THEN '101-500'
WHEN c.company_size_id = 6
THEN '501-1000'
WHEN c.company_size_id = 7
THEN '1001-5000'
WHEN c.company_size_id = 8
THEN '5001-10000'
WHEN c.company_size_id = 9
THEN '10001+'
ELSE CAST(c.company_size_id AS VARCHAR)
END Company_Size
FROM dm.professional_dimension pf
LEFT JOIN src.barrister_professional_company c
ON c.professional_Id = pf.professional_id
AND c.end_date IS NULL
WHERE pf.PROFESSIONAL_PRACTICE_INDICATOR = 'Practicing'
AND pf.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'
			  AND pf.PROFESSIONAL_NAME = 'lawyer'
              AND   pf.INDUSTRY_NAME = 'Legal'
              --AND pf.professional_id = 151-- < 10000
              ORDER BY pf.professional_id