WITH deduped_pfad AS
(
  SELECT pfad.PROFESSIONAL_ID
  -- ,dm.domain_size -- this is the only reason we subquery off the dm table; we don't need this
         ,
         pfad.is_claim,
         pfad.claim_date,
         pfad.claim_method,
         pfad.domain,
         pfad.emaildomain,
         pfad.emailsuffix,
         pfad.lowscoreemaildomain,
         pfad.rating,
         pfad.county,
         pfad.state,
         CASE
           WHEN toppa.ParentPracticeArea1 IN ('Criminal Defense','DUI & DWI','Divorce & Separation','Personal Injury','Family','Immigration','Car Accidents','Bankruptcy & Debt','Chapter 11 Bankruptcy','Chapter 13 Bankruptcy','Chapter 7 Bankruptcy','Workers Compensation','Child Custody','Employment & Labor','Real Estate','Estate Planning','Business','Lawsuits & Disputes','Motorcycle Accident') THEN 'Y'
           ELSE 'N'
         END AS PriorityPA1,
         pfad.LawyerName,
         pfad.LawyerName_Full,
         pfad.firstname,
         pfad.lastname,
         pfad.middlename,
         pfad.suffix,
         pfad.phone1,
         pfad.phone2,
         pfad.phone3,
         pfad.email,
         pfad.delete_ind AS professional_delete_indicator,
         pfad.practice_ind AS professional_practice_indicator,
         pfad.prof_name AS professional_name,
         pfad.ind_name AS industry_name,
         pfad.country AS professional_country_name_1,
         toppa.PracticeArea1,
         toppa.PracticeArea2,
         toppa.PracticeArea3,
         toppa.ParentPracticeArea1,
         toppa.ParentPracticeArea2,
         toppa.ParentPracticeArea3,
         CASE
           WHEN pfad.HasEmail = 1 THEN 'Ok Email'
           ELSE 'Bad Email'
         END Email_Status,
         CASE
           WHEN pfad.HasPhone1 + pfad.HasPhone2 + pfad.HasPhone3 = 0 THEN 'Bad Phone'
           ELSE 'Ok Phone'
         END AS Phone_Status,
         CASE
           WHEN pfad.IsExcludedTitle = 1 THEN 'Exclude Title'
           ELSE 'Title Okay'
         END IsExcludedTitle
  FROM (SELECT pd.*,
               CASE
                 WHEN pd.phone1 IS NOT NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.phone1,pd.email,pd.lastname,pd.firstname,pd.state ORDER BY pd.phone1 DESC,pd.email DESC,phone2 DESC,phone3 DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NonNullPhone1Check,
               CASE
                 WHEN pd.phone1 IS NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.email,pd.firstname,pd.lastname,pd.state ORDER BY pd.email DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NullPhone1Check,
               CASE
                 WHEN pd.email IS NOT NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.email,pd.phone1,pd.lastname,pd.firstname,pd.state ORDER BY pd.phone1 DESC,pd.email DESC,phone2 DESC,phone3 DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NonNullEmailCheck,
               CASE
                 WHEN pd.email IS NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.phone1,pd.firstname,pd.lastname,pd.state ORDER BY pd.phone1 DESC,phone2 DESC,phone3 DESC,pd.county DESC,pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS NullEmailCheck,
               CASE
                 WHEN pd.email IS NULL AND pd.phone1 IS NULL THEN ROW_NUMBER() OVER (PARTITION BY pd.lastname,pd.firstname,pd.state ORDER BY pd.MiddleInitial DESC,pd.MiddleNameLength DESC,pd.suffix DESC,pd.rating DESC,pd.professional_id)
                 ELSE 1
               END AS DoubleNullCheck /* If the first/last, middle, state, and county are the same, take out both entities and put on a separate list (filter all values > 1) 
           ,ROW_NUMBER() OVER(PARTITION BY pd.firstname, pd.lastname, pd.MiddleInitial, pd.state, pd.county 
                              ORDER BY pd.professional_id) PoojaTest1 */ /* If the phone, first, last, county, and state are the same, take out both entities and put on a separate list (filter all values > 1) 
           ,ROW_NUMBER() OVER(PARTITION BY pd.phone1, pd.firstname, pd.lastname, pd.state, pd.county
                              ORDER BY pd.professional_id) PoojaTest2 */ /* If the email, first, last, county, and state are the same, take out both entities and put on a separate list (filter all values > 1)     
           ,ROW_NUMBER() OVER(PARTITION BY pd.email, pd.firstname, pd.lastname, pd.state, pd.county
                              ORDER BY pd.professional_id) PoojaTest3 */,
               CASE
                 WHEN pd.email IS NULL THEN 0
                 ELSE 1
               END AS HasEmail,
               CASE
                 WHEN pd.phone1 IS NULL THEN 0
                 ELSE 1
               END AS HasPhone1,
               CASE
                 WHEN pd.phone2 IS NULL THEN 0
                 ELSE 1
               END AS HasPhone2,
               CASE
                 WHEN pd.county IS NULL THEN 0
                 ELSE 1
               END AS HasCounty,
               CASE
                 WHEN pd.phone3 IS NULL THEN 0
                 ELSE 1
               END AS HasPhone3,
               CASE
                 WHEN pd.MiddleInitial IS NULL THEN 0
                 ELSE 1
               END AS HasMiddleInitial,
               (SUBSTR(UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3)) EmailSuffix,
               substr(pd.emaildomain,1,LENGTH(pd.emaildomain) - instr (pd.emaildomain,'.')) EmailDomainSubTest2,
               instr(pd.emaildomain,'.') +1 StringTest,
               CASE
                 WHEN (SUBSTR (UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3) IN ('.EDU','.GOV','.ORG','CO.US')) THEN 1
                 ELSE 0
               END AS LowScoreEmailDomain /*,case 
              when (SUBSTR(upper(pd.emaildomain),length(pd.emaildomain)-3) in ('.EDU','.GOV','.ORG', 'CO.US')) 
                  then 1
                  else 0
              end AS HighScoreEmailDomain */,
               LOCATE('.',pd.emaildomain) EmailPeriodPosition,
               SUBSTR(UPPER(pd.emaildomain),LENGTH(pd.emaildomain) - LOCATE ('.',pd.emaildomain)) EmailHostParse
        FROM (SELECT pf.PROFESSIONAL_ID,
                     pf.professional_claim_method_name claim_method,
                     CASE
                       WHEN pf.PROFESSIONAL_CLAIM_DATE IS NULL THEN 0
                       ELSE 1
                     END AS is_claim,
                     pf.professional_claim_date claim_date,
                     CASE
                       WHEN pf.PROFESSIONAL_COUNTY_NAME_1 = 'NOT APPLICABLE'
              -- get rid of string values in county name 
              THEN NULL
                       ELSE pf.PROFESSIONAL_COUNTY_NAME_1
                     END county,
                     CASE
                       WHEN pf.PROFESSIONAL_STATE_NAME_1 = 'NOT APPLICABLE'
              -- get rid of string values in state name
              THEN NULL
                       ELSE pf.PROFESSIONAL_STATE_NAME_1
                     END state,
                     CASE
                       WHEN pf.PROFESSIONAL_CITY_NAME_1 = 'NOT APPLICABLE' THEN NULL
                       ELSE pf.PROFESSIONAL_STATE_NAME_1
                     END city,
                     PROFESSIONAL_PREFIX,
                     PROFESSIONAL_FIRST_NAME AS FirstName,
                     PROFESSIONAL_LAST_NAME AS LastName,
                     PROFESSIONAL_MIDDLE_NAME AS MiddleName,
                     PROFESSIONAL_SUFFIX AS Suffix,
                     CASE
                       WHEN PROFESSIONAL_PHONE_NUMBER_1 LIKE '%Not%'
              --get rid of string values in phone number 
              THEN NULL
                       WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_1) < 10
              --get rid of invalid phone numbers 
              THEN NULL
                       ELSE PROFESSIONAL_PHONE_NUMBER_1
                     END AS phone1,
                     CASE
                       WHEN PROFESSIONAL_PHONE_NUMBER_2 LIKE '%Not%' THEN NULL
                       WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_2) < 10 THEN NULL
                       WHEN PROFESSIONAL_PHONE_NUMBER_2 = PROFESSIONAL_PHONE_NUMBER_1
              -- get rid of duplicate phone numbers 
              THEN NULL
                       ELSE PROFESSIONAL_PHONE_NUMBER_2
                     END AS phone2,
                     CASE
                       WHEN PROFESSIONAL_PHONE_NUMBER_3 LIKE '%Not%' THEN NULL
                       WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_3) < 10 THEN NULL
                       WHEN PROFESSIONAL_PHONE_NUMBER_3 = PROFESSIONAL_PHONE_NUMBER_1
              -- get rid of duplicate phone numbers 
              THEN NULL
                       WHEN PROFESSIONAL_PHONE_NUMBER_3 = PROFESSIONAL_PHONE_NUMBER_2
              -- get rid of duplicate phone numbers 
              THEN NULL
                       ELSE PROFESSIONAL_PHONE_NUMBER_3
                     END AS phone3,
                     CASE
                       WHEN LTRIM (LOWER(PROFESSIONAL_EMAIL_ADDRESS_NAME)) LIKE 'info@%' THEN NULL
                       WHEN LTRIM (LOWER(PROFESSIONAL_EMAIL_ADDRESS_NAME)) LIKE 'contactus@%' THEN NULL
                       WHEN PROFESSIONAL_EMAIL_ADDRESS_NAME = ' ' THEN NULL
                       WHEN PROFESSIONAL_EMAIL_ADDRESS_NAME = 'Null' THEN NULL
                       ELSE PROFESSIONAL_EMAIL_ADDRESS_NAME
                     END AS email,
                     LENGTH(TRIM(PROFESSIONAL_MIDDLE_NAME)) AS MiddleNameLength,
                     pf.PROFESSIONAL_AVVO_RATING AS rating-- invalid string
                     ,
                     concat(PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME) AS LawyerName-- invalid string 
                     -- these are useful to identify lawyers that have prefixes and be unusual or need to be excluded
                     ,
                     CASE
                       WHEN PROFESSIONAL_PREFIX IS NULL AND PROFESSIONAL_SUFFIX IS NULL AND PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_PREFIX IS NULL AND PROFESSIONAL_SUFFIX IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_PREFIX IS NULL AND PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                       WHEN PROFESSIONAL_PREFIX IS NULL THEN concat (PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                       WHEN PROFESSIONAL_SUFFIX IS NULL AND PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_SUFFIX IS NULL THEN concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME)
                       WHEN PROFESSIONAL_MIDDLE_NAME IS NULL THEN concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                       ELSE concat (PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
                     END AS LawyerName_Full,
                     CASE
                       WHEN PROFESSIONAL_PREFIX IN ('Chiefjustice','Col','Col.','Colonel','Hon','Hon.','Honorable','Maj','Maj.','Maj. Gen.','Major','Mr. Judge','Mr. Justice','The Honorable') THEN 1
                       ELSE 0
                     END AS IsExcludedTitle,
                     SUBSTR(TRIM(PROFESSIONAL_MIDDLE_NAME),1,1) MiddleInitial
              --,pf.PROFESSIONAL_DELETE_INDICATOR  as delete_ind
                     --,pf.PROFESSIONAL_PRACTICE_INDICATOR as practice_ind
                     ,
                     pf.PROFESSIONAL_NAME AS prof_name,
                     pf.INDUSTRY_NAME AS ind_name,
                     pf.PROFESSIONAL_COUNTRY_NAME_1 AS country,
                     substr(pf.professional_email_address_name,instr (professional_email_address_name,'@') +1) AS emaildomain-- works!
                     ,
                     CASE
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
              AND   LOWER (pf.PROFESSIONAL_FIRST_NAME) = 'vincent'
              --(for testing purposes)) pd /*
    LEFT JOIN SRC.barrister_professional_status ps ON ps.professional_id = pfad.PROFESSIONAL_ID
    LEFT JOIN (SELECT x.PROFESSIONAL_ID,
                      MIN(CASE WHEN x.rt = 1 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea1,
                      MIN(CASE WHEN x.rt = 2 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea2,
                      MIN(CASE WHEN x.rt = 3 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea3,
                      MIN(CASE WHEN x.rt = 1 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea1,
                      MIN(CASE WHEN x.rt = 2 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea2,
                      MIN(CASE WHEN x.rt = 3 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea3
               FROM (SELECT pfsp.PROFESSIONAL_ID,
                            pfsp.SPECIALTY_PERCENT,
                            sp.SPECIALTY_NAME,
                            sp.PARENT_SPECIALTY_NAME,
                            ROW_NUMBER() OVER (PARTITION BY pfsp.PROFESSIONAL_ID ORDER BY pfsp.SPECIALTY_PERCENT DESC) rt
                     FROM DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp
                       JOIN DM.SPECIALTY_DIMENSION sp ON sp.SPECIALTY_ID = pfsp.SPECIALTY_ID
                     WHERE pfsp.DELETE_FLAG = 'N') x
               GROUP BY 1) toppa ON toppa.PROFESSIONAL_ID = pfad.PROFESSIONAL_ID
  WHERE ps.DECEASED = 'N'
  --  invalid status list
  AND   ps.JUDGE = 'N'
  AND   ps.RETIRED = 'N'
  AND   ps.OFFICIAL = 'N'
  AND   ps.UNVERIFIED = 'N'
  AND   ps.SANCTIONED = 'N'
  AND   pfad.NonNullPhone1Check + pfad.NullPhone1Check + pfad.NonNullEmailCheck + pfad.NullEmailCheck + pfad.DoubleNullCheck = 5
  -- not flagged as a duplicate by any field
),
profile_views AS
(
  SELECT regexp_extract(url,'-([0-9]+)',1) AS professional_id
  --,d1.year_month
         COUNT(DISTINCT render_instance_guid) AS distinct_pv
  FROM src.page_view pv
    JOIN dm.date_dim d1 ON d1.actual_date = pv.event_date
  WHERE event_date BETWEEN '2014-01-01' AND '2016-02-29'
  AND   page_type = 'Attorney_Profile'
  AND   regexp_extract (url,'-([0-9]+)',1) < '10000'
  GROUP BY 1--,2
),
reviews AS
(
  SELECT professional_id,
         COUNT(DISTINCT id) Review_Count,
         SUM(recommended) / COUNT(recommended)*1.0 PercentRecommended,
         AVG(overall_rating) AvgRating
  FROM src.barrister_professional_review pr
  WHERE created_at BETWEEN '2014-01-01' AND '2016-02-29'
  GROUP BY professional_Id
)

endorsements AS (

SELECT eds.endorsee_id AS professional_id,
                   COUNT(DISTINCT eds.id_ AS End_Count
                   FROM src.barrister_professional_endorsement eds
                   WHERE eds.created_at BETWEEN '2014-01-01' AND '2016-02-29'
                   GROUP BY 1
                   
)

SELECT pf.*
       ,pv.distinct_pv
       ,r.Review_Count
      ,r.PercentRecommended
       ,r.AvgRating
       ,e.professional_id
FROM deduped_pfad pf
  LEFT JOIN profile_views pv 
    ON pv.professional_id = pf.professional_id
  LEFT JOIN reviews r 
    ON r.professional_id = pf.professional_id
  LEFT JOIN endorsements e
    ON e.professional_id = pf.professional_id
    
 /* Notes:
There are four table objects used in this query:
1. "pfad": lawyer dimension data and duplicate rankings - joins on professional id
2. "dm": only used to get a count of lawyer profiles in each domain - joins on domain name (get rid of this for now)
3. "ps": only used to get some kind of status info - joins on professional id (move to where clause to exclude all listed status types)
4. "toppa": only used to get practice area - joins on professional id 

Final output should only be *unclaimed* profiles with missing data (either email or phone1 or both)
Be sure to /replace pfad subquery before running
*/ /* Notes:
 - Delete indicator must state "not deleted"
 - Practice indicator must state "practicing"
 - First and last must both be filled out
 - Must have at least *one* of Phone1-3, State, County, Email
 
 
- need to deal with partitioning when there are null values so that they're not considered distinct from each other.  */ /*INVALIDATE METADATA DM.PROFESSIONAL_DIMENSION
  INVALIDATE METADATA src.Barrister_Professional_Status */ /* this is the big DIM query that gets all the lawyer info and ranks duplicates in several ways */

