WITH company AS (SELECT c.professional_id
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
,ROW_NUMBER() OVER(PARTITION BY c.professional_id ORDER BY c.start_date) Num
FROM src.barrister_professional_company c
WHERE c.end_date IS NULL )

SELECT c.professional_id
,c.company_name AS company_name_1
,c.start_date AS start_date_1
,c.position_name AS position_name_1
,c.title_name AS title_name_1
,c.company_size AS company_size_1
,c2.company_name AS company_name_2
,c2.start_date AS start_date_2
,c2.position_name AS position_name_2
,c2.title_name AS title_name_2
,c2.company_size AS company_size_2
,c3.company_name AS company_name_3
,c3.start_date AS start_date_3
,c3.position_name AS position_name_3
,c3.title_name AS title_name_3
,c3.company_size AS company_size_3
FROM company c
LEFT JOIN company c2
ON c2.professional_id = c.professional_id
AND c2.Num = 2
LEFT JOIN company c3
ON c3.professional_id = c.professional_id
AND c3.Num = 2
WHERE c.Num = 1