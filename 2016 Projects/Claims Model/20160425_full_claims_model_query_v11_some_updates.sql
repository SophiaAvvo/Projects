WITH deduped_pfad AS
(
SELECT pfad.PROFESSIONAL_ID
         ,pfad.is_claim
         ,pfad.claim_date
		 ,pfad.reference_date_prior_day
		 ,pfad.reference_date_prior_month
         ,pfad.claim_method
         ,pfad.domain
         ,pfad.emaildomain
         ,pfad.emailsuffix
         ,pfad.lowscoreemaildomain
         -- ,pfad.rating
         ,pfad.county
		 ,pfad.license_state
         -- ,pfad.state
         ,CASE
           WHEN toppa.ParentPracticeArea1 IN ('Criminal Defense','DUI & DWI','Divorce & Separation','Personal Injury','Family','Immigration','Car Accidents','Bankruptcy & Debt','Chapter 11 Bankruptcy','Chapter 13 Bankruptcy','Chapter 7 Bankruptcy','Workers Compensation','Child Custody','Employment & Labor','Real Estate','Estate Planning','Business','Lawsuits & Disputes','Motorcycle Accident') THEN 'Y'
           ELSE 'N'
         END AS PriorityPA1
         --,pfad.LawyerName
         -- ,pfad.LawyerName_Full
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
         ,pfad.country AS professional_country_name_1
         /*,toppa.PracticeArea1
         ,toppa.PracticeArea2
         ,toppa.PracticeArea3
         ,toppa.ParentPracticeArea1
         ,toppa.ParentPracticeArea2
         ,toppa.ParentPracticeArea3 */
         ,CASE
           WHEN pfad.HasEmail = 1 THEN 'Ok Email'
           ELSE 'Bad Email'
         END Email_Status
         ,CASE
           WHEN pfad.HasPhone1 + pfad.HasPhone2 + pfad.HasPhone3 = 0 THEN 'Bad Phone'
           ELSE 'Ok Phone'
         END AS Phone_Status
         ,CASE
           WHEN pfad.IsExcludedTitle = 1 THEN 'Exclude Title'
           ELSE 'Title Okay'
         END IsExcludedTitle
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
               ,(SUBSTR(UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3)) EmailSuffix
               ,CASE
                 WHEN (SUBSTR (UPPER(pd.emaildomain),LENGTH(pd.emaildomain) -3) IN ('.EDU','.GOV','.ORG','CO.US')) THEN 1
                 ELSE 0
               END AS LowScoreEmailDomain
			          ,CASE
					  WHEN LOWER(pf.emaildomain) IN ('gmail.com', 'yahoo.com', 'aol.com', 'msn.com', 'hotmail.com')
						THEN 1
					  ELSE 0
					END HighScoreEmailDomain
              -- ,CAST(pf.professional_Id AS VARCHAR) AS professional_id_str
        FROM (SELECT pf.PROFESSIONAL_ID
                     ,pf.professional_claim_method_name claim_method
                     ,CASE
                       WHEN pf.PROFESSIONAL_CLAIM_DATE IS NULL THEN 0
                       ELSE 1
                     END AS is_claim
                     ,pf.professional_claim_date claim_date
					 ,CASE
						WHEN pf.professional_claim_date IS NULL
							then to_date(now() - interval 1 day)
						ELSE to_date(to_utc_timestamp(pf.professional_claim_date, 'pdt') - interval 1 day) 
						END AS reference_date_prior_day
					,CASE
						WHEN pf.professional_claim_date IS NULL
							then to_date(now() - interval 31 days)
						ELSE to_date(to_utc_timestamp(pf.professional_claim_date, 'pdt') - interval 31 days) 
						END AS reference_date_prior_month
					 ,CASE
						WHEN pf.professional_claim_date IS NULL
							then now() - interval 1 day
						ELSE to_utc_timestamp(pf.professional_claim_date, 'pdt') - interval 1 day 
						END AS reference_datetime_prior_day
					,CASE
						WHEN pf.professional_claim_date IS NULL
							then now() - interval 31 days
						ELSE to_utc_timestamp(pf.professional_claim_date, 'pdt') - interval 31 days
						END AS reference_datetime_prior_month	
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
                       WHEN PROFESSIONAL_PREFIX IN ('Chiefjustice','Col','Col.','Colonel','Hon','Hon.','Honorable','Maj','Maj.','Maj. Gen.','Major','Mr. Judge','Mr. Justice','The Honorable') THEN 1
                       ELSE 0
                     END AS IsExcludedTitle
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
					 ,pf.professional_license_state_name_1 AS license_state
              FROM DM.PROFESSIONAL_DIMENSION pf
              WHERE pf.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'
              AND   pf.PROFESSIONAL_PRACTICE_INDICATOR = 'Practicing'
              AND   (CASE WHEN pf.PROFESSIONAL_STATE_NAME_1 IS NULL THEN 1 ELSE 0 END) = 0
              AND   (CASE WHEN PROFESSIONAL_FIRST_NAME IS NULL THEN 1 ELSE 0 END) = 0
              AND   (CASE WHEN PROFESSIONAL_LAST_NAME IS NULL THEN 1 ELSE 0 END) = 0
              AND   pf.PROFESSIONAL_NAME = 'lawyer'
              AND   pf.INDUSTRY_NAME = 'Legal'
             ) pd
             
    ) pfad
    LEFT JOIN SRC.barrister_professional_status ps 
         ON ps.professional_id = pfad.PROFESSIONAL_ID
    /*LEFT JOIN (SELECT x.PROFESSIONAL_ID
                   ,MIN(CASE WHEN x.rt = 1 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea1
                      ,MIN(CASE WHEN x.rt = 2 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea2
                      ,MIN(CASE WHEN x.rt = 3 THEN x.SPECIALTY_NAME ELSE NULL END) AS PracticeArea3
                      ,MIN(CASE WHEN x.rt = 1 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea1
                      ,MIN(CASE WHEN x.rt = 2 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea2
                      ,MIN(CASE WHEN x.rt = 3 THEN x.PARENT_SPECIALTY_NAME ELSE NULL END) AS ParentPracticeArea3
               FROM (SELECT pfsp.PROFESSIONAL_ID
                            ,pfsp.SPECIALTY_PERCENT
                            ,sp.SPECIALTY_NAME
                            ,sp.PARENT_SPECIALTY_NAME
                            ,ROW_NUMBER() OVER (PARTITION BY pfsp.PROFESSIONAL_ID ORDER BY pfsp.SPECIALTY_PERCENT DESC) rt
                     FROM DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp
                       JOIN DM.SPECIALTY_DIMENSION sp ON sp.SPECIALTY_ID = pfsp.SPECIALTY_ID
                     WHERE pfsp.DELETE_FLAG = 'N') x
               GROUP BY 1) toppa ON toppa.PROFESSIONAL_ID = pfad.PROFESSIONAL_ID */
  WHERE ps.DECEASED = 'N'
  AND   ps.JUDGE = 'N'
  AND   ps.RETIRED = 'N'
  AND   ps.OFFICIAL = 'N'
  AND   ps.UNVERIFIED = 'N'
  AND   ps.SANCTIONED = 'N'
  AND   pfad.NonNullPhone1Check + pfad.NullPhone1Check + pfad.NonNullEmailCheck + pfad.NullEmailCheck + pfad.DoubleNullCheck = 5
  --AND STRRIGHT(pf.professional_id_str, 1) NOT IN ('0', '1', '2', '3')
)
  
 /* ,
-- test this part next  
profile_views AS
(
  SELECT CAST(regexp_extract(url,'-([0-9]+)',1) AS INT) AS professional_id
		,p.reference_date_prior_day
		,p.reference_date_prior_month
		,p.is_claim
         ,COUNT(DISTINCT render_instance_guid) AS distinct_pv
		 ,COUNT(DISTINCT pv.event_date) DayCountCheck
  FROM src.page_view pv
    JOIN deduped_pfad p
		ON p.professional_id = CAST(regexp_extract(url,'-([0-9]+)',1) AS INT)
		AND pv.event_date BETWEEN p.reference_date_prior_month AND p.reference_date_prior_day
		  AND   page_type = 'Attorney_Profile'
    JOIN dm.date_dim d1 ON d1.actual_date = pv.event_date
  -- WHERE event_date BETWEEN '2015-05-01' AND '2016-02-29'
  GROUP BY 1,2,3,4
  ORDER BY professional_id
)*/

,

reviews AS
(
  SELECT professional_id,
         COUNT(DISTINCT id) Review_Count,
         SUM(recommended) / COUNT(recommended)*1.0 PercentRecommended,
         AVG(overall_rating) AvgRating
  FROM src.barrister_professional_review pr
	JOIN deduped_pfad p
		ON p.professional_id = pr.professional_id
		AND pr.created_at BETWEEN p.reference_datetime_prior_month AND p.reference_datetime_prior_day
  GROUP BY pr.professional_Id
)

,

endorsements AS (

	SELECT eds.endorsee_id AS professional_id
		,COUNT(DISTINCT eds.id) AS End_Count
    FROM src.barrister_professional_endorsement eds
		JOIN deduped_pfad p
			ON p.professional_id = eds.endorsee_id 
			AND eds.created_at BETWEEN p.reference_datetime_prior_month AND p.reference_datetime_prior_day
    GROUP BY 1
                   
)

,

license AS (

SELECT professional_id
  ,MIN(license_date) FirstLicenseDate
  ,MAX(license_date) LastLicenseDate
  ,COUNT(id) licensecount
FROM src.barrister_license bl
GROUP BY professional_id

)

/*

contacts as
( select 
professional_id
, count(*) as num_contacts

from src.contact_impression ci
join dm.date_dim d on d.actual_date = ci.event_date
where ci.event_date BETWEEN '2015-05-01' AND '2016-02-29'
group by 1
 )
 ,
 
impressions as
(  select 
CAST(id AS INT) as professional_id
, count(api.persistent_session_id) as num_profileimpression

from dm.all_professional_impressions api
join dm.date_dim d on d.actual_date = api.event_date
where api.event_date >= '2015-11-01'
group by 1
 )  
 
 */

SELECT pf.*
       ,pv.distinct_pv
       ,r.Review_Count
      ,r.PercentRecommended
       ,r.AvgRating
       ,e.End_Count
       ,lc.FirstLicenseDate
       ,lc.LastLicenseDate
       ,lc.licensecount
       ,ed.EmailDomainSize
       ,CASE
          WHEN ed.EmailDomainSize >= 1
            THEN 'Not Unique'
            WHEN ed.EmailDomainSize = 1
              THEN 'Unique'
            ELSE NULL
        END UniqueDomainFlag

       ,af.*
       ,imp.num_profileimpression AS impressions2016only
       ,c.num_contacts
FROM deduped_pfad pf
  LEFT JOIN license lc
    ON lc.professional_id = pf.professional_id
  LEFT JOIN profile_views pv 
    ON pv.professional_id = pf.professional_id
  LEFT JOIN reviews r 
    ON r.professional_id = pf.professional_id
  LEFT JOIN endorsements e
    ON e.professional_id = pf.professional_id
  LEFT JOIN (SELECT pf.emaildomain
              ,COUNT(DISTINCT pf.professional_id) EmailDomainSize
              FROM deduped_pfad pf
              GROUP BY pf.emaildomain) ed
     ON pf.emaildomain = ed.emaildomain
  LEFT JOIN ad_fields af
     ON af.state = pf.state
     AND af.county = pf.county
  LEFT JOIN impressions imp
     ON imp.professional_id = pf.professional_id
  LEFT JOIN contacts c
     ON c.professional_id = pf.professional_id
WHERE (lc.lastlicensedate >= '1943-01-01' OR lc.lastlicensedate IS NULL)
  --AND STRRIGHT(CAST(pf.professional_id AS VARCHAR), 1) IN ('0', '1', '2', '3', '4')
    
 
