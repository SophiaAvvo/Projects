						
						
						
						
						
WITH deduped_pfad AS						
(						
SELECT pfad.PROFESSIONAL_ID						
		,pfad.claim_date				
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
         ,REGEXP_REPLACE(toppa.PracticeArea1, ',', '') PracticeArea1						
         ,REGEXP_REPLACE(toppa.PracticeArea2, ',', '') PracticeArea2						
         ,REGEXP_REPLACE(toppa.PracticeArea2, ',', '') PracticeArea3						
         ,REGEXP_REPLACE(toppa.ParentPracticeArea1, ',', '') ParentPracticeArea1						
         ,REGEXP_REPLACE(toppa.ParentPracticeArea2, ',', '') ParentPracticeArea2						
         ,REGEXP_REPLACE(toppa.ParentPracticeArea3, ',', '') ParentPracticeArea3 						
		 ,toppa.SpecialtyCount AS PracticeAreaCount				
		,toppa.PA1Percent				
		,toppa.PA2Percent				
		,toppa.PA3Percent				
		/*		,CASE 		
					WHEN ps.DECEASED = 'Y'	
						THEN 1
					ELSE 0	
				END IsDeceased		
				,CASE 		
					WHEN ps.RETIRED = 'Y'	
						THEN 1
					ELSE 0	
				END IsRetired		
				,CASE 		
					WHEN ps.JUDGE = 'Y'	
						THEN 1
					ELSE 0	
				END IsJudge		
				,CASE 		
					WHEN ps.OFFICIAL = 'Y'	
						THEN 1
					ELSE 0	
				END IsOfficial		
				,CASE 		
					WHEN ps.UNVERIFIED = 'Y'	
						THEN 1
					ELSE 0	
				END IsUnverified */		
        ,CASE						
            WHEN ps.SANCTIONED = 'Y'						
                THEN 1						
            ELSE 0						
         END IsSanctioned
		,gender		 
  FROM (SELECT pd.*						
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
				,gender
        FROM (SELECT pf.PROFESSIONAL_ID						
					,pf.professional_claim_date AS claim_date	
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
					,pf.professional_gender_name AS gender
					,
              FROM DM.PROFESSIONAL_DIMENSION pf						
              WHERE pf.PROFESSIONAL_DELETE_INDICATOR = 'Not Deleted'						
			  AND pf.PROFESSIONAL_PRACTICE_INDICATOR = 'Practicing'			
			  AND pf.PROFESSIONAL_CLAIM_DATE IS NOT NULL			
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
					  ,MAX(CASE WHEN x.rt = 1 THEN x.specialty_percent ELSE NULL END) PA1Percent	
					  ,MAX(CASE WHEN x.rt = 2 THEN x.specialty_percent ELSE NULL END) PA2Percent	
					  ,MAX(CASE WHEN x.rt = 3 THEN x.specialty_percent ELSE NULL END) PA3Percent	
               FROM (SELECT pfsp.PROFESSIONAL_ID						
                            ,pfsp.SPECIALTY_PERCENT						
                            ,sp.SPECIALTY_NAME						
                            ,sp.PARENT_SPECIALTY_NAME						
                            ,ROW_NUMBER() OVER (PARTITION BY pfsp.PROFESSIONAL_ID ORDER BY pfsp.SPECIALTY_PERCENT DESC) rt						
                     FROM DM.PROFESSIONAL_SPECIALTY_BRIDGE pfsp						
                       JOIN DM.SPECIALTY_DIMENSION sp ON sp.SPECIALTY_ID = pfsp.SPECIALTY_ID						
                     WHERE pfsp.DELETE_FLAG = 'N') x						
               GROUP BY 1) toppa ON toppa.PROFESSIONAL_ID = pfad.PROFESSIONAL_ID						
  						
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
  WHERE pr.approval_status_id = 2						
  GROUP BY professional_Id						
)						
						
,						
						
endorsements AS (						
						
SELECT eds.endorsee_id AS professional_id						
                   ,COUNT(DISTINCT eds.id) AS PeerEndCount						
                   FROM src.barrister_professional_endorsement eds						
                   GROUP BY 1						
                   						
)						
						
, message_prep AS (SELECT msg.professional_id						
  ,SUM(CASE WHEN prev_event_date IS NULL THEN 1						
            WHEN DATEDIFF(event_date, prev_event_date) >= 14 THEN 1						
            ELSE 0						
       END) AS item_count						
FROM						
  (						
  SELECT contact_type, event_date, FROM_UNIXTIME(gmt_timestamp) AS gmt_time, professional_id, user_id, persistent_session_id						
    ,LAG(event_date) OVER (PARTITION BY contact_type, professional_id, user_id						
                                  ORDER BY gmt_timestamp) AS prev_event_date						
  FROM src.contact_impression ci						
  JOIN dm.date_dim dd						
	ON dd.actual_date = ci.event_date					
	AND dd.year_month = 201611					
  WHERE contact_type = 'message'						
  ) msg						
GROUP BY 1						
						
UNION ALL						
						
SELECT ci.professional_id						
,COUNT(*) AS item_count						
FROM src.contact_impression ci						
JOIN dm.date_dim dd						
	ON dd.actual_date = ci.event_date					
	AND dd.year_month = 201611					
WHERE ci.contact_type = 'email'						
and ci.user_id is not null						
GROUP BY 1						
)						
						
,						
						
cnt_email as						
(						
select professional_id						
,SUM(item_count) as cnt_emailcontacts						
from message_prep ci						
group by 1						
)						
						
						
,cnt_website as 						
(						
select						
ci.professional_id						
, count(*) as cnt_webcontacts						
from src.contact_impression ci						
join dm.date_dim dt 						
	on ci.event_date = dt.actual_date					
	AND ci.user_id <> '-1'					
WHERE dt.year_month = 201611						
AND ci.contact_type = 'website'						
group by 1						
						
)						
						
,cnt_phone AS (						
select ci.professional_id						
, count(*) as cnt_phone						
from src.contact_impression ci						
join dm.date_dim dt 						
	on ci.event_date = dt.actual_date					
WHERE dt.year_month = 201611						
AND ci.contact_type = 'phone'						
group by 1						
)						
						
,ads AS(						
SELECT professional_id						
,MAX(CASE						
     WHEN product_line_id IN (2,7)						
     THEN olaf.order_line_begin_date						
     ELSE NULL						
     END) Is_Advertiser						
,MAX(CASE						
     WHEN product_line_id IN (11, 12, 15)						
     THEN olaf.order_line_begin_date						
     ELSE NULL						
     END) AS Is_Ignite_Or_Website						
,MAX(CASE						
     WHEN product_line_id = 4						
     THEN olaf.order_line_begin_date						
     ELSE NULL						
     END) Is_Pro						
,SUM(CASE						
     WHEN product_line_id IN (2,4,7,11,12,15)						
     THEN olaf.order_line_net_price_amount_usd						
     ELSE 0						
     END) revenue_for_listed_products						
FROM dm.order_line_accumulation_fact olaf						
WHERE order_line_begin_date >= '2016-12-01'						
GROUP BY 1						
)		

,first_current_ads AS (
SELECT ld.professional_id
,ld.first_ad_run_date
,ld.has_ads AS is_current_advertiser
FROM lawyer_cube_data_by_day ld
WHERE as_of_date = (SELECT MAX(as_of_date) FROM dm.lawyer_cube_data_by_day)
)				
						
,acv AS (						
SELECT professional_id						
,SUM(adjusted_attribution_value) AS total_acv						
,SUM(phone_attributed_value) AS phone_attributed_value						
,SUM(website_attributed_value) AS website_attributed_value						
,SUM(email_attributed_value) AS email_msg_attributed_value						
FROM dm.webanalytics_ad_attribution_v0 wa						
JOIN dm.date_dim dd						
ON dd.actual_date = wa.attribution_date						
AND dd.year_month = 201611						
GROUP BY 1)						
						
,company AS (SELECT c.professional_id						
,c.company_name						
,c.start_date						
,c.position_name						
,c.title_name						
/*,CASE						
WHEN c.company_size_id = 1						
THEN 'Unknown'						
WHEN c.company_size_id = 2						
THEN '1-10'						
WHEN c.company_size_id = 3						
THEN '11-50'						
WHEN c.company_size_id = 4						
THEN '51-100'						
WHEN c.company_size_id = 5						
THEN '101-500'						
WHEN c.company_size_id = 6						
THEN '501-1000'						
WHEN c.company_size_id = 7						
THEN '1001-5000'						
WHEN c.company_size_id = 8						
THEN '5001-10000'						
WHEN c.company_size_id = 9						
THEN '10001+'						
ELSE CAST(c.company_size_id AS VARCHAR) -- this is always "Unknown"						
END Company_Size */						
,ROW_NUMBER() OVER(PARTITION BY c.professional_id ORDER BY c.start_date) Num						
FROM src.barrister_professional_company c						
WHERE c.end_date IS NULL 						
						
)						
						
,company2 AS (						
						
SELECT c.professional_id						
,c.company_name AS company_name_1						
,c.start_date AS start_date_1						
,c.position_name AS position_name_1						
,c.title_name AS title_name_1						
--,c.company_size AS company_size_1						
,c2.company_name AS company_name_2						
,c2.start_date AS start_date_2						
,c2.position_name AS position_name_2						
,c2.title_name AS title_name_2						
--,c2.company_size AS company_size_2						
,c3.company_name AS company_name_3						
,c3.start_date AS start_date_3						
,c3.position_name AS position_name_3						
,c3.title_name AS title_name_3						
--,c3.company_size AS company_size_3						
FROM company c						
LEFT JOIN company c2						
ON c2.professional_id = c.professional_id						
AND c2.Num = 2						
LEFT JOIN company c3						
ON c3.professional_id = c.professional_id						
AND c3.Num = 2						
WHERE c.Num = 1						
						
)					

, churned_advertisers AS (
SELECT professional_id
  ,MIN(year_month_begin_date) AS first_cancellation_month
FROM tmp_data_dm.sr_prr_sub_bills
WHERE has_ads_during_month = 'Y'
AND has_ads_eom = 'N'
)

,
SELECT professional_id
,MAX(order_line_begin_date) AS most_recent_ad_date	
						
						
SELECT gt.*						
,ld.LicenseCount						
,ld.SanctionCount						
,ld.FirstLicenseDate						
,DATEDIFF(now(), ld.FirstLicenseDate)/365.25 YearsSinceFirstLicensed						
,r.ReviewCount						
,r.RecommendedCount AS ClientReccomendedCount						
,r.PercentRecommended AS ClientPctRecommended						
,r.AvgClientRating						
,eds.PeerEndCount						
,s.school_id						
,s.graduation_date						
,cw.cnt_webcontacts AS previous_month_website_visits						
,cp.cnt_phone AS previous_month_phone_calls						
,ce.cnt_emailcontacts AS previous_month_emails_or_messages						
/*,CASE						
	WHEN ad.Is_Advertiser IS NOT NULL					
		THEN 1				
	ELSE 0					
END Is_Advertiser						
,CASE						
	WHEN ad.Is_Ignite_Or_Website IS NOT NULL					
		THEN 1				
	ELSE 0					
END AS Is_Ignite_Or_Website						
,CASE						
	WHEN ad.Is_Pro IS NOT NULL					
		THEN 1				
	ELSE 0					
END AS Is_Pro */				
,ad.revenue_for_listed_Products						
,acv.total_acv						
,acv.phone_attributed_value						
,acv.website_attributed_value						
,acv.email_msg_attributed_value						
,c2.company_name_1						
,c2.start_date_1						
,c2.position_name_1						
,c2.title_name_1						
--,c2.company_size_1						
,c2.company_name_2						
,c2.start_date_2						
,c2.position_name_2						
,c2.title_name_2						
--,c2.company_size_2						
,c2.company_name_3						
,c2.start_date_3						
,c2.position_name_3						
,c2.title_name_3			
,fca.first_ad_run_date
,fca.is_current_advertiser			
--,c2.company_size_3						
FROM deduped_pfad gt						
	LEFT JOIN license_discipline ld					
		ON ld.professional_id = gt.professional_id				
	LEFT JOIN reviews r					
		ON r.professional_id = gt.professional_id				
	LEFT JOIN endorsements eds					
		ON eds.professional_id = gt.professional_id				
	LEFT JOIN school2 s					
		ON s.professional_id = gt.professional_id				
		AND s.Selector = 1				
	/*LEFT JOIN ads ad					
		ON ad.professional_id = gt.professional_id	*/			
	LEFT JOIN acv					
		ON acv.professional_id = gt.professional_id				
	LEFT JOIN cnt_phone cp					
		ON cp.professional_id = gt.professional_id				
	LEFT JOIN cnt_website cw					
		ON cw.professional_id = gt.professional_id				
	LEFT JOIN cnt_email ce					
		ON ce.professional_id = gt.professional_id				
	LEFT JOIN company2 c2					
		ON c2.professional_id = gt.professional_id
	LEFT JOIN first_current_ads fca
		ON fca.professional_id = gt.professional_id
	
