/* Updated August 8 to incorporate a much broader set of PAs, based mostly on Parent PA */

with tmp_reviews as	
(	
  	
select                                                                    	
  pfrv.professional_id                                     	
  , sum(pfrv.overall_rating)/COUNT(distinct pfrv.id) as review_rating      	
  , COUNT(distinct pfrv.id) as num_reviews	
from src.barrister_professional_review pfrv       	
                join DM.professional_dimension pf on pf.professional_id = pfrv.professional_id	
                join dm.date_dim dt on dt.actual_date = to_date(pfrv.created_at)	
                where pfrv.approval_status_id = 2          	
                                -- and pfrv.DEL_FLAG = 'N'           	
                                and pf.professional_delete_indicator = 'Not Deleted'	
                                and pf.professional_name = 'lawyer'	
                                and pf.industry_name = 'Legal'	
  group by 1                                         	
	
	
) , 	
	
tmp_answers as	
(	
select 	
    created_by as professional_id	
    , count(distinct question_id) as num_questionsanswered	
from src.content_answer 	
	where approval_status_id in (1,2)
    group by 1	
  	
) 	,
	
tmp_sanctioned as	
(	
  select professional_id	
         , sanctioned	
  , deceased	
  , judge	
  , retired	
  , official	
from src.hist_barrister_professional_status 	
)	
	
	
	
select	
pf.professional_id	
, pf.professional_email_address_name
, pf.professional_avvo_rating
, r.review_rating	
, r.num_reviews	
, pfsp.specialty_percent	
, sp.specialty_name   as PracticeArea	
, sp.parent_specialty_name as Parent_PracticeArea	
, professional_license_state_name_1	
, professional_license_state_name_2	
, professional_license_state_name_3	
, professional_county_name_1	
, professional_city_name_1	
, professional_state_name_1
, num_questionsanswered	
, sanctioned	
, deceased	
, judge	
, retired	
, official	
, case when specialty_name in (	
  'Immigration',	
  'Business',	
  'Family',
  'Estate Planning', -- added on 5/18
  'Real Estate' -- added on 5/18

  
  ) then 1 
  WHEN parent_specialty_name IN (
  'Family'
  ,'Immigration'
  ,'Business'
  ,'Estate Planning'
  ,'Real Estate'
  ) 
  THEN 1
  else 2 end as Breadth
, case when specialty_name in (	
  'Landlord & Tenant',
  'Bankruptcy & Debt',
  'Criminal Defense',
  'Employment & Labor',
  'Divorce & Separation' -- added on 5/26; moved on 06/30
 
  ) then 1 
    WHEN parent_specialty_name IN ( 
  'Family'
  ,'Immigration'
  ,'Business'
  ,'Estate Planning'
  ,'Real Estate'
  ,'Bankruptcy & Debt'
  ,'Criminal Defense'
  ,'Employment & Labor'
  ) 
  THEN 1
  else 2 end as AdvisorOnly
  
, case when ( cast(pf.professional_avvo_rating as int) >= 7 and cast(pf.professional_avvo_rating as int)>= 4 ) then 1 else 2 end as AdvisorQualified

-- , ROW_NUMBER() OVER(partition by pfsp.professional_id order by FlagInclusion, pfsp.specialty_percent desc ) as BestRecord  	
, ROW_NUMBER() OVER(partition by pfsp.professional_id order by pfsp.specialty_percent desc ) as BestRecord	

, case when (concat(professional_state_name_1,"_",professional_county_name_1)) in 
(
             'ARIZONA_MARICOPA',
'ARIZONA_PINAL',
'CALIFORNIA_LOS ANGELES',
'CALIFORNIA_ORANGE',
'CALIFORNIA_RIVERSIDE',
'CALIFORNIA_SAN BERNARDINO',
'CALIFORNIA_VENTURA',
'CALIFORNIA_PLACER',
'CALIFORNIA_EL DORADO',
'CALIFORNIA_SAN DIEGO',
'CALIFORNIA_SACRAMENTO',
'CALIFORNIA_YOLO',
'CALIFORNIA_ALAMEDA',
'CALIFORNIA_CONTRA COSTA',
'CALIFORNIA_VENTURA',
'CALIFORNIA_SAN BENITO',
'CALIFORNIA_SANTA CLARA',
'CALIFORNIA_SAN FRANCISCO',
'CALIFORNIA_SAN MATEO',
'COLORADO_ADAMS',
'COLORADO_ARAPAHOE',
'COLORADO_BROOMFIELD',
'COLORADO_CLEAR CREEK',
'COLORADO_DENVER',
'COLORADO_DOUGLAS',
'COLORADO_ELBERT',
'COLORADO_GILPIN',
'COLORADO_JEFFERSON',
'COLORADO_PARK',
'CONNECTICUT_HARTFORD',
'CONNECTICUT_MIDDLESEX',
'CONNECTICUT_TOLLAND',
'FLORIDA_MIAMI-DADE',
'FLORIDA_BROWARD',
'FLORIDA_PALM BEACH',
'FLORIDA_LAKE',
'FLORIDA_ORANGE',
'FLORIDA_OSCEOLA',
'FLORIDA_SEMINOLE',
'FLORIDA_HILLSBOROUGH',
'FLORIDA_PINELLAS',
'FLORIDA_PASCO',
'FLORIDA_HERNANDO',
'GEORGIA_DEKALB',
'GEORGIA_GWINNETT',
'GEORGIA_COBB',
'GEORGIA_FULTON',
'GEORGIA_CLAYTON',
'GEORGIA_COWETA',
'GEORGIA_DOUGLAS',
'GEORGIA_FAYETTE',
'GEORGIA_HENRY',
'ILLINOIS_DUPAGE',
'ILLINOIS_COOK',
'ILLINOIS_KANE',
'ILLINOIS_KENDALL',
'ILLINOIS_MCHENRY',
'ILLINOIS_WILL',
'ILLINOIS_MADISON',
'ILLINOIS_ST. CLAIR',
'ILLINOIS_CLINTON',
'ILLINOIS_MONROE',
'ILLINOIS_JERSEY',
'MARYLAND_ANNE ARUNDEL',
'MARYLAND_BALTIMORE CITY',
'MARYLAND_BALTIMORE',
'MARYLAND_CARROLL',
'MARYLAND_HARFORD',
'MARYLAND_HOWARD',
'MARYLAND_MONTGOMERY',
'MARYLAND_CHARLES',
"MARYLAND_PRINCE GEORGE'S",
'MASSACHUSETTS_NORFOLK',
'MASSACHUSETTS_PLYMOUTH',
'MASSACHUSETTS_SUFFOLK',
'MASSACHUSETTS_MIDDLESEX',
'MASSACHUSETTS_ESSEX',
'MICHIGAN_LAPEER',
'MICHIGAN_LIVINGSTON',
'MICHIGAN_MACOMB',
'MICHIGAN_OAKLAND',
'MICHIGAN_ST. CLAIR',
'MICHIGAN_WAYNE',
'MINNESOTA_ANOKA',
'MINNESOTA_CARVER',
'MINNESOTA_DAKOTA',
'MINNESOTA_HENNEPIN',
'MINNESOTA_RAMSEY',
'MINNESOTA_WASHINGTON',
'MINNESOTA_SCOTT',
'MISSOURI_JACKSON',
'MISSOURI_JOHNSON',
'MISSOURI_CLAY',
'MISSOURI_WYANDOTTE',
'MISSOURI_CASS',
'MISSOURI_PLATTE',
'MISSOURI_LEAVENWORTH',
'MISSOURI_MIAMI',
'MISSOURI_LAFAYETTE',
'MISSOURI_FRANKLIN',
'MISSOURI_RAY',
'MISSOURI_CLINTON',
'MISSOURI_BATES',
'MISSOURI_LINN',
'MISSOURI_CALDWELL',
'MISSOURI_ST. LOUIS CITY',
'MISSOURI_ST. LOUIS',
'MISSOURI_ST. CHARLES',
'MISSOURI_JEFFERSON',
'MISSOURI_FRANKLIN',
'MISSOURI_LINCOLN',
'MISSOURI_WARREN',
'NEVADA_CLARK',
'NEW HAMPSHIRE_ROCKINGHAM',
'NEW HAMPSHIRE_STRAFFORD',
'NEW HAMPSHIRE_HILLSBOROUGH',
'NEW JERSEY_HUDSON',
'NEW JERSEY_MIDDLESEX',
'NEW JERSEY_MONMOUTH',
'NEW JERSEY_OCEAN',
'NEW JERSEY_PASSAIC',
'NEW JERSEY_BERGEN',
'NEW YORK_KINGS',
'NEW YORK_NEW YORK',
'NEW YORK_ORANGE',
'NEW YORK_QUEENS',
'NEW YORK_ROCKLAND',
'NEW YORK_RICHMOND',
'NEW YORK_SULLIVAN',
'NEW YORK_WESTCHESTER',
'NEW YORK_BRONX',
'NORTH CAROLINA_MECKLENBURG',
'NORTH CAROLINA_CATHAM',
'NORTH CAROLINA_DURHAM',
'NORTH CAROLINA_FRANKLIN',
'NORTH CAROLINA_JOHNSTON',
'NORTH CAROLINA_NASH',
'NORTH CAROLINA_ORANGE',
'NORTH CAROLINA_PERSON',
'NORTH CAROLINA_WAKE',
'OHIO_CUYAHOGA',
'OHIO_GEAUGA',
'OHIO_LAKE',
'OHIO_LORAIN',
'OHIO_MEDINA',
'OREGON_MULTNOMAH',
'OREGON_WASHINGTON',
'OREGON_CLACKAMAS',
'OREGON_COLUMBIA',
'OREGON_YAMHILL',
'PENNSYLVANIA_CHESTER',
'PENNSYLVANIA_BUCKS',
'PENNSYLVANIA_DELAWARE',
'PENNSYLVANIA_MONTGOMERY',
'PENNSYLVANIA_PHILADELPHIA',
'SOUTH CAROLINA_DARLINGTON',
'SOUTH CAROLINA_FLORENCE',
'TENNESSEE_CANNON',
'TENNESSEE_CHEATHAM',
'TENNESSEE_DAVIDSON',
'TENNESSEE_DICKSON',
'TENNESSEE_HICKMAN',
'TENNESSEE_MACON',
'TENNESSEE_MAURY',
'TENNESSEE_ROBERTSON',
'TENNESSEE_RUTHERFORD',
'TENNESSEE_SMITH',
'TENNESSEE_SUMNER',
'TENNESSEE_TROUSDALE',
'TENNESSEE_WILLIAMSON',
'TENNESSEE_WILSON',
'TEXAS_BASTROP',
'TEXAS_COLLIN',
'TEXAS_DALLAS',
'TEXAS_DENTON',
'TEXAS_ELLIS',
'TEXAS_HUNT',
'TEXAS_CALDWELL',
'TEXAS_KAUFMAN',
'TEXAS_HAYS',
'TEXAS_ROCKWALL',
'TEXAS_TRAVIS',
'TEXAS_WILLIAMSON',
'TEXAS_FORT BEND',
'TEXAS_HARRIS',
'TEXAS_LIBERTY',
'TEXAS_MONTGOMERY',
'TEXAS_WALLER',
'TEXAS_COMAL',
'TEXAS_GUADALUPE',
'TEXAS_WILSON',
'TEXAS_CHAMBERS',
'TEXAS_BEXAR',
'UTAH_SALT LAKE',
'UTAH_TOOELE',
'VIRGINIA_ARLINGTON',
'VIRGINIA_ALEXANDRIA CITY',
'VIRGINIA_FAIRFAX',
'WASHINGTON_KING',
'WASHINGTON_PIERCE',
'WASHINGTON_SNOHOMISH',
'WASHINGTON_CLARK',
'WASHINGTON_SKAMANIA',
'WISCONSIN_DODGE',
'WISCONSIN_JEFFERSON',
'WISCONSIN_MILWAUKEE',
'WISCONSIN_OZAUKEE',
'WISCONSIN_RACINE',
'WISCONSIN_WALWORTH',
'WISCONSIN_WASHINGTON',
'WISCONSIN_WAUKESHA')
then 'Yes' else 'No' end as TargetMetro

from DM.professional_dimension  pf  	
join DM.professional_specialty_bridge pfsp on pfsp.professional_id = pf.professional_id 	
join DM.specialty_dimension sp on sp.specialty_id = pfsp.specialty_id  	
left join tmp_reviews r on r.professional_id = pf.professional_id	
left join tmp_answers a on a.professional_id = pf.professional_id	
left join tmp_sanctioned s on s.professional_id = pf.professional_id	
where pf.professional_delete_indicator = 'Not Deleted'            	
	and pf.professional_practice_indicator = 'Practicing'             
	and pf.professional_name = 'lawyer'               
	and pf.industry_name = 'Legal'              
	-- and pf.professional_country_name_1 = 'UNITED STATES'  
	and pfsp.delete_flag = 'N' 
	and s.judge = 'N'
    and s.deceased = 'N'
    and
	(
	(professional_license_state_name_1 in ('Arizona')
	  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Arizona')
	  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Arizona'))
	  
	 OR
	 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('California')
	  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('California')
	  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('California'))
	
	
	OR 
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Colorado')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Colorado')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Colorado'))	
      	
    OR 	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Connecticut')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Connecticut')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Connecticut'))	
  	
  OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Florida')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Florida')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Florida'))	
 	
 OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Georgia')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Georgia')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Georgia'))	
 	
  OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Illinois')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Illinois')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Illinois') )	
  	
    OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Massachusetts')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Massachusetts')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Massachusetts') )	
   	
       OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Maryland')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Maryland')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Maryland') )	
  	
       OR	
 ((PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Michigan')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Michigan')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Michigan') )	
   )	
       OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Minnesota')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Minnesota')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Minnesota') )	
	
             OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Missouri')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Missouri')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Missouri') )	
      	
         OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('North Carolina')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('North Carolina')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('North Carolina') )	
	
      OR	
       (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Nevada')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Nevada')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Nevada') )	
      	
          OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('New Hampshire')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('New Hampshire')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('New Hampshire') )	
  	
          OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('New York')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('New York')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('New York') )	
 	
                OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('New Jersey')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('New Jersey')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('New Jersey') )	
          OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Ohio')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Ohio')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Ohio') )	
 	
          OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Oregon')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Oregon')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Oregon') )	
 	
          OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Pennsylvania')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Pennsylvania')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Pennsylvania') )	
      	
                OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('South Carolina')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('South Carolina')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('South Carolina') )	
 	
   OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Tennessee')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Tennessee')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Tennessee') )	
      	
   OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Texas')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Texas')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Texas') )	
      	
         OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Utah')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Utah')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Utah') )	
 	
          OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Virginia')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Virginia')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Virginia') )	
 	
          OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Washington')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Washington')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Washington') )	
      	
         OR	
 (PROFESSIONAL_LICENSE_STATE_NAME_1 in ('Wisconsin')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_2 in ('Wisconsin')	
  OR PROFESSIONAL_LICENSE_STATE_NAME_3 in ('Wisconsin') )	
 	
	)
	and pfsp.specialty_percent  >= 10
	and (parent_specialty_name  in (
	
'Immigration',	
'Business',	
'Family',	
'Estate Planning', -- added on 5/18
'Real Estate', -- added on 5/18
'Bankruptcy & Debt',
'Criminal Defense',
'Employment & Labor'

)	
OR specialty_name IN ('Wrongful Death', 'Nursing Home Abuse and Neglect')
)

and professional_claim_date is not null	
order by professional_id,  pfsp.specialty_percent desc