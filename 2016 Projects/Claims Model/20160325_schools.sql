SELECT *
    ,CASE
        WHEN (LOWER(degree_level_name) LIKE '%JD%' 
        OR LOWER(degree_level_name) LIKE '%juris%' 
        OR LOWER(degree_area_name) LIKE '%juris%' 
        OR LOWER(degree_area_name) LIKE '%JD%'
        OR LOWER(school_name) LIKE '%law%'
            THEN CASE
                     WHEN LOWER(school_name) LIKE '%stanford%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%yale%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%harvard%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%cambridge%'
                         THEN 1      
                     WHEN LOWER(school_name) LIKE '%of chicago%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%oxford%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%columbia%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%new york university%'
                         THEN 1         
                     WHEN LOWER(school_name) LIKE '%berkeley%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%of michigan%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%of pennsylvania%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%duke%'
                         THEN 1      
                     WHEN LOWER(school_name) LIKE '%london school%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%of virginia%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%of melbourne%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%cornell%'
                         THEN 1               
                     WHEN LOWER(school_name) LIKE '%northwestern%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%georgetown%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%university college london%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%of sydney%'
                         THEN 1      
                     WHEN LOWER(school_name) LIKE '%of singapore%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%of texas%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%columbia%'
                         THEN 1
                     WHEN LOWER(school_name) LIKE '%new york university%'
                         THEN 1                  
FROM src.barrister_professional_school_version s
LIMIT 10;
