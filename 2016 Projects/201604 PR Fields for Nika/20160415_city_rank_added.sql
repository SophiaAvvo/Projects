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
  AND LOWER(pfad.firstname) = 'vincent'
  -- ORDER BY pfad.phone1,pfad.email,pfad.lastname,pfad.state, pfad.NonNullPhone1Check, pfad.NonNullEmailCheck, pfad.NullPhone1Check, pfad.NullEmailCheck, pfad.DoubleNullCheck
  
)
,

license_discipline AS (
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
,DATEDIFF(now(), ld.FirstLicenseDate)/365.25 YearsSinceFirstLicensed
,r.ReviewCount
,r.RecommendedCount
,r.PercentRecommended
,r.AvgClientRating
,eds.PeerEndCount
FROM deduped_pfad p
	LEFT JOIN license_discipline ld
		ON ld.professional_id = p.professional_id
	LEFT JOIN reviews r
		ON r.professional_id = p.professional_id
	LEFT JOIN endorsements eds
		ON eds.professional_id = p.professional_id