select pfad.PROFESSIONAL_ID
    , pfad.claim_year_month
               , pfad.claim_date
               , dm.domain_size
               , pfad.is_claim
               , pfad.domain
               , pfad.emaildomain
               , pfad.professional_avvo_rating
               , pfad.PROFESSIONAL_COUNTY_NAME_1
               , pfad.PROFESSIONAL_STATE_NAME_1
    , amd.ad_market_id
               , amd.ad_region_id
               , amd.ad_market_region_name
               , amd.ad_market_state_name
               , amd.ad_market_county_name
               , amd.ad_market_specialty_name
               , spcl.SPECIALTY_PERCENT
               , spcl.SPECIALTY_NAME
               , spcl.PARENT_SPECIALTY_NAME
               , case when SPECIALTY_NAME  is null then 'N' else 'Y' end as has_specialty
               , case when SPECIALTY_NAME  in ('Criminal Defense','DUI & DWI','Divorce & Separation','Personal Injury','Family','Immigration',
                                                                                                                                                                                    'Car Accidents','Bankruptcy & Debt','Chapter 11 Bankruptcy','Chapter 13 Bankruptcy','Chapter 7 Bankruptcy',
                                                                                                                                                                                                                                                'Workers Compensation','Child Custody','Employment & Labor','Real Estate','Estate Planning','Business',
                                                                                                                                                                                                                                                'Lawsuits & Disputes','Motorcycle Accident')
                              then 'Y' else 'N' end as PriorityPA
               , LawyerName
               , PROFESSIONAL_PHONE_NUMBER_1
               , PROFESSIONAL_PHONE_NUMBER_2
               , PROFESSIONAL_PHONE_NUMBER_3
               , PROFESSIONAL_EMAIL_ADDRESS_NAME
               , ps.deceased 
               , ps.JUDGE
               , ps.RETIRED
               , ps.official
               , ps.unverified
               , ps.sanctioned
               , pfad.professional_delete_indicator
               , pfad.professional_practice_indicator
               , pfad.professional_name
               , pfad.industry_name
               , pfad.professional_country_name_1
               , case when 
                            -- PROFESSIONAL_PRACTICE_INDICATOR != 'Practicing' or 
                                                                                                         -- PROFESSIONAL_NAME != 'lawyer' or 
                                                                                                         -- INDUSTRY_NAME != 'Legal' or
                                                                                                         DECEASED = 'Y' or 
                                                                                                         JUDGE = 'Y' or
                                                                                                         RETIRED = 'Y' or
                                                                                                         OFFICIAL= 'Y' or
                                                                                                         UNVERIFIED= 'Y' or
                                                                                                         SANCTIONED= 'Y'
                              then 'Exclude Profile' else 'Valid Profile' end as Exclusions
               , first_purch_dt
               , last_purch_dt 
               , case when extract(last_purch_dt,'year') = extract(now(),'year') and extract(last_purch_dt,'month') = extract(now(),'month')  then 'Current Advertiser'
                                                            when last_purch_dt is not null then 'Past Advertiser'
        else 'Never Advertised' end as Client_Status
               , toppa.PracticeArea1
               , toppa.PracticeArea2
               , toppa.PracticeArea3
               , toppa.ParentPracticeArea1
               , toppa.ParentPracticeArea2
               , toppa.ParentPracticeArea3
               , case when PROFESSIONAL_EMAIL_ADDRESS_NAME = ' ' or PROFESSIONAL_EMAIL_ADDRESS_NAME = 'Null' or PROFESSIONAL_EMAIL_ADDRESS_NAME is null then 'Email Missing'
             else 'Email Caputured' end as Email_Status
               ,case when  (LENGTH(PROFESSIONAL_PHONE_NUMBER_1) < 10 ) 
         or (PROFESSIONAL_PHONE_NUMBER_1 is null and PROFESSIONAL_PHONE_NUMBER_2 is null and PROFESSIONAL_PHONE_NUMBER_3 is null)
         then 'Bad Phone' else 'Ok Phone' end as Phone_Status
              ,case when (SUBSTR(upper(pfad.domain),length(pfad.domain)-3) in ('.EDU','.GOV','.ORG')) then 'Exclude' else 'Include' end as DomainExclusion
    
               from
              (
                              select pf.PROFESSIONAL_ID
    , case when pf.PROFESSIONAL_CLAIM_DATE is null then 'Not-Claimed' else 'Claimed' end as is_claim
    , dd.year_month as claim_year_month
               , to_date(pf.professional_claim_date) as claim_date
               , pf.PROFESSIONAL_AVVO_RATING 
    , pf.PROFESSIONAL_COUNTY_NAME_1
               , pf.PROFESSIONAL_STATE_NAME_1
    , pf.professional_postal_code_1
    , concat(PROFESSIONAL_FIRST_NAME,' ',PROFESSIONAL_LAST_NAME) as LawyerName
               , PROFESSIONAL_PHONE_NUMBER_1
    , PROFESSIONAL_PHONE_NUMBER_2
    , PROFESSIONAL_PHONE_NUMBER_3
    , PROFESSIONAL_EMAIL_ADDRESS_NAME
    , pf.PROFESSIONAL_DELETE_INDICATOR 
    , pf.PROFESSIONAL_PRACTICE_INDICATOR 
    , pf.PROFESSIONAL_NAME
    , pf.INDUSTRY_NAME
    , pf.PROFESSIONAL_COUNTRY_NAME_1 
    ,substr(pf.professional_email_address_name, instr(professional_email_address_name,'@')+1) as emaildomain
               , case when (parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST') is null and instr(pf.PROFESSIONAL_WEBSITE_URL,'http:')=1 ) then pf.PROFESSIONAL_WEBSITE_URL 
                              when (parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST') is null and instr(pf.PROFESSIONAL_WEBSITE_URL,'http:')=0 ) then substr(pf.PROFESSIONAL_WEBSITE_URL,instr(pf.PROFESSIONAL_WEBSITE_URL,'www.')+1)
               when (parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST') is not null and instr(pf.PROFESSIONAL_WEBSITE_URL,'www'  )=0 ) then parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST')
        else substr(parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST'),instr(pf.PROFESSIONAL_WEBSITE_URL,'www.')-3) end as domain
from  DM.PROFESSIONAL_DIMENSION pf
full join dm.date_dim dd on dd.actual_date=to_date(pf.professional_claim_date)
-- exclusions
  where pf.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'
    and pf.PROFESSIONAL_PRACTICE_INDICATOR = 'Practicing'
    and pf.PROFESSIONAL_NAME = 'lawyer'
    and pf.INDUSTRY_NAME = 'Legal'
  --  and pf.PROFESSIONAL_COUNTRY_NAME_1 = 'UNITED STATES'
) pfad

     
left join 
( 
select pfsp.professional_id     
               , pfsp.SPECIALTY_PERCENT
               , sp.SPECIALTY_NAME  
               , sp.PARENT_SPECIALTY_NAME
from DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp      
               join  DM.SPECIALTY_DIMENSION sp on sp.SPECIALTY_ID = pfsp.SPECIALTY_ID       
  where pfsp.DELETE_FLAG = 'N'    
) spcl on pfad.professional_id = spcl.professional_id
     
left join 
(
select             
    
     case when (parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST') is null and instr(pf.PROFESSIONAL_WEBSITE_URL,'http:')=1 ) then pf.PROFESSIONAL_WEBSITE_URL 
          when (parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST') is null and instr(pf.PROFESSIONAL_WEBSITE_URL,'http:')=0 ) then substr(pf.PROFESSIONAL_WEBSITE_URL,instr(pf.PROFESSIONAL_WEBSITE_URL,'www.')+1)
          when (parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST') is not null and instr(pf.PROFESSIONAL_WEBSITE_URL,'www'  )=0 ) then parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST')
        else substr(parse_url(pf.PROFESSIONAL_WEBSITE_URL,'HOST'),instr(pf.PROFESSIONAL_WEBSITE_URL,'www.')-3) end as domain

    , count(distinct PROFESSIONAL_ID) as domain_size
from  DM.PROFESSIONAL_DIMENSION pf             
where pf.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'            
  and pf.PROFESSIONAL_PRACTICE_INDICATOR = 'Practicing'             
  and pf.PROFESSIONAL_NAME = 'lawyer'
  and pf.INDUSTRY_NAME = 'Legal'              
-- and pf.PROFESSIONAL_COUNTRY_NAME_1 = 'UNITED STATES'
group by 1

) dm on dm.domain = pfad.domain
     left join SRC.barrister_professional_status ps on ps.professional_id = pfad.PROFESSIONAL_ID
--  where deceased = 'N'
--       AND JUDGE = 'N'
--       AND RETIRED = 'N'
--       AND OFFICIAL= 'N'
--       AND UNVERIFIED= 'N'
--       AND SANCTIONED= 'N'
--  order by professional_id

left join 
(
SELECT
professional_id
,min(OLAF.order_line_begin_date) as first_purch_dt
,max(OLAF.order_line_begin_date) as last_purch_dt
FROM DM.order_line_accumulation_fact  olaf
JOIN DM.product_line_dimension pd on pd.product_line_id = olaf.product_line_id
              --  join  DM.professional_dimension pf on pf.professional_id = olaf.professional_id
              WHERE pd.product_line_id in (2,7) and professional_id >0
group by 1
) purch on purch.professional_id = pfad.PROFESSIONAL_ID


left join 
( select x.PROFESSIONAL_ID    

        , MIN(case when x.rt = 1 then x.SPECIALTY_NAME else NULL end) as PracticeArea1       
        , MIN(case when x.rt = 2 then x.SPECIALTY_NAME else NULL end) as PracticeArea2  
     , MIN(case when x.rt = 3 then x.SPECIALTY_NAME else NULL end) as PracticeArea3 
     , MIN(case when x.rt = 1 then x.PARENT_SPECIALTY_NAME else NULL end) as ParentPracticeArea1       
        , MIN(case when x.rt = 2 then x.PARENT_SPECIALTY_NAME else NULL end) as ParentPracticeArea2  
     , MIN(case when x.rt = 3 then x.PARENT_SPECIALTY_NAME else NULL end) as ParentPracticeArea3 
     
    from           
    (          
        select pfsp.PROFESSIONAL_ID     
            , pfsp.SPECIALTY_PERCENT
            , sp.SPECIALTY_NAME  
            , sp.PARENT_SPECIALTY_NAME
            , ROW_NUMBER() OVER(partition by pfsp.PROFESSIONAL_ID order by pfsp.SPECIALTY_PERCENT, sp.SPECIALTY_NAME desc ) rt   
        from DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp      
        join  DM.SPECIALTY_DIMENSION sp on sp.SPECIALTY_ID = pfsp.SPECIALTY_ID       
        where pfsp.DELETE_FLAG = 'N'      
    ) x        
    group by 1
) toppa on toppa.PROFESSIONAL_ID = pfad.PROFESSIONAL_ID

left join 
(
               select * from dm.geography_dimension
               where geo_postal_code!='Not Applicable'
) gd on substr(pfad.professional_postal_code_1,1,5)=substr(gd.geo_postal_code,1,5)
left join dm.ad_market_dimension amd on amd.ad_region_id=gd.sales_region_id and amd.ad_market_specialty_name= spcl.specialty_name
