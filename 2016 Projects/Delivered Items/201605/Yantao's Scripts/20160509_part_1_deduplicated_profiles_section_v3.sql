WITH deduped_pfad AS
(
SELECT pfad.PROFESSIONAL_ID
         ,pfad.is_claim
         ,pfad.claim_date
		 ,pfad.reference_date_prior_day
		 ,pfad.reference_date_prior_month
		 ,pfad.reference_datetime_prior_day
		 ,pfad.reference_datetime_prior_month
         ,pfad.claim_method
         ,pfad.domain
         ,pfad.emaildomain
         ,pfad.emailsuffix
		 ,pfad.HighScoreEmailDomain
         ,pfad.county
		 ,pfad.license_state
         ,pfad.state
         ,pfad.firstname
         ,pfad.lastname
         ,pfad.middlename
         ,pfad.suffix
         ,pfad.phone1
         ,pfad.phone2
         ,pfad.phone3
         ,pfad.email
         ,pfad.prof_name AS professional_name
         ,pfad.ind_name AS industry_name
         ,pfad.country AS country

         ,CASE
           WHEN pfad.HasEmail = 1 THEN 'Ok Email'
           ELSE 'Bad Email'
         END Email_Status
         ,CASE
           WHEN pfad.HasPhone1 + pfad.HasPhone2 + pfad.HasPhone3 = 0 THEN 'Bad Phone'
           ELSE 'Ok Phone'
         END AS Phone_Status
         ,IsFlaggedTitle
		 ,InstitutionalEmailFlag
		 ,InstitutionalEmailType
  FROM (SELECT pd.*
              ,CASE
                 WHEN pd.phone1 IS NOT NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.phone1,pd.email,pd.lastname,pd.firstname,pd.state ORDER BY pd.is_claim DESC, pd.phone1 DESC,pd.email DESC,phone2 DESC,phone3 DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NonNullPhone1Check
               ,CASE
                 WHEN pd.phone1 IS NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.email,pd.firstname,pd.lastname,pd.state ORDER BY pd.is_claim DESC, pd.email DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NullPhone1Check
               ,CASE
                 WHEN pd.email IS NOT NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.email,pd.phone1,pd.lastname,pd.firstname,pd.state ORDER BY pd.is_claim DESC, pd.phone1 DESC,pd.email DESC,phone2 DESC,phone3 DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NonNullEmailCheck
               ,CASE
                 WHEN pd.email IS NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.phone1,pd.firstname,pd.lastname,pd.state ORDER BY pd.is_claim DESC, pd.phone1 DESC,phone2 DESC,phone3 DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NullEmailCheck
               ,CASE
                 WHEN pd.email IS NULL AND pd.phone1 IS NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.lastname,pd.firstname,pd.state ORDER BY pd.is_claim DESC, pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS DoubleNullCheck 
               ,CASE
                 WHEN pd.email IS NULL THEN 0
                 ELSE 1
               END AS HasEmail
               ,CASE
                 WHEN pd.phone1 IS NULL THEN 0
                 ELSE 1
               END AS HasPhone1
               ,CASE
                 WHEN pd.phone2 IS NULL THEN 0
                 ELSE 1
               END AS HasPhone2
               ,CASE
                 WHEN pd.county IS NULL THEN 0
                 ELSE 1
               END AS HasCounty
               ,CASE
                 WHEN pd.phone3 IS NULL THEN 0
                 ELSE 1
               END AS HasPhone3
               ,CASE
                 WHEN pd.MiddleInitial IS NULL THEN 0
                 ELSE 1
               END AS HasMiddleInitial
			                  ,CASE
                 WHEN (SUBSTR (UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3) IN ('.EDU','.GOV','.ORG', '.MIL')) THEN 1
                 WHEN INSTR(LOWER(pd.emaildomain), '.gov') > 0
                    THEN 1        
                 WHEN INSTR(LOWER(pd.emaildomain), '.org') > 0
                    THEN 1
                 WHEN INSTR(LOWER(pd.emaildomain), '.edu') > 0
                    THEN 1
                 WHEN INSTR(LOWER(pd.emaildomain), '.mil') > 0
                    THEN 1        
                 WHEN INSTR(LOWER(pd.emaildomain), '.co.us') > 0
                    THEN 1
                 WHEN INSTR(LOWER(pd.emaildomain), 'courts.') > 0
                    THEN 1
                 WHEN INSTR(LOWER(pd.emaildomain), '.state') > 0
                    THEN 1
                 WHEN STRLEFT(LOWER(pd.emaildomain), 3) = 'co.'
                 AND STRRIGHT(LOWER(pd.emaildomain), 3) = '.us'
                    THEN 1
                 WHEN INSTR(LOWER(pd.emaildomain), 'prosecutor') > 0 
                 AND INSTR(LOWER(pd.emaildomain), 'county') > 0
                    THEN 1
                 ELSE 0
               END AS InstitutionalEmailFlag
			   ,CASE
                 WHEN (SUBSTR (UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3) = '.EDU')
					THEN 'School'
				WHEN (SUBSTR (UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3) = '.GOV')
					THEN 'Government'
				WHEN (SUBSTR (UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3) = '.ORG')
					THEN 'Nonprofit'
				WHEN (SUBSTR (UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3) = '.MIL')
					THEN 'Military'					
                 WHEN INSTR(LOWER(pd.emaildomain), '.gov') > 0
                    THEN 'Government'        
                 WHEN INSTR(LOWER(pd.emaildomain), '.org') > 0
                    THEN 'Nonprofit'
                 WHEN INSTR(LOWER(pd.emaildomain), '.edu') > 0
                    THEN 'School'
                 WHEN INSTR(LOWER(pd.emaildomain), '.mil') > 0
                    THEN 'Military' 
                 WHEN INSTR(LOWER(pd.emaildomain), '.co.us') > 0
                    THEN 'Government'
                 WHEN INSTR(LOWER(pd.emaildomain), 'courts.') > 0
                    THEN 'Government'
                 WHEN INSTR(LOWER(pd.emaildomain), '.state') > 0
                    THEN 'Government'
                 WHEN STRLEFT(LOWER(pd.emaildomain), 3) = 'co.'
                 AND STRRIGHT(LOWER(pd.emaildomain), 3) = '.us'
                    THEN 'Government'
                 WHEN INSTR(LOWER(pd.emaildomain), 'prosecutor') > 0 
                 AND INSTR(LOWER(pd.emaildomain), 'county') > 0
                    THEN 'Government'
                 ELSE 'Unidentified/Other'
               END AS InstitutionalEmailType
               ,(SUBSTR(UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3)) EmailSuffix
			   ,CASE
					  WHEN LOWER(pd.emaildomain) IN ('gmail.com', 'yahoo.com', 'aol.com', 'msn.com', 'hotmail.com')
						THEN 1
					  ELSE 0
					END HighScoreEmailDomain
        FROM (SELECT pf.PROFESSIONAL_ID
                     ,pf.professional_claim_method_name claim_method
                     ,CASE
                       WHEN pf.PROFESSIONAL_CLAIM_DATE IS NULL THEN 0
                       ELSE 1
                     END AS is_claim
                     ,pf.professional_claim_date claim_date
					 ,CASE
						WHEN pf.professional_claim_date IS NULL
							then from_unixtime(unix_timestamp(now() - interval 1 days), 'yyyy-MM-dd HH:mm:ss')
						ELSE from_unixtime(unix_timestamp(cast(professional_claim_date as timestamp) - interval 1 days), 'yyyy-MM-dd HH:mm:ss') 
						END AS reference_datetime_prior_day
					,CASE
						WHEN pf.professional_claim_date IS NULL
							then from_unixtime(unix_timestamp(now() - interval 31 days), 'yyyy-MM-dd HH:mm:ss')
						ELSE from_unixtime(unix_timestamp(cast(professional_claim_date as timestamp) - interval 31 days), 'yyyy-MM-dd HH:mm:ss') 
						END AS reference_datetime_prior_month
					 ,CASE
						WHEN pf.professional_claim_date IS NULL
							then from_unixtime(unix_timestamp(now() - interval 1 days), 'yyyy-MM-dd')
						ELSE from_unixtime(unix_timestamp(cast(professional_claim_date as timestamp) - interval 1 days), 'yyyy-MM-dd') 
						END AS reference_date_prior_day
					 ,CASE
						WHEN pf.professional_claim_date IS NULL
							then from_unixtime(unix_timestamp(now() - interval 31 days), 'yyyy-MM-dd')
						ELSE from_unixtime(unix_timestamp(cast(professional_claim_date as timestamp) - interval 31 days), 'yyyy-MM-dd') 
						END AS reference_date_prior_month
                    ,CASE   
					   WHEN pf.PROFESSIONAL_COUNTY_NAME_1 = 'NOT APPLICABLE'
              THEN NULL
                       ELSE LOWER(TRIM(pf.PROFESSIONAL_COUNTY_NAME_1))
                     END county
                     ,CASE
                       WHEN pf.PROFESSIONAL_STATE_NAME_1 = 'NOT APPLICABLE'
              THEN NULL
                       ELSE LOWER(TRIM(pf.PROFESSIONAL_STATE_NAME_1))
                     END state
                     ,CASE
                       WHEN pf.PROFESSIONAL_CITY_NAME_1 = 'NOT APPLICABLE' THEN NULL
                       ELSE LOWER(TRIM(pf.PROFESSIONAL_CITY_NAME_1))
                     END city
                     ,PROFESSIONAL_PREFIX
                     ,PROFESSIONAL_FIRST_NAME AS FirstName
                     ,PROFESSIONAL_LAST_NAME AS LastName
                     ,PROFESSIONAL_MIDDLE_NAME AS MiddleName
                     ,PROFESSIONAL_SUFFIX AS Suffix
                     ,CASE
                       WHEN PROFESSIONAL_PHONE_NUMBER_1 LIKE '%Not%'
              THEN NULL
                       WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_1) < 10
              THEN NULL
                       ELSE PROFESSIONAL_PHONE_NUMBER_1
                     END AS phone1
                     ,CASE
                       WHEN PROFESSIONAL_PHONE_NUMBER_2 LIKE '%Not%' THEN NULL
                       WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_2) < 10 THEN NULL
                       WHEN PROFESSIONAL_PHONE_NUMBER_2 = PROFESSIONAL_PHONE_NUMBER_1
              THEN NULL
                       ELSE PROFESSIONAL_PHONE_NUMBER_2
                     END AS phone2
                     ,CASE
                       WHEN PROFESSIONAL_PHONE_NUMBER_3 LIKE '%Not%' THEN NULL
                       WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_3) < 10 THEN NULL
                       WHEN PROFESSIONAL_PHONE_NUMBER_3 = PROFESSIONAL_PHONE_NUMBER_1
              THEN NULL
                       WHEN PROFESSIONAL_PHONE_NUMBER_3 = PROFESSIONAL_PHONE_NUMBER_2
              THEN NULL
                       ELSE PROFESSIONAL_PHONE_NUMBER_3
                     END AS phone3
                     ,CASE
                       WHEN LTRIM (LOWER(PROFESSIONAL_EMAIL_ADDRESS_NAME)) LIKE 'info@%' THEN NULL
                       WHEN LTRIM (LOWER(PROFESSIONAL_EMAIL_ADDRESS_NAME)) LIKE 'contactus@%' THEN NULL
                       WHEN PROFESSIONAL_EMAIL_ADDRESS_NAME = ' ' THEN NULL
                       WHEN PROFESSIONAL_EMAIL_ADDRESS_NAME = 'Null' THEN NULL
                       ELSE PROFESSIONAL_EMAIL_ADDRESS_NAME
                     END AS email
                     ,LENGTH(TRIM(PROFESSIONAL_MIDDLE_NAME)) AS MiddleNameLength
                     ,pf.PROFESSIONAL_AVVO_RATING AS rating
                     /*,concat(PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME) AS LawyerName

                     ,CASE
                       WHEN PROFESSIONAL_PREFIX IS NULL AND PROFESSIONAL_SUFFIX IS NULL AND PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_PREFIX IS NULL AND PROFESSIONAL_SUFFIX IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_PREFIX IS NULL AND PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                       WHEN PROFESSIONAL_PREFIX IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                       WHEN PROFESSIONAL_SUFFIX IS NULL AND PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_SUFFIX IS NULL THEN concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                       ELSE concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                     END AS LawyerName_Full */
                     ,CASE
                       WHEN LOWER(PROFESSIONAL_PREFIX) IN ('chiefjustice','col','col.','colonel','hon','hon.','honorable','maj','maj.','maj. gen.','major','mr. judge','mr. justice','the honorable') THEN 1
                       WHEN professional_prefix IS NULL THEN 0
                       ELSE 0
                     END AS IsFlaggedTitle
                     ,SUBSTR(TRIM(PROFESSIONAL_MIDDLE_NAME),1,1) MiddleInitial
                     ,pf.PROFESSIONAL_NAME AS prof_name
                     ,pf.INDUSTRY_NAME AS ind_name
                     ,pf.PROFESSIONAL_COUNTRY_NAME_1 AS country
                     ,substr(pf.professional_email_address_name,instr (professional_email_address_name,'@') +1) AS emaildomain
                     ,CASE
                       WHEN (parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST') IS NULL AND instr (pf.PROFESSIONAL_WEBSITE_URL,'http:') = 1) THEN pf.PROFESSIONAL_WEBSITE_URL
                       WHEN (parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST') IS NULL AND instr (pf.PROFESSIONAL_WEBSITE_URL,'http:') = 0) THEN substr (pf.PROFESSIONAL_WEBSITE_URL,instr (pf.PROFESSIONAL_WEBSITE_URL,'www.') +1)
                       WHEN (parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST') IS NOT NULL AND instr (pf.PROFESSIONAL_WEBSITE_URL,'www') = 0) THEN parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST')
                       ELSE substr (parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST'),instr (pf.PROFESSIONAL_WEBSITE_URL,'www.') -3)
                     END AS DOMAIN
					 ,COALESCE(pf.professional_license_state_name_1, pf.professional_license_state_name_2, pf.professional_license_state_name_3) license_state
              FROM DM.PROFESSIONAL_DIMENSION pf
              WHERE pf.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'
              AND   pf.PROFESSIONAL_PRACTICE_INDICATOR = 'Practicing'
              /*AND   (CASE WHEN pf.PROFESSIONAL_STATE_NAME_1 IS NULL THEN 1 ELSE 0 END) = 0
              AND   (CASE WHEN PROFESSIONAL_FIRST_NAME IS NULL THEN 1 ELSE 0 END) = 0
              AND   (CASE WHEN PROFESSIONAL_LAST_NAME IS NULL THEN 1 ELSE 0 END) = 0 */
              AND   pf.PROFESSIONAL_NAME = 'lawyer'
              AND   pf.INDUSTRY_NAME = 'Legal'
			  --- AND pf.professional_id < 1000
             ) pd
             
    ) pfad
    JOIN SRC.barrister_professional_status ps 
         ON ps.professional_id = pfad.PROFESSIONAL_ID
		   AND ps.DECEASED = 'N'
		  AND   ps.JUDGE = 'N'
		  AND   ps.RETIRED = 'N'
		  AND   ps.OFFICIAL = 'N'
		  AND   ps.UNVERIFIED = 'N'
		  AND   ps.SANCTIONED = 'N'
		  AND   pfad.NonNullPhone1Check + pfad.NullPhone1Check + pfad.NonNullEmailCheck + pfad.NullEmailCheck + pfad.DoubleNullCheck = 5

)
,

license AS (

SELECT bl.professional_id
  ,MIN(license_date) FirstLicenseDate
  ,MAX(license_date) LastLicenseDate
  ,COUNT(id) licensecount
FROM src.barrister_license bl
	JOIN deduped_pfad p
		ON p.professional_id = bl.professional_id
		AND bl.license_date <= p.reference_datetime_prior_day

GROUP BY bl.professional_id

)

SELECT pf.*
,ed.EmailDomainSize
       ,lc.FirstLicenseDate
       ,lc.LastLicenseDate
       ,lc.licensecount
FROM deduped_pfad pf
  LEFT JOIN (SELECT pf.emaildomain
              ,COUNT(DISTINCT pf.professional_id) EmailDomainSize
              FROM deduped_pfad pf
              GROUP BY pf.emaildomain) ed
		ON pf.emaildomain = ed.emaildomain	  
  LEFT JOIN license lc
    ON lc.professional_id = pf.professional_id
WHERE (lc.lastlicensedate >= '1943-01-01' OR lc.lastlicensedate IS NULL) 	
	