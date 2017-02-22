
WITH deduped_pfad AS 

(select pfad.PROFESSIONAL_ID
	-- ,dm.domain_size -- this is the only reason we subquery off the dm table; we don't need this
	,pfad.is_claim
	,pfad.claim_date
	,pfad.claim_method
	,pfad.domain
	,pfad.emaildomain
	,pfad.emailsuffix
	,pfad.lowscoreemaildomain
	,pfad.rating
	,pfad.county
	,pfad.state
	,case 
        when toppa.ParentPracticeArea1  in ('Criminal Defense','DUI & DWI','Divorce & Separation','Personal Injury','Family','Immigration',
        												'Car Accidents','Bankruptcy & Debt','Chapter 11 Bankruptcy','Chapter 13 Bankruptcy','Chapter 7 Bankruptcy',
																'Workers Compensation','Child Custody','Employment & Labor','Real Estate','Estate Planning','Business',
																'Lawsuits & Disputes','Motorcycle Accident')
		    then 'Y' 
            else 'N' 
        end as PriorityPA1
	,pfad.LawyerName
	,pfad.LawyerName_Full
	,pfad.firstname
    ,pfad.lastname
    ,pfad.middlename
    ,pfad.suffix
 	,pfad.phone1
	,pfad.phone2
	,pfad.phone3
	,pfad.email
	,pfad.delete_ind AS professional_delete_indicator
	,pfad.practice_ind AS professional_practice_indicator
	,pfad.prof_name AS professional_name
	,pfad.ind_name AS industry_name
	,pfad.country AS professional_country_name_1
	,toppa.PracticeArea1
	,toppa.PracticeArea2
	,toppa.PracticeArea3
	,toppa.ParentPracticeArea1
	,toppa.ParentPracticeArea2
	,toppa.ParentPracticeArea3
    ,CASE
        WHEN pfad.HasEmail = 1
            THEN 'Ok Email'
        ELSE 'Bad Email'
    END Email_Status
	,case 
        when pfad.HasPhone1 + pfad.HasPhone2 + pfad.HasPhone3 = 0
            then 'Bad Phone' 
            else 'Ok Phone' 
      end as Phone_Status
    ,CASE
        WHEN pfad.IsExcludedTitle = 1
            THEN 'Exclude Title'
            ELSE 'Title Okay'
        END IsExcludedTitle

 FROM (  
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
           /* If the first/last, middle, state, and county are the same, take out both entities and put on a separate list (filter all values > 1) 
           ,ROW_NUMBER() OVER(PARTITION BY pd.firstname, pd.lastname, pd.MiddleInitial, pd.state, pd.county 
                              ORDER BY pd.professional_id) PoojaTest1 */
           /* If the phone, first, last, county, and state are the same, take out both entities and put on a separate list (filter all values > 1) 
           ,ROW_NUMBER() OVER(PARTITION BY pd.phone1, pd.firstname, pd.lastname, pd.state, pd.county
                              ORDER BY pd.professional_id) PoojaTest2 */
           /* If the email, first, last, county, and state are the same, take out both entities and put on a separate list (filter all values > 1)     
           ,ROW_NUMBER() OVER(PARTITION BY pd.email, pd.firstname, pd.lastname, pd.state, pd.county
                              ORDER BY pd.professional_id) PoojaTest3 */ 
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
           ,(SUBSTR(upper(pd.emaildomain),length(pd.emaildomain)-3)) EmailSuffix
           ,substr(pd.emaildomain, 1, length(pd.emaildomain) - instr(pd.emaildomain, '.')) EmailDomainSubTest2
           ,instr(pd.emaildomain,'.')+1 StringTest
           ,case 
              when (SUBSTR(upper(pd.emaildomain),length(pd.emaildomain)-3) in ('.EDU','.GOV','.ORG', 'CO.US')) 
                  then 1
                  else 0
              end AS LowScoreEmailDomain
           /*,case 
              when (SUBSTR(upper(pd.emaildomain),length(pd.emaildomain)-3) in ('.EDU','.GOV','.ORG', 'CO.US')) 
                  then 1
                  else 0
              end AS HighScoreEmailDomain */
           ,LOCATE('.', pd.emaildomain) EmailPeriodPosition
           ,SUBSTR(upper(pd.emaildomain), LENGTH(pd.emaildomain) - LOCATE('.', pd.emaildomain)) EmailHostParse
       FROM (select pf.PROFESSIONAL_ID
             ,pf.professional_claim_method_name claim_method
              ,case
                  when pf.PROFESSIONAL_CLAIM_DATE is null
                      then 0
                      else 1
                  end as is_claim
              ,pf.professional_claim_date claim_date
              ,CASE
                  WHEN pf.PROFESSIONAL_COUNTY_NAME_1 = 'NOT APPLICABLE' -- get rid of string values in county name 
                      THEN NULL
                      ELSE pf.PROFESSIONAL_COUNTY_NAME_1
                  END county
              ,CASE
                  WHEN pf.PROFESSIONAL_STATE_NAME_1 = 'NOT APPLICABLE' -- get rid of string values in state name
                      THEN NULL
                      ELSE pf.PROFESSIONAL_STATE_NAME_1
                  END state
              ,CASE
                  WHEN pf.PROFESSIONAL_CITY_NAME_1 = 'NOT APPLICABLE' 
                      THEN NULL
                      ELSE pf.PROFESSIONAL_STATE_NAME_1
                  END city  
              ,PROFESSIONAL_PREFIX
              ,PROFESSIONAL_FIRST_NAME as FirstName 
              ,PROFESSIONAL_LAST_NAME as LastName
              ,PROFESSIONAL_MIDDLE_NAME as MiddleName
              ,PROFESSIONAL_SUFFIX as Suffix
      		,CASE
                  WHEN PROFESSIONAL_PHONE_NUMBER_1 LIKE '%Not%' --get rid of string values in phone number 
                      THEN NULL
                  WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_1) < 10 --get rid of invalid phone numbers 
                      THEN NULL
                      ELSE PROFESSIONAL_PHONE_NUMBER_1
                  END as phone1 
        		,CASE
                  WHEN PROFESSIONAL_PHONE_NUMBER_2 LIKE '%Not%'  
                      THEN NULL
                  WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_2) < 10 
                      THEN NULL
                  WHEN PROFESSIONAL_PHONE_NUMBER_2 = PROFESSIONAL_PHONE_NUMBER_1 -- get rid of duplicate phone numbers 
                      THEN NULL
                      ELSE PROFESSIONAL_PHONE_NUMBER_2
                  END as phone2 
        		,CASE
                  WHEN PROFESSIONAL_PHONE_NUMBER_3 LIKE '%Not%' 
                      THEN NULL
                  WHEN LENGTH(PROFESSIONAL_PHONE_NUMBER_3) < 10 
                      THEN NULL
                  WHEN PROFESSIONAL_PHONE_NUMBER_3 = PROFESSIONAL_PHONE_NUMBER_1 -- get rid of duplicate phone numbers 
                      THEN NULL
                  WHEN PROFESSIONAL_PHONE_NUMBER_3 = PROFESSIONAL_PHONE_NUMBER_2 -- get rid of duplicate phone numbers 
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
              ,LENGTH(TRIM(PROFESSIONAL_MIDDLE_NAME)) AS MiddleNameLength
              ,pf.PROFESSIONAL_AVVO_RATING AS rating -- invalid string
              ,concat(PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME) as LawyerName -- invalid string 
            -- these are useful to identify lawyers that have prefixes and be unusual or need to be excluded
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
                
              ,SUBSTR(TRIM(PROFESSIONAL_MIDDLE_NAME), 1, 1) MiddleInitial
              --,pf.PROFESSIONAL_DELETE_INDICATOR  as delete_ind
              --,pf.PROFESSIONAL_PRACTICE_INDICATOR as practice_ind
              ,pf.PROFESSIONAL_NAME as prof_name
              ,pf.INDUSTRY_NAME as ind_name
              ,pf.PROFESSIONAL_COUNTRY_NAME_1 as country
              ,substr(pf.professional_email_address_name, instr(professional_email_address_name,'@')+1) as emaildomain -- works!
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
      from  DM.PROFESSIONAL_DIMENSION pf
      -- exclusions
      where pf.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'
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
         AND LOWER(pf.PROFESSIONAL_FIRST_NAME) = 'vincent' --(for testing purposes)


          ) pd
      /*WHERE (case 
              when (SUBSTR(upper(pd.domain),length(pd.domain)-3) in ('.EDU','.GOV','.ORG')) 
                  then 1
                  else 0
              end) = 0 -- exclude these three domains (confirmed that this is working as advertised) */
  
      
      /*WHERE (case 
              when (SUBSTR(upper(pd.domain),length(pd.domain)-3) in ('.EDU','.GOV','.ORG')) 
                  then 1
                  else 0
              end) = 0 -- exclude these three domains (confirmed that this is working as advertised) */
  
      ) pfad
   
       
     
    left join SRC.barrister_professional_status ps 
        on ps.professional_id = pfad.PROFESSIONAL_ID
   

  left join ( 
        select x.PROFESSIONAL_ID    
            ,MIN(case 
                     when x.rt = 1 
                         then x.SPECIALTY_NAME 
                         else NULL 
                 end) as PracticeArea1       
            ,MIN(case 
                     when x.rt = 2 
                         then x.SPECIALTY_NAME 
                         else NULL 
                     end) as PracticeArea2  
            ,MIN(case 
                     when x.rt = 3 
                         then x.SPECIALTY_NAME 
                         else NULL 
                     end) as PracticeArea3 
            ,MIN(case 
                     when x.rt = 1 
                         then x.PARENT_SPECIALTY_NAME 
                         else NULL 
                     end) as ParentPracticeArea1       
            ,MIN(case 
                     when x.rt = 2 
                         then x.PARENT_SPECIALTY_NAME else NULL end) as ParentPracticeArea2  
            ,MIN(case when x.rt = 3 then x.PARENT_SPECIALTY_NAME else NULL end) as ParentPracticeArea3 
     
        from (          
            select pfsp.PROFESSIONAL_ID     
                ,pfsp.SPECIALTY_PERCENT
                ,sp.SPECIALTY_NAME
                ,sp.PARENT_SPECIALTY_NAME
                ,ROW_NUMBER() OVER(partition by pfsp.PROFESSIONAL_ID order by pfsp.SPECIALTY_PERCENT desc ) rt   
            from DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp      
                join DM.SPECIALTY_DIMENSION sp 
                    on sp.SPECIALTY_ID = pfsp.SPECIALTY_ID       
            where pfsp.DELETE_FLAG = 'N'      
            ) x        
        group by 1
    ) toppa 
on toppa.PROFESSIONAL_ID = pfad.PROFESSIONAL_ID

WHERE ps.DECEASED = 'N' --  invalid status list
    AND ps.JUDGE = 'N' 
    AND ps.RETIRED = 'N' 
    AND ps.OFFICIAL= 'N' 
    AND ps.UNVERIFIED= 'N' 
    AND ps.SANCTIONED= 'N'
    AND pfad.NonNullPhone1Check + pfad.NullPhone1Check + pfad.NonNullEmailCheck + pfad.NullEmailCheck + pfad.DoubleNullCheck = 5 -- not flagged as a duplicate by any field      
)
,

profile_views AS (
select regexp_extract(url, '-([0-9]+)', 1) as professional_id
--,d1.year_month
, count(distinct render_instance_guid) as distinct_pv
from src.page_view pv
join dm.date_dim d1 
            	   on d1.actual_date = pv.event_date
where event_date BETWEEN '2014-01-01' AND '2016-02-29' 
  and page_type = 'Attorney_Profile'
  AND regexp_extract(url, '-([0-9]+)', 1) < '10000'
group by 1--,2

)

,

reviews AS (

SELECT professional_id
  ,COUNT(DISTINCT id) Review_Count
  ,SUM(recommended)/COUNT(recommended)*1.0 PercentRecommended
  ,AVG(overall_rating) AvgRating
FROM src.barrister_professional_review pr
WHERE created_at BETWEEN '2014-01-01' AND '2016-02-29'
GROUP BY professional_Id

)

SELECT pf.*
  ,pv.distinct_pv
  ,r.Review_Count
  ,r.PercentRecommended
  ,r.AvgRating
FROM deduped_pfad pf
  LEFT JOIN profile_views pv
    ON pv.professional_id = pf.professional_id
  LEFT JOIN reviews r
    ON r.professional_id = pf.professional_id



 /* Notes:
There are four table objects used in this query:
1. "pfad": lawyer dimension data and duplicate rankings - joins on professional id
2. "dm": only used to get a count of lawyer profiles in each domain - joins on domain name (get rid of this for now)
3. "ps": only used to get some kind of status info - joins on professional id (move to where clause to exclude all listed status types)
4. "toppa": only used to get practice area - joins on professional id 

Final output should only be *unclaimed* profiles with missing data (either email or phone1 or both)
Be sure to /replace pfad subquery before running
*/

 /* Notes:
 - Delete indicator must state "not deleted"
 - Practice indicator must state "practicing"
 - First and last must both be filled out
 - Must have at least *one* of Phone1-3, State, County, Email
 
 
- need to deal with partitioning when there are null values so that they're not considered distinct from each other.  */

  /*INVALIDATE METADATA DM.PROFESSIONAL_DIMENSION
  INVALIDATE METADATA src.Barrister_Professional_Status */

/* this is the big DIM query that gets all the lawyer info and ranks duplicates in several ways */
	
 

