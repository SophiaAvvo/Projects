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
		 ,pfad.city
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
  -- AND LOWER(pfad.firstname) = 'vincent'
  -- ORDER BY pfad.phone1,pfad.email,pfad.lastname,pfad.state, pfad.NonNullPhone1Check, pfad.NonNullEmailCheck, pfad.NullPhone1Check, pfad.NullEmailCheck, pfad.DoubleNullCheck
  
)

, license_discipline AS (
  SELECT ps.professional_id
  ,MIN(bl.license_date) FirstLicenseDate
  ,MAX(bl.license_date) LastLicenseDate
  ,COUNT(DISTINCT bl.id) LicenseCount
  ,COUNT(bs.id) SanctionCount
  /*,COUNT(DISTINCT CASE
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
         END ) SuspensionCount */
  
FROM SRC.barrister_professional_status ps
  LEFT JOIN src.barrister_license bl
      ON ps.professional_id = bl.professional_id
  LEFT JOIN src.barrister_sanction bs
      ON bl.id = bs.license_id
-- WHERE ps.sanctioned = 'Y'--AND bs.case_information LIKE '%disbar%'
GROUP BY 1
-- ORDER BY SuspensionCount DESC
  )
  
,school1 AS (
SELECT s.*
     ,ld.FirstLicenseDate
    -- ,COUNT(id) DegreeCount
        ,CASE
      WHEN LOWER(s.degree_area_name) LIKE '%law%'
        THEN 1
      WHEN LOWER(s.degree_level_name) LIKE '%law%'
        THEN 1
      ELSE 0
     END IsLawDegreeArea
     ,CASE
      WHEN LOWER(s.degree_level_name) LIKE '%juris %'
        THEN 1
      WHEN LOWER(s.degree_level_name) LIKE '%jd%'
        THEN 1
      WHEN LOWER(s.degree_level_name) LIKE '%j.d.%'
        THEN 1
      ELSE 0
     END IsJD
    ,CASE
WHEN s.school_id = 11 THEN 72
WHEN s.school_id = 18 THEN 31
WHEN s.school_id = 23 THEN 16
WHEN s.school_id = 24 THEN 38
WHEN s.school_id = 28 THEN 51
WHEN s.school_id = 33 THEN 51
WHEN s.school_id = 37 THEN 36
WHEN s.school_id = 38 THEN 27
WHEN s.school_id = 40 THEN 36
WHEN s.school_id = 41 THEN 51
WHEN s.school_id = 43 THEN 83
WHEN s.school_id = 53 THEN 121
WHEN s.school_id = 56 THEN 64
WHEN s.school_id = 57 THEN 107
WHEN s.school_id = 66 THEN 140
WHEN s.school_id = 70 THEN 72
WHEN s.school_id = 77 THEN 51
WHEN s.school_id = 78 THEN 113
WHEN s.school_id = 79 THEN 115
WHEN s.school_id = 82 THEN 24
WHEN s.school_id = 83 THEN 4
WHEN s.school_id = 86 THEN 13
WHEN s.school_id = 90 THEN 115
WHEN s.school_id = 95 THEN 121
WHEN s.school_id = 99 THEN 113
WHEN s.school_id = 100 THEN 129
WHEN s.school_id = 101 THEN 10
WHEN s.school_id = 102 THEN 121
WHEN s.school_id = 108 THEN 19
WHEN s.school_id = 118 THEN 51
WHEN s.school_id = 162 THEN 100
WHEN s.school_id = 163 THEN 45
WHEN s.school_id = 164 THEN 36
WHEN s.school_id = 166 THEN 93
WHEN s.school_id = 172 THEN 46
WHEN s.school_id = 173 THEN 20
WHEN s.school_id = 174 THEN 13
WHEN s.school_id = 175 THEN 64
WHEN s.school_id = 179 THEN 107
WHEN s.school_id = 182 THEN 121
WHEN s.school_id = 185 THEN 2
WHEN s.school_id = 188 THEN 51
WHEN s.school_id = 191 THEN 135
WHEN s.school_id = 193 THEN 135
WHEN s.school_id = 195 THEN 51
WHEN s.school_id = 199 THEN 29
WHEN s.school_id = 200 THEN 87
WHEN s.school_id = 217 THEN 129
WHEN s.school_id = 225 THEN 30
WHEN s.school_id = 229 THEN 17
WHEN s.school_id = 243 THEN 23
WHEN s.school_id = 244 THEN 72
WHEN s.school_id = 252 THEN 87
WHEN s.school_id = 253 THEN 72
WHEN s.school_id = 254 THEN 87
WHEN s.school_id = 255 THEN 68
WHEN s.school_id = 256 THEN 126
WHEN s.school_id = 257 THEN 43
WHEN s.school_id = 258 THEN 51
WHEN s.school_id = 261 THEN 93
WHEN s.school_id = 264 THEN 146
WHEN s.school_id = 267 THEN 104
WHEN s.school_id = 268 THEN 87
WHEN s.school_id = 272 THEN 22
WHEN s.school_id = 279 THEN 44
WHEN s.school_id = 280 THEN 14
WHEN s.school_id = 287 THEN 140
WHEN s.school_id = 288 THEN 6
WHEN s.school_id = 293 THEN 93
WHEN s.school_id = 298 THEN 12
WHEN s.school_id = 299 THEN 26
WHEN s.school_id = 304 THEN 135
WHEN s.school_id = 305 THEN 31
WHEN s.school_id = 308 THEN 51
WHEN s.school_id = 310 THEN 140
WHEN s.school_id = 317 THEN 54
WHEN s.school_id = 333 THEN 118
WHEN s.school_id = 352 THEN 36
WHEN s.school_id = 353 THEN 81
WHEN s.school_id = 354 THEN 83
WHEN s.school_id = 355 THEN 93
WHEN s.school_id = 356 THEN 135
WHEN s.school_id = 362 THEN 107
WHEN s.school_id = 364 THEN 87
WHEN s.school_id = 366 THEN 41
WHEN s.school_id = 367 THEN 68
WHEN s.school_id = 374 THEN 146
WHEN s.school_id = 378 THEN 140
WHEN s.school_id = 379 THEN 42
WHEN s.school_id = 383 THEN 129
WHEN s.school_id = 386 THEN 107
WHEN s.school_id = 391 THEN 3
WHEN s.school_id = 392 THEN 100
WHEN s.school_id = 393 THEN 93
WHEN s.school_id = 394 THEN 51
WHEN s.school_id = 395 THEN 144
WHEN s.school_id = 396 THEN 107
WHEN s.school_id = 403 THEN 61
WHEN s.school_id = 404 THEN 107
WHEN s.school_id = 415 THEN 51
WHEN s.school_id = 419 THEN 140
WHEN s.school_id = 425 THEN 51
WHEN s.school_id = 427 THEN 51
WHEN s.school_id = 429 THEN 46
WHEN s.school_id = 435 THEN 51
WHEN s.school_id = 436 THEN 51
WHEN s.school_id = 437 THEN 51
WHEN s.school_id = 444 THEN 51
WHEN s.school_id = 481 THEN 51
WHEN s.school_id = 513 THEN 51
WHEN s.school_id = 523 THEN 51
WHEN s.school_id = 531 THEN 51
WHEN s.school_id = 554 THEN 25
WHEN s.school_id = 572 THEN 51
WHEN s.school_id = 575 THEN 51
WHEN s.school_id = 576 THEN 50
WHEN s.school_id = 582 THEN 51
WHEN s.school_id = 584 THEN 121
WHEN s.school_id = 585 THEN 23
WHEN s.school_id = 587 THEN 40
WHEN s.school_id = 588 THEN 121
WHEN s.school_id = 589 THEN 61
WHEN s.school_id = 591 THEN 135
WHEN s.school_id = 593 THEN 34
WHEN s.school_id = 595 THEN 51
WHEN s.school_id = 597 THEN 9
WHEN s.school_id = 598 THEN 36
WHEN s.school_id = 599 THEN 16
WHEN s.school_id = 600 THEN 54
WHEN s.school_id = 601 THEN 51
WHEN s.school_id = 603 THEN 51
WHEN s.school_id = 604 THEN 4
WHEN s.school_id = 605 THEN 79
WHEN s.school_id = 606 THEN 43
WHEN s.school_id = 607 THEN 54
WHEN s.school_id = 610 THEN 68
WHEN s.school_id = 615 THEN 49
WHEN s.school_id = 616 THEN 29
WHEN s.school_id = 619 THEN 100
WHEN s.school_id = 620 THEN 19
WHEN s.school_id = 622 THEN 58
WHEN s.school_id = 623 THEN 118
WHEN s.school_id = 624 THEN 40
WHEN s.school_id = 625 THEN 27
WHEN s.school_id = 627 THEN 68
WHEN s.school_id = 628 THEN 58
WHEN s.school_id = 634 THEN 129
WHEN s.school_id = 637 THEN 46
WHEN s.school_id = 639 THEN 61
WHEN s.school_id = 640 THEN 10
WHEN s.school_id = 641 THEN 20
WHEN s.school_id = 642 THEN 104
WHEN s.school_id = 643 THEN 64
WHEN s.school_id = 644 THEN 104
WHEN s.school_id = 645 THEN 121
WHEN s.school_id = 650 THEN 54
WHEN s.school_id = 651 THEN 83
WHEN s.school_id = 654 THEN 72
WHEN s.school_id = 655 THEN 31
WHEN s.school_id = 656 THEN 129
WHEN s.school_id = 658 THEN 58
WHEN s.school_id = 659 THEN 100
WHEN s.school_id = 661 THEN 51
WHEN s.school_id = 664 THEN 7
WHEN s.school_id = 665 THEN 81
WHEN s.school_id = 667 THEN 78
WHEN s.school_id = 668 THEN 51
WHEN s.school_id = 671 THEN 79
WHEN s.school_id = 672 THEN 144
WHEN s.school_id = 676 THEN 93
WHEN s.school_id = 677 THEN 145
WHEN s.school_id = 678 THEN 20
WHEN s.school_id = 680 THEN 129
WHEN s.school_id = 684 THEN 72
WHEN s.school_id = 685 THEN 15
WHEN s.school_id = 690 THEN 140
WHEN s.school_id = 691 THEN 21
WHEN s.school_id = 693 THEN 72
WHEN s.school_id = 694 THEN 49
WHEN s.school_id = 696 THEN 46
WHEN s.school_id = 697 THEN 8
WHEN s.school_id = 699 THEN 24
WHEN s.school_id = 703 THEN 31
WHEN s.school_id = 705 THEN 129
WHEN s.school_id = 711 THEN 16
WHEN s.school_id = 713 THEN 129
WHEN s.school_id = 715 THEN 93
WHEN s.school_id = 718 THEN 51
WHEN s.school_id = 720 THEN 31
WHEN s.school_id = 721 THEN 115
WHEN s.school_id = 722 THEN 43
WHEN s.school_id = 723 THEN 18
WHEN s.school_id = 724 THEN 87
WHEN s.school_id = 727 THEN 83
WHEN s.school_id = 736 THEN 121
WHEN s.school_id = 739 THEN 135
WHEN s.school_id = 742 THEN 1
WHEN s.school_id = 743 THEN 64
WHEN s.school_id = 3081 THEN 65
WHEN s.school_id = 3217 THEN 20
WHEN s.school_id = 3224 THEN 51
WHEN s.school_id = 3250 THEN 35
WHEN s.school_id = 3251 THEN 15
WHEN s.school_id = 3316 THEN 51
WHEN s.school_id = 3356 THEN 51
WHEN s.school_id = 3371 THEN 48
WHEN s.school_id = 3389 THEN 51
WHEN s.school_id = 3512 THEN 80
WHEN s.school_id = 3575 THEN 140
WHEN s.school_id = 3581 THEN 119
WHEN s.school_id = 3755 THEN 119
WHEN s.school_id = 4302 THEN 119
WHEN s.school_id = 4334 THEN 26
WHEN s.school_id = 4347 THEN 132
WHEN s.school_id = 4351 THEN 27
WHEN s.school_id = 4516 THEN 51
WHEN s.school_id = 4771 THEN 40
WHEN s.school_id = 4783 THEN 45
WHEN s.school_id = 4844 THEN 2
WHEN s.school_id = 4870 THEN 33
WHEN s.school_id = 4871 THEN 18
WHEN s.school_id = 5025 THEN 51
WHEN s.school_id = 5666 THEN 8
WHEN s.school_id = 5677 THEN 3
WHEN s.school_id = 5678 THEN 7
WHEN s.school_id = 5679 THEN 11
WHEN s.school_id = 5680 THEN 51
WHEN s.school_id = 5681 THEN 51
WHEN s.school_id = 5682 THEN 51
WHEN s.school_id = 5683 THEN 51
WHEN s.school_id = 5684 THEN 51
WHEN s.school_id = 5685 THEN 42
WHEN s.school_id = 5686 THEN 51
WHEN s.school_id = 5687 THEN 51
WHEN s.school_id = 5688 THEN 51
WHEN s.school_id = 5690 THEN 37
WHEN s.school_id = 5691 THEN 51
WHEN s.school_id = 5692 THEN 51
WHEN s.school_id = 5694 THEN 13
WHEN s.school_id = 5695 THEN 49
WHEN s.school_id = 5697 THEN 51
WHEN s.school_id = 5698 THEN 51
ELSE NULL
END AS LawSchoolRank
,CASE
WHEN s.school_id = 2 THEN "Abraham Lincoln Law School"
WHEN s.school_id = 3 THEN "Advani Law School"
WHEN s.school_id = 4 THEN "Albany Law School of Union University"
WHEN s.school_id = 6 THEN "American College of Law"
WHEN s.school_id = 7 THEN "American Extension School of Law"
WHEN s.school_id = 8 THEN "American Heritage University School of Law"
WHEN s.school_id = 9 THEN "American Justice School of Law"
WHEN s.school_id = 10 THEN "American University of Armenia School of Law"
WHEN s.school_id = 11 THEN "American University, Washington College of Law"
WHEN s.school_id = 12 THEN "Ankara Universitesi Hukuk Fakultesi"
WHEN s.school_id = 13 THEN "Antioch School of Law"
WHEN s.school_id = 14 THEN "Appalachian School of Law"
WHEN s.school_id = 15 THEN "Arellano Law Foundation"
WHEN s.school_id = 16 THEN "Arhus Universitet Faculty of Law and Economics"
WHEN s.school_id = 17 THEN "Aristotelion Panepistimion Thessalonikis Faculty of Law and Economics"
WHEN s.school_id = 18 THEN "Arizona State University Sandra Day O'Connor College of Law"
WHEN s.school_id = 19 THEN "Armstrong College School of Law"
WHEN s.school_id = 20 THEN "Ateneo de Manila Law School"
WHEN s.school_id = 21 THEN "Athinisin Ethnikon Kai Kapodistriakon Panepistimion Faculty of Law"
WHEN s.school_id = 22 THEN "Atlanta Law School"
WHEN s.school_id = 23 THEN "Australian National University College of Law"
WHEN s.school_id = 24 THEN "National Autonomous University of Mexico Faculty of Law"
WHEN s.school_id = 25 THEN "Ave Maria School of Law"
WHEN s.school_id = 26 THEN "Bar-llan University Faculty of Law"
WHEN s.school_id = 27 THEN "Barry University Dwayne O. Andreas School of Law"
WHEN s.school_id = 28 THEN "Baylor University School of Law"
WHEN s.school_id = 29 THEN "Belfast (Queen's) University Faculty of Law"
WHEN s.school_id = 30 THEN "Benjamin Harrison School of Law"
WHEN s.school_id = 31 THEN "Bernadean University"
WHEN s.school_id = 32 THEN "Birmingham School of Law (Birmingham, AL)"
WHEN s.school_id = 33 THEN "Birmingham Law School (England)"
WHEN s.school_id = 34 THEN "Birzeit University Law Center"
WHEN s.school_id = 35 THEN "Blackstone College of Law"
WHEN s.school_id = 36 THEN "Bond University Faculty of Law"
WHEN s.school_id = 37 THEN "Boston College Law School"
WHEN s.school_id = 38 THEN "Boston University School of Law"
WHEN s.school_id = 39 THEN "Bournemouth University School of Finance & Law"
WHEN s.school_id = 40 THEN "Brigham Young University - J. Reuben Clark Law School"
WHEN s.school_id = 41 THEN "University of Bristol Law School"
WHEN s.school_id = 42 THEN "British-American University School of Law"
WHEN s.school_id = 43 THEN "Brooklyn Law School"
WHEN s.school_id = 44 THEN "Brunel University Faculty of Law"
WHEN s.school_id = 45 THEN "Buckingham University Faculty of Law"
WHEN s.school_id = 46 THEN "Cabrillo Pacific University"
WHEN s.school_id = 47 THEN "CAL Northern School of Law"
WHEN s.school_id = 48 THEN "California College of Law"
WHEN s.school_id = 49 THEN "California Pacific School of Law"
WHEN s.school_id = 50 THEN "California Southern Law School"
WHEN s.school_id = 51 THEN "California Western School of Law"
WHEN s.school_id = 53 THEN "Campbell University, Norman Adrian Wiggins School of Law"
WHEN s.school_id = 54 THEN "Capital University Law School"
WHEN s.school_id = 55 THEN "Carleton University Dept of Law"
WHEN s.school_id = 56 THEN "Case Western Reserve University School of Law"
WHEN s.school_id = 57 THEN "Catholic University of America, School of Law"
WHEN s.school_id = 59 THEN "Central Philippine University College of Law"
WHEN s.school_id = 60 THEN "Central Wesleyan College"
WHEN s.school_id = 61 THEN "Centre Universitaire d'Avignon UFR Sciences Jurisdiques Politique et Economique"
WHEN s.school_id = 62 THEN "Centre Universitaire de Luxembourg Departement de Droit"
WHEN s.school_id = 63 THEN "Centre Universitaire de Perpignan"
WHEN s.school_id = 64 THEN "Centre Universitaire de Toulon et du Var"
WHEN s.school_id = 65 THEN "Centre Universitaire du Mans Faculte de Droit et des Sciences Economiques"
WHEN s.school_id = 66 THEN "Chapman University School of Law"
WHEN s.school_id = 67 THEN "Charlotte School of Law"
WHEN s.school_id = 68 THEN "Chelmer Institute of Higher Education Faculty of Social Sciences Law Department"
WHEN s.school_id = 69 THEN "Chester College of Law"
WHEN s.school_id = 70 THEN "Chicago-Kent College of Law Illinois Institute of Technology"
WHEN s.school_id = 71 THEN "Christian-Albrechts-Universitat Kiel Fachbereich Rechtswissenschaft"
WHEN s.school_id = 72 THEN "Citrus Belt Law School"
WHEN s.school_id = 73 THEN "City of Birmingham Department of Law, Franchise Street"
WHEN s.school_id = 74 THEN "City of London Department of Law School of Business Studies"
WHEN s.school_id = 75 THEN "City of London Polytechnic"
WHEN s.school_id = 76 THEN "City University Faculty of Law"
WHEN s.school_id = 77 THEN "City University of Hong Kong School of Law"
WHEN s.school_id = 78 THEN "City University of New York School of Law at Queens College"
WHEN s.school_id = 79 THEN "Cleveland State University - Cleveland-Marshall College of Law"
WHEN s.school_id = 80 THEN "Colegio Publico de Abogados de Capital Federal"
WHEN s.school_id = 81 THEN "College of Europe Law Department"
WHEN s.school_id = 82 THEN "College of William and Mary, Marshall-Wythe School of Law"
WHEN s.school_id = 83 THEN "Columbia University School of Law"
WHEN s.school_id = 85 THEN "Concord University School of Law"
WHEN s.school_id = 86 THEN "Cornell Law School"
WHEN s.school_id = 87 THEN "Council of Legal Education Inns of Court School of Law"
WHEN s.school_id = 88 THEN "Council On Legal Education"
WHEN s.school_id = 89 THEN "Coventry (Lanchester) Department of Legal Studies"
WHEN s.school_id = 90 THEN "Creighton University School of Law"
WHEN s.school_id = 91 THEN "Dalhousie University School of Law"
WHEN s.school_id = 92 THEN "Dallas School of Law"
WHEN s.school_id = 93 THEN "Deakin University School of Law"
WHEN s.school_id = 94 THEN "Democritus University of Thrace Law School"
WHEN s.school_id = 95 THEN "DePaul University College of Law"
WHEN s.school_id = 96 THEN "Desert College of Law"
WHEN s.school_id = 97 THEN "Dixie University"
WHEN s.school_id = 98 THEN "Domaine Universitaire de Jacob-Bellecombett"
WHEN s.school_id = 99 THEN "Drake University Law School"
WHEN s.school_id = 100 THEN "Drexel University College of Law"
WHEN s.school_id = 101 THEN "Duke University School of Law"
WHEN s.school_id = 102 THEN "Duquesne University School of Law"
WHEN s.school_id = 103 THEN "East Anglia University Faculty of Law"
WHEN s.school_id = 104 THEN "East Bay Law School Inc"
WHEN s.school_id = 105 THEN "East China University of Politics and Law Faculty of Intl Law"
WHEN s.school_id = 106 THEN "East Texas College of Law"
WHEN s.school_id = 107 THEN "Elon University School of Law"
WHEN s.school_id = 108 THEN "Emory University School of Law"
WHEN s.school_id = 109 THEN "Empire College School of Law"
WHEN s.school_id = 110 THEN "Erasmus University Rotterdam Faculty of Law"
WHEN s.school_id = 111 THEN "Ernst-Moritz-Arndt-Universitat Nordeuropa Institut Wissenschaftsbereich Staat und Recht"
WHEN s.school_id = 112 THEN "Escuela de Derech de la Universidad Central de Venezuela"
WHEN s.school_id = 113 THEN "Esquire College"
WHEN s.school_id = 114 THEN "Essex University Faculty of Law"
WHEN s.school_id = 115 THEN "Eugenio Maria de Hostos School of Law"
WHEN s.school_id = 116 THEN "Exeter University School of Law"
WHEN s.school_id = 117 THEN "Fachbereich Rechtswissenschaft der Universitat Trier"
WHEN s.school_id = 118 THEN "Albert Ludwigs University of Freiburg Faculty of Law"
WHEN s.school_id = 119 THEN "Fachschaft JuraUniversitat zu Koln Rechtswissenschaftliche Fakultat"
WHEN s.school_id = 120 THEN "Faculte de droit de l'Universite de Moncton"
WHEN s.school_id = 121 THEN "Facultes Universitaires Notre-Dame de la Paix"
WHEN s.school_id = 122 THEN "Facultes Universitaires Saint-Louis Faculte de Droit"
WHEN s.school_id = 123 THEN "Faculty of Law Adam Mickiewica University"
WHEN s.school_id = 124 THEN "Faculty of Law and Admistration University of Warsaw"
WHEN s.school_id = 125 THEN "Faculty of Law Belgrade University"
WHEN s.school_id = 126 THEN "Faculty of Law Blagoevgrad University"
WHEN s.school_id = 127 THEN "Faculty of Law Catholic University of Lublin"
WHEN s.school_id = 128 THEN "Faculty of Law Charles University"
WHEN s.school_id = 129 THEN "Faculty of Law Comenius University"
WHEN s.school_id = 130 THEN "Faculty of Law Eotvos Lorand University"
WHEN s.school_id = 131 THEN "Faculty of Law in Bialystok Warsaw University"
WHEN s.school_id = 132 THEN "Faculty of Law Jagiellonian University"
WHEN s.school_id = 133 THEN "Faculty of Law Janus Pannonius University"
WHEN s.school_id = 134 THEN "Faculty of Law Jozsef Attila University"
WHEN s.school_id = 135 THEN "Faculty of Law Marie-Curie University"
WHEN s.school_id = 136 THEN "Faculty of Law Miskolc University"
WHEN s.school_id = 137 THEN "Faculty of Law New Bulgarian University"
WHEN s.school_id = 138 THEN "Faculty of Law Nicolas Copernicus University"
WHEN s.school_id = 139 THEN "Faculty of Law Novi Sad University"
WHEN s.school_id = 140 THEN "Faculty of Law of Lomonosov Moscow State University"
WHEN s.school_id = 141 THEN "Faculty of Law Plovidiv Univeristy"
WHEN s.school_id = 142 THEN "Faculty of Law School of Magistrates"
WHEN s.school_id = 143 THEN "Faculty of Law Silesian University"
WHEN s.school_id = 144 THEN "Faculty of Law Skopje University"
WHEN s.school_id = 145 THEN "Faculty of Law Szczecin University"
WHEN s.school_id = 146 THEN "Faculty of Law University of Busharest"
WHEN s.school_id = 147 THEN "University of Craiova Faculty of Law and Administrative Sciences"
WHEN s.school_id = 148 THEN "Faculty of Law University of Gdansk"
WHEN s.school_id = 149 THEN "University of Latvia Faculty of Law"
WHEN s.school_id = 150 THEN "Faculty of Law University of Ljubljana (Univerza v Ljubljani)"
WHEN s.school_id = 151 THEN "Faculty of Law University of Maribor"
WHEN s.school_id = 152 THEN "Faculty of Law University of P.J. Safarik"
WHEN s.school_id = 153 THEN "Faculty of Law University of Sibiu"
WHEN s.school_id = 154 THEN "Faculty of Law University of Titograd"
WHEN s.school_id = 155 THEN "Faculty of Law University of Wroclaw,"
WHEN s.school_id = 156 THEN "Faculty of Law Vilnius University"
WHEN s.school_id = 157 THEN "Faculty of Law, Lodz University"
WHEN s.school_id = 158 THEN "Faulkner University, Thomas Goode Jones School of Law"
WHEN s.school_id = 159 THEN "Federation Universitaire et Polytechnique de Lille"
WHEN s.school_id = 160 THEN "Florida A&M University College of Law"
WHEN s.school_id = 161 THEN "Florida Coastal School of Law"
WHEN s.school_id = 162 THEN "Florida International University College of Law"
WHEN s.school_id = 163 THEN "Florida State University College of Law"
WHEN s.school_id = 164 THEN "Fordham University School of Law"
WHEN s.school_id = 165 THEN "Fort Worth School of Law"
WHEN s.school_id = 166 THEN "Franklin Pierce Law Center"
WHEN s.school_id = 167 THEN "Fraternity of Saint Thomas Aquinas University"
WHEN s.school_id = 168 THEN "Freie Universitat Berlin Fachbereich Rechtswissenschaft"
WHEN s.school_id = 169 THEN "Friedrich-Alexander-Universitat Erlangen-Numberg Fachbereich Rechtswissenschaft"
WHEN s.school_id = 170 THEN "Galveston School of Law"
WHEN s.school_id = 171 THEN "Georg-August-Universitat in Gottingen Juristische Fakultat"
WHEN s.school_id = 172 THEN "George Mason University School of Law"
WHEN s.school_id = 173 THEN "George Washington University National Law Center"
WHEN s.school_id = 174 THEN "Georgetown University Law Center"
WHEN s.school_id = 175 THEN "Georgia State University College of Law"
WHEN s.school_id = 176 THEN "Gesamthochschule Siegen Fachbereich Wirtschaftswissenschaft"
WHEN s.school_id = 177 THEN "Glendale University College of Law"
WHEN s.school_id = 178 THEN "Golden Gate University School of Law"
WHEN s.school_id = 179 THEN "Gonzaga University School of Law"
WHEN s.school_id = 180 THEN "Gujarat Law School"
WHEN s.school_id = 181 THEN "Haifa University, Israel Faculty of Law"
WHEN s.school_id = 182 THEN "Hamline University School of Law"
WHEN s.school_id = 183 THEN "Handelshogskolan vid Goteborgs Universitet Law Faculty"
WHEN s.school_id = 184 THEN "Hanse Law School"
WHEN s.school_id = 185 THEN "Harvard University Law School"
WHEN s.school_id = 186 THEN "Hatfield Faculty of Law"
WHEN s.school_id = 187 THEN "Heinrich Heine University Law School"
WHEN s.school_id = 188 THEN "University of Helsinki Faculty of Law"
WHEN s.school_id = 189 THEN "Hochschule fur okonomie Berlin Institut fur Handels- und Wirtschaftsrecht"
WHEN s.school_id = 190 THEN "Hochschule fur Technisch und Wirtschaft"
WHEN s.school_id = 191 THEN "Hofstra University School of Law"
WHEN s.school_id = 193 THEN "Howard University School of Law"
WHEN s.school_id = 194 THEN "Humberside Faculty of Law"
WHEN s.school_id = 195 THEN "Humboldt University Faculty of Law"
WHEN s.school_id = 197 THEN "Humphreys College of Law at Stockton"
WHEN s.school_id = 198 THEN "Ibmec Law School in Rio de Janeiro"
WHEN s.school_id = 199 THEN "Indiana University School of Law, Bloomington"
WHEN s.school_id = 200 THEN "Indiana University School of Law, Indianapolis"
WHEN s.school_id = 201 THEN "Inland Valley Univeristy, Inland Valley College of Law"
WHEN s.school_id = 202 THEN "Inns of Court School of Law"
WHEN s.school_id = 203 THEN "Institut International des Droits de l'Homme"
WHEN s.school_id = 204 THEN "Institute du Droit Compare"
WHEN s.school_id = 205 THEN "Institute of Intl Legal Studies"
WHEN s.school_id = 206 THEN "Instituteto Tech. De Nueva Lar"
WHEN s.school_id = 207 THEN "Inter American University of Puerto Rico School of Law"
WHEN s.school_id = 208 THEN "Intl Islamic University Malaysia"
WHEN s.school_id = 209 THEN "Irvine University College of Law"
WHEN s.school_id = 210 THEN "Ism-Institut Superieur del la Magistrature"
WHEN s.school_id = 211 THEN "Istanbul University Faculty of Law"
WHEN s.school_id = 212 THEN "Istituto Universitario Europeo Department of Law"
WHEN s.school_id = 214 THEN "Jitendra Chauhan College of Law"
WHEN s.school_id = 215 THEN "John F. Kennedy University School of Law"
WHEN s.school_id = 216 THEN "John Marshall Law School, Atlanta"
WHEN s.school_id = 217 THEN "John Marshall Law School, Chicago"
WHEN s.school_id = 218 THEN "John William University School of Law"
WHEN s.school_id = 219 THEN "Jones Law Institute"
WHEN s.school_id = 220 THEN "Juristische FakultatUniversitat Tubingen Fachbereich Rechtswissenschaft"
WHEN s.school_id = 221 THEN "Justinian Prima - Skopje, Faculty of Law"
WHEN s.school_id = 222 THEN "Justus-Liebig-Universitat Giessen Fachbereich Rechtswissenschaft"
WHEN s.school_id = 223 THEN "Karl-Franzens-Universitat Graz Rechtswissenschaftliche Fakultat"
WHEN s.school_id = 224 THEN "Katholieke Universiteit Brussel"
WHEN s.school_id = 225 THEN "University of Leuven Faculty of Law"
WHEN s.school_id = 226 THEN "Katholieke Universiteit Nijmegen Faculteit der Rechtsgeleerdheid"
WHEN s.school_id = 227 THEN "Keele University Faculty of Law (Staffordshire)"
WHEN s.school_id = 228 THEN "Keele University Faculty of Law (Keele)"
WHEN s.school_id = 229 THEN "King's College London, Dickson Poon School of Law"
WHEN s.school_id = 231 THEN "Kingston School of Law"
WHEN s.school_id = 232 THEN "La Trobe University School of Law and Legal Studies"
WHEN s.school_id = 233 THEN "Laclede School of Law"
WHEN s.school_id = 234 THEN "Lancashire Faculty of Law"
WHEN s.school_id = 235 THEN "Lancaster University Faculty of Law"
WHEN s.school_id = 236 THEN "Lapin yliopisto Faculty of Law"
WHEN s.school_id = 237 THEN "Larry H. Layton School of Law"
WHEN s.school_id = 238 THEN "LaSalle University School of Law"
WHEN s.school_id = 239 THEN "Laurel University School of Law"
WHEN s.school_id = 240 THEN "Laval University Faculty of Law"
WHEN s.school_id = 241 THEN "Law School of the University of Sarajevo"
WHEN s.school_id = 242 THEN "Lebanon University"
WHEN s.school_id = 243 THEN "Leiden University, Leiden Law School"
WHEN s.school_id = 244 THEN "Lewis & Clark Law School"
WHEN s.school_id = 245 THEN "Liberty University School of Law"
WHEN s.school_id = 246 THEN "Lincoln Law School of Sacramento"
WHEN s.school_id = 247 THEN "Lincoln Law School of San Jose"
WHEN s.school_id = 248 THEN "Lincoln University Law School"
WHEN s.school_id = 249 THEN "Loma Linda College of Law"
WHEN s.school_id = 251 THEN "London School of Law"
WHEN s.school_id = 252 THEN "Louis D. Brandeis School of Law at the University of Louisville"
WHEN s.school_id = 253 THEN "Louisiana State University, Paul M. Hebert Law Center"
WHEN s.school_id = 254 THEN "Loyola Law School, Loyola Marymount University"
WHEN s.school_id = 255 THEN "Loyola University Chicago School of Law"
WHEN s.school_id = 256 THEN "Loyola University New Orleans College of Law"
WHEN s.school_id = 257 THEN "Ludwig Maximilian University of Munich Faculty of Law"
WHEN s.school_id = 258 THEN "Lund University Faculty of Law"
WHEN s.school_id = 259 THEN "Macquarie University, Macquarie Law School"
WHEN s.school_id = 261 THEN "Marquette University Law School"
WHEN s.school_id = 262 THEN "Martin-Luther-Universitat"
WHEN s.school_id = 263 THEN "Massachusetts School of Law at Andover"
WHEN s.school_id = 264 THEN "McGeorge School of Law, University of the Pacific"
WHEN s.school_id = 266 THEN "MD Kirk School of Law"
WHEN s.school_id = 267 THEN "Mercer University - Walter F. George School of Law"
WHEN s.school_id = 268 THEN "Michigan State University College of Law"
WHEN s.school_id = 269 THEN "Mid Valley College of Law"
WHEN s.school_id = 270 THEN "Miles College Law School"
WHEN s.school_id = 271 THEN "Mississippi College School of Law"
WHEN s.school_id = 272 THEN "Monash University Faculty of Law"
WHEN s.school_id = 273 THEN "Monterey College of Law"
WHEN s.school_id = 274 THEN "Mt. Vernon School of Law"
WHEN s.school_id = 275 THEN "Murdoch University School of Law"
WHEN s.school_id = 276 THEN "Nashville School of Law"
WHEN s.school_id = 277 THEN "National Law School"
WHEN s.school_id = 278 THEN "National Taipei University College of Law"
WHEN s.school_id = 279 THEN "National Taiwan University College of Law"
WHEN s.school_id = 280 THEN "National University of Singapore Faculty of Law"
WHEN s.school_id = 281 THEN "National University School of Law"
WHEN s.school_id = 282 THEN "Nat'l Conf Black Lawyers Comm"
WHEN s.school_id = 283 THEN "Nevada School of Law at Old College"
WHEN s.school_id = 284 THEN "New College of California School of Law"
WHEN s.school_id = 285 THEN "New England School of Law"
WHEN s.school_id = 286 THEN "New Jersey Law School"
WHEN s.school_id = 287 THEN "New York Law School"
WHEN s.school_id = 288 THEN "New York University School of Law"
WHEN s.school_id = 289 THEN "Newport University School of Law"
WHEN s.school_id = 290 THEN "Nigerian Law School"
WHEN s.school_id = 291 THEN "North Carolina Central University School of Law"
WHEN s.school_id = 292 THEN "North Texas School of Law"
WHEN s.school_id = 293 THEN "Northeastern University School of Law"
WHEN s.school_id = 294 THEN "Northern Illinois University College of Law"
WHEN s.school_id = 295 THEN "Northern Kentucky University, Salmon P. Chase College of Law"
WHEN s.school_id = 296 THEN "Northrop University School of Law"
WHEN s.school_id = 297 THEN "Northwestern California University School of Law"
WHEN s.school_id = 298 THEN "Northwestern University School of Law"
WHEN s.school_id = 299 THEN "Notre Dame Law School"
WHEN s.school_id = 300 THEN "Nova Southeastern University - Shepard Broad Law Center"
WHEN s.school_id = 301 THEN "O W Coburn School of Law"
WHEN s.school_id = 302 THEN "Oak Brook College of Law & Gov't Policy"
WHEN s.school_id = 303 THEN "Oakland College of Law"
WHEN s.school_id = 304 THEN "Ohio Northern University - Claude W. Pettit College of Law"
WHEN s.school_id = 305 THEN "Ohio State University Moritz College of Law"
WHEN s.school_id = 306 THEN "Oklahoma City University School of Law"
WHEN s.school_id = 307 THEN "Old College Law School"
WHEN s.school_id = 308 THEN "Osgoode Hall Law School, York University"
WHEN s.school_id = 310 THEN "Pace University School of Law"
WHEN s.school_id = 311 THEN "Pacific Coast University School of Law"
WHEN s.school_id = 312 THEN "Pacific West College of Law"
WHEN s.school_id = 313 THEN "Pakistan College of Law"
WHEN s.school_id = 314 THEN "Palacky University Faculty of Law"
WHEN s.school_id = 315 THEN "Peninsula University Law School"
WHEN s.school_id = 316 THEN "People's College of Law"
WHEN s.school_id = 317 THEN "Pepperdine University School of Law"
WHEN s.school_id = 318 THEN "Perpustakaan Udang-Udang"
WHEN s.school_id = 319 THEN "Philadelphia School of Law"
WHEN s.school_id = 320 THEN "Philipps-Universitat Marburg Fachbereich Rechtswissenschaften"
WHEN s.school_id = 321 THEN "Phoenix International School of Law"
WHEN s.school_id = 322 THEN "Pontifical Catholic University of Puerto Rico School of Law"
WHEN s.school_id = 323 THEN "Pontifical Gregorian University Facolta de Diritto Canonico"
WHEN s.school_id = 324 THEN "Pontifical Lateran University"
WHEN s.school_id = 325 THEN "Pontifical Lateran University Facolta de Diritto Canonico"
WHEN s.school_id = 326 THEN "Pontifical University of St. Thomas Aquinas Facolta de Diritto Canonico"
WHEN s.school_id = 327 THEN "Pontificia Universita Urbaniana"
WHEN s.school_id = 328 THEN "Pontificio Ateneo Antonianum"
WHEN s.school_id = 329 THEN "Pontificium Institutum Orientalium Studiorum Facultas Juris Canonico Orientalis"
WHEN s.school_id = 330 THEN "Potomac School of Law"
WHEN s.school_id = 331 THEN "Punjab University Department of Law"
WHEN s.school_id = 332 THEN "Queen's University Faculty of Law"
WHEN s.school_id = 333 THEN "Quinnipiac University School of Law"
WHEN s.school_id = 334 THEN "Rattsvetenskapliga Institutionen"
WHEN s.school_id = 335 THEN "Rechtswissenschaft"
WHEN s.school_id = 336 THEN "Rechtswissenschaftliche Fakultat"
WHEN s.school_id = 337 THEN "Rechtswissenschaftliche FakultatFriedrich-Schiller-Universitat"
WHEN s.school_id = 338 THEN "Regent University School of Law"
WHEN s.school_id = 339 THEN "Reynaldo G. Garza School of Law"
WHEN s.school_id = 340 THEN "Rheinische Friedrich-Wilhelms Universitat Rechtsfakultat"
WHEN s.school_id = 341 THEN "Rhodes University, Faculty of Law"
WHEN s.school_id = 342 THEN "Ridgecrest School of Law"
WHEN s.school_id = 343 THEN "Rijksuniversiteit Gent Faculteit van de Rechtsgeleerdheid"
WHEN s.school_id = 344 THEN "Rijksuniversiteit Groningen Faculteit der Rechtsgeleerdheid"
WHEN s.school_id = 346 THEN "Rijksuniversiteit Limburg Faculteit der Rechtsgeleerdheid"
WHEN s.school_id = 347 THEN "Rio Grande School of Law"
WHEN s.school_id = 348 THEN "Robert Gordon's Institute of Technology"
WHEN s.school_id = 349 THEN "Roger Williams University School of Law"
WHEN s.school_id = 350 THEN "Royalton College Law Center"
WHEN s.school_id = 351 THEN "Ruhr-Universitat Bochum Abteilung fur Rechtswissenschaft"
WHEN s.school_id = 352 THEN "Heidelberg University Faculty of Law"
WHEN s.school_id = 353 THEN "Rutgers, The State University of New Jersey School of Law - Camden"
WHEN s.school_id = 354 THEN "Rutgers, State University of New Jersey School of Law - Newark"
WHEN s.school_id = 355 THEN "Saint Louis University School of Law"
WHEN s.school_id = 356 THEN "Samford University, Cumberland School of Law"
WHEN s.school_id = 357 THEN "San Fernando Valley College of Law"
WHEN s.school_id = 358 THEN "San Francisco Law School"
WHEN s.school_id = 359 THEN "San Joaquin College of Law"
WHEN s.school_id = 360 THEN "San Mateo Law School"
WHEN s.school_id = 361 THEN "Santa Barbara College of Law"
WHEN s.school_id = 362 THEN "Santa Clara University School of Law"
WHEN s.school_id = 364 THEN "Seattle University School of Law"
WHEN s.school_id = 366 THEN "Seoul National University College of Law"
WHEN s.school_id = 367 THEN "Seton Hall University School of Law"
WHEN s.school_id = 368 THEN "Silicon Valley Law School"
WHEN s.school_id = 369 THEN "Silliman University College of Law"
WHEN s.school_id = 370 THEN "Simon Greenleaf School of Law"
WHEN s.school_id = 371 THEN "So. Massachusetts--rhode Island"
WHEN s.school_id = 372 THEN "Somerville Law School"
WHEN s.school_id = 373 THEN "South Bay University School of Law"
WHEN s.school_id = 374 THEN "South Texas College of Law"
WHEN s.school_id = 375 THEN "Southern California Institute of Law - Santa Barbara"
WHEN s.school_id = 376 THEN "Southern California Institute of Law - Ventura"
WHEN s.school_id = 377 THEN "Southern California University for Professional Studies"
WHEN s.school_id = 378 THEN "Southern Illinois University School of Law"
WHEN s.school_id = 379 THEN "Southern Methodist University, Dedman School of Law"
WHEN s.school_id = 380 THEN "Southern New England School of Law"
WHEN s.school_id = 381 THEN "Southern University Law Center"
WHEN s.school_id = 382 THEN "Southland University School of Law"
WHEN s.school_id = 383 THEN "Southwestern University School of Law"
WHEN s.school_id = 384 THEN "St Francis eUniversity Law School"
WHEN s.school_id = 386 THEN "St John's University School of Law"
WHEN s.school_id = 387 THEN "St Lawrence University School of Law"
WHEN s.school_id = 388 THEN "St Mary's University of San Antonio School of Law"
WHEN s.school_id = 389 THEN "St Paul College of Law"
WHEN s.school_id = 391 THEN "Stanford Law School"
WHEN s.school_id = 392 THEN "State University of New York at Buffalo School of Law"
WHEN s.school_id = 393 THEN "Stetson University College of Law"
WHEN s.school_id = 394 THEN "Stockholm University Faculty of Law"
WHEN s.school_id = 395 THEN "Suffolk University Law School"
WHEN s.school_id = 396 THEN "Syracuse University College of Law"
WHEN s.school_id = 397 THEN "Technische Hochschule Darmstadt"
WHEN s.school_id = 398 THEN "Technische Hochschule Merseburg Sektion Wirtschaftswissenschaften Institut fur Rechtswissenschaft"
WHEN s.school_id = 399 THEN "Technische Hochschule Zittau Fachgebiet Recht"
WHEN s.school_id = 400 THEN "Technische Universitat"
WHEN s.school_id = 401 THEN "Technische Universitat Chemnitz Sektion Wirtschaftswissenschaften"
WHEN s.school_id = 402 THEN "Technische Universitat Hannover Fakultat fur Rechtswissenschaften"
WHEN s.school_id = 403 THEN "Temple University - James E. Beasley School of Law"
WHEN s.school_id = 404 THEN "Texas Tech University School of Law"
WHEN s.school_id = 405 THEN "Texas A&M University School of Law"
WHEN s.school_id = 407 THEN "Charleston School of Law"
WHEN s.school_id = 408 THEN "College of Law of England and Wales, Chester"
WHEN s.school_id = 409 THEN "College of Law of England and Wales, Guilford"
WHEN s.school_id = 410 THEN "College of Law of England and Wales, London"
WHEN s.school_id = 412 THEN "Honourable Society of the Kings Inns"
WHEN s.school_id = 413 THEN "Incorporated Law Society of Ireland"
WHEN s.school_id = 415 THEN "Pennsylvania State University, Dickinson School of Law"
WHEN s.school_id = 416 THEN "Philips College"
WHEN s.school_id = 417 THEN "Thomas M. Cooley Law School"
WHEN s.school_id = 418 THEN "University of Hull Law School"
WHEN s.school_id = 419 THEN "University of Memphis - Cecil C. Humphreys School of Law"
WHEN s.school_id = 420 THEN "University of West Los Angeles School of Law - San Fernando Valley Campus"
WHEN s.school_id = 421 THEN "University of West Los Angeles School of Law - West Los Angeles"
WHEN s.school_id = 422 THEN "Thomas Jefferson School of Law"
WHEN s.school_id = 424 THEN "Thurgood Marshall School of Law"
WHEN s.school_id = 425 THEN "Tilburg University, Tilburg Law School"
WHEN s.school_id = 426 THEN "Touro College - Jacob D. Fuchsberg Law Center"
WHEN s.school_id = 427 THEN "Trinity College Dublin Faculty of Law"
WHEN s.school_id = 428 THEN "Trinity Law School"
WHEN s.school_id = 429 THEN "Tulane University Law School"
WHEN s.school_id = 430 THEN "Turun yliopisto Faculty of Law"
WHEN s.school_id = 431 THEN "Ukrainische Freie Universitat"
WHEN s.school_id = 432 THEN "Umea universitet, Law Institute"
WHEN s.school_id = 433 THEN "University of Calabar Faculty of Law"
WHEN s.school_id = 434 THEN "Universidad Autonoma de Barcelona Facultad de Derecho"
WHEN s.school_id = 435 THEN "Universidad Autonoma de Madrid Facultad de Derecho"
WHEN s.school_id = 436 THEN "Universidad Carlos III de Madrid Facultad de Derecho"
WHEN s.school_id = 437 THEN "Universidad Complutense de Madrid Facultad de Derecho"
WHEN s.school_id = 438 THEN "Universidad de Alcala de Henares Facultad de Derecho"
WHEN s.school_id = 439 THEN "Universidad de Alicante Facultad de Derecho"
WHEN s.school_id = 440 THEN "Universidad de Barcelona Facultad de Derecho"
WHEN s.school_id = 441 THEN "University of Cadiz Faculty of Law"
WHEN s.school_id = 442 THEN "Universidad de Cantabria Facultad de Derecho"
WHEN s.school_id = 443 THEN "Universidad de Castilla la Mancha Facultad de Derecho"
WHEN s.school_id = 444 THEN "University of Chile Law School"
WHEN s.school_id = 445 THEN "Universidad de Cordoba Facultad de Derecho"
WHEN s.school_id = 446 THEN "Universidad de Deusto Facultad de Derecho"
WHEN s.school_id = 447 THEN "Universidad de Extremadura Facultad de Derecho"
WHEN s.school_id = 448 THEN "Universidad de Girona Facultad de Derecho"
WHEN s.school_id = 449 THEN "Universidad de Granada Facultad de Derecho"
WHEN s.school_id = 450 THEN "Universidad de la Coruna Facultad de Derecho"
WHEN s.school_id = 451 THEN "Universidad de La Laguna Facultad de Derecho"
WHEN s.school_id = 452 THEN "Universidad de las Americas"
WHEN s.school_id = 453 THEN "Universidad de las islas Baleares Facultad de Derecho"
WHEN s.school_id = 454 THEN "Universidad de Las Palmas de Gran Canaria Facultad de Derecho"
WHEN s.school_id = 455 THEN "Universidad de Leon Facultad de Derecho"
WHEN s.school_id = 456 THEN "Universidad de Lleida Facultad de Derecho"
WHEN s.school_id = 457 THEN "Universidad de los Andes"
WHEN s.school_id = 458 THEN "Universidad de Malaga Facultad de Derecho"
WHEN s.school_id = 459 THEN "Universidad de Murcia Facultad de Derecho"
WHEN s.school_id = 460 THEN "Universidad de Navarra Facultad de Derecho"
WHEN s.school_id = 461 THEN "Universidad de Oviedo Facultad de Derecho"
WHEN s.school_id = 462 THEN "Universidad de Palermo"
WHEN s.school_id = 463 THEN "Universidad de Santiago de Compostela Facultad de Derecho"
WHEN s.school_id = 464 THEN "Universidad de Sevilla Facultad de Derecho"
WHEN s.school_id = 465 THEN "Universidad de Valencia Facultad de Derecho"
WHEN s.school_id = 466 THEN "Universidad de Valladolid Facultad de Derecho"
WHEN s.school_id = 468 THEN "Universidad de Vigo Facultad de Derecho"
WHEN s.school_id = 469 THEN "Universidad de Zaragoza Facultad de Derecho"
WHEN s.school_id = 470 THEN "Universidad del Pais Vasco Facultad de Derecho"
WHEN s.school_id = 471 THEN "Universidad Diego Portales"
WHEN s.school_id = 472 THEN "Universidad Interamericana de Puerto Rico, School of Law"
WHEN s.school_id = 473 THEN "Universidad Jaime I"
WHEN s.school_id = 474 THEN "Universidad Nacional de Educacion a Distancia Facultad de Derecho"
WHEN s.school_id = 475 THEN "Universidad Pompeu Fabra Facultad de Derecho"
WHEN s.school_id = 476 THEN "Universidad Pontifica de Comillas Facultad de Derecho"
WHEN s.school_id = 477 THEN "Universidade Autonoma de Lisboa/Luis de Camoes Faculdade de Direito"
WHEN s.school_id = 478 THEN "Universidade Catolica Portuguesa (Catholic University) Faculdade de Direito"
WHEN s.school_id = 479 THEN "Universita Cattolica \"Sacro Cuore\" Facolta di Giurisprudenza"
WHEN s.school_id = 480 THEN "Universita di Bari Facolta di Giurisprudenza"
WHEN s.school_id = 481 THEN "University of Bologna Faculty of Law"
WHEN s.school_id = 482 THEN "Universita di Cagliari Facolta di Giurisprudenza"
WHEN s.school_id = 483 THEN "Universita di Camerino Facolta di Giurisprudenza"
WHEN s.school_id = 484 THEN "Universita di Catania Facolta di Giurisprudenza"
WHEN s.school_id = 485 THEN "Universita di Catanzaro Facolta di Giurisprudenza"
WHEN s.school_id = 486 THEN "Universita di Ferrara Facolta di Giurisprudenza"
WHEN s.school_id = 487 THEN "Universita di Firenze Facolta di Giurisprudenza"
WHEN s.school_id = 488 THEN "Universita di Genova Facolta di Giurisprudenza"
WHEN s.school_id = 489 THEN "Universita di Macerata Facolta di Giurisprudenza"
WHEN s.school_id = 490 THEN "Universita di Messina Facolta di Giurisprudenza"
WHEN s.school_id = 491 THEN "Universita di Milano Facolta di Giurisprudenza"
WHEN s.school_id = 492 THEN "Universita di Modena Facolta di Giurisprudenza"
WHEN s.school_id = 493 THEN "Universita di Napoli Facolta di Giurisprudenza"
WHEN s.school_id = 494 THEN "Universita di Padova Facolta di Giurisprudenza"
WHEN s.school_id = 495 THEN "Universita di Palermo Facolta di Giurisprudenza"
WHEN s.school_id = 496 THEN "Universita di Parma Facolta di Giurisprudenza"
WHEN s.school_id = 497 THEN "Universita di Pavia Facolta di Giurisprudenza"
WHEN s.school_id = 498 THEN "Universita di Perugia Facolta di Giurisprudenza"
WHEN s.school_id = 499 THEN "Universita di Pisa Facolta di Giurisprudenza"
WHEN s.school_id = 500 THEN "Universita di Roma Facolta di Giurisprudenza"
WHEN s.school_id = 502 THEN "Universita di Salerno Facolta di Giurisprudenza"
WHEN s.school_id = 503 THEN "Universita di Sassari Facolta di Giurisprudenza"
WHEN s.school_id = 504 THEN "Universita di Siena Facolta di Giurisprudenza"
WHEN s.school_id = 505 THEN "Universita di Teramo Facolta di Giurisprudenza"
WHEN s.school_id = 506 THEN "Universita di Torino Facolta di Giurisprudenza"
WHEN s.school_id = 507 THEN "Universita di Trento Facolta di Giurisprudenza"
WHEN s.school_id = 508 THEN "Universita di Trieste Facolta di Giurisprudenza"
WHEN s.school_id = 509 THEN "Universita di Urbino Facolta di Giurisprudenza"
WHEN s.school_id = 510 THEN "Universita L.U.I.S.S. Facolta di Giurisprudenza"
WHEN s.school_id = 511 THEN "Universita Pontificia Salesiana"
WHEN s.school_id = 512 THEN "Universitaire Faculteiten Sint-Aloysius Faculteit Rechtsgeleerdheid"
WHEN s.school_id = 513 THEN "University of Antwerp Faculty of Law"
WHEN s.school_id = 514 THEN "Universitaire Instelling Antwerpen (UIA) Faculteit Rechtsgeleerdheid"
WHEN s.school_id = 515 THEN "Universitat Augsburg Juristischer Fachbereich"
WHEN s.school_id = 516 THEN "Universitat Basel - Juristische Fakultat Institut fur Rechtswissenschaft"
WHEN s.school_id = 517 THEN "Universitat Bayreuth"
WHEN s.school_id = 518 THEN "Universitat Bielefeld Fakultat fur Rechtswissenschaft"
WHEN s.school_id = 519 THEN "Universitat Bremen Juristenausbildung"
WHEN s.school_id = 520 THEN "Universitat de Bern (University Bern) Faculty of Jurisprudence and Economics"
WHEN s.school_id = 521 THEN "Universitat des Saarlandes"
WHEN s.school_id = 522 THEN "Universitat fur Bildungswissenschaftung Institut fur Rechtswissenschaft"
WHEN s.school_id = 523 THEN "University of Hamburg Faculty of Law"
WHEN s.school_id = 524 THEN "University of Innsbruck Faculty of Law"
WHEN s.school_id = 525 THEN "Universitat KonstanzRechtswissenschaft"
WHEN s.school_id = 526 THEN "Universitat Mannheim (WH) FFakultat fur Rechtswissenschaft"
WHEN s.school_id = 527 THEN "Universitat Munchen"
WHEN s.school_id = 528 THEN "Universitat Regensburg Fachbereich Rechtswissenschaft"
WHEN s.school_id = 529 THEN "Universitat Salzburg Rechtswissenschaftliche Fakultat"
WHEN s.school_id = 530 THEN "Universitat Wien Rechtswissenschaftliche Fakultat"
WHEN s.school_id = 531 THEN "University of Zurich Faculty of Law"
WHEN s.school_id = 532 THEN "Universite Catholique de Louvain Faculte de Droit"
WHEN s.school_id = 533 THEN "Universite D'Angers Faculte de Droit et Sciences Economiques"
WHEN s.school_id = 535 THEN "Universite de Brest"
WHEN s.school_id = 536 THEN "Universite de Caen Faculte de Droit et des Sciences Politiques"
WHEN s.school_id = 537 THEN "Universite de Clermont-Ferrand I Sciences Juridiques et Politiques"
WHEN s.school_id = 538 THEN "Universite de Dijon Faculte de Droit et de Sciences Politiques"
WHEN s.school_id = 540 THEN "Universite de Franche-Comte (Besancon)"
WHEN s.school_id = 541 THEN "Universite de Fribourg Faculte de Droit"
WHEN s.school_id = 542 THEN "Universite de Geneve Facultat de Droit"
WHEN s.school_id = 543 THEN "Universite de Grenoble II"
WHEN s.school_id = 544 THEN "Universite de Lausanne Faculte de droit"
WHEN s.school_id = 545 THEN "Universite de Liege Faculte de Droit"
WHEN s.school_id = 546 THEN "Universite de Lille II Faculte des Sciences Juridiques"
WHEN s.school_id = 547 THEN "Universite de Limoges Faculte de Droit et des Sciences Economiques"
WHEN s.school_id = 548 THEN "Universite de Metz U.E.R. Sciences Juridiques, Economiques et Sociales"
WHEN s.school_id = 549 THEN "Universite de Montpellier I Faculte de Droit et des Sciences Economiques"
WHEN s.school_id = 550 THEN "Universite de Nancy II"
WHEN s.school_id = 551 THEN "Universite de Nantes UFR Droit el Scicures"
WHEN s.school_id = 552 THEN "Universite de Neuchatel Faculte de Droit"
WHEN s.school_id = 553 THEN "Universite de Nice UFR Sciences Juridiques, Politiques, Economiques et de Gestion"
WHEN s.school_id = 554 THEN "Pantheon-Sorbonne University, Sorbonne Law School (Paris I)"
WHEN s.school_id = 555 THEN "Pantheon-Assas University Faculty of Law (Paris II)"
WHEN s.school_id = 556 THEN "Paris West University Nanterre La Defense Faculty of Law (Paris X)"
WHEN s.school_id = 557 THEN "University of Paris-Sud Faculty of Law (Paris XI)"
WHEN s.school_id = 558 THEN "Universite de Paris XII Faculte de Droit et des Sciences Economiques"
WHEN s.school_id = 559 THEN "Universite de Paris XIII Law and Political Sciences"
WHEN s.school_id = 560 THEN "Universite de Pau"
WHEN s.school_id = 561 THEN "Universite de Picardie"
WHEN s.school_id = 562 THEN "Universite de Poitiers UFR Droit et Sciences Sociales"
WHEN s.school_id = 563 THEN "Universite de Quebec a Montreal JURIS"
WHEN s.school_id = 564 THEN "Universite de Reims"
WHEN s.school_id = 565 THEN "Universite de Rennes I Faculte de Droite et Sciences Politiques"
WHEN s.school_id = 566 THEN "Universite de Rouen Faculte de Droit et des Sciences Economiques"
WHEN s.school_id = 567 THEN "Universite de Saint-Etienne Faculte de Droit et Economiques et de Gestion"
WHEN s.school_id = 568 THEN "Universite de St. Gallen for Business Administration, Economics, Law and Social Sciences"
WHEN s.school_id = 569 THEN "Universite d'Orleans"
WHEN s.school_id = 570 THEN "Universite du Droit et de La Sante Lille II Service Universitaire Accueil Information Orientation"
WHEN s.school_id = 572 THEN "Universite Libre de Bruxelles Faculte de Droit"
WHEN s.school_id = 573 THEN "Universite Lyon II Lumiere Faculte des Sciences Juridiques"
WHEN s.school_id = 574 THEN "Universiteit Brussel Rechtsfaculteit"
WHEN s.school_id = 575 THEN "University of Amsterdam Faculty of Law"
WHEN s.school_id = 576 THEN "Utrecht University School of Law"
WHEN s.school_id = 577 THEN "Universitet i Bergen Det Juridiske Fakultet"
WHEN s.school_id = 578 THEN "University of Oslo Faculty of Law"
WHEN s.school_id = 579 THEN "Universitet i Tromso Institutter for Rettsvitenskap"
WHEN s.school_id = 580 THEN "Universitet Island Faculty of Law"
WHEN s.school_id = 581 THEN "University College Cork Faculty of Law"
WHEN s.school_id = 582 THEN "University College Dublin, Sutherland School of Law"
WHEN s.school_id = 583 THEN "University College Faculty of Law"
WHEN s.school_id = 584 THEN "University of Akron, C. Blake McDowell Law Center"
WHEN s.school_id = 585 THEN "University of Alabama School of Law"
WHEN s.school_id = 586 THEN "University of Alberta Faculty of Law"
WHEN s.school_id = 587 THEN "University of Arizona College of Law"
WHEN s.school_id = 588 THEN "University of Arkansas at Little Rock, William H. Bowen School of Law"
WHEN s.school_id = 589 THEN "University of Arkansas, Fayetteville, Leflar Law Center"
WHEN s.school_id = 591 THEN "University of Baltimore School of Law"
WHEN s.school_id = 592 THEN "University of Bridgeport School of Law"
WHEN s.school_id = 593 THEN "University of British Columbia School of Law"
WHEN s.school_id = 595 THEN "University of Buenos Aires Faculty of Law"
WHEN s.school_id = 596 THEN "University of Calgary, Faculty of Law"
WHEN s.school_id = 597 THEN "University of California at Berkeley, Boalt Hall School of Law"
WHEN s.school_id = 598 THEN "University of California at Davis School of Law"
WHEN s.school_id = 599 THEN "University of California at Los Angeles School of Law"
WHEN s.school_id = 600 THEN "University of California, Hastings College of the Law"
WHEN s.school_id = 601 THEN "University of Canterbury School of Law"
WHEN s.school_id = 603 THEN "University of Cape Town Faculty of Law"
WHEN s.school_id = 604 THEN "University of Chicago Law School"
WHEN s.school_id = 605 THEN "University of Cincinnati College of Law"
WHEN s.school_id = 606 THEN "University of Colorado School of Law"
WHEN s.school_id = 607 THEN "University of Connecticut School of Law"
WHEN s.school_id = 608 THEN "University of Copenhagen Faculty of Law"
WHEN s.school_id = 609 THEN "University of Dayton School of Law"
WHEN s.school_id = 610 THEN "University of Denver Sturm College of Law"
WHEN s.school_id = 611 THEN "University of Detroit Mercy School of Law"
WHEN s.school_id = 613 THEN "University of Dundee Faculty of Law"
WHEN s.school_id = 615 THEN "University of Florida, Fredric G. Levin College of Law"
WHEN s.school_id = 616 THEN "University of Georgia School of Law"
WHEN s.school_id = 617 THEN "University of Glasgow Faculty of Law,"
WHEN s.school_id = 618 THEN "University of Groningen Faculty of Law"
WHEN s.school_id = 619 THEN "University of Hawaii at Manoa - William S. Richardson School of Law"
WHEN s.school_id = 620 THEN "University of Hong Kong Faculty of Law"
WHEN s.school_id = 621 THEN "University of Honolulu School of Law"
WHEN s.school_id = 622 THEN "University of Houston Law Center"
WHEN s.school_id = 623 THEN "University of Idaho College of Law"
WHEN s.school_id = 624 THEN "University of Illinois College of Law"
WHEN s.school_id = 625 THEN "University of Iowa College of Law"
WHEN s.school_id = 626 THEN "University of Jabalpur Department of Law"
WHEN s.school_id = 627 THEN "University of Kansas School of Law"
WHEN s.school_id = 628 THEN "University of Kentucky College of Law"
WHEN s.school_id = 629 THEN "University of La Verne College of Law"
WHEN s.school_id = 630 THEN "University of Lagos Faculty of Law"
WHEN s.school_id = 632 THEN "University of Limerick Law Department"
WHEN s.school_id = 633 THEN "University of London School of Law"
WHEN s.school_id = 634 THEN "University of Maine School of Law"
WHEN s.school_id = 635 THEN "University of Malta Faculty of Law"
WHEN s.school_id = 636 THEN "University of Manitoba Faculty of Law"
WHEN s.school_id = 637 THEN "University of Maryland School of Law"
WHEN s.school_id = 639 THEN "University of Miami School of Law"
WHEN s.school_id = 640 THEN "University of Michigan Law School"
WHEN s.school_id = 641 THEN "University of Minnesota Law School"
WHEN s.school_id = 642 THEN "University of Mississippi School of Law"
WHEN s.school_id = 643 THEN "University of Missouri - Columbia School of Law"
WHEN s.school_id = 644 THEN "University of Missouri - Kansas City School of Law"
WHEN s.school_id = 645 THEN "University of Montana School of Law"
WHEN s.school_id = 646 THEN "University of Montreal Faculty of Law"
WHEN s.school_id = 647 THEN "University of Mumbai Faculty of Law"
WHEN s.school_id = 648 THEN "University of Munster Faculty of Law"
WHEN s.school_id = 649 THEN "University of Natal Faculty of Law"
WHEN s.school_id = 650 THEN "University of Nebraska College of Law"
WHEN s.school_id = 651 THEN "University of Nevada Las Vegas, William S. Boyd School of Law"
WHEN s.school_id = 652 THEN "University of New Brunswick Law School (Fredericton)"
WHEN s.school_id = 653 THEN "University of New Brunswick Law School (Saint John)"
WHEN s.school_id = 654 THEN "University of New Mexico School of Law"
WHEN s.school_id = 655 THEN "University of North Carolina School of Law"
WHEN s.school_id = 656 THEN "University of North Dakota School of Law"
WHEN s.school_id = 657 THEN "University of Northern California - Lorenzo Patino School of Law"
WHEN s.school_id = 658 THEN "University of Oklahoma College of Law"
WHEN s.school_id = 659 THEN "University of Oregon School of Law"
WHEN s.school_id = 660 THEN "University of Osijek Faculty of Law"
WHEN s.school_id = 661 THEN "University of Otago Faculty of Law"
WHEN s.school_id = 662 THEN "University of Ottawa Faculty of Law (Universite d'Ottawa Faculte de droit)"
WHEN s.school_id = 663 THEN "University of Panama Faculty of Law"
WHEN s.school_id = 664 THEN "University of Pennsylvania Law School"
WHEN s.school_id = 665 THEN "University of Pittsburgh School of Law"
WHEN s.school_id = 666 THEN "University of Puerto Rico School of Law"
WHEN s.school_id = 667 THEN "University of Puget Sound School of Law"
WHEN s.school_id = 668 THEN "University of Richmond, The T. C. Williams School of Law"
WHEN s.school_id = 669 THEN "University of Rijeka Faculty of Law"
WHEN s.school_id = 670 THEN "University of Salamanca School of Law"
WHEN s.school_id = 671 THEN "University of San Diego School of Law"
WHEN s.school_id = 672 THEN "University of San Francisco School of Law"
WHEN s.school_id = 674 THEN "University of Saskatchewan College of Law"
WHEN s.school_id = 675 THEN "University of Sherbrooke Faculty of Law"
WHEN s.school_id = 676 THEN "University of South Carolina School of Law"
WHEN s.school_id = 677 THEN "University of South Dakota School of Law"
WHEN s.school_id = 678 THEN "University of Southern California Law School"
WHEN s.school_id = 679 THEN "University of Split Faculty of Law"
WHEN s.school_id = 680 THEN "University of St. Thomas School of Law - Minneapolis"
WHEN s.school_id = 681 THEN "University of Strathclyde School of Law,"
WHEN s.school_id = 682 THEN "University of Sydney, Sydney Law School"
WHEN s.school_id = 683 THEN "University of Tartu, Faculty of Law"
WHEN s.school_id = 684 THEN "University of Tennessee College of Law"
WHEN s.school_id = 685 THEN "University of Texas School of Law"
WHEN s.school_id = 687 THEN "University of The East College of Law"
WHEN s.school_id = 688 THEN "University of the Philippines College of Law"
WHEN s.school_id = 689 THEN "University of the West of England, Department of Law"
WHEN s.school_id = 690 THEN "University of Toledo College of Law"
WHEN s.school_id = 691 THEN "University of Toronto Faculty of Law"
WHEN s.school_id = 692 THEN "University of Tromsoe Faculty of Law"
WHEN s.school_id = 693 THEN "University of Tulsa College of Law"
WHEN s.school_id = 694 THEN "University of Utah S.J. Quinney College of Law"
WHEN s.school_id = 695 THEN "University of Victoria Faculty of Law"
WHEN s.school_id = 696 THEN "Victoria University of Wellington Faculty of Law"
WHEN s.school_id = 697 THEN "University of Virginia School of Law"
WHEN s.school_id = 698 THEN "University of Waikato School of Law"
WHEN s.school_id = 699 THEN "University of Washington School of Law"
WHEN s.school_id = 701 THEN "University of Western Ontario Faculty of Law"
WHEN s.school_id = 702 THEN "University of Windsor Faculty of Law"
WHEN s.school_id = 703 THEN "University of Wisconsin Law School"
WHEN s.school_id = 704 THEN "University of Witwatersrand Faculty of Law"
WHEN s.school_id = 705 THEN "University of Wyoming College of Law"
WHEN s.school_id = 706 THEN "University of Zagreb Faculty of Law"
WHEN s.school_id = 707 THEN "Uppsala University Department Of Law"
WHEN s.school_id = 708 THEN "US Army JAG School"
WHEN s.school_id = 709 THEN "Valparaiso University School of Law"
WHEN s.school_id = 710 THEN "Van Norman University College of Law"
WHEN s.school_id = 711 THEN "Vanderbilt University Law School"
WHEN s.school_id = 712 THEN "Ventura College of Law"
WHEN s.school_id = 713 THEN "Vermont Law School"
WHEN s.school_id = 714 THEN "Vice Dean, Faculty of Law Sofia University"
WHEN s.school_id = 715 THEN "Villanova University School of Law"
WHEN s.school_id = 716 THEN "Virginia Law School"
WHEN s.school_id = 717 THEN "VMU School of Law"
WHEN s.school_id = 718 THEN "Vrije Universiteit Faculty of law"
WHEN s.school_id = 719 THEN "Vytautas Magnus University School of Law"
WHEN s.school_id = 720 THEN "Wake Forest University School of Law"
WHEN s.school_id = 721 THEN "Washburn University School of Law"
WHEN s.school_id = 722 THEN "Washington and Lee University School of Law"
WHEN s.school_id = 723 THEN "Washington University School of Law"
WHEN s.school_id = 724 THEN "Wayne State University Law School"
WHEN s.school_id = 725 THEN "West Coast School of Law"
WHEN s.school_id = 726 THEN "West Haven University School of Law"
WHEN s.school_id = 727 THEN "West Virginia University College of Law"
WHEN s.school_id = 728 THEN "Western New England College School of Law"
WHEN s.school_id = 729 THEN "Western Sierra Law School"
WHEN s.school_id = 731 THEN "Western State University College of Law"
WHEN s.school_id = 732 THEN "Westfalische Wilhelms University Faculty of Law"
WHEN s.school_id = 733 THEN "Whittier College School of Law"
WHEN s.school_id = 735 THEN "Widener University School of Law"
WHEN s.school_id = 736 THEN "Willamette University College of Law"
WHEN s.school_id = 737 THEN "William & Mary Law School"
WHEN s.school_id = 738 THEN "William Howard Taft University School of Law"
WHEN s.school_id = 739 THEN "William Mitchell College of Law"
WHEN s.school_id = 740 THEN "Wirschaftsuniversitat Wien Buro des Rektors"
WHEN s.school_id = 741 THEN "Woodrow Wilson College of Law"
WHEN s.school_id = 742 THEN "Yale Law School"
WHEN s.school_id = 743 THEN "Yeshiva University, Benjamin N. Cardozo School of Law"
WHEN s.school_id = 744 THEN "Aberdeen University Faculty of Law"
WHEN s.school_id = 2902 THEN "Augusta Law School"
WHEN s.school_id = 2905 THEN "Balboa Law College"
WHEN s.school_id = 2909 THEN "Central California College School Of Law"
WHEN s.school_id = 2911 THEN "Detroit College of Law"
WHEN s.school_id = 2914 THEN "Franklin University Law School"
WHEN s.school_id = 2919 THEN "Gerry Spence Trial Lawyers College"
WHEN s.school_id = 2940 THEN "National Judicial College"
WHEN s.school_id = 2992 THEN "William McKinley School of Law"
WHEN s.school_id = 2994 THEN "Lake Erie Law School"
WHEN s.school_id = 2995 THEN "Columbus College of Law"
WHEN s.school_id = 3013 THEN "Widener University School of Law, Harrisburg PA"
WHEN s.school_id = 3043 THEN "Memphis State University School of Law"
WHEN s.school_id = 3053 THEN "Tufts University - Fletcher School of Law and Diplomacy"
WHEN s.school_id = 3063 THEN "Lewis University College of Law"
WHEN s.school_id = 3070 THEN "Loyola University School of Law"
WHEN s.school_id = 3071 THEN "Lincoln Law School"
WHEN s.school_id = 3075 THEN "Rutgers University School of Law"
WHEN s.school_id = 3076 THEN "Indiana University School of Law"
WHEN s.school_id = 3081 THEN "University of Missouri School of Law"
WHEN s.school_id = 3132 THEN "Southern California Institute of Law"
WHEN s.school_id = 3137 THEN "University of California School of Law"
WHEN s.school_id = 3164 THEN "Kyushu University, Faculty of Law"
WHEN s.school_id = 3171 THEN "Instituto Tecnologico y de Estudios Superiores de Monterrey"
WHEN s.school_id = 3176 THEN "Universitat Leipzig School of Law"
WHEN s.school_id = 3179 THEN "University of Liege Law School"
WHEN s.school_id = 3202 THEN "Peoples' Friendship University of Russia School of Law"
WHEN s.school_id = 3209 THEN "Bangalore University, Law College"
WHEN s.school_id = 3217 THEN "University of Tokyo Faculty of Law"
WHEN s.school_id = 3223 THEN "Universidad Panamericana Faculty of Law"
WHEN s.school_id = 3224 THEN "Waseda Law School"
WHEN s.school_id = 3237 THEN "University of Wollongong Faculty of Law"
WHEN s.school_id = 3247 THEN "University of Heidelberg School of Law"
WHEN s.school_id = 3249 THEN "University of Strathclyde, Faculty of Law, Arts & Social Sciences"
WHEN s.school_id = 3250 THEN "University of Nottingham School of Law"
WHEN s.school_id = 3251 THEN "University of New South Wales Faculty of Law"
WHEN s.school_id = 3256 THEN "Babes-Bolyai University, School of Law"
WHEN s.school_id = 3275 THEN "James Cook University Faculty of Law"
WHEN s.school_id = 3276 THEN "Escuela Libre de Derecho"
WHEN s.school_id = 3285 THEN "De Montfort Law School"
WHEN s.school_id = 3289 THEN "European University Institute Department of Law"
WHEN s.school_id = 3296 THEN "University of Exeter School of Law"
WHEN s.school_id = 3301 THEN "Johannes Gutenberg University of Mainz Faculty of Law"
WHEN s.school_id = 3305 THEN "Delhi University, Faculty of Law"
WHEN s.school_id = 3306 THEN "University of Florence School of Law"
WHEN s.school_id = 3307 THEN "Sofia University Faculty of Law"
WHEN s.school_id = 3312 THEN "Far Eastern University Institute of Law"
WHEN s.school_id = 3316 THEN "University of Adelaide Law School"
WHEN s.school_id = 3319 THEN "Federal University of Rio de Janeiro Faculty of Law"
WHEN s.school_id = 3330 THEN "Fontbonne College Law School"
WHEN s.school_id = 3336 THEN "Immanuel Kant State University of Russia Law School"
WHEN s.school_id = 3343 THEN "Keio University Faculty of Law"
WHEN s.school_id = 3344 THEN "Kensington University College of Law"
WHEN s.school_id = 3345 THEN "University of Kerala College of Law"
WHEN s.school_id = 3356 THEN "Korea University Law School"
WHEN s.school_id = 3364 THEN "Free University of Brussels Faculty of Law"
WHEN s.school_id = 3368 THEN "University of Freiburg School of Law"
WHEN s.school_id = 3371 THEN "Kyoto University Faculty of Law"
WHEN s.school_id = 3379 THEN "Fu Jen Catholic University School of Law"
WHEN s.school_id = 3381 THEN "Fudan University School of Law"
WHEN s.school_id = 3389 THEN "Catholic University of Leuven, School of Law"
WHEN s.school_id = 3393 THEN "Gilbert Johnson Law School"
WHEN s.school_id = 3400 THEN "Hamilton College Law School"
WHEN s.school_id = 3403 THEN "Golden West University"
WHEN s.school_id = 3412 THEN "Government Law College"
WHEN s.school_id = 3421 THEN "University of Bern School of Law"
WHEN s.school_id = 3423 THEN "University of Leeds School of Law"
WHEN s.school_id = 3426 THEN "Central European University, Legal Studies Department"
WHEN s.school_id = 3430 THEN "Hebrew University of Jerusalem Faculty of Law"
WHEN s.school_id = 3431 THEN "Liverpool John Moores University School of Law"
WHEN s.school_id = 3443 THEN "London Guildhall University School of Law"
WHEN s.school_id = 3445 THEN "Beijing University School of Law"
WHEN s.school_id = 3453 THEN "Himachal Pradesh University School of Law"
WHEN s.school_id = 3456 THEN "Guangdong University of Foreign Studies School of Law"
WHEN s.school_id = 3458 THEN "Guildford College of Law"
WHEN s.school_id = 3459 THEN "Hitotsubashi University Law School"
WHEN s.school_id = 3465 THEN "Nanjing University School of Law"
WHEN s.school_id = 3469 THEN "Hokkaido University School of Law"
WHEN s.school_id = 3475 THEN "National Cheng-Chi University School of Law"
WHEN s.school_id = 3481 THEN "National Law School of India University"
WHEN s.school_id = 3483 THEN "Hosei University School of Law"
WHEN s.school_id = 3485 THEN "National University of Ireland Faculty of Law"
WHEN s.school_id = 3506 THEN "University of Augsburg, Munich Intellectual Property Law Center"
WHEN s.school_id = 3512 THEN "Catholic University of America, Columbus School of Law"
WHEN s.school_id = 3530 THEN "St. Thomas University School of Law"
WHEN s.school_id = 3532 THEN "Concord Law School"
WHEN s.school_id = 3536 THEN "University of the District of Columbia, David A. Clarke School of Law"
WHEN s.school_id = 3539 THEN "Saratoga University School of Law"
WHEN s.school_id = 3544 THEN "Maharishi Dayanand University Faculty of Law"
WHEN s.school_id = 3545 THEN "New England Law Boston"
WHEN s.school_id = 3547 THEN "St Xavier Law School"
WHEN s.school_id = 3575 THEN "St. Marys University School of Law"
WHEN s.school_id = 3581 THEN "University of Akron School of Law"
WHEN s.school_id = 3591 THEN "University of Massachusetts School of Law"
WHEN s.school_id = 3755 THEN "University of New Hampshire School of Law"
WHEN s.school_id = 4068 THEN "John Marshall Law School"
WHEN s.school_id = 4071 THEN "University of Belgrade Faculty of Law"
WHEN s.school_id = 4284 THEN "Free University of Amsterdam Faculty of Law"
WHEN s.school_id = 4300 THEN "California Southern University School of Law"
WHEN s.school_id = 4302 THEN "Drexel University Earle Mack School of Law"
WHEN s.school_id = 4330 THEN "Jackson School of Law"
WHEN s.school_id = 4331 THEN "La Salle Extension University Law School"
WHEN s.school_id = 4334 THEN "McGill University Faculty of Law"
WHEN s.school_id = 4336 THEN "Phoenix School of Law"
WHEN s.school_id = 4337 THEN "Panjab University, Department of Laws"
WHEN s.school_id = 4343 THEN "Peoples College of Law"
WHEN s.school_id = 4347 THEN "City University of New York School of Law"
WHEN s.school_id = 4351 THEN "University of Edinburgh School of Law"
WHEN s.school_id = 4492 THEN "City University London, City Law School"
WHEN s.school_id = 4516 THEN "University of Manchester School of Law"
WHEN s.school_id = 4646 THEN "Meiji University School of Law"
WHEN s.school_id = 4663 THEN "Autonomous University of Nuevo Leon Faculty of Law"
WHEN s.school_id = 4664 THEN "Norwich Law School"
WHEN s.school_id = 4719 THEN "University of Anahuac Faculty of Law"
WHEN s.school_id = 4724 THEN "Eberhard Karls University Faculty of Law"
WHEN s.school_id = 4746 THEN "Temple University School of Law, Tokyo"
WHEN s.school_id = 4771 THEN "Tsinghua University School of Law"
WHEN s.school_id = 4783 THEN "Queen Mary University of London School of Law"
WHEN s.school_id = 4787 THEN "University of Ghana Faculty of Law"
WHEN s.school_id = 4801 THEN "University of Nueva Caceres College of Law"
WHEN s.school_id = 4802 THEN "Rand Afrikaans University Faculty of Law"
WHEN s.school_id = 4814 THEN "Soochow University School of Law"
WHEN s.school_id = 4842 THEN "Ateneo de Davao University College of Law"
WHEN s.school_id = 4844 THEN "University of Cambridge Faculty of Law"
WHEN s.school_id = 4850 THEN "University of Arkansas School of Law"
WHEN s.school_id = 4853 THEN "Lebanese University Faculty of Law, Political and Administrative Sciences"
WHEN s.school_id = 4864 THEN "Free University of Bogota Colombia, Faculty of Law"
WHEN s.school_id = 4865 THEN "University of Vienna School of Law"
WHEN s.school_id = 4867 THEN "China University of Political Science and Law"
WHEN s.school_id = 4869 THEN "Tel Aviv University Faculty of Law"
WHEN s.school_id = 4870 THEN "University of Auckland Faculty of Law"
WHEN s.school_id = 4871 THEN "Peking University Law School"
WHEN s.school_id = 4878 THEN "Cardiff University Law School"
WHEN s.school_id = 4879 THEN "University of Hertfordshire School of Law"
WHEN s.school_id = 4880 THEN "University of North Texas at Dallas College of Law"
WHEN s.school_id = 4881 THEN "University of Sussex Law School"
WHEN s.school_id = 4882 THEN "Oliver Schreiner School of Law"
WHEN s.school_id = 4992 THEN "University of Bucharest Faculty of Law"
WHEN s.school_id = 5025 THEN "Maastricht University Faculty of Law"
WHEN s.school_id = 5029 THEN "Saint Petersburg State University, Faculty of Law"
WHEN s.school_id = 5176 THEN "Samara State University School of Law"
WHEN s.school_id = 5329 THEN "Abraham Lincoln University School of Law"
WHEN s.school_id = 5330 THEN "Humphreys College Laurence Drivon School of Law"
WHEN s.school_id = 5451 THEN "University of West Los Angeles School of Law"
WHEN s.school_id = 5452 THEN "Hugh Wooding Law School"
WHEN s.school_id = 5460 THEN "Westminster University School of Law"
WHEN s.school_id = 5580 THEN "Handong International Law School"
WHEN s.school_id = 5619 THEN "Lviv University Faculty of Law"
WHEN s.school_id = 5625 THEN "University of Dusseldorf Faculty of Law"
WHEN s.school_id = 5645 THEN "Dimitrie Cantemir Christian University School of Law"
WHEN s.school_id = 5653 THEN "University of San Luis Obispo School of Law"
WHEN s.school_id = 5654 THEN "Arizona Summit Law School"
WHEN s.school_id = 5655 THEN "Lincoln Memorial University – Duncan School of Law"
WHEN s.school_id = 5656 THEN "Texas Wesleyan University School of Law"
WHEN s.school_id = 5659 THEN "Sri Lanka Law College"
WHEN s.school_id = 5661 THEN "University of California, Irvine School of Law"
WHEN s.school_id = 5665 THEN "Oxford Brookes University School of Law"
WHEN s.school_id = 5666 THEN "University of Melbourne, Melbourne Law School"
WHEN s.school_id = 5669 THEN "Belmont University College of Law"
WHEN s.school_id = 5677 THEN "University of Oxford Faculty of Law"
WHEN s.school_id = 5678 THEN "London School of Economics and Political Science, Law Department"
WHEN s.school_id = 5679 THEN "University College London Faculty of Law"
WHEN s.school_id = 5680 THEN "Durham Law School"
WHEN s.school_id = 5681 THEN "University of Warwick School of Law"
WHEN s.school_id = 5682 THEN "Sungkyunkwan University College of Law"
WHEN s.school_id = 5683 THEN "Yonsei University College of Law"
WHEN s.school_id = 5684 THEN "Sapienza University of Rome Faculty of Law"
WHEN s.school_id = 5685 THEN "Chinese University of Hong Kong Faculty of Law"
WHEN s.school_id = 5686 THEN "Goethe University Frankfurt Faculty of Law"
WHEN s.school_id = 5687 THEN "Paris Institute of Political Studies (Sciences Po)"
WHEN s.school_id = 5688 THEN "Shanghai Jiao Tong University, KoGuan Law School"
WHEN s.school_id = 5690 THEN "Pontifical Catholic University of Chile Faculty of Law"
WHEN s.school_id = 5691 THEN "University of Sao Paulo Faculty of Law"
WHEN s.school_id = 5692 THEN "Ghent University Faculty of Law"
WHEN s.school_id = 5694 THEN "University of Sydney Law School"
WHEN s.school_id = 5695 THEN "University of Queensland, TC Beirne School of Law"
WHEN s.school_id = 5697 THEN "Griffith University, Griffith Law School"
WHEN s.school_id = 5698 THEN "University of Western Australia Faculty of Law"
WHEN s.school_id = 5702 THEN "Obafemi Awolowo University Faculty of Law"
WHEN s.school_id = 5703 THEN "College of Law of England and Wales"
WHEN s.school_id = 5705 THEN "Volgograd State University Faculty of Law"
WHEN s.school_id = 5706 THEN "Ghana School of Law"
WHEN s.school_id = 5708 THEN "Savannah Law School"
WHEN s.school_id = 5710 THEN "Roger Williams University, Ralph R. Papitto School of Law"
WHEN s.school_id = 5711 THEN "Mitchell Hamline School of Law"
ELSE NULL
END LawSchoolName
,CASE
  WHEN s.graduation_date > ld.FirstLicenseDate
      THEN 0
  WHEN s.graduation_date IS NULL
      THEN 0
  WHEN ld.FirstLicenseDate IS NULL
      THEN 0
  ELSE 1
 END IsPreLicense
FROM src.barrister_professional_school s
  LEFT JOIN license_discipline ld
      ON ld.professional_id = s.professional_id
WHERE school_id IN (
2
,3
,4
,6
,7
,8
,9
,10
,11
,12
,13
,14
,15
,16
,17
,18
,19
,20
,21
,22
,23
,24
,25
,26
,27
,28
,29
,30
,31
,32
,33
,34
,35
,36
,37
,38
,39
,40
,41
,42
,43
,44
,45
,46
,47
,48
,49
,50
,51
,53
,54
,55
,56
,57
,59
,60
,61
,62
,63
,64
,65
,66
,67
,68
,69
,70
,71
,72
,73
,74
,75
,76
,77
,78
,79
,80
,81
,82
,83
,85
,86
,87
,88
,89
,90
,91
,92
,93
,94
,95
,96
,97
,98
,99
,100
,101
,102
,103
,104
,105
,106
,107
,108
,109
,110
,111
,112
,113
,114
,115
,116
,117
,118
,119
,120
,121
,122
,123
,124
,125
,126
,127
,128
,129
,130
,131
,132
,133
,134
,135
,136
,137
,138
,139
,140
,141
,142
,143
,144
,145
,146
,147
,148
,149
,150
,151
,152
,153
,154
,155
,156
,157
,158
,159
,160
,161
,162
,163
,164
,165
,166
,167
,168
,169
,170
,171
,172
,173
,174
,175
,176
,177
,178
,179
,180
,181
,182
,183
,184
,185
,186
,187
,188
,189
,190
,191
,193
,194
,195
,197
,198
,199
,200
,201
,202
,203
,204
,205
,206
,207
,208
,209
,210
,211
,212
,214
,215
,216
,217
,218
,219
,220
,221
,222
,223
,224
,225
,226
,227
,228
,229
,231
,232
,233
,234
,235
,236
,237
,238
,239
,240
,241
,242
,243
,244
,245
,246
,247
,248
,249
,251
,252
,253
,254
,255
,256
,257
,258
,259
,261
,262
,263
,264
,266
,267
,268
,269
,270
,271
,272
,273
,274
,275
,276
,277
,278
,279
,280
,281
,282
,283
,284
,285
,286
,287
,288
,289
,290
,291
,292
,293
,294
,295
,296
,297
,298
,299
,300
,301
,302
,303
,304
,305
,306
,307
,308
,310
,311
,312
,313
,314
,315
,316
,317
,318
,319
,320
,321
,322
,323
,324
,325
,326
,327
,328
,329
,330
,331
,332
,333
,334
,335
,336
,337
,338
,339
,340
,341
,342
,343
,344
,346
,347
,348
,349
,350
,351
,352
,353
,354
,355
,356
,357
,358
,359
,360
,361
,362
,364
,366
,367
,368
,369
,370
,371
,372
,373
,374
,375
,376
,377
,378
,379
,380
,381
,382
,383
,384
,386
,387
,388
,389
,391
,392
,393
,394
,395
,396
,397
,398
,399
,400
,401
,402
,403
,404
,405
,407
,408
,409
,410
,412
,413
,415
,416
,417
,418
,419
,420
,421
,422
,424
,425
,426
,427
,428
,429
,430
,431
,432
,433
,434
,435
,436
,437
,438
,439
,440
,441
,442
,443
,444
,445
,446
,447
,448
,449
,450
,451
,452
,453
,454
,455
,456
,457
,458
,459
,460
,461
,462
,463
,464
,465
,466
,468
,469
,470
,471
,472
,473
,474
,475
,476
,477
,478
,479
,480
,481
,482
,483
,484
,485
,486
,487
,488
,489
,490
,491
,492
,493
,494
,495
,496
,497
,498
,499
,500
,502
,503
,504
,505
,506
,507
,508
,509
,510
,511
,512
,513
,514
,515
,516
,517
,518
,519
,520
,521
,522
,523
,524
,525
,526
,527
,528
,529
,530
,531
,532
,533
,535
,536
,537
,538
,540
,541
,542
,543
,544
,545
,546
,547
,548
,549
,550
,551
,552
,553
,554
,555
,556
,557
,558
,559
,560
,561
,562
,563
,564
,565
,566
,567
,568
,569
,570
,572
,573
,574
,575
,576
,577
,578
,579
,580
,581
,582
,583
,584
,585
,586
,587
,588
,589
,591
,592
,593
,595
,596
,597
,598
,599
,600
,601
,603
,604
,605
,606
,607
,608
,609
,610
,611
,613
,615
,616
,617
,618
,619
,620
,621
,622
,623
,624
,625
,626
,627
,628
,629
,630
,632
,633
,634
,635
,636
,637
,639
,640
,641
,642
,643
,644
,645
,646
,647
,648
,649
,650
,651
,652
,653
,654
,655
,656
,657
,658
,659
,660
,661
,662
,663
,664
,665
,666
,667
,668
,669
,670
,671
,672
,674
,675
,676
,677
,678
,679
,680
,681
,682
,683
,684
,685
,687
,688
,689
,690
,691
,692
,693
,694
,695
,696
,697
,698
,699
,701
,702
,703
,704
,705
,706
,707
,708
,709
,710
,711
,712
,713
,714
,715
,716
,717
,718
,719
,720
,721
,722
,723
,724
,725
,726
,727
,728
,729
,731
,732
,733
,735
,736
,737
,738
,739
,740
,741
,742
,743
,744
,2902
,2905
,2909
,2911
,2914
,2919
,2940
,2992
,2994
,2995
,3013
,3043
,3053
,3063
,3070
,3071
,3075
,3076
,3081
,3132
,3137
,3164
,3171
,3176
,3179
,3202
,3209
,3217
,3223
,3224
,3237
,3247
,3249
,3250
,3251
,3256
,3275
,3276
,3285
,3289
,3296
,3301
,3305
,3306
,3307
,3312
,3316
,3319
,3330
,3336
,3343
,3344
,3345
,3356
,3364
,3368
,3371
,3379
,3381
,3389
,3393
,3400
,3403
,3412
,3421
,3423
,3426
,3430
,3431
,3443
,3445
,3453
,3456
,3458
,3459
,3465
,3469
,3475
,3481
,3483
,3485
,3506
,3512
,3530
,3532
,3536
,3539
,3544
,3545
,3547
,3575
,3581
,3591
,3755
,4068
,4071
,4284
,4300
,4302
,4330
,4331
,4334
,4336
,4337
,4343
,4347
,4351
,4492
,4516
,4646
,4663
,4664
,4719
,4724
,4746
,4771
,4783
,4787
,4801
,4802
,4814
,4842
,4844
,4850
,4853
,4864
,4865
,4867
,4869
,4870
,4871
,4878
,4879
,4880
,4881
,4882
,4992
,5025
,5029
,5176
,5329
,5330
,5451
,5452
,5460
,5580
,5619
,5625
,5645
,5653
,5654
,5655
,5656
,5659
,5661
,5665
,5666
,5669
,5677
,5678
,5679
,5680
,5681
,5682
,5683
,5684
,5685
,5686
,5687
,5688
,5690
,5691
,5692
,5694
,5695
,5697
,5698
,5702
,5703
,5705
,5706
,5708
,5710
,5711
)
)

, school2 AS (

SELECT s.*
,ROW_NUMBER() OVER(PARTITION BY s.professional_id ORDER BY s.IsJD DESC, s.IsPreLicense DESC, s.IsLawDegreeArea DESC, s.degree_area_id DESC, s.graduation_date DESC, s.LawSchoolRank DESC, s.LawSchoolName DESC, s.school_id) Selector
FROM school1 s

)

,

reviews AS
(
SELECT professional_id,
         COUNT(id) ReviewCount
		 ,SUM(recommended) RecommendedCount
         ,SUM(recommended) / COUNT(recommended)*1.0 PercentRecommended
         ,SUM(CAST(overall_rating AS DOUBLE))/COUNT(pr.id) AvgClientRating
  FROM src.barrister_professional_review pr
  --WHERE created_at BETWEEN '2015-05-01' AND '2016-02-29'
  GROUP BY professional_Id
)

,

endorsements AS (

SELECT eds.endorsee_id AS professional_id
                   ,COUNT(DISTINCT eds.id) AS PeerEndCount
                   FROM src.barrister_professional_endorsement eds
                   -- WHERE eds.created_at BETWEEN '2015-05-01' AND '2016-02-29'
                   GROUP BY 1
                   
)

,school AS (
SELECT *
FROM src.barrister_professional_school s
WHERE school_id IN (
				2
				,3
				,4
				,6
				,7
				,8
				,9
				,10
				,11
				,12
				,13
				,14
				,15
				,16
				,17
				,18
				,19
				,20
				,21
				,22
				,23
				,24
				,25
				,26
				,27
				,28
				,29
				,30
				,31
				,32
				,33
				,34
				,35
				,36
				,37
				,38
				,39
				,40
				,41
				,42
				,43
				,44
				,45
				,46
				,47
				,48
				,49
				,50
				,51
				,53
				,54
				,55
				,56
				,57
				,59
				,60
				,61
				,62
				,63
				,64
				,65
				,66
				,67
				,68
				,69
				,70
				,71
				,72
				,73
				,74
				,75
				,76
				,77
				,78
				,79
				,80
				,81
				,82
				,83
				,85
				,86
				,87
				,88
				,89
				,90
				,91
				,92
				,93
				,94
				,95
				,96
				,97
				,98
				,99
				,100
				,101
				,102
				,103
				,104
				,105
				,106
				,107
				,108
				,109
				,110
				,111
				,112
				,113
				,114
				,115
				,116
				,117
				,118
				,119
				,120
				,121
				,122
				,123
				,124
				,125
				,126
				,127
				,128
				,129
				,130
				,131
				,132
				,133
				,134
				,135
				,136
				,137
				,138
				,139
				,140
				,141
				,142
				,143
				,144
				,145
				,146
				,147
				,148
				,149
				,150
				,151
				,152
				,153
				,154
				,155
				,156
				,157
				,158
				,159
				,160
				,161
				,162
				,163
				,164
				,165
				,166
				,167
				,168
				,169
				,170
				,171
				,172
				,173
				,174
				,175
				,176
				,177
				,178
				,179
				,180
				,181
				,182
				,183
				,184
				,185
				,186
				,187
				,188
				,189
				,190
				,191
				,193
				,194
				,195
				,197
				,198
				,199
				,200
				,201
				,202
				,203
				,204
				,205
				,206
				,207
				,208
				,209
				,210
				,211
				,212
				,214
				,215
				,216
				,217
				,218
				,219
				,220
				,221
				,222
				,223
				,224
				,225
				,226
				,227
				,228
				,229
				,231
				,232
				,233
				,234
				,235
				,236
				,237
				,238
				,239
				,240
				,241
				,242
				,243
				,244
				,245
				,246
				,247
				,248
				,249
				,251
				,252
				,253
				,254
				,255
				,256
				,257
				,258
				,259
				,261
				,262
				,263
				,264
				,266
				,267
				,268
				,269
				,270
				,271
				,272
				,273
				,274
				,275
				,276
				,277
				,278
				,279
				,280
				,281
				,282
				,283
				,284
				,285
				,286
				,287
				,288
				,289
				,290
				,291
				,292
				,293
				,294
				,295
				,296
				,297
				,298
				,299
				,300
				,301
				,302
				,303
				,304
				,305
				,306
				,307
				,308
				,310
				,311
				,312
				,313
				,314
				,315
				,316
				,317
				,318
				,319
				,320
				,321
				,322
				,323
				,324
				,325
				,326
				,327
				,328
				,329
				,330
				,331
				,332
				,333
				,334
				,335
				,336
				,337
				,338
				,339
				,340
				,341
				,342
				,343
				,344
				,346
				,347
				,348
				,349
				,350
				,351
				,352
				,353
				,354
				,355
				,356
				,357
				,358
				,359
				,360
				,361
				,362
				,364
				,366
				,367
				,368
				,369
				,370
				,371
				,372
				,373
				,374
				,375
				,376
				,377
				,378
				,379
				,380
				,381
				,382
				,383
				,384
				,386
				,387
				,388
				,389
				,391
				,392
				,393
				,394
				,395
				,396
				,397
				,398
				,399
				,400
				,401
				,402
				,403
				,404
				,405
				,407
				,408
				,409
				,410
				,412
				,413
				,415
				,416
				,417
				,418
				,419
				,420
				,421
				,422
				,424
				,425
				,426
				,427
				,428
				,429
				,430
				,431
				,432
				,433
				,434
				,435
				,436
				,437
				,438
				,439
				,440
				,441
				,442
				,443
				,444
				,445
				,446
				,447
				,448
				,449
				,450
				,451
				,452
				,453
				,454
				,455
				,456
				,457
				,458
				,459
				,460
				,461
				,462
				,463
				,464
				,465
				,466
				,468
				,469
				,470
				,471
				,472
				,473
				,474
				,475
				,476
				,477
				,478
				,479
				,480
				,481
				,482
				,483
				,484
				,485
				,486
				,487
				,488
				,489
				,490
				,491
				,492
				,493
				,494
				,495
				,496
				,497
				,498
				,499
				,500
				,502
				,503
				,504
				,505
				,506
				,507
				,508
				,509
				,510
				,511
				,512
				,513
				,514
				,515
				,516
				,517
				,518
				,519
				,520
				,521
				,522
				,523
				,524
				,525
				,526
				,527
				,528
				,529
				,530
				,531
				,532
				,533
				,535
				,536
				,537
				,538
				,540
				,541
				,542
				,543
				,544
				,545
				,546
				,547
				,548
				,549
				,550
				,551
				,552
				,553
				,554
				,555
				,556
				,557
				,558
				,559
				,560
				,561
				,562
				,563
				,564
				,565
				,566
				,567
				,568
				,569
				,570
				,572
				,573
				,574
				,575
				,576
				,577
				,578
				,579
				,580
				,581
				,582
				,583
				,584
				,585
				,586
				,587
				,588
				,589
				,591
				,592
				,593
				,595
				,596
				,597
				,598
				,599
				,600
				,601
				,603
				,604
				,605
				,606
				,607
				,608
				,609
				,610
				,611
				,613
				,615
				,616
				,617
				,618
				,619
				,620
				,621
				,622
				,623
				,624
				,625
				,626
				,627
				,628
				,629
				,630
				,632
				,633
				,634
				,635
				,636
				,637
				,639
				,640
				,641
				,642
				,643
				,644
				,645
				,646
				,647
				,648
				,649
				,650
				,651
				,652
				,653
				,654
				,655
				,656
				,657
				,658
				,659
				,660
				,661
				,662
				,663
				,664
				,665
				,666
				,667
				,668
				,669
				,670
				,671
				,672
				,674
				,675
				,676
				,677
				,678
				,679
				,680
				,681
				,682
				,683
				,684
				,685
				,687
				,688
				,689
				,690
				,691
				,692
				,693
				,694
				,695
				,696
				,697
				,698
				,699
				,701
				,702
				,703
				,704
				,705
				,706
				,707
				,708
				,709
				,710
				,711
				,712
				,713
				,714
				,715
				,716
				,717
				,718
				,719
				,720
				,721
				,722
				,723
				,724
				,725
				,726
				,727
				,728
				,729
				,731
				,732
				,733
				,735
				,736
				,737
				,738
				,739
				,740
				,741
				,742
				,743
				,744
				,2902
				,2905
				,2909
				,2911
				,2914
				,2919
				,2940
				,2992
				,2994
				,2995
				,3013
				,3043
				,3053
				,3063
				,3070
				,3071
				,3075
				,3076
				,3081
				,3132
				,3137
				,3164
				,3171
				,3176
				,3179
				,3202
				,3209
				,3217
				,3223
				,3224
				,3237
				,3247
				,3249
				,3250
				,3251
				,3256
				,3275
				,3276
				,3285
				,3289
				,3296
				,3301
				,3305
				,3306
				,3307
				,3312
				,3316
				,3319
				,3330
				,3336
				,3343
				,3344
				,3345
				,3356
				,3364
				,3368
				,3371
				,3379
				,3381
				,3389
				,3393
				,3400
				,3403
				,3412
				,3421
				,3423
				,3426
				,3430
				,3431
				,3443
				,3445
				,3453
				,3456
				,3458
				,3459
				,3465
				,3469
				,3475
				,3481
				,3483
				,3485
				,3506
				,3512
				,3530
				,3532
				,3536
				,3539
				,3544
				,3545
				,3547
				,3575
				,3581
				,3591
				,3755
				,4068
				,4071
				,4284
				,4300
				,4302
				,4330
				,4331
				,4334
				,4336
				,4337
				,4343
				,4347
				,4351
				,4492
				,4516
				,4646
				,4663
				,4664
				,4719
				,4724
				,4746
				,4771
				,4783
				,4787
				,4801
				,4802
				,4814
				,4842
				,4844
				,4850
				,4853
				,4864
				,4865
				,4867
				,4869
				,4870
				,4871
				,4878
				,4879
				,4880
				,4881
				,4882
				,4992
				,5025
				,5029
				,5176
				,5329
				,5330
				,5451
				,5452
				,5460
				,5580
				,5619
				,5625
				,5645
				,5653
				,5654
				,5655
				,5656
				,5659
				,5661
				,5665
				,5666
				,5669
				,5677
				,5678
				,5679
				,5680
				,5681
				,5682
				,5683
				,5684
				,5685
				,5686
				,5687
				,5688
				,5690
				,5691
				,5692
				,5694
				,5695
				,5697
				,5698
				,5702
				,5703
				,5705
				,5706
				,5708
				,5710
				,5711
				)
)

SELECT p.*
,CASE
	WHEN p.city = 'new york city' AND p.state = 'new york' THEN 1
	WHEN p.city = 'los angeles' AND p.state = 'california' THEN 2
	WHEN p.city = 'chicago' AND p.state = 'illinois' THEN 3
	WHEN p.city = 'houston' AND p.state = 'texas' THEN 4
	WHEN p.city = 'philadelphia' AND p.state = 'pennsylvania' THEN 5
	WHEN p.city = 'phoenix' AND p.state = 'arizona' THEN 6
	WHEN p.city = 'san antonio' AND p.state = 'texas' THEN 7
	WHEN p.city = 'san diego' AND p.state = 'california' THEN 8
	WHEN p.city = 'dallas' AND p.state = 'texas' THEN 9
	WHEN p.city = 'san jose' AND p.state = 'california' THEN 10
	WHEN p.city = 'austin' AND p.state = 'texas' THEN 11
	WHEN p.city = 'jacksonville' AND p.state = 'florida' THEN 12
	WHEN p.city = 'indianapolis' AND p.state = 'indiana' THEN 13
	WHEN p.city = 'san francisco' AND p.state = 'california' THEN 14
	WHEN p.city = 'columbus' AND p.state = 'ohio' THEN 15
	WHEN p.city = 'fort worth' AND p.state = 'texas' THEN 16
	WHEN p.city = 'charlotte' AND p.state = 'north carolina' THEN 17
	WHEN p.city = 'detroit' AND p.state = 'michigan' THEN 18
	WHEN p.city = 'el paso' AND p.state = 'texas' THEN 19
	WHEN p.city = 'memphis' AND p.state = 'tennessee' THEN 20
	WHEN p.city = 'boston' AND p.state = 'massachusetts' THEN 21
	WHEN p.city = 'seattle' AND p.state = 'washington' THEN 22
	WHEN p.city = 'denver' AND p.state = 'colorado' THEN 23
	WHEN p.city = 'washington' AND p.state = 'dc' THEN 24
	WHEN p.city = 'nashville-davidson' AND p.state = 'tennessee' THEN 25
	WHEN p.city = 'baltimore' AND p.state = 'maryland' THEN 26
	WHEN p.city = 'louisville/jefferson' AND p.state = 'kentucky' THEN 27
	WHEN p.city = 'portland' AND p.state = 'oregon' THEN 28
	WHEN p.city = 'oklahoma' AND p.state = 'oklahoma' THEN 29
	WHEN p.city = 'milwaukee' AND p.state = 'wisconsin' THEN 30
	WHEN p.city = 'las vegas' AND p.state = 'nevada' THEN 31
	WHEN p.city = 'albuquerque' AND p.state = 'new mexico' THEN 32
	WHEN p.city = 'tucson' AND p.state = 'arizona' THEN 33
	WHEN p.city = 'fresno' AND p.state = 'california' THEN 34
	WHEN p.city = 'sacramento' AND p.state = 'california' THEN 35
	WHEN p.city = 'long beach' AND p.state = 'california' THEN 36
	WHEN p.city = 'kansas' AND p.state = 'missouri' THEN 37
	WHEN p.city = 'mesa' AND p.state = 'arizona' THEN 38
	WHEN p.city = 'virginia beach' AND p.state = 'virginia' THEN 39
	WHEN p.city = 'atlanta' AND p.state = 'georgia' THEN 40
	WHEN p.city = 'colorado springs' AND p.state = 'colorado' THEN 41
	WHEN p.city = 'raleigh' AND p.state = 'north carolina' THEN 42
	WHEN p.city = 'omaha' AND p.state = 'nebraska' THEN 43
	WHEN p.city = 'miami' AND p.state = 'florida' THEN 44
	WHEN p.city = 'oakland' AND p.state = 'california' THEN 45
	WHEN p.city = 'tulsa' AND p.state = 'oklahoma' THEN 46
	WHEN p.city = 'minneapolis' AND p.state = 'minnesota' THEN 47
	WHEN p.city = 'cleveland' AND p.state = 'ohio' THEN 48
	WHEN p.city = 'wichita' AND p.state = 'kansas' THEN 49
	WHEN p.city = 'arlington' AND p.state = 'texas' THEN 50
	WHEN p.city = 'new orleans' AND p.state = 'louisiana' THEN 51
	WHEN p.city = 'bakersfield' AND p.state = 'california' THEN 52
	WHEN p.city = 'tampa' AND p.state = 'florida' THEN 53
	WHEN p.city = 'honolulu' AND p.state = 'hawaii' THEN 54
	WHEN p.city = 'anaheim' AND p.state = 'california' THEN 55
	WHEN p.city = 'aurora' AND p.state = 'colorado' THEN 56
	WHEN p.city = 'santa ana' AND p.state = 'california' THEN 57
	WHEN p.city = 'st. louis' AND p.state = 'missouri' THEN 58
	WHEN p.city = 'riverside' AND p.state = 'california' THEN 59
	WHEN p.city = 'corpus christi' AND p.state = 'texas' THEN 60
	WHEN p.city = 'pittsburgh' AND p.state = 'pennsylvania' THEN 61
	WHEN p.city = 'lexington-fayette' AND p.state = 'kentucky' THEN 62
	WHEN p.city = 'anchorage municipality' AND p.state = 'alaska' THEN 63
	WHEN p.city = 'stockton' AND p.state = 'california' THEN 64
	WHEN p.city = 'cincinnati' AND p.state = 'ohio' THEN 65
	WHEN p.city = 'st. paul' AND p.state = 'minnesota' THEN 66
	WHEN p.city = 'toledo' AND p.state = 'ohio' THEN 67
	WHEN p.city = 'newark' AND p.state = 'new jersey' THEN 68
	WHEN p.city = 'greensboro' AND p.state = 'north carolina' THEN 69
	WHEN p.city = 'plano' AND p.state = 'texas' THEN 70
	WHEN p.city = 'henderson' AND p.state = 'nevada' THEN 71
	WHEN p.city = 'lincoln' AND p.state = 'nebraska' THEN 72
	WHEN p.city = 'buffalo' AND p.state = 'new york' THEN 73
	WHEN p.city = 'fort wayne' AND p.state = 'indiana' THEN 74
	WHEN p.city = 'jersey' AND p.state = 'new jersey' THEN 75
	WHEN p.city = 'chula vista' AND p.state = 'california' THEN 76
	WHEN p.city = 'orlando' AND p.state = 'florida' THEN 77
	WHEN p.city = 'st. petersburg' AND p.state = 'florida' THEN 78
	WHEN p.city = 'norfolk' AND p.state = 'virginia' THEN 79
	WHEN p.city = 'chandler' AND p.state = 'arizona' THEN 80
	WHEN p.city = 'laredo' AND p.state = 'texas' THEN 81
	WHEN p.city = 'madison' AND p.state = 'wisconsin' THEN 82
	WHEN p.city = 'durham' AND p.state = 'north carolina' THEN 83
	WHEN p.city = 'lubbock' AND p.state = 'texas' THEN 84
	WHEN p.city = 'winston-salem' AND p.state = 'north carolina' THEN 85
	WHEN p.city = 'garland' AND p.state = 'texas' THEN 86
	WHEN p.city = 'glendale' AND p.state = 'arizona' THEN 87
	WHEN p.city = 'hialeah' AND p.state = 'florida' THEN 88
	WHEN p.city = 'reno' AND p.state = 'nevada' THEN 89
	WHEN p.city = 'baton rouge' AND p.state = 'louisiana' THEN 90
	WHEN p.city = 'irvine' AND p.state = 'california' THEN 91
	WHEN p.city = 'chesapeake' AND p.state = 'virginia' THEN 92
	WHEN p.city = 'irving' AND p.state = 'texas' THEN 93
	WHEN p.city = 'scottsdale' AND p.state = 'arizona' THEN 94
	WHEN p.city = 'north las vegas' AND p.state = 'nevada' THEN 95
	WHEN p.city = 'fremont' AND p.state = 'california' THEN 96
	WHEN p.city = 'gilbert town' AND p.state = 'arizona' THEN 97
	WHEN p.city = 'san bernardino' AND p.state = 'california' THEN 98
	WHEN p.city = 'boise' AND p.state = 'idaho' THEN 99
	WHEN p.city = 'birmingham' AND p.state = 'alabama' THEN 100
ELSE 0
END CityStateRank
,ld.LicenseCount
,ld.SanctionCount
,ld.FirstLicenseDate
,DATEDIFF(now(), ld.FirstLicenseDate)/365.25 YearsSinceFirstLicensed
,r.ReviewCount
,r.RecommendedCount
,r.PercentRecommended
,r.AvgClientRating
,eds.PeerEndCount
,s.LawSchoolName
,s.LawSchoolRank
-- ,ROW_NUMBER() OVER(PARTITION BY p.professional_id ORDER BY LawSchoolName) DupeChecker (no duplicates)
FROM deduped_pfad p
	LEFT JOIN license_discipline ld
		ON ld.professional_id = p.professional_id
	LEFT JOIN reviews r
		ON r.professional_id = p.professional_id
	LEFT JOIN endorsements eds
		ON eds.professional_id = p.professional_id
	LEFT JOIN school2 s
		ON s.professional_id = p.professional_id
		AND s.Selector = 1
-- ORDER BY DupeChecker DESC