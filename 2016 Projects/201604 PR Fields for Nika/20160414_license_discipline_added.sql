WITH deduped_pfad AS
(
SELECT pfad.PROFESSIONAL_ID
         ,pfad.is_claim
         -- ,pfad.is_unclaimed
         -- ,pfad.claim_date
         -- ,pfad.claim_method
         -- ,pfad.domain
         -- ,COALESCE(pfad.emaildomain, 'No Valid Email') emaildomain
          -- ,pfad.emailsuffix
         ,pfad.rating AS AvvoRating
         ,pfad.county
         ,pfad.state
         /*,CASE
           WHEN toppa.ParentPracticeArea1 IN ("Criminal Defense","DUI & DWI","Divorce & Separation","Personal Injury","Family","Immigration","Car Accidents","Bankruptcy & Debt","Chapter 11 Bankruptcy","Chapter 13 Bankruptcy","Chapter 7 Bankruptcy","Workers Compensation","Child Custody","Employment & Labor","Real Estate","Estate Planning","Business","Lawsuits & Disputes","Motorcycle Accident") THEN 'Y'
           ELSE 'N'
         END AS PriorityPA1*/
         /*,pfad.LawyerName
         ,pfad.LawyerName_Full
         ,pfad.prefix */
         ,pfad.firstname
         ,pfad.lastname
         ,pfad.middlename
         /*,pfad.suffix
         ,pfad.phone1
         ,pfad.phone2
         ,pfad.phone3
         ,pfad.email 
         ,pfad.prof_name AS professional_name
         ,pfad.ind_name AS industry_name  */
         ,pfad.country AS professional_country_name_1
		 ,pfad.InstitutionalEmailFlag
		 ,pfad.InstitutionalEmailType
		 ,pfad.Professional_Practice_Indicator
         ,REGEXP_REPLACE(toppa.PracticeArea1, ',', '') PracticeArea1
         ,REGEXP_REPLACE(toppa.PracticeArea2, ',', '') PracticeArea2
         ,REGEXP_REPLACE(toppa.PracticeArea2, ',', '') PracticeArea3
         ,REGEXP_REPLACE(toppa.ParentPracticeArea1, ',', '') ParentPracticeArea1
         ,REGEXP_REPLACE(toppa.ParentPracticeArea2, ',', '') ParentPracticeArea2
         ,REGEXP_REPLACE(toppa.ParentPracticeArea3, ',', '') ParentPracticeArea3 
		 ,toppa.SpecialtyCount
		,toppa.PrimarySpecialtyPercent
         ,CASE
           WHEN pfad.HasEmail = 1 THEN 'Ok Email'
           ELSE 'Bad Email'
         END Email_Status
         /*,CASE
           WHEN pfad.HasPhone1 + pfad.HasPhone2 + pfad.HasPhone3 = 0 THEN 'Bad Phone'
           ELSE 'Ok Phone'
         END AS Phone_Status */
         ,pfad.IsFlaggedTitle
         ,ps.DECEASED
		,ps.JUDGE
				,ps.RETIRED
				,ps.OFFICIAL 
				,ps.UNVERIFIED
				,ps.SANCTIONED
        ,CASE
            WHEN ps.SANCTIONED = 'Y'
                THEN 1
            ELSE 0
         END IsSanctioned
		 ,CASE
			WHEN ps.DECEASED = 'N'
			  AND   ps.JUDGE = 'N'
			  AND   ps.RETIRED = 'N'
			  AND   ps.OFFICIAL = 'N'
			  AND   ps.UNVERIFIED = 'N'
			  AND   ps.SANCTIONED = 'N'
			  AND pfad.PROFESSIONAL_PRACTICE_INDICATOR = 'Practicing'
			  AND pfad.firstname IS NOT NULL
			  AND pfad.lastname IS NOT NULL
			  AND pfad.state IS NOT NULL
				THEN 1
			ELSE 0
		 END IsStandardProfile
  FROM (SELECT pd.*
              ,CASE
                 WHEN pd.phone1 IS NOT NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.phone1,pd.email,pd.lastname,pd.firstname,pd.state ORDER BY pd.is_claim DESC, pd.practicingflag DESC, pd.phone1 DESC,pd.email DESC,phone2 DESC,phone3 DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NonNullPhone1Check
               ,CASE
                 WHEN pd.phone1 IS NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.email,pd.firstname,pd.lastname,pd.state ORDER BY pd.is_claim DESC, pd.practicingflag DESC, pd.email DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NullPhone1Check
               ,CASE
                 WHEN pd.email IS NOT NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.email,pd.phone1,pd.lastname,pd.firstname,pd.state ORDER BY pd.is_claim DESC, pd.practicingflag DESC, pd.phone1 DESC,pd.email DESC,phone2 DESC,phone3 DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NonNullEmailCheck
               ,CASE
                 WHEN pd.email IS NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.phone1,pd.firstname,pd.lastname,pd.state ORDER BY pd.is_claim DESC, pd.practicingflag DESC, pd.phone1 DESC,phone2 DESC,phone3 DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NullEmailCheck
               ,CASE
                 WHEN pd.email IS NULL AND pd.phone1 IS NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.lastname,pd.firstname,pd.state ORDER BY pd.is_claim DESC, pd.practicingflag DESC, pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
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
               -- ,(SUBSTR(UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3)) EmailSuffix
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
        FROM (SELECT pf.PROFESSIONAL_ID
                     -- ,pf.professional_claim_method_name claim_method
                     ,CASE
                       WHEN pf.PROFESSIONAL_CLAIM_DATE IS NULL THEN 0
                       ELSE 1
                     END AS is_claim
                     ,CASE
                       WHEN pf.PROFESSIONAL_CLAIM_DATE IS NULL THEN 1
                       ELSE 0
                     END AS is_unclaimed
                     --  ,pf.professional_claim_date claim_date
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
                     ,PROFESSIONAL_PREFIX Prefix
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
                     ,concat(PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME) AS LawyerName

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
              ,pf.PROFESSIONAL_PRACTICE_INDICATOR
					,CASE
                         WHEN pf.PROFESSIONAL_PRACTICE_INDICATOR = 'Practicing'
							THEN 1
						 ELSE 0
					  END PracticingFlag			  
              FROM DM.PROFESSIONAL_DIMENSION pf
              WHERE pf.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'
			  AND pf.PROFESSIONAL_NAME = 'lawyer'
              AND   pf.INDUSTRY_NAME = 'Legal'
             ) pd
             
    ) pfad
    LEFT JOIN SRC.barrister_professional_status ps 
         ON ps.professional_id = pfad.PROFESSIONAL_ID
    LEFT JOIN (SELECT x.PROFESSIONAL_ID
                   ,MIN(CASE WHEN x.rt = 1 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea1
                      ,MIN(CASE WHEN x.rt = 2 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea2
                      ,MIN(CASE WHEN x.rt = 3 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea3
                      ,MIN(CASE WHEN x.rt = 1 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea1
                      ,MIN(CASE WHEN x.rt = 2 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea2
                      ,MIN(CASE WHEN x.rt = 3 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea3
					  ,MAX(x.rt) SpecialtyCount
					  ,MAX(x.specialty_percent) PrimarySpecialtyPercent
               FROM (SELECT pfsp.PROFESSIONAL_ID
                            ,pfsp.SPECIALTY_PERCENT
                            ,sp.SPECIALTY_NAME
                            ,sp.PARENT_SPECIALTY_NAME
                            ,ROW_NUMBER() OVER (PARTITION BY pfsp.PROFESSIONAL_ID ORDER BY pfsp.SPECIALTY_PERCENT DESC) rt
                     FROM DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp
                       JOIN DM.SPECIALTY_DIMENSION sp ON sp.SPECIALTY_ID = pfsp.SPECIALTY_ID
                     WHERE pfsp.DELETE_FLAG = 'N') x
               GROUP BY 1) toppa ON toppa.PROFESSIONAL_ID = pfad.PROFESSIONAL_ID
     /*LEFT JOIN src.barrister_professional bp -- to get contact flag
        ON bp.id = pfad.professional_id */
  WHERE /*ps.DECEASED = 'N'
  AND   ps.JUDGE = 'N'
  AND   ps.RETIRED = 'N'
  AND   ps.OFFICIAL = 'N'
  AND   ps.UNVERIFIED = 'N'
  AND   ps.SANCTIONED = 'N' */
  pfad.NonNullPhone1Check + pfad.NullPhone1Check + pfad.NonNullEmailCheck + pfad.NullEmailCheck + pfad.DoubleNullCheck = 5
  AND LOWER(pfad.firstname) = 'vincent'
  -- ORDER BY pfad.phone1,pfad.email,pfad.lastname,pfad.state, pfad.NonNullPhone1Check, pfad.NonNullEmailCheck, pfad.NullPhone1Check, pfad.NullEmailCheck, pfad.DoubleNullCheck
  
)
,

license_discipline AS (
  SELECT ps.professional_id
  ,MIN(bl.license_date) FirstLicenseDate
  ,MAX(bl.license_date) LastLicenseDate
  ,COUNT(bl.id) licensecount
  ,COUNT(bs.id) SanctionCount
  ,COUNT(DISTINCT CASE
      WHEN bs.case_information LIKE '%disbarred%'
          THEN bs.license_id
      ELSE NULL
   END ) DisbarCount
   ,COUNT(CASE
            WHEN bs.case_information LIKE '%suspended%'
                THEN bs.sanction_number
            WHEN bs.case_information LIKE '%suspension%'
                THEN bs.sanction_number
            ELSE NULL
         END ) SuspensionCount
  
FROM SRC.barrister_professional_status ps
  LEFT JOIN src.barrister_license bl
      ON ps.professional_id = bl.professional_id
  LEFT JOIN src.barrister_sanction bs
      ON bl.id = bs.license_id
WHERE ps.sanctioned = 'Y'--AND bs.case_information LIKE '%disbar%'
GROUP BY 1
-- ORDER BY SuspensionCount DESC
  )
,

reviews AS
(
  SELECT professional_id,
         COUNT(DISTINCT id) Review_Count,
         SUM(recommended) / COUNT(recommended)*1.0 PercentRecommended,
         SUM(CAST(overall_rating AS DOUBLE))/COUNT(DISTINCT professional_id) AvgRating
  FROM src.barrister_professional_review pr
  --WHERE created_at BETWEEN '2015-05-01' AND '2016-02-29'
  GROUP BY professional_Id
)

,

endorsements AS (

SELECT eds.endorsee_id AS professional_id
                   ,COUNT(DISTINCT eds.id) AS End_Count
                   FROM src.barrister_professional_endorsement eds
                   -- WHERE eds.created_at BETWEEN '2015-05-01' AND '2016-02-29'
                   GROUP BY 1
                   
)