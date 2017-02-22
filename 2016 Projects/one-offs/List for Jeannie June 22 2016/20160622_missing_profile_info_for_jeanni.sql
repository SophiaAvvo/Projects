WITH temp AS (select distinct p.professional_id
        		, CASE 
					WHEN UPPER(p.professional_address_1_line_1) = 'NOT APPLICABLE'
						THEN NULL
					WHEN p.professional_address_1_line_1 = ''
						THEN NULL
					ELSE p.professional_address_1_line_1
				END address_line_1
        		, CASE 
					WHEN UPPER(p.professional_state_name_1) = 'NOT APPLICABLE'
						THEN NULL
					WHEN p.professional_state_name_1 = ''
						THEN NULL						
					ELSE p.professional_state_name_1
				END AS "state"
        		, CASE 
					WHEN UPPER(p.professional_city_name_1) = 'NOT APPLICABLE'
						THEN NULL
					WHEN p.professional_city_name_1 = ''
						THEN NULL							
					ELSE p.professional_city_name_1
				END city      				
        		, CASE 
					WHEN UPPER(p.professional_postal_code_1) = 'NOT APPLICABLE'
						THEN NULL
					WHEN p.professional_postal_code_1 = ''
						THEN NULL							
					ELSE p.professional_postal_code_1
				END zip
				, p.professional_country_name_1
        		,CASE
                  WHEN p.professional_claim_date IS NULL
					THEN NULL
					WHEN EXTRACT(month FROM p.professional_claim_date) < 10
                    THEN CAST(CONCAT(CAST(EXTRACT(year FROM p.professional_claim_date) AS VARCHAR), '0', CAST(EXTRACT(month FROM p.professional_claim_date) AS VARCHAR)) AS INT)
                    ELSE CAST(CONCAT(CAST(EXTRACT(year FROM p.professional_claim_date) AS VARCHAR), CAST(EXTRACT(month FROM p.professional_claim_date) AS VARCHAR)) AS INT)
                  END ClaimYearMonth
        	from dm.professional_dimension p
        		where p.professional_delete_indicator = 'Not Deleted'
        		and p.professional_practice_indicator = 'Practicing'
        		and p.professional_name = 'lawyer'
        		and p.industry_name = 'Legal'
              )
              
             /* SELECT COUNT(professional_id)
              ,COUNT(CASE WHEN state IS NULL THEN professional_Id ELSE NULL END) missing_state
              ,COUNT(CASE WHEN city IS NULL THEN professional_Id ELSE NULL END) missing_city
              ,COUNT(CASE WHEN address_line_1 IS NULL THEN professional_Id ELSE NULL END) missing_address_line_1
              FROM temp */
              --WHERE state IS NULL


SELECT COUNT(CASE 
				WHEN LOWER(professional_country_name_1) = 'united states' 
					THEN t.professional_id
				ELSE NULL
				END) USAProfiles
	,COUNT(CASE 
				WHEN (LOWER(professional_country_name_1) <> 'united states' OR professional_country_name_1 IS NULL)
					THEN t.professional_id
				ELSE NULL
				END) NonUSAProfiles
	,COUNT(CASE 
				WHEN LOWER(professional_country_name_1) = 'united states'
				AND (city IS NULL OR state IS NULL OR address_line_1 IS NULL)
					THEN t.professional_id
				ELSE NULL
				END) USAProfilesMissingAddress
	,COUNT(CASE 
				WHEN (LOWER(professional_country_name_1) <> 'united states' OR professional_country_name_1 IS NULL)
					THEN t.professional_id
				ELSE NULL
				END) NonUSAProfilesMissingAddress				
FROM temp t
