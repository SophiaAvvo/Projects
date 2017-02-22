WITH deduped_pfad AS
(
SELECT pfad.PROFESSIONAL_ID
		 ,pfad.reference_date_prior_day
		 ,pfad.reference_date_prior_month
		 ,pfad.reference_datetime_prior_day
		 ,pfad.reference_datetime_prior_month
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
        FROM (SELECT pf.PROFESSIONAL_ID
                     ,CASE
                       WHEN pf.PROFESSIONAL_CLAIM_DATE IS NULL THEN 0
                       ELSE 1
                     END AS is_claim
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
							then to_date(now() - interval 1 day)
						ELSE to_date(to_utc_timestamp(pf.professional_claim_date, 'PDT') - interval 1 day) 
						END AS reference_date_prior_day
					,CASE
						WHEN pf.professional_claim_date IS NULL
							then to_date(now() - interval 31 days)
						ELSE to_date(to_utc_timestamp(pf.professional_claim_date, 'PDT') - interval 31 days) 
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
                     ,SUBSTR(TRIM(PROFESSIONAL_MIDDLE_NAME),1,1) MiddleInitial
					 --,COALESCE(pf.professional_license_state_name_1, pf.professional_license_state_name_2, pf.professional_license_state_name_3) license_state
              FROM DM.PROFESSIONAL_DIMENSION pf
              WHERE pf.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'
              AND   pf.PROFESSIONAL_PRACTICE_INDICATOR = 'Practicing'
              /*AND   (CASE WHEN pf.PROFESSIONAL_STATE_NAME_1 IS NULL THEN 1 ELSE 0 END) = 0
              AND   (CASE WHEN PROFESSIONAL_FIRST_NAME IS NULL THEN 1 ELSE 0 END) = 0
              AND   (CASE WHEN PROFESSIONAL_LAST_NAME IS NULL THEN 1 ELSE 0 END) = 0 */
              AND   pf.PROFESSIONAL_NAME = 'lawyer'
              AND   pf.INDUSTRY_NAME = 'Legal'
			  AND pf.professional_id < 100
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

r1 AS (

select
  sd.professional_id
  ,(case when sd.displayable_score>10 then 10
  when sd.displayable_score<1 then 1 else
  sd.displayable_score end ) rating
  ,score_date
  ,ROW_NUMBER() OVER(PARTITION BY sd.professional_id ORDER BY score_date) Num
  from
  (
  select opsl.professional_id,opsl.score_date,round(sum(opsl.displayable_score)+5,1) displayable_score
  from
  src.history_barrister_professional_scoring_log  opsl
  join src.barrister_scoring_category_attribute  osca 
  on opsl.scoring_category_attribute_id=osca.id
	--AND opsl.score_date >= '2015-05-01'
  join src.barrister_scoring_category  osc on
  osca.scoring_category_id=osc.id
  and osc.name='Overall'
  group by opsl.professional_id,opsl.score_date
  ) sd
  
  )
  
,
r2 AS (SELECT x.professional_id
,x.rating
,x.score_date AS ScoreDate1
,to_date(COALESCE(DATE_ADD(y.score_date, -1), now() - interval 1 day)) AS ScoreDate2
FROM r1 x
LEFT JOIN r1 y
ON x.professional_id = y.professional_id
AND x.Num = y.Num - 1
  -- ORDER BY 1,3,4   

)

,

r3 AS (
SELECT r.professional_id
,r.rating Rating
,p.reference_date_prior_day RatingDate
FROM r2 r
JOIN deduped_pfad p
  ON p.reference_date_prior_day BETWEEN r.scoredate1 AND r.scoredate2
  AND p.professional_id = r.professional_id
  
)

SELECT *
,ROW_NUMBER() OVER(PARTITION BY professional_id, RatingDate OrDER BY Rating DESC)
FROM r3
  
