SELECT t.* FROM 
(SELECT pd.*
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
               --,SUM(pd.is_claim) OVER(PARTITION BY pd.phone1,pd.email,pd.lastname,pd.firstname,pd.state) HasClaimTwin
        /* If the first/last, middle, state, and county are the same, take out both entities and put on a separate list (filter all values > 1) 
           ,ROW_NUMBER() OVER(PARTITION BY pd.firstname, pd.lastname, pd.MiddleInitial, pd.state, pd.county 
                              ORDER BY pd.professional_id) PoojaTest1 */ /* If the phone, first, last, county, and state are the same, take out both entities and put on a separate list (filter all values > 1) 
           ,ROW_NUMBER() OVER(PARTITION BY pd.phone1, pd.firstname, pd.lastname, pd.state, pd.county
                              ORDER BY pd.professional_id) PoojaTest2 */ /* If the email, first, last, county, and state are the same, take out both entities and put on a separate list (filter all values > 1)     
           ,ROW_NUMBER() OVER(PARTITION BY pd.email, pd.firstname, pd.lastname, pd.state, pd.county
                              ORDER BY pd.professional_id) PoojaTest3 */
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
               ,(SUBSTR(UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3)) EmailSuffix
               -- ,substr(pd.emaildomain,1,LENGTH(pd.emaildomain) - instr (pd.emaildomain,'.')) EmailDomainSubTest2
               -- ,instr(pd.emaildomain,'.') +1 StringTest
               ,CASE
                 WHEN (SUBSTR (UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3) IN ('.EDU','.GOV','.ORG','CO.US')) THEN 1
                 ELSE 0
               END AS LowScoreEmailDomain /*,case 
              ,CASE
                when pd.emaildomain LIKE '%gmail%'
                  then 1
                WHEN 
                  else 0
              end AS HighScoreEmailDomain */
               -- ,LOCATE('.',pd.emaildomain) EmailPeriodPosition
               -- ,SUBSTR(UPPER(pd.emaildomain),LENGTH(pd.emaildomain) - LOCATE ('.',pd.emaildomain)) EmailHostParse
        FROM (SELECT pf.PROFESSIONAL_ID
                     ,pf.professional_claim_method_name claim_method
                     ,CASE
                       WHEN pf.PROFESSIONAL_CLAIM_DATE IS NULL THEN 0
                       ELSE 1
                     END AS is_claim
                     ,pf.professional_claim_date claim_date
                     ,CASE
                       WHEN pf.PROFESSIONAL_COUNTY_NAME_1 = 'NOT APPLICABLE'
              -- get rid of string values in county name 
              THEN NULL
                       ELSE pf.PROFESSIONAL_COUNTY_NAME_1
                     END county
                     ,CASE
                       WHEN pf.PROFESSIONAL_STATE_NAME_1 = 'NOT APPLICABLE'
              -- get rid of string values in state name
              THEN NULL
                       ELSE pf.PROFESSIONAL_STATE_NAME_1
                     END state
                     ,CASE
                       WHEN pf.PROFESSIONAL_CITY_NAME_1 = 'NOT APPLICABLE' THEN NULL
                       ELSE pf.PROFESSIONAL_STATE_NAME_1
                     END city
                     ,PROFESSIONAL_PREFIX
                     ,PROFESSIONAL_FIRST_NAME AS FirstName
                     ,PROFESSIONAL_LAST_NAME AS LastName
                     ,PROFESSIONAL_MIDDLE_NAME AS MiddleName
                     ,PROFESSIONAL_SUFFIX AS Suffix
                     ,CASE
                       WHEN PROFESSIONAL_PHONE_NUMBER_1 LIKE '%Not%'
              -- get rid of string values in phone number 
              THEN NULL
                       WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_1) < 10
              -- get rid of invalid phone numbers 
              THEN NULL
                       ELSE PROFESSIONAL_PHONE_NUMBER_1
                     END AS phone1
                     ,CASE
                       WHEN PROFESSIONAL_PHONE_NUMBER_2 LIKE '%Not%' THEN NULL
                       WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_2) < 10 THEN NULL
                       WHEN PROFESSIONAL_PHONE_NUMBER_2 = PROFESSIONAL_PHONE_NUMBER_1
              -- get rid of duplicate phone numbers 
              THEN NULL
                       ELSE PROFESSIONAL_PHONE_NUMBER_2
                     END AS phone2
                     ,CASE
                       WHEN PROFESSIONAL_PHONE_NUMBER_3 LIKE '%Not%' THEN NULL
                       WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_3) < 10 THEN NULL
                       WHEN PROFESSIONAL_PHONE_NUMBER_3 = PROFESSIONAL_PHONE_NUMBER_1
              -- get rid of duplicate phone numbers 
              THEN NULL
                       WHEN PROFESSIONAL_PHONE_NUMBER_3 = PROFESSIONAL_PHONE_NUMBER_2
              -- get rid of duplicate phone numbers 
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
                     ,pf.PROFESSIONAL_AVVO_RATING AS rating-- invalid string
                     ,concat(PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME) AS LawyerName-- invalid string 
                     -- these are useful to identify lawyers that have prefixes and be unusual or need to be excluded
                     ,CASE
                       WHEN PROFESSIONAL_PREFIX IS NULL AND PROFESSIONAL_SUFFIX IS NULL AND PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_PREFIX IS NULL AND PROFESSIONAL_SUFFIX IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_PREFIX IS NULL AND PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                       WHEN PROFESSIONAL_PREFIX IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                       WHEN PROFESSIONAL_SUFFIX IS NULL AND PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_SUFFIX IS NULL THEN concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                       ELSE concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                     END AS LawyerName_Full
                     ,CASE
                       WHEN PROFESSIONAL_PREFIX IN ('Chiefjustice','Col','Col.','Colonel','Hon','Hon.','Honorable','Maj','Maj.','Maj. Gen.','Major','Mr. Judge','Mr. Justice','The Honorable') THEN 1
                       ELSE 0
                     END AS IsExcludedTitle
                     ,SUBSTR(TRIM(PROFESSIONAL_MIDDLE_NAME),1,1) MiddleInitial
              -- ,pf.PROFESSIONAL_DELETE_INDICATOR  as delete_ind
                     -- ,pf.PROFESSIONAL_PRACTICE_INDICATOR as practice_ind
                     ,pf.PROFESSIONAL_NAME AS prof_name
                     ,pf.INDUSTRY_NAME AS ind_name
                     ,pf.PROFESSIONAL_COUNTRY_NAME_1 AS country
                     ,substr(pf.professional_email_address_name,instr (professional_email_address_name,'@') +1) AS emaildomain-- works!
                     ,CASE
                       WHEN (parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST') IS NULL AND instr (pf.PROFESSIONAL_WEBSITE_URL,'http:') = 1) THEN pf.PROFESSIONAL_WEBSITE_URL
                       WHEN (parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST') IS NULL AND instr (pf.PROFESSIONAL_WEBSITE_URL,'http:') = 0) THEN substr (pf.PROFESSIONAL_WEBSITE_URL,instr (pf.PROFESSIONAL_WEBSITE_URL,'www.') +1)
                       WHEN (parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST') IS NOT NULL AND instr (pf.PROFESSIONAL_WEBSITE_URL,'www') = 0) THEN parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST')
                       ELSE substr (parse_url (pf.PROFESSIONAL_WEBSITE_URL,'HOST'),instr (pf.PROFESSIONAL_WEBSITE_URL,'www.') -3)
                     END AS DOMAIN
              FROM DM.PROFESSIONAL_DIMENSION pf
              -- exclusions
              WHERE pf.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'
              AND   pf.PROFESSIONAL_PRACTICE_INDICATOR = 'Practicing'
              -- keep and flag per discussion with Pooja
              AND   (CASE WHEN pf.PROFESSIONAL_STATE_NAME_1 IS NULL THEN 1 ELSE 0 END) = 0
              AND   (CASE WHEN PROFESSIONAL_FIRST_NAME IS NULL THEN 1 ELSE 0 END) = 0
              AND   (CASE WHEN PROFESSIONAL_LAST_NAME IS NULL THEN 1 ELSE 0 END) = 0
              -- Must have at least first, last, and state
              AND   pf.PROFESSIONAL_NAME = 'lawyer'
              AND   pf.INDUSTRY_NAME = 'Legal'
              --  and pf.PROFESSIONAL_COUNTRY_NAME_1 = 'UNITED STATES'
              AND   LOWER (pf.PROFESSIONAL_FIRST_NAME) = 'vincent' -- (for testing purposes)
              
             ) pd
             
) t
WHERE HasClaimTwin <> 0
        /*WHERE (case 
              when (SUBSTR(upper(pd.domain),length(pd.domain)-3) in ('.EDU','.GOV','.ORG')) 
                  then 1
                  else 0
              end) = 0 -- exclude these three domains (confirmed that this is working as advertised) */ /*WHERE (case 
              when (SUBSTR(upper(pd.domain),length(pd.domain)-3) in ('.EDU','.GOV','.ORG')) 
                  then 1
                  else 0
              end) = 0 -- exclude these three domains (confirmed that this is working as advertised) */
   ORDER BY lastname
   ,firstname
   ,state
   ,phone1
   ,email
   ,is_claim
     ,NonNullPhone1Check
     ,NullPhone1Check
     ,NonNullEmailCheck
     ,NullEmailCheck
     ,DoubleNullCheck
