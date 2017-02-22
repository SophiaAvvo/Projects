
WITH professional_dimension AS 

(

   
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
/*WHERE (case 
        when (SUBSTR(upper(pd.domain),length(pd.domain)-3) in ('.EDU','.GOV','.ORG')) 
            then 1
            else 0
        end) = 0 -- exclude these three domains (confirmed that this is working as advertised) */
  
)
         

select pfad.PROFESSIONAL_ID
	-- ,dm.domain_size -- this is the only reason we subquery off the dm table; we don't need this
	,pfad.is_claim
	,pfad.domain
	,pfad.emaildomain
	,pfad.rating AS professional_avvo_rating
	,pfad.county AS PROFESSIONAL_COUNTY_NAME_1
	,pfad.state AS PROFESSIONAL_STATE_NAME_1
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
	,pfad.firstname AS PROFESSIONAL_FIRST_NAME
    ,pfad.lastname AS PROFESSIONAL_LAST_NAME
    ,pfad.middlename AS PROFESSIONAL_MIDDLE_NAME
    ,pfad.suffix AS PROFESSIONAL_SUFFIX
 	,pfad.phone1 AS PROFESSIONAL_PHONE_NUMBER_1
	,pfad.phone2 AS PROFESSIONAL_PHONE_NUMBER_2
	,pfad.phone3 AS PROFESSIONAL_PHONE_NUMBER_3
	,pfad.email AS PROFESSIONAL_EMAIL_ADDRESS_NAME
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
    -- ,pfad.NonNullPhone1Check + pfad.NullPhone1Check + pfad.NonNullEmailCheck + pfad.NullEmailCheck + pfad.DoubleNullCheck DupeCheck5 (this works, moving to where clause)
    -- ,pfad.HasPhone1 + pfad.HasEmail PopulatedFieldsCheck (this works, moving to where clause)
    /*,CASE
        WHEN ps.DECEASED = 'Y' --  invalid status list
            THEN 1
        WHEN ps.JUDGE = 'Y' 
            THEN 1
        WHEN ps.RETIRED = 'Y' 
            THEN 1
        WHEN ps.OFFICIAL= 'Y' 
            THEN 1
        WHEN ps.UNVERIFIED= 'Y' 
            THEN 1
        WHEN ps.SANCTIONED = 'Y'
            THEN 1
            ELSE 0
        END AS IsInvalidStatus (moved to WHERE clause) */
   -- ,SUBSTR(upper(pfad.domain),length(pfad.domain)-3) SubstringDomainCheck (verified)
    ,pt1.Test1
   -- ,pt1.EmailCountCheck
   -- ,pt1.Phone1CountCheck
    ,pt2.Test2
    ,pt3.Test3 -- (this works)
    ,ps.DECEASED
    ,ps.JUDGE
    ,ps.RETIRED
    ,ps.OFFICIAL
    ,ps.UNVERIFIED
    ,ps.SANCTIONED
    from professional_dimension pfad 

       
     
 /*    
    left join (
        select 
            case 
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
            ,count(distinct PROFESSIONAL_ID) as domain_size
        from DM.PROFESSIONAL_DIMENSION pf             
        where pf.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'            
        group by 1

        ) dm 
         
         on dm.domain = pfad.domain
 */        
     
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

    -- Flag values for exclusion where there are multiple entries with identical first, last, state, county, and middle (and at least one entry is missing phone or email)
  LEFT JOIN (SELECT FirstName
               ,LastName
               ,State
               ,County
               ,MiddleInitial
               ,MAX(PoojaTest1) Test1
               ,SUM(HasPhone1) Phone1CountCheck
               ,SUM(HasEmail) EmailCountCheck               
           FROM professional_dimension
           -- null values count as a match
           GROUP BY FirstName
                   ,LastName
                   ,State
                   ,County
                   ,MiddleInitial
           HAVING MAX(PoojaTest1) > 1
           ) pt1
        ON pt1.FirstName = pfad.FirstName
        AND pt1.LastName = pfad.LastName
        AND pt1.State = pfad.State
        AND pt1.County = pfad.County
        AND pt1.MiddleInitial = pfad.MiddleInitial
        AND (EmailCountCheck < Test1 OR Phone1CountCheck < Test1) -- (at least one value must be missing)
        
    -- Flag values for exclusion where there are multiple entries with identical first, last, state, county, and phone
    LEFT JOIN (SELECT FirstName
               ,LastName
               ,State
               ,County
               ,Phone1
               ,MAX(PoojaTest2) Test2
           FROM professional_dimension
           -- null values count as a match
           GROUP BY FirstName
                   ,LastName
                   ,State
                   ,County
                   ,Phone1
           HAVING MAX(PoojaTest2) > 1
           ) pt2
        ON pt2.FirstName = pfad.FirstName
        AND pt2.LastName = pfad.LastName
        AND pt2.State = pfad.State
        AND pt2.County = pfad.County
        AND pt2.Phone1 = pfad.Phone1

    -- Flag values for exclusion where there are multiple entries with identical first, last, state, county, and email
    LEFT JOIN (SELECT FirstName
               ,LastName
               ,State
               ,County
               ,Email
               ,MAX(PoojaTest3) Test3
           FROM professional_dimension
           --null values count as a match
           GROUP BY FirstName
                   ,LastName
                   ,State
                   ,County
                   ,Email
           HAVING MAX(PoojaTest3) > 1
           ) pt3
        ON pt3.FirstName = pfad.FirstName
        AND pt3.LastName = pfad.LastName
        AND pt3.State = pfad.State
        AND pt3.County = pfad.County
        AND pt3.Email = pfad.Email
        



/*WHERE ps.DECEASED = 'N' --  invalid status list
    AND ps.JUDGE = 'N' 
    AND ps.RETIRED = 'N' 
    AND ps.OFFICIAL= 'N' 
    AND ps.UNVERIFIED= 'N' 
    AND ps.SANCTIONED= 'N' */
    --AND HasPhone1 + HasEmail < 2 -- Must not have both fields filled out
    --pfad.is_claim = 0
    --AND HasPhone1 + HasEmail = 0
    --AND pfad.HasPhone1 + pfad.HasPhone2 + pfad.HasPhone3 >= 1
    --AND pfad.HasEmail = 0
    --AND pfad.NonNullPhone1Check + pfad.NullPhone1Check + pfad.NonNullEmailCheck + pfad.NullEmailCheck + pfad.DoubleNullCheck = 5 -- not flagged as a duplicate by any field
WHERE    (pt1.test1 IS NOT NULL
         OR pt2.test2 IS NOT NULL
         OR pt3.test3 IS NOT NULL)
ORDER BY 
    pfad.LastName
    ,pfad.FirstName
    ,pfad.MiddleInitial
    ,pfad.State
    ,pfad.County
    ,pfad.phone1
    ,pfad.email
    ,pfad.Professional_ID 


 /* Notes:
There are four table objects used in this query:
1. "pfad": lawyer dimension data and duplicate rankings - joins on professional id
2. "dm": only used to get a count of lawyer profiles in each domain - joins on domain name (get rid of this for now)
3. "ps": only used to get some kind of status info - joins on professional id (move to where clause to exclude all listed status types)
4. "toppa": only used to get practice area - joins on professional id 

Final output should only be *unclaimed* profiles with missing data (either email or phone1 or both)
Be sure to review/replace pfad subquery before running
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
	
 

