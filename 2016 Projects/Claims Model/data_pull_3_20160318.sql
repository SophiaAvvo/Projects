WITH 
select pf.PROFESSIONAL_ID
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
        --,pf.PROFESSIONAL_PRACTICE_INDICATOR as practice_ind
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
     ,pf.professional_claim_date
     ,pf.professional_claim_method_name
    ,CASE
      WHEN pf.professional_claim_date IS NULL
        THEN 'null'
      WHEN pf.professional_claim_date = ''
        THEN 'blank'
      ELSE 'populated'
    END Claim_date_test
    	,pa.PracticeArea1
FROM DM.PROFESSIONAL_DIMENSION pf    
WHERE pf.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'
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
    AND (pf.professional_claim_date >= '2014-06-01' OR pf.professional_claim_date IS NULL OR pf.professional_claim_date = '')



) prof_data

SELECT pfad.PROFESSIONAL_ID
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
	,pa.PracticeArea2
	,pa.PracticeArea3
	,pa.ParentPracticeArea1
	,pa.ParentPracticeArea2
	,pa.ParentPracticeArea3
	,case 
        when (SUBSTR(upper(pd.domain),length(pd.domain)-3) in ('.EDU','.GOV','.ORG', '.CO.US')) 
            then 1
            else 0
        end AS EmailDomainIssue
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
from  prof_data pf
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
on toppa.PROFESSIONAL_ID = pf.PROFESSIONAL_ID
  LEFT JOIN (SELECT 
    FROM 

-- exclusions
WHERE ps.DECEASED = 'N' --  invalid status list
    AND ps.JUDGE = 'N' 
    AND ps.RETIRED = 'N' 
    AND ps.OFFICIAL= 'N' 
    AND ps.UNVERIFIED= 'N' 
    AND ps.SANCTIONED= 'N'

    ORDER BY pf.professional_claim_date DESC
    LIMIT 100000;
