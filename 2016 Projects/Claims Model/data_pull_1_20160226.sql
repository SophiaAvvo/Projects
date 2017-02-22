 SELECT pd.*
     ,CASE
         WHEN pd.phone1 IS NOT NULL
             THEN ROW_NUMBER() OVER(PARTITION BY pd.phone1, pd.email, pd.lastname, pd.firstname, pd.state 
                                    ORDER BY pd.phone1 DESC, pd.email DESC, phone2 DESC, phone3 DESC, pd.county DESC, pd.MiddleInitial DESC, pd.MiddleNameLength DESC, pd.suffix DESC, pd.rating DESC, pd.professional_id)
             ELSE 1 
      END AS NonNullPhone1Check
     ,CASE
         WHEN pd.phone1 IS NULL
             THEN ROW_NUMBER() OVER(PARTITION BY pd.email, pd.firstname, pd.lastname, pd.state 
                                    ORDER BY pd.email DESC, pd.county DESC, pd.MiddleInitial DESC, pd.MiddleNameLength DESC, pd.suffix DESC, pd.rating DESC, pd.professional_id )
             ELSE 1
         END AS NullPhone1Check
     ,CASE
         WHEN pd.email IS NOT NULL
             THEN ROW_NUMBER() OVER(PARTITION BY pd.email, pd.phone1, pd.lastname, pd.firstname, pd.state 
                                    ORDER BY pd.phone1 DESC, pd.email DESC, phone2 DESC, phone3 DESC, pd.county DESC, pd.MiddleInitial DESC, pd.MiddleNameLength DESC, pd.suffix DESC, pd.rating DESC,pd.professional_id)
             ELSE 1
      END AS NonNullEmailCheck
     ,CASE
         WHEN pd.email IS NULL
             THEN ROW_NUMBER() OVER(PARTITION BY pd.phone1, pd.firstname, pd.lastname, pd.state 
                                    ORDER BY pd.phone1 DESC, phone2 DESC, phone3 DESC, pd.county DESC, pd.MiddleInitial DESC, pd.MiddleNameLength DESC, pd.suffix DESC, pd.rating DESC, pd.professional_id)
             ELSE 1
         END AS NullEmailCheck
     ,CASE
         WHEN pd.email IS NULL 
         AND pd.phone1 IS NULL
             THEN ROW_NUMBER() OVER(PARTITION BY pd.lastname, pd.firstname, pd.state 
                                    ORDER BY pd.MiddleInitial DESC, pd.MiddleNameLength DESC, pd.suffix DESC, pd.rating DESC, pd.professional_id)
             ELSE 1
         END AS DoubleNullCheck
     /* If the first/last, middle, state, and county are the same, take out both entities and put on a separate list (filter all values > 1) */
     ,ROW_NUMBER() OVER(PARTITION BY pd.firstname, pd.lastname, pd.MiddleInitial, pd.state, pd.county 
                        ORDER BY /*pd.MiddleInitial DESC, pd.MiddleNameLength DESC, pd.suffix DESC, pd.rating DESC,*/ pd.professional_id) PoojaTest1 
     /* If the phone, first, last, county, and state are the same, take out both entities and put on a separate list (filter all values > 1) */
     ,ROW_NUMBER() OVER(PARTITION BY pd.phone1, pd.firstname, pd.lastname, pd.state, pd.county
                        ORDER BY /*pd.MiddleInitial DESC, pd.MiddleNameLength DESC, pd.suffix DESC, pd.rating DESC,*/ pd.professional_id) PoojaTest2
     /* If the email, first, last, county, and state are the same, take out both entities and put on a separate list (filter all values > 1) */     
     ,ROW_NUMBER() OVER(PARTITION BY pd.email, pd.firstname, pd.lastname, pd.state, pd.county
                        ORDER BY /*pd.MiddleInitial DESC, pd.MiddleNameLength DESC, pd.suffix DESC, pd.rating DESC, */pd.professional_id) PoojaTest3
     ,CASE
         WHEN pd.email IS NULL
             THEN 0
             ELSE 1
         END AS HasEmail
     ,CASE
         WHEN pd.phone1 IS NULL
             THEN 0
             ELSE 1
         END AS HasPhone1
     ,CASE
         WHEN pd.phone2 IS NULL
             THEN 0
             ELSE 1
         END AS HasPhone2
     ,CASE
         WHEN pd.county IS NULL
             THEN 0
             ELSE 1
         END AS HasCounty
     ,CASE
         WHEN pd.phone3 IS NULL
             THEN 0
             ELSE 1
         END AS HasPhone3
     ,CASE
         WHEN pd.MiddleInitial IS NULL
             THEN 0
             ELSE 1
         END AS HasMiddleInitial
 FROM (select pf.PROFESSIONAL_ID
        ,CASE
            WHEN pf.PROFESSIONAL_COUNTY_NAME_1 = 'NOT APPLICABLE' /* get rid of string values in county name */
                THEN NULL
                ELSE pf.PROFESSIONAL_COUNTY_NAME_1
            END county
        ,CASE
            WHEN pf.PROFESSIONAL_STATE_NAME_1 = 'NOT APPLICABLE' /* get rid of string values in state name */
                THEN NULL
                ELSE pf.PROFESSIONAL_STATE_NAME_1
            END state
        ,PROFESSIONAL_PREFIX
        ,PROFESSIONAL_FIRST_NAME as FirstName /* simplifying field names for readability */
        ,PROFESSIONAL_LAST_NAME as LastName
        ,PROFESSIONAL_MIDDLE_NAME as MiddleName
        ,PROFESSIONAL_SUFFIX as Suffix
		,CASE
            WHEN PROFESSIONAL_PHONE_NUMBER_1 LIKE '%Not%' /* get rid of string values in phone number */
                THEN NULL
            WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_1) < 10 /* get rid of invalid phone numbers */
                THEN NULL
                ELSE PROFESSIONAL_PHONE_NUMBER_1
            END as phone1 
  		,CASE
            WHEN PROFESSIONAL_PHONE_NUMBER_2 LIKE '%Not%' /* get rid of string values in phone number */
                THEN NULL
            WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_2) < 10 /* get rid of invalid phone numbers */
                THEN NULL
            WHEN PROFESSIONAL_PHONE_NUMBER_2 = PROFESSIONAL_PHONE_NUMBER_1 /* get rid of duplicate phone numbers */
                THEN NULL
                ELSE PROFESSIONAL_PHONE_NUMBER_2
            END as phone2 
  		,CASE
            WHEN PROFESSIONAL_PHONE_NUMBER_3 LIKE '%Not%' /* get rid of string values in phone number */
                THEN NULL
            WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_3) < 10 /* get rid of invalid phone numbers */
                THEN NULL
            WHEN PROFESSIONAL_PHONE_NUMBER_3 = PROFESSIONAL_PHONE_NUMBER_1 /* get rid of duplicate phone numbers */
                THEN NULL
            WHEN PROFESSIONAL_PHONE_NUMBER_3 = PROFESSIONAL_PHONE_NUMBER_2 /* get rid of duplicate phone numbers */
                THEN NULL
                ELSE PROFESSIONAL_PHONE_NUMBER_3
            END as phone3
        ,CASE
            WHEN LTRIM(LOWER(PROFESSIONAL_EMAIL_ADDRESS_NAME)) LIKE 'info@%'
                THEN NULL
            WHEN LTRIM(LOWER(PROFESSIONAL_EMAIL_ADDRESS_NAME)) LIKE 'contactus@%'
                THEN NULL
            when PROFESSIONAL_EMAIL_ADDRESS_NAME = ' '
                THEN NULL
            WHEN PROFESSIONAL_EMAIL_ADDRESS_NAME = 'Null'
                THEN NULL
                ELSE PROFESSIONAL_EMAIL_ADDRESS_NAME 
            END as email
        ,LENGTH(TRIM(PROFESSIONAL_MIDDLE_NAME)) MiddleNameLength
        ,pf.PROFESSIONAL_AVVO_RATING rating
        ,concat(PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME) as LawyerName
      /* these are useful to identify lawyers that have prefixes and be unusual or need to be excluded*/
        ,case 
            when PROFESSIONAL_PREFIX IS NULL 
            AND PROFESSIONAL_SUFFIX IS NULL 
            AND PROFESSIONAL_MIDDLE_NAME IS NULL 
                THEN concat(PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME)
   	        when PROFESSIONAL_PREFIX IS NULL 
            AND PROFESSIONAL_SUFFIX IS NULL 
                THEN concat(PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME)
	        when PROFESSIONAL_PREFIX IS NULL 
            AND PROFESSIONAL_MIDDLE_NAME IS NULL 
                THEN concat(PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
            when PROFESSIONAL_PREFIX IS NULL 
                THEN concat(PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
			when PROFESSIONAL_SUFFIX IS NULL 
            AND PROFESSIONAL_MIDDLE_NAME IS NULL 
                THEN concat(PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME)
         	when PROFESSIONAL_SUFFIX IS NULL 
                THEN concat(PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME)
         	WHEN PROFESSIONAL_MIDDLE_NAME IS NULL 
                THEN concat(PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX)
			ELSE concat(PROFESSIONAL_PREFIX,' ',PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_MIDDLE_NAME,' ',PROFESSIONAL_LAST_NAME,' ',PROFESSIONAL_SUFFIX) END as LawyerName_Full
		,case 
            when PROFESSIONAL_PREFIX in ('Chiefjustice','Col','Col.','Colonel','Hon','Hon.','Honorable','Maj','Maj.','Maj. Gen.','Major','Mr. Judge','Mr. Justice','The Honorable') 
                then 1 
                else 0 
            end as IsExcludedTitle
          ,case
            when pf.PROFESSIONAL_CLAIM_DATE is null
                then 0
                else 1
            end as is_claim
        ,SUBSTR(TRIM(PROFESSIONAL_MIDDLE_NAME), 1, 1) MiddleInitial
        ,pf.PROFESSIONAL_DELETE_INDICATOR  as delete_ind
        ,pf.PROFESSIONAL_PRACTICE_INDICATOR as practice_ind
        ,pf.PROFESSIONAL_NAME as prof_name
        ,pf.INDUSTRY_NAME as ind_name
        ,pf.PROFESSIONAL_COUNTRY_NAME_1 as country
        ,substr(pf.professional_email_address_name, instr(professional_email_address_name,'@')+1) as emaildomain
	    ,case 
            when (parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST') is null 
            and instr(pf.PROFESSIONAL_WEBSITE_URL,'http:')=1 ) 
                then pf.PROFESSIONAL_WEBSITE_URL 
    		when (parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST') is null 
            and instr(pf.PROFESSIONAL_WEBSITE_URL,'http:')=0 ) 
                then substr(pf.PROFESSIONAL_WEBSITE_URL,instr(pf.PROFESSIONAL_WEBSITE_URL,'www.')+1)
      	    when (parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST') is not null 
            and instr(pf.PROFESSIONAL_WEBSITE_URL,'www'  )=0 ) 
                then parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST')
                else substr(parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST'),instr(pf.PROFESSIONAL_WEBSITE_URL,'www.')-3) 
            end as domain
   /*, case when (PROFESSIONAL_PHONE_NUMBER_1 is null) then 1 else 
			(ROW_NUMBER() OVER(partition by concat(PROFESSIONAL_PHONE_NUMBER_1,PROFESSIONAL_FIRST_NAME,PROFESSIONAL_LAST_NAME,pf.PROFESSIONAL_STATE_NAME_1) order by pf.PROFESSIONAL_AVVO_RATING desc, PROFESSIONAL_PHONE_NUMBER_1 desc, pf.PROFESSIONAL_ID)) 
			 end as phonedupe_1
	, case when (PROFESSIONAL_PHONE_NUMBER_1 is null) then 1 else 
			(ROW_NUMBER() OVER(partition by concat(PROFESSIONAL_PHONE_NUMBER_1,PROFESSIONAL_FIRST_NAME,PROFESSIONAL_LAST_NAME) order by pf.PROFESSIONAL_AVVO_RATING desc, PROFESSIONAL_PHONE_NUMBER_1 desc, pf.PROFESSIONAL_ID)) 
			end as phonedupe_2
			
	, case when (PROFESSIONAL_EMAIL_ADDRESS_NAME is null) then 1 else 
			(ROW_NUMBER() OVER(partition by concat(PROFESSIONAL_EMAIL_ADDRESS_NAME,PROFESSIONAL_FIRST_NAME,PROFESSIONAL_LAST_NAME,pf.PROFESSIONAL_STATE_NAME_1) order by pf.PROFESSIONAL_AVVO_RATING desc, PROFESSIONAL_PHONE_NUMBER_1 desc, pf.PROFESSIONAL_ID)) 
			 end as emaildupe_1
	, case when (PROFESSIONAL_EMAIL_ADDRESS_NAME is null) then 1 else 
			(ROW_NUMBER() OVER(partition by concat(PROFESSIONAL_EMAIL_ADDRESS_NAME,PROFESSIONAL_FIRST_NAME,PROFESSIONAL_LAST_NAME) order by pf.PROFESSIONAL_AVVO_RATING desc, PROFESSIONAL_PHONE_NUMBER_1 desc, pf.PROFESSIONAL_ID)) 
			 end as emaildupe_2 
             */
from  DM.PROFESSIONAL_DIMENSION pf
-- exclusions
where pf.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'
AND LOWER(pf.professional_first_name) = 'james'
AND LOWER(pf.professional_last_name) = 'salley'
    and pf.PROFESSIONAL_PRACTICE_INDICATOR = 'Practicing' -- keep and flag per discussion with Pooja
    AND (CASE
            WHEN pf.PROFESSIONAL_STATE_NAME_1 IS NULL
                THEN 1
                ELSE 0
            END) = 0
     AND (CASE
             WHEN PROFESSIONAL_FIRST_NAME IS NULL
                THEN 1
                ELSE 0
            END) = 0
     AND (CASE
             WHEN PROFESSIONAL_LAST_NAME IS NULL
                THEN 1
                ELSE 0
            END) = 0
            -- Must have at least first, last, and state
    and pf.PROFESSIONAL_NAME = 'lawyer'
    and pf.INDUSTRY_NAME = 'Legal'
  --  and pf.PROFESSIONAL_COUNTRY_NAME_1 = 'UNITED STATES'
    -- AND LOWER(pf.PROFESSIONAL_FIRST_NAME) = 'vincent' (for testing purposes)


    ) pd
WHERE (case 
        when (SUBSTR(upper(pd.domain),length(pd.domain)-3) in ('.EDU','.GOV','.ORG')) 
            then 1
            else 0
        end) = 0 -- exclude these three domains (confirmed that this is working as advertised)
