WITH deduped_pfad AS
(
SELECT pfad.PROFESSIONAL_ID
         ,pfad.is_claim
         ,pfad.rating AS AvvoRating
         ,pfad.county
         ,pfad.state
		 ,pfad.city
		 ,pfad.zip
         ,pfad.firstname
         ,pfad.lastname
         ,pfad.middlename
         ,pfad.country 
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
                     ,CASE
                       WHEN pf.PROFESSIONAL_CLAIM_DATE IS NULL THEN 0
                       ELSE 1
                     END AS is_claim
                     ,CASE
                       WHEN pf.PROFESSIONAL_CLAIM_DATE IS NULL THEN 1
                       ELSE 0
                     END AS is_unclaimed
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
              ,CASE
                  WHEN TRIM(LOWER(pf.professional_postal_code_1)) = '%not%' OR LENGTH(TRIM(REGEXP_REPLACE(pf.professional_postal_code_1, '[^[:digit:]]', ''))) < 5
                     THEN NULL
                  ELSE strleft(TRIM(REGEXP_REPLACE(pf.professional_postal_code_1, '[^[:digit:]]', '')), 5)
               END zip
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
  WHERE
  pfad.NonNullPhone1Check + pfad.NullPhone1Check + pfad.NonNullEmailCheck + pfad.NullEmailCheck + pfad.DoubleNullCheck = 5
  
)

,

georank AS (
  SELECT CASE
	WHEN pd.city LIKE '%new york%' AND pd.state = 'new york' THEN 1
	WHEN pd.city = 'los angeles' AND pd.state = 'california' THEN 2
	WHEN pd.city = 'chicago' AND pd.state = 'illinois' THEN 3
	WHEN pd.city = 'houston' AND pd.state = 'texas' THEN 4
	WHEN pd.city = 'philadelphia' AND pd.state = 'pennsylvania' THEN 5
	WHEN pd.city = 'phoenix' AND pd.state = 'arizona' THEN 6
	WHEN pd.city = 'san antonio' AND pd.state = 'texas' THEN 7
	WHEN pd.city = 'san diego' AND pd.state = 'california' THEN 8
	WHEN pd.city = 'dallas' AND pd.state = 'texas' THEN 9
	WHEN pd.city = 'san jose' AND pd.state = 'california' THEN 10
	WHEN pd.city = 'austin' AND pd.state = 'texas' THEN 11
	WHEN pd.city = 'jacksonville' AND pd.state = 'florida' THEN 12
	WHEN pd.city = 'indianapolis' AND pd.state = 'indiana' THEN 13
	WHEN pd.city = 'san francisco' AND pd.state = 'california' THEN 14
	WHEN pd.city = 'columbus' AND pd.state = 'ohio' THEN 15
	WHEN pd.city = 'fort worth' AND pd.state = 'texas' THEN 16
	WHEN pd.city = 'charlotte' AND pd.state = 'north carolina' THEN 17
	WHEN pd.city = 'detroit' AND pd.state = 'michigan' THEN 18
	WHEN pd.city = 'el paso' AND pd.state = 'texas' THEN 19
	WHEN pd.city = 'memphis' AND pd.state = 'tennessee' THEN 20
	WHEN pd.city = 'boston' AND pd.state = 'massachusetts' THEN 21
	WHEN pd.city = 'seattle' AND pd.state = 'washington' THEN 22
	WHEN pd.city = 'denver' AND pd.state = 'colorado' THEN 23
	WHEN pd.city LIKE '%washington%' AND pd.state = 'dist. of columbia' THEN 24
	WHEN pd.city = 'nashville' AND pd.state = 'tennessee' THEN 25
	WHEN pd.county = 'davidson' AND pd.state = 'tennessee' THEN 25
	WHEN pd.city = 'baltimore' AND pd.state = 'maryland' THEN 26
	WHEN pd.city = 'louisville' AND pd.state = 'kentucky' THEN 27
	WHEN pd.county = 'jefferson' AND pd.state = 'kentucky' THEN 27
	WHEN pd.city = 'portland' AND pd.state = 'oregon' THEN 28
	WHEN pd.city LIKE '%oklahoma%' AND pd.state = 'oklahoma' THEN 29
	WHEN pd.city = 'milwaukee' AND pd.state = 'wisconsin' THEN 30
	WHEN pd.city = 'las vegas' AND pd.state = 'nevada' THEN 31
	WHEN pd.city = 'albuquerque' AND pd.state = 'new mexico' THEN 32
	WHEN pd.city = 'tucson' AND pd.state = 'arizona' THEN 33
	WHEN pd.city = 'fresno' AND pd.state = 'california' THEN 34
	WHEN pd.city = 'sacramento' AND pd.state = 'california' THEN 35
	WHEN pd.city = 'long beach' AND pd.state = 'california' THEN 36
	WHEN pd.city LIKE '%kansas%' AND pd.state = 'missouri' THEN 37
	WHEN pd.city = 'mesa' AND pd.state = 'arizona' THEN 38
	WHEN pd.city = 'virginia beach' AND pd.state = 'virginia' THEN 39
	WHEN pd.city = 'atlanta' AND pd.state = 'georgia' THEN 40
	WHEN pd.city = 'colorado springs' AND pd.state = 'colorado' THEN 41
	WHEN pd.city = 'raleigh' AND pd.state = 'north carolina' THEN 42
	WHEN pd.city = 'omaha' AND pd.state = 'nebraska' THEN 43
	WHEN pd.city = 'miami' AND pd.state = 'florida' THEN 44
	WHEN pd.city = 'oakland' AND pd.state = 'california' THEN 45
	WHEN pd.city = 'tulsa' AND pd.state = 'oklahoma' THEN 46
	WHEN pd.city = 'minneapolis' AND pd.state = 'minnesota' THEN 47
	WHEN pd.city = 'cleveland' AND pd.state = 'ohio' THEN 48
	WHEN pd.city = 'wichita' AND pd.state = 'kansas' THEN 49
	WHEN pd.city = 'arlington' AND pd.state = 'texas' THEN 50
	WHEN pd.city = 'new orleans' AND pd.state = 'louisiana' THEN 51
	WHEN pd.city = 'bakersfield' AND pd.state = 'california' THEN 52
	WHEN pd.city = 'tampa' AND pd.state = 'florida' THEN 53
	WHEN pd.city = 'honolulu' AND pd.state = 'hawaii' THEN 54
	WHEN pd.city = 'anaheim' AND pd.state = 'california' THEN 55
	WHEN pd.city = 'aurora' AND pd.state = 'colorado' THEN 56
	WHEN pd.city = 'santa ana' AND pd.state = 'california' THEN 57
	WHEN pd.city = 'st. louis' AND pd.state = 'missouri' THEN 58
	WHEN pd.city = 'riverside' AND pd.state = 'california' THEN 59
	WHEN pd.city = 'corpus christi' AND pd.state = 'texas' THEN 60
	WHEN pd.city = 'pittsburgh' AND pd.state = 'pennsylvania' THEN 61
	WHEN pd.city = 'lexington' AND pd.state = 'kentucky' THEN 62
	WHEN pd.county = 'fayette' AND pd.state = 'kentucky' THEN 62
	WHEN pd.city = 'anchorage municipality' AND pd.state = 'alaska' THEN 63
	WHEN pd.county = 'anchorage' AND pd.state = 'alaska' THEN 63
	WHEN pd.city = 'stockton' AND pd.state = 'california' THEN 64
	WHEN pd.city = 'cincinnati' AND pd.state = 'ohio' THEN 65
	WHEN pd.city = 'st. paul' AND pd.state = 'minnesota' THEN 66
	WHEN pd.city = 'toledo' AND pd.state = 'ohio' THEN 67
	WHEN pd.city = 'newark' AND pd.state = 'new jersey' THEN 68
	WHEN pd.city = 'greensboro' AND pd.state = 'north carolina' THEN 69
	WHEN pd.city = 'plano' AND pd.state = 'texas' THEN 70
	WHEN pd.city = 'henderson' AND pd.state = 'nevada' THEN 71
	WHEN pd.city = 'lincoln' AND pd.state = 'nebraska' THEN 72
	WHEN pd.city = 'buffalo' AND pd.state = 'new york' THEN 73
	WHEN pd.city = 'fort wayne' AND pd.state = 'indiana' THEN 74
	WHEN pd.city LIKE '%jersey%' AND pd.state = 'new jersey' THEN 75
	WHEN pd.city = 'chula vista' AND pd.state = 'california' THEN 76
	WHEN pd.city = 'orlando' AND pd.state = 'florida' THEN 77
	WHEN pd.city LIKE '%peters%' AND pd.state = 'florida' THEN 78
	WHEN pd.city = 'norfolk' AND pd.state = 'virginia' THEN 79
	WHEN pd.city = 'chandler' AND pd.state = 'arizona' THEN 80
	WHEN pd.city = 'laredo' AND pd.state = 'texas' THEN 81
	WHEN pd.city = 'madison' AND pd.state = 'wisconsin' THEN 82
	WHEN pd.city = 'durham' AND pd.state = 'north carolina' THEN 83
	WHEN pd.city = 'lubbock' AND pd.state = 'texas' THEN 84
	WHEN pd.city LIKE'%winston%' AND pd.city LIKE '%salem%' AND pd.state = 'north carolina' THEN 85
	WHEN pd.city = 'garland' AND pd.state = 'texas' THEN 86
	WHEN pd.city = 'glendale' AND pd.state = 'arizona' THEN 87
	WHEN pd.city = 'hialeah' AND pd.state = 'florida' THEN 88
	WHEN pd.city = 'reno' AND pd.state = 'nevada' THEN 89
	WHEN pd.city = 'baton rouge' AND pd.state = 'louisiana' THEN 90
	WHEN pd.city = 'irvine' AND pd.state = 'california' THEN 91
	WHEN pd.city = 'chesapeake' AND pd.state = 'virginia' THEN 92
	WHEN pd.city = 'irving' AND pd.state = 'texas' THEN 93
	WHEN pd.city = 'scottsdale' AND pd.state = 'arizona' THEN 94
	WHEN pd.city IN ('north las vegas', 'n las vegas') AND pd.state = 'nevada' THEN 95
	WHEN pd.city = 'fremont' AND pd.state = 'california' THEN 96
	WHEN pd.city = 'gilbert town' AND pd.state = 'arizona' THEN 97
	WHEN pd.city = 'san bernardino' AND pd.state = 'california' THEN 98
	WHEN pd.city = 'boise' AND pd.state = 'idaho' THEN 99
	WHEN pd.city = 'birmingham' AND pd.state = 'alabama' THEN 100
ELSE 0
END GeoRank
,CASE
WHEN pd.city LIKE '%new york%' AND pd.state = 'new york' THEN 'New York City'
WHEN pd.city = 'los angeles' AND pd.state = 'california' THEN 'Los Angeles'
WHEN pd.city = 'chicago' AND pd.state = 'illinois' THEN 'Chicago'
WHEN pd.city = 'houston' AND pd.state = 'texas' THEN 'Houston'
WHEN pd.city = 'philadelphia' AND pd.state = 'pennsylvania' THEN 'Philadelphia'
WHEN pd.city = 'phoenix' AND pd.state = 'arizona' THEN 'Phoenix'
WHEN pd.city = 'san antonio' AND pd.state = 'texas' THEN 'San Antonio'
WHEN pd.city = 'san diego' AND pd.state = 'california' THEN 'San Diego'
WHEN pd.city = 'dallas' AND pd.state = 'texas' THEN 'Dallas'
WHEN pd.city = 'san jose' AND pd.state = 'california' THEN 'San Jose'
WHEN pd.city = 'austin' AND pd.state = 'texas' THEN 'Austin'
WHEN pd.city = 'jacksonville' AND pd.state = 'florida' THEN 'Jacksonville'
WHEN pd.city = 'indianapolis' AND pd.state = 'indiana' THEN 'Indianapolis'
WHEN pd.city = 'san francisco' AND pd.state = 'california' THEN 'San Francisco'
WHEN pd.city = 'columbus' AND pd.state = 'ohio' THEN 'Columbus'
WHEN pd.city = 'fort worth' AND pd.state = 'texas' THEN 'Fort Worth'
WHEN pd.city = 'charlotte' AND pd.state = 'north carolina' THEN 'Charlotte'
WHEN pd.city = 'detroit' AND pd.state = 'michigan' THEN 'Detroit'
WHEN pd.city = 'el paso' AND pd.state = 'texas' THEN 'El Paso'
WHEN pd.city = 'memphis' AND pd.state = 'tennessee' THEN 'Memphis'
WHEN pd.city = 'boston' AND pd.state = 'massachusetts' THEN 'Boston'
WHEN pd.city = 'seattle' AND pd.state = 'washington' THEN 'Seattle'
WHEN pd.city = 'denver' AND pd.state = 'colorado' THEN 'Denver'
WHEN pd.city LIKE '%washington%' AND pd.state = 'dist. of columbia' THEN 'Washington'
WHEN pd.city = 'nashville' AND pd.state = 'tennessee' THEN 'Nashville-Davidson'
WHEN pd.county = 'davidson' AND pd.state = 'tennessee' THEN 'Nashville-Davidson'
WHEN pd.city = 'baltimore' AND pd.state = 'maryland' THEN 'Baltimore'
WHEN pd.city = 'louisville' AND pd.state = 'kentucky' THEN 'Louisville/Jefferson'
WHEN pd.county = 'jefferson' AND pd.state = 'kentucky' THEN 'Louisville/Jefferson'
WHEN pd.city = 'portland' AND pd.state = 'oregon' THEN 'Portland'
WHEN pd.city LIKE '%oklahoma%' AND pd.state = 'oklahoma' THEN 'Oklahoma '
WHEN pd.city = 'milwaukee' AND pd.state = 'wisconsin' THEN 'Milwaukee'
WHEN pd.city = 'las vegas' AND pd.state = 'nevada' THEN 'Las Vegas'
WHEN pd.city = 'albuquerque' AND pd.state = 'new mexico' THEN 'Albuquerque'
WHEN pd.city = 'tucson' AND pd.state = 'arizona' THEN 'Tucson'
WHEN pd.city = 'fresno' AND pd.state = 'california' THEN 'Fresno'
WHEN pd.city = 'sacramento' AND pd.state = 'california' THEN 'Sacramento'
WHEN pd.city = 'long beach' AND pd.state = 'california' THEN 'Long Beach'
WHEN pd.city LIKE '%kansas%' AND pd.state = 'missouri' THEN 'Kansas '
WHEN pd.city = 'mesa' AND pd.state = 'arizona' THEN 'Mesa'
WHEN pd.city = 'virginia beach' AND pd.state = 'virginia' THEN 'Virginia Beach'
WHEN pd.city = 'atlanta' AND pd.state = 'georgia' THEN 'Atlanta'
WHEN pd.city = 'colorado springs' AND pd.state = 'colorado' THEN 'Colorado Springs'
WHEN pd.city = 'raleigh' AND pd.state = 'north carolina' THEN 'Raleigh'
WHEN pd.city = 'omaha' AND pd.state = 'nebraska' THEN 'Omaha'
WHEN pd.city = 'miami' AND pd.state = 'florida' THEN 'Miami'
WHEN pd.city = 'oakland' AND pd.state = 'california' THEN 'Oakland'
WHEN pd.city = 'tulsa' AND pd.state = 'oklahoma' THEN 'Tulsa'
WHEN pd.city = 'minneapolis' AND pd.state = 'minnesota' THEN 'Minneapolis'
WHEN pd.city = 'cleveland' AND pd.state = 'ohio' THEN 'Cleveland'
WHEN pd.city = 'wichita' AND pd.state = 'kansas' THEN 'Wichita'
WHEN pd.city = 'arlington' AND pd.state = 'texas' THEN 'Arlington'
WHEN pd.city = 'new orleans' AND pd.state = 'louisiana' THEN 'New Orleans'
WHEN pd.city = 'bakersfield' AND pd.state = 'california' THEN 'Bakersfield'
WHEN pd.city = 'tampa' AND pd.state = 'florida' THEN 'Tampa'
WHEN pd.city = 'honolulu' AND pd.state = 'hawaii' THEN 'Honolulu'
WHEN pd.city = 'anaheim' AND pd.state = 'california' THEN 'Anaheim'
WHEN pd.city = 'aurora' AND pd.state = 'colorado' THEN 'Aurora'
WHEN pd.city = 'santa ana' AND pd.state = 'california' THEN 'Santa Ana'
WHEN pd.city = 'st. louis' AND pd.state = 'missouri' THEN 'St. Louis'
WHEN pd.city = 'riverside' AND pd.state = 'california' THEN 'Riverside'
WHEN pd.city = 'corpus christi' AND pd.state = 'texas' THEN 'Corpus Christi'
WHEN pd.city = 'pittsburgh' AND pd.state = 'pennsylvania' THEN 'Pittsburgh'
WHEN pd.city = 'lexington' AND pd.state = 'kentucky' THEN 'Lexington-Fayette'
WHEN pd.county = 'fayette' AND pd.state = 'kentucky' THEN 'Lexington-Fayette'
WHEN pd.city = 'anchorage municipality' AND pd.state = 'alaska' THEN 'Anchorage municipality'
WHEN pd.county = 'anchorage' AND pd.state = 'alaska' THEN 'Anchorage municipality'
WHEN pd.city = 'stockton' AND pd.state = 'california' THEN 'Stockton'
WHEN pd.city = 'cincinnati' AND pd.state = 'ohio' THEN 'Cincinnati'
WHEN pd.city = 'st. paul' AND pd.state = 'minnesota' THEN 'St. Paul'
WHEN pd.city = 'toledo' AND pd.state = 'ohio' THEN 'Toledo'
WHEN pd.city = 'newark' AND pd.state = 'new jersey' THEN 'Newark'
WHEN pd.city = 'greensboro' AND pd.state = 'north carolina' THEN 'Greensboro'
WHEN pd.city = 'plano' AND pd.state = 'texas' THEN 'Plano'
WHEN pd.city = 'henderson' AND pd.state = 'nevada' THEN 'Henderson'
WHEN pd.city = 'lincoln' AND pd.state = 'nebraska' THEN 'Lincoln'
WHEN pd.city = 'buffalo' AND pd.state = 'new york' THEN 'Buffalo'
WHEN pd.city = 'fort wayne' AND pd.state = 'indiana' THEN 'Fort Wayne'
WHEN pd.city LIKE '%jersey%' AND pd.state = 'new jersey' THEN 'Jersey '
WHEN pd.city = 'chula vista' AND pd.state = 'california' THEN 'Chula Vista'
WHEN pd.city = 'orlando' AND pd.state = 'florida' THEN 'Orlando'
WHEN pd.city LIKE '%peters%' AND pd.state = 'florida' THEN 'St. Petersburg'
WHEN pd.city = 'norfolk' AND pd.state = 'virginia' THEN 'Norfolk'
WHEN pd.city = 'chandler' AND pd.state = 'arizona' THEN 'Chandler'
WHEN pd.city = 'laredo' AND pd.state = 'texas' THEN 'Laredo'
WHEN pd.city = 'madison' AND pd.state = 'wisconsin' THEN 'Madison'
WHEN pd.city = 'durham' AND pd.state = 'north carolina' THEN 'Durham'
WHEN pd.city = 'lubbock' AND pd.state = 'texas' THEN 'Lubbock'
WHEN pd.city LIKE'%winston%' AND pd.city LIKE '%salem%' AND pd.state = 'north carolina' THEN 'Winston-Salem'
WHEN pd.city = 'garland' AND pd.state = 'texas' THEN 'Garland'
WHEN pd.city = 'glendale' AND pd.state = 'arizona' THEN 'Glendale'
WHEN pd.city = 'hialeah' AND pd.state = 'florida' THEN 'Hialeah'
WHEN pd.city = 'reno' AND pd.state = 'nevada' THEN 'Reno'
WHEN pd.city = 'baton rouge' AND pd.state = 'louisiana' THEN 'Baton Rouge'
WHEN pd.city = 'irvine' AND pd.state = 'california' THEN 'Irvine'
WHEN pd.city = 'chesapeake' AND pd.state = 'virginia' THEN 'Chesapeake'
WHEN pd.city = 'irving' AND pd.state = 'texas' THEN 'Irving'
WHEN pd.city = 'scottsdale' AND pd.state = 'arizona' THEN 'Scottsdale'
WHEN pd.city IN ('north las vegas', 'n las vegas') AND pd.state = 'nevada' THEN 'North Las Vegas'
WHEN pd.city = 'fremont' AND pd.state = 'california' THEN 'Fremont'
WHEN pd.city = 'gilbert town' AND pd.state = 'arizona' THEN 'Gilbert town'
WHEN pd.city = 'san bernardino' AND pd.state = 'california' THEN 'San Bernardino'
WHEN pd.city = 'boise' AND pd.state = 'idaho' THEN 'Boise'
WHEN pd.city = 'birmingham' AND pd.state = 'alabama' THEN 'Birmingham'
ELSE NULL
END CityNameFormat
,CASE
WHEN pd.city LIKE '%new york%' AND pd.state = 'new york' THEN 'New York'
WHEN pd.city = 'los angeles' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'chicago' AND pd.state = 'illinois' THEN 'Illinois'
WHEN pd.city = 'houston' AND pd.state = 'texas' THEN 'Texas'
WHEN pd.city = 'philadelphia' AND pd.state = 'pennsylvania' THEN 'Pennsylvania'
WHEN pd.city = 'phoenix' AND pd.state = 'arizona' THEN 'Arizona'
WHEN pd.city = 'san antonio' AND pd.state = 'texas' THEN 'Texas'
WHEN pd.city = 'san diego' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'dallas' AND pd.state = 'texas' THEN 'Texas'
WHEN pd.city = 'san jose' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'austin' AND pd.state = 'texas' THEN 'Texas'
WHEN pd.city = 'jacksonville' AND pd.state = 'florida' THEN 'Florida'
WHEN pd.city = 'indianapolis' AND pd.state = 'indiana' THEN 'Indiana'
WHEN pd.city = 'san francisco' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'columbus' AND pd.state = 'ohio' THEN 'Ohio'
WHEN pd.city = 'fort worth' AND pd.state = 'texas' THEN 'Texas'
WHEN pd.city = 'charlotte' AND pd.state = 'north carolina' THEN 'North Carolina'
WHEN pd.city = 'detroit' AND pd.state = 'michigan' THEN 'Michigan'
WHEN pd.city = 'el paso' AND pd.state = 'texas' THEN 'Texas'
WHEN pd.city = 'memphis' AND pd.state = 'tennessee' THEN 'Tennessee'
WHEN pd.city = 'boston' AND pd.state = 'massachusetts' THEN 'Massachusetts'
WHEN pd.city = 'seattle' AND pd.state = 'washington' THEN 'Washington'
WHEN pd.city = 'denver' AND pd.state = 'colorado' THEN 'Colorado'
WHEN pd.city LIKE '%washington%' AND pd.state = 'dist. of columbia' THEN 'DC'
WHEN pd.city = 'nashville' AND pd.state = 'tennessee' THEN 'Tennessee'
WHEN pd.county = 'davidson' AND pd.state = 'tennessee' THEN 'Tennessee'
WHEN pd.city = 'baltimore' AND pd.state = 'maryland' THEN 'Maryland'
WHEN pd.city = 'louisville' AND pd.state = 'kentucky' THEN 'Kentucky'
WHEN pd.county = 'jefferson' AND pd.state = 'kentucky' THEN 'Kentucky'
WHEN pd.city = 'portland' AND pd.state = 'oregon' THEN 'Oregon'
WHEN pd.city LIKE '%oklahoma%' AND pd.state = 'oklahoma' THEN 'Oklahoma'
WHEN pd.city = 'milwaukee' AND pd.state = 'wisconsin' THEN 'Wisconsin'
WHEN pd.city = 'las vegas' AND pd.state = 'nevada' THEN 'Nevada'
WHEN pd.city = 'albuquerque' AND pd.state = 'new mexico' THEN 'New Mexico'
WHEN pd.city = 'tucson' AND pd.state = 'arizona' THEN 'Arizona'
WHEN pd.city = 'fresno' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'sacramento' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'long beach' AND pd.state = 'california' THEN 'California'
WHEN pd.city LIKE '%kansas%' AND pd.state = 'missouri' THEN 'Missouri'
WHEN pd.city = 'mesa' AND pd.state = 'arizona' THEN 'Arizona'
WHEN pd.city = 'virginia beach' AND pd.state = 'virginia' THEN 'Virginia'
WHEN pd.city = 'atlanta' AND pd.state = 'georgia' THEN 'Georgia'
WHEN pd.city = 'colorado springs' AND pd.state = 'colorado' THEN 'Colorado'
WHEN pd.city = 'raleigh' AND pd.state = 'north carolina' THEN 'North Carolina'
WHEN pd.city = 'omaha' AND pd.state = 'nebraska' THEN 'Nebraska'
WHEN pd.city = 'miami' AND pd.state = 'florida' THEN 'Florida'
WHEN pd.city = 'oakland' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'tulsa' AND pd.state = 'oklahoma' THEN 'Oklahoma'
WHEN pd.city = 'minneapolis' AND pd.state = 'minnesota' THEN 'Minnesota'
WHEN pd.city = 'cleveland' AND pd.state = 'ohio' THEN 'Ohio'
WHEN pd.city = 'wichita' AND pd.state = 'kansas' THEN 'Kansas'
WHEN pd.city = 'arlington' AND pd.state = 'texas' THEN 'Texas'
WHEN pd.city = 'new orleans' AND pd.state = 'louisiana' THEN 'Louisiana'
WHEN pd.city = 'bakersfield' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'tampa' AND pd.state = 'florida' THEN 'Florida'
WHEN pd.city = 'honolulu' AND pd.state = 'hawaii' THEN 'Hawaii'
WHEN pd.city = 'anaheim' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'aurora' AND pd.state = 'colorado' THEN 'Colorado'
WHEN pd.city = 'santa ana' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'st. louis' AND pd.state = 'missouri' THEN 'Missouri'
WHEN pd.city = 'riverside' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'corpus christi' AND pd.state = 'texas' THEN 'Texas'
WHEN pd.city = 'pittsburgh' AND pd.state = 'pennsylvania' THEN 'Pennsylvania'
WHEN pd.city = 'lexington' AND pd.state = 'kentucky' THEN 'Kentucky'
WHEN pd.county = 'fayette' AND pd.state = 'kentucky' THEN 'Kentucky'
WHEN pd.city = 'anchorage municipality' AND pd.state = 'alaska' THEN 'Alaska'
WHEN pd.county = 'anchorage' AND pd.state = 'alaska' THEN 'Alaska'
WHEN pd.city = 'stockton' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'cincinnati' AND pd.state = 'ohio' THEN 'Ohio'
WHEN pd.city = 'st. paul' AND pd.state = 'minnesota' THEN 'Minnesota'
WHEN pd.city = 'toledo' AND pd.state = 'ohio' THEN 'Ohio'
WHEN pd.city = 'newark' AND pd.state = 'new jersey' THEN 'New Jersey'
WHEN pd.city = 'greensboro' AND pd.state = 'north carolina' THEN 'North Carolina'
WHEN pd.city = 'plano' AND pd.state = 'texas' THEN 'Texas'
WHEN pd.city = 'henderson' AND pd.state = 'nevada' THEN 'Nevada'
WHEN pd.city = 'lincoln' AND pd.state = 'nebraska' THEN 'Nebraska'
WHEN pd.city = 'buffalo' AND pd.state = 'new york' THEN 'New York'
WHEN pd.city = 'fort wayne' AND pd.state = 'indiana' THEN 'Indiana'
WHEN pd.city LIKE '%jersey%' AND pd.state = 'new jersey' THEN 'New Jersey'
WHEN pd.city = 'chula vista' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'orlando' AND pd.state = 'florida' THEN 'Florida'
WHEN pd.city LIKE '%peters%' AND pd.state = 'florida' THEN 'Florida'
WHEN pd.city = 'norfolk' AND pd.state = 'virginia' THEN 'Virginia'
WHEN pd.city = 'chandler' AND pd.state = 'arizona' THEN 'Arizona'
WHEN pd.city = 'laredo' AND pd.state = 'texas' THEN 'Texas'
WHEN pd.city = 'madison' AND pd.state = 'wisconsin' THEN 'Wisconsin'
WHEN pd.city = 'durham' AND pd.state = 'north carolina' THEN 'North Carolina'
WHEN pd.city = 'lubbock' AND pd.state = 'texas' THEN 'Texas'
WHEN pd.city LIKE'%winston%' AND pd.city LIKE '%salem%' AND pd.state = 'north carolina' THEN 'North Carolina'
WHEN pd.city = 'garland' AND pd.state = 'texas' THEN 'Texas'
WHEN pd.city = 'glendale' AND pd.state = 'arizona' THEN 'Arizona'
WHEN pd.city = 'hialeah' AND pd.state = 'florida' THEN 'Florida'
WHEN pd.city = 'reno' AND pd.state = 'nevada' THEN 'Nevada'
WHEN pd.city = 'baton rouge' AND pd.state = 'louisiana' THEN 'Louisiana'
WHEN pd.city = 'irvine' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'chesapeake' AND pd.state = 'virginia' THEN 'Virginia'
WHEN pd.city = 'irving' AND pd.state = 'texas' THEN 'Texas'
WHEN pd.city = 'scottsdale' AND pd.state = 'arizona' THEN 'Arizona'
WHEN pd.city IN ('north las vegas', 'n las vegas') AND pd.state = 'nevada' THEN 'Nevada'
WHEN pd.city = 'fremont' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'gilbert town' AND pd.state = 'arizona' THEN 'Arizona'
WHEN pd.city = 'san bernardino' AND pd.state = 'california' THEN 'California'
WHEN pd.city = 'boise' AND pd.state = 'idaho' THEN 'Idaho'
WHEN pd.city = 'birmingham' AND pd.state = 'alabama' THEN 'Alabama'
ELSE NULL
END StateNameFormat
,pd.zip
,pd.city
,pd.county
,pd.professional_id
--COUNT(DISTINCT pd.professional_id) ProfIdCount
FROM deduped_pfad pd

)

, license_discipline AS (
  SELECT ps.professional_id
  ,MIN(bl.license_date) FirstLicenseDate
  ,MAX(bl.license_date) LastLicenseDate
  ,COUNT(DISTINCT bl.id) LicenseCount
  ,COUNT(bs.id) SanctionCount
  
FROM SRC.barrister_professional_status ps
  LEFT JOIN src.barrister_license bl
      ON ps.professional_id = bl.professional_id
  LEFT JOIN src.barrister_sanction bs
      ON bl.id = bs.license_id
GROUP BY 1
  )
  
,school1 AS (
SELECT s.*
     ,ld.FirstLicenseDate
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
,ROW_NUMBER() OVER(PARTITION BY s.professional_id ORDER BY s.IsJD DESC, s.IsPreLicense DESC, s.IsLawDegreeArea DESC, s.degree_area_id DESC, s.graduation_date DESC, s.school_id) Selector
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
  GROUP BY professional_Id
)

,

endorsements AS (

SELECT eds.endorsee_id AS professional_id
                   ,COUNT(DISTINCT eds.id) AS PeerEndCount
                   FROM src.barrister_professional_endorsement eds
                   GROUP BY 1
                   
)

,

geozip AS (
			  SELECT zip
			  ,StateNameFormat
			  ,CityNameFormat
			  ,GeoRank
			  ,COUNT(professional_id) ProfIDCount
FROM georank
WHERE GeoRank > 0 
AND zip <> '00000'
AND zip IS NOT NULL
GROUP BY 1,2,3,4
HAVING COUNT(professional_id) > 1
)

,geotrimmer AS (
  
 SELECT p.*
	  ,COALESCE(g.georank, z.georank) GeoRank
  ,COALESCE(g.StateNameFormat, z.StateNameFormat) StateNameFormat
  ,COALESCE(g.CityNameFormat, z.CityNameFormat) CityNameFormat
  ,ROW_NUMBER() OVER(PARTITION BY p.professional_id ORDER BY z.ProfIDCount DESC, z.GeoRank) DupeChecker
FROM deduped_pfad p
  LEFT JOIN georank g
	ON g.professional_id = p.professional_Id
    AND g.georank > 0
  LEFT JOIN (SELECT zip
			  ,StateNameFormat
			  ,CityNameFormat
			  ,GeoRank
			  ,ProfIDCount
			  ,ROW_NUMBER() OVER(PARTITION BY zip ORDER BY ProfIDCount DESC, GeoRank) ZipNum
             FROM geozip
			) z
ON z.zip = p.zip
AND z.ZipNum = 1
WHERE COALESCE(g.georank, z.georank) IS NOT NULL

)

SELECT gt.*
,ld.LicenseCount
,ld.SanctionCount
,ld.FirstLicenseDate
,DATEDIFF(now(), ld.FirstLicenseDate)/365.25 YearsSinceFirstLicensed
,r.ReviewCount
,r.RecommendedCount
,r.PercentRecommended
,r.AvgClientRating
,eds.PeerEndCount
,s.school_id
,s.graduation_date
FROM geotrimmer gt
	LEFT JOIN license_discipline ld
		ON ld.professional_id = gt.professional_id
	LEFT JOIN reviews r
		ON r.professional_id = gt.professional_id
	LEFT JOIN endorsements eds
		ON eds.professional_id = gt.professional_id
	LEFT JOIN school2 s
		ON s.professional_id = gt.professional_id
		AND s.Selector = 1