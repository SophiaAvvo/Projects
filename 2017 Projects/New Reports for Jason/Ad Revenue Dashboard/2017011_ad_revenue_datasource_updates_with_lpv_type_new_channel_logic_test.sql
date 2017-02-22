with chan_def as -- note: internal weblogs first touch
(select distinct lpv_source
 , lpv_medium
 , lpv_campaign
 , lpv_content
 ,lpv_page_type
,case  
when lpv_content = 'utm_content=sgt' or lpv_medium = 'utm_medium=sem%2F%3Futm_source%3Dgoogle%2F%3Futm_content%3Dsgt' or lpv_campaign = 'utm_campaign=sgt'
                    then 'GDN Network'
when lpv_source = '' 
and lpv_medium = '' 
and lpv_campaign = '' 
and lpv_content = '' 
AND lpv_referring_domain IN ('', 'N/A')
THEN 'Direct'
when lpv_source = '' 
and lpv_medium = '' 
and lpv_campaign = '' 
and lpv_content = '' 
AND lpv_referring_domain NOT IN ('', 'N/A')
AND lpv_page_type = 'Homepage'
	THEN 'Organic'
when lpv_source IN ('utm_sorce=elocal', 'utm_source=pbx', 'utm_source=marchex') then 'Marchex/eLocal/pbx Calls'
when (lpv_campaign in ('utm_campaign=brand', 'utm_campaign=Branded_Terms', 'utm_campaign=legalbroad', 'utm_campaign=Brand|RLSA') or lpv_content = 'utm_content=brand')
	AND LOWER(lpv_campaign) NOT LIKE '%fb%'
    then 'SEM Brand'
when lpv_source = '' 
and lpv_medium = '' 
and lpv_campaign = '' 
and lpv_content = '' 
AND lpv_referring_domain NOT IN ('', 'N/A')
AND lpv_page_type <> 'Homepage'
	THEN 'SEO - Non-Brand'
WHEN (LOWER(lpv_campaign) LIKE 'legal_q_&_a_search' 
OR LOWER(lpv_campaign) LIKE '%pls|%'
OR LOWER(lpv_campaign) LIKE '%legalqa%'
OR LOWER(lpv_campaign) LIKE '%plsremarketing%'
OR LOWER(lpv_campaign) LIKE '%advisorremarketing%'
OR lpv_campaign = 'utm_campaign=pls')
AND (CASE 
WHEN LOWER(lpv_campaign) LIKE '%fb%'
THEN 1
ELSE 0
END) = 0
THEN 'SEM Non-Brand'
WHEN lpv_medium IN ('utm_medium=cpc', 'utm_medium=sem', 'utm_medium=cpm', 'utm_medium=sem%3Fpromo_code%3DAVVO25')
AND (LoWER(lpv_source) LIKE '%google%'
	OR LoWER(lpv_source) LIKE '%bing%'
	OR LoWER(lpv_source) LIKE '%yahoo%')
AND (CASE 
WHEN LOWER(lpv_campaign) LIKE '%fb%'
THEN 1
ELSE 0
END) = 0
THEN 'SEM Non-Brand'
when (lpv_medium in ('utm_medium=em', 'utm_medium=ema', 'utm_medium=emai', 'utm_medium=email', 'utm_medium=emailutm_content')
                    or lpv_source = 'utm_source=email'
OR LOWER(lpv_campaign) LIKE '%reset_password%'
)
AND (CASE
WHEN LOWER(lpv_campaign) LIKE '%client_choice_award%'
THEN 1
WHEN LOWER(lpv_campaign) LIKE '%best_answer_pro%'
THEN 1
WHEN LOWER(lpv_campaign) LIKE '%digest%'
THEN 1
WHEN LOWER(lpv_campaign) LIKE '%_pro'
THEN 1
ELSE 0
END) = 0
THEN 'Consumer Email'
WHEN lpv_medium in ('utm_medium=em', 'utm_medium=ema', 'utm_medium=emai', 'utm_medium=email', 'utm_medium=emailutm_content')
                    or lpv_source = 'utm_source=email'
AND (LOWER(lpv_source) LIKE '%best_answer_pro%'
		OR LOWER(lpv_campaign) LIKE '%digest%'
OR LOWER(lpv_campaign) LIKE '%client_choice_award%'
OR LOWER(lpv_campaign) LIKE '%_pro'
)
THEN 'Attorney Email'
when lpv_medium in ('utm_medium=affiliate', 'utm_medium=affiliates', 'utm_medium=affiliawww')
                    or lpv_source in ('utm_source=boomerater', 'utm_source=boomerater%20', 'utm_source=lifecare', 'utm_source=affiliates', 'utm_source=affiliate')
                    then 'Partners'	
WHEN (LOWER(lpv_medium) LIKE '%cpc%'
OR LOWER(lpv_medium) LIKE '%cpm%'
OR LOWER(lpv_medium) LIKE '%banner%'
OR LOWER(lpv_medium) LIKE '%display%')
AND (LOWER(lpv_campaign) LIKE '%fb_%'
OR LOWER(lpv_campaign) LIKE '%acq%'
OR LOWER(lpv_campaign) LIKE '%pls_avvofb%'
OR LOWER(lpv_campaign) LIKE '%pls_fb_%'
OR LOWER(lpv_campaign) LIKE '%pls_fbb%'
OR LOWER(lpv_campaign) LIKE '%tw_%'
OR LOWER(lpv_campaign) LIKE '%_abandoners%'
OR LOWER(lpv_campaign) LIKE '%pls_%')
AND (CASE
WHEN LOWER(lpv_campaign) LIKE '%2016brandvideos_t_acq%'
THEN 1
WHEN LOWER(lpv_campaign) LIKE '%ricampaign%'
THEN 1
WHEN LOWER(lpv_campaign) LIKE '%fb_boosted%'
THEN 1
WHEN LOWER(lpv_campaign) LIKE '%lawyer%'
THEN 1
WHEN LOWER(lpv_campaign) LIKE '%pokemon%'
THEN 1
WHEN LOWER(lpv_campaign) LIKE '%eng_%'
THEN 1
ELSE 0
END) = 0
THEN 'Display & Emerging'
WHEN LOWER(lpv_campaign) IN ('utm_campaign=2016brandvideos_t_acq', 'utm_campaign=claim 2016')
OR LOWER(lpv_campaign) LIKE '%ricampaign%'
OR LOWER(lpv_campaign) LIKE '%2016brandvideos%'
OR LOWER(lpv_campaign) LIKE '%relstudy%'
OR LOWER(lpv_campaign) LIKE '%eng_%'
OR LOWER(lpv_campaign) LIKE '%prenupforlove%'
OR LOWER(lpv_campaign) LIKE 'fb_lawyer%'
OR LOWER(lpv_medium) IN ('utm_medium=video', 'utm_medium=mobile', 'utm_medium=mobile_video', 'utm_medium=mobile_tablet', 'utm_content')
OR LOWER(lpv_medium) LIKE '%display%'
OR LOWER(lpv_source) LIKE '%outbrain%'
then 'Digital Engagement'
when lpv_campaign like 'utm_campaign=FB_%' or lpv_campaign like 'utm_campaign=pls_avvofb%' or lpv_campaign = 'utm_campaign=pls_fb%'
                    or lpv_source in ('utm_source=facebook', 'utm_source=twitter', 'utm_source=linkedin', 'utm_source=gplus', 'utm_source=plus',
                                                             'utm_source=googleplus', 'utm_source=youtube', 'utm_source=pinterest', 'utm_source=twitterfeed',
                                                             'utm_source=Facebook', 'utm_source=Twitter', 'utm_source=topix',
                                                             'utm_source=SocialProof', 'utm_source=thetwitter', 'utm_source=faceb', 'utm_source=social', 'utm_source=t.co')
                                           or lpv_medium in ('utm_medium=facebook', 'utm_medium=twitter')
										   
                    then 'Digital Engagement'
when (lpv_medium in ('utm_medium=display','utm_medium=video','utm_medium=mobile_video', 'utm_medium=mobile', 'utm_medium=content', 'utm_medium=mobile_tablet')
                    and lpv_source != 'utm_source=google' and lpv_source != 'utm_source=gsp')
                    or lpv_source = 'utm_source=Outbrain' or lpv_source = 'utm_source=preroll'
	THEN 'Digital Engagement'
when lpv_content = 'utm_content=adblock' or (lpv_campaign = 'utm_campaign=adblock' and lpv_content != 'utm_content=brand') or lpv_content = 'utm_content=amm'
					or (lpv_campaign = 'utm_campaign=amm' and lpv_content != 'utm_content=brand')
                    then 'SEM Non-Brand'
when lpv_medium in ('utm_medium=avvo_badge', 'utm_medium=avvo_badg', 'utm_medium=avvo_bad', 'utm_medium=avvo_ba', 'utm_medium=avvo_b')
                    then 'Other'
when lpv_source = 'utm_source=avvo' or lpv_source = 'utm_source=eboutique' then 'Other'
else 'Other' end channel
from dm.ad_attribution_v3_all
),

rev as
(select d1.year_month, case when p.product_line_id = 2 then 'Display' when p.product_line_id = 7 then 'Sponsored' else 'Other' end inventory_type,
 case when a2.ad_market_block_flag = 'Y' then 'Block' else 'Exclusive' end market_type, am.ad_market_id,
 sum(o.order_line_net_price_amount_usd) revenue
 from dm.order_line_accumulation_fact o
 join dm.order_line_ad_market_fact am on am.order_line_number = o.order_line_number
 join dm.product_line_dimension p on p.product_line_id = o.product_line_id
 join dm.date_dim d1 on d1.actual_date = o.order_line_begin_date
 join dm.ad_market_dimension a2 on a2.ad_market_id = am.ad_market_id
  where am.ad_market_id = 719913 -- in (719913,720420,714583)
 AND d1.year_month =201612
 group by 1,2,3,4),
 
 
total_acv as
(select 'Sponsored' inventory_type, d.year_month, case when a.ad_market_block_flag = 'Y' then 'Block' else 'Exclusive' end market_type, a.ad_market_id,
sum(sl_adcontact_value) ACV
from dm.ad_attribution_v3_all v3
join dm.date_dim d on d.actual_date = v3.event_date
join dm.ad_market_dimension a on a.ad_market_id = v3.ad_market_id
where a.ad_market_id = 719913 -- in (719913,720420,714583)
AND d.year_month =201612
group by 1,2,3,4

 union all

select 'Display' inventory_type, d.year_month, case when a.ad_market_block_flag = 'Y' then 'Block' else 'Exclusive' end market_type, a.ad_market_id,
sum(da_adcontact_value) ACV
from dm.ad_attribution_v3_all v3
join dm.date_dim d on d.actual_date = v3.event_date
join dm.ad_market_dimension a on a.ad_market_id = v3.ad_market_id
where a.ad_market_id = 719913 -- in (719913,720420,714583)
AND d.year_month =201612
group by 1,2,3,4 
),


m2_acv_old as
(
select 'Sponsored' inventory_type, d.year_month, case when a.ad_market_block_flag = 'Y' then 'Block' else 'Exclusive' end market_type, a.ad_market_id,
sum(case when chan_def.channel in ('SEM Non-Brand', 'SEM Brand', 'GDN Network') then v3.sl_adcontact_value end) sem_acv_old,
sum(case when chan_def.channel not in ('SEM Non-Brand', 'SEM Brand', 'GDN Network') then v3.sl_adcontact_value end) other_acv_old
from dm.ad_attribution_v3_all v3
join dm.date_dim d on d.actual_date = v3.event_date
join dm.ad_market_dimension a on a.ad_market_id = v3.ad_market_id
join chan_def 
	on chan_def.lpv_source = v3.lpv_source 
	and chan_def.lpv_medium = v3.lpv_medium 
	and chan_def.lpv_campaign = v3.lpv_campaign 
	and chan_def.lpv_content = v3.lpv_content
	AND chan_def.lpv_page_type = v3.lpv_page_type
	
where d.year_month =201612
 AND a.ad_market_id = 719913 -- in (719913,720420,714583)
group by 1,2,3,4
  
union all

select 'Display' inventory_type, d.year_month, case when a.ad_market_block_flag = 'Y' then 'Block' else 'Exclusive' end market_type, a.ad_market_id,
sum(case when chan_def.channel in ('SEM Non-Brand', 'SEM Brand', 'GDN Network') then v3.da_adcontact_value end) sem_acv_old,
sum(case when chan_def.channel not in ('SEM Non-Brand', 'SEM Brand', 'GDN Network') then v3.da_adcontact_value end) other_acv_old
from dm.ad_attribution_v3_all v3
join dm.date_dim d on d.actual_date = v3.event_date
join dm.ad_market_dimension a on a.ad_market_id = v3.ad_market_id
join chan_def 
on chan_def.lpv_source = v3.lpv_source 
and chan_def.lpv_medium = v3.lpv_medium 
and chan_def.lpv_campaign = v3.lpv_campaign 
and chan_def.lpv_content = v3.lpv_content
AND chan_def.lpv_page_type = v3.lpv_page_type
where d.year_month =201612
 AND a.ad_market_id = 719913 -- in (719913,720420,714583)
group by 1,2,3,4
),

m2_acv_new as
(select 'Sponsored' inventory_type, d.year_month, case when a.ad_market_block_flag = 'Y' then 'Block' else 'Exclusive' end market_type, a.ad_market_id,
sum(case when chan_def.channel in ('SEM Non-Brand', 'Marchex/eLocal/pbx Calls', 'SEM Brand', 'GDN Network') then v3.sl_adcontact_value end) paid_acv_new,
sum(case when chan_def.channel not in ('SEM Non-Brand', 'Marchex/eLocal/pbx Calls', 'SEM Brand', 'GDN Network') then v3.sl_adcontact_value end) other_acv_new
from dm.ad_attribution_v3_all v3
join dm.date_dim d on d.actual_date = v3.event_date
join dm.ad_market_dimension a on a.ad_market_id = v3.ad_market_id
join chan_def 
on chan_def.lpv_source = v3.lpv_source 
and chan_def.lpv_medium = v3.lpv_medium 
and chan_def.lpv_campaign = v3.lpv_campaign 
and chan_def.lpv_content = v3.lpv_content
AND chan_def.lpv_page_type = v3.lpv_page_type
 where  a.ad_market_id = 719913 -- in (719913,720420,714583)
AND d.year_month =201612
group by 1,2,3,4

union all

select 'Display' inventory_type, d.year_month, case when a.ad_market_block_flag = 'Y' then 'Block' else 'Exclusive' end market_type, a.ad_market_id,
sum(case when chan_def.channel in ('SEM Non-Brand', 'Marchex/eLocal/pbx Calls', 'SEM Brand', 'GDN Network') then v3.da_adcontact_value end) paid_acv_new,
sum(case when chan_def.channel not in ('SEM Non-Brand', 'Marchex/eLocal/pbx Calls', 'SEM Brand', 'GDN Network') then v3.da_adcontact_value end) other_acv_new
from dm.ad_attribution_v3_all v3
join dm.date_dim d on d.actual_date = v3.event_date
join dm.ad_market_dimension a on a.ad_market_id = v3.ad_market_id
join chan_def 
on chan_def.lpv_source = v3.lpv_source 
and chan_def.lpv_medium = v3.lpv_medium 
and chan_def.lpv_campaign = v3.lpv_campaign 
and chan_def.lpv_content = v3.lpv_content
AND chan_def.lpv_page_type = v3.lpv_page_type
 where  a.ad_market_id = 719913 -- in (719913,720420,714583)
 AND d.year_month =201612
group by 1,2,3,4)


-- this outer query of sum of rev by channel is test
/* select channel, sum(revenue_m1) revm1, sum(acv) acv, sum(total_acv) total_acv, sum(m2_sem_acv_old) m2semacvold, sum(m2_other_acv_old) m2otheracvold,
 sum(total_rev) total_rev, sum(revenue_m2_old) revm2old
 from ( */

select inventory_type
, year_month
, market_type
, ad_market_id
, state
, county
, region
, parent_pa
, PA
, channel
, lpv_page_type
, avg(total_rev) total_rev
, avg(total_acv) total_acv
, sum(acv) acv
  -- averaging total_rev and total_acv here because we already have the sum by market which we want to keep to calculate the m1
, case when avg(total_acv) = 0 then 0 else (sum(acv)/avg(total_acv))*avg(total_rev) end revenue_m1
, avg(sem_acv_old) m2_sem_acv_old
, avg(other_acv_old) m2_other_acv_old
, avg(paid_acv_new) m2_paid_acv_new
, avg(other_acv_new) m2_other_acv_new
, case when avg(total_rev) > avg(total_acv) then 'case 1'
when channel in ('SEM Non-Brand', 'SEM Brand', 'GDN Network') and avg(total_rev) > avg(other_acv_old)
then 'case 2'
when channel in ('SEM Non-Brand', 'SEM Brand', 'GDN Network') and avg(total_rev) <= avg(other_acv_old)
then 'case 3'
when avg(other_acv_old) < avg(total_rev) then 'case 4'
else 'case 5' end revenue_m2_old_test
, case when avg(total_rev) > avg(total_acv) then (sum(acv)/avg(total_acv))*avg(total_rev)
when channel in ('SEM Non-Brand', 'SEM Brand', 'GDN Network') and avg(total_rev) > avg(other_acv_old)
then sum(acv)/(avg(total_acv)-avg(other_acv_old))*(avg(total_rev)-avg(other_acv_old))
when channel in ('SEM Non-Brand', 'SEM Brand', 'GDN Network') and avg(total_rev) <= avg(other_acv_old)
then 0
when avg(other_acv_old) < avg(total_rev) then (sum(acv)/avg(other_acv_old))*avg(other_acv_old) -- (which is just ACV, but I did it this way so these case statements could be more easily mapped to the old query)
else (sum(acv)/avg(other_acv_old))*avg(total_rev) end revenue_m2_old

-- if all revenue is greater than all acv, don't have to worry about giving too much credit to any channel because all acv is needed
-- else if looking at an SEM/paid channel (depending on new or old definitions), take the % of SEM/paid ACV that this channel makes up and apply that to the remaining revenue not fulfilled by other channel ACV
-- if there is no revenue not fulfilled by other channels, then the SEM/paid channel will have m2 revenue of 0
-- otherwise, if looking at an "other" channel, the m2 revenue will be the % of "other" ACV it makes up times the "other" acv (so full ACV value) if it's less than the total rev. or the % of "other" acv times total revenue
               
               
, case when avg(total_rev) > avg(total_acv) then  (sum(acv)/avg(total_acv))*avg(total_rev)
when channel in ('SEM Non-Brand', 'Marchex/eLocal/pbx Calls', 'SEM Brand', 'GDN Network') and avg(total_rev) > avg(other_acv_new)
then sum(acv)/(avg(total_acv)-avg(other_acv_new))*(avg(total_rev)-avg(other_acv_new)) -- (remember can't use paid acv in the denominator)
when channel in ('SEM Non-Brand', 'Marchex/eLocal/pbx Calls', 'SEM Brand', 'GDN Network') and avg(total_rev) <= avg(other_acv_new)
then 0
when avg(other_acv_new) < avg(total_rev) then (sum(acv)/avg(other_acv_new))*avg(other_acv_new) 
else (sum(acv)/avg(other_acv_new))*avg(total_rev) end revenue_m2_new

from (
select 'Sponsored' inventory_type
, d.year_month
, a.market_type
, a.ad_market_id
, a.state
, a.county
, a.region
, a.parent_pa
, a.PA
, chan_def.channel
, chan_def.lpv_page_type
, rev.revenue total_rev
, total_acv.acv total_acv
, m2_acv_old.sem_acv_old
, m2_acv_old.other_acv_old
, m2_acv_new.paid_acv_new
, m2_acv_new.other_acv_new
, sum(sl_adcontact_value) ACV
from dm.ad_attribution_v3_all v3
  join chan_def 
  on chan_def.lpv_source = v3.lpv_source 
  and chan_def.lpv_medium = v3.lpv_medium 
  and chan_def.lpv_campaign = v3.lpv_campaign 
  and chan_def.lpv_content = v3.lpv_content
  AND chan_def.lpv_page_type = v3.lpv_page_type
join dm.date_dim d on d.actual_date = v3.event_date
join (select ad_market_id, case when ad_market_block_flag = 'Y' then 'Block' else 'Exclusive' end market_type,
      a1.ad_market_state_name state, a1.ad_market_county_name county, a1.ad_market_region_name region, s1.parent_specialty_name parent_pa, s1.specialty_name pa
      from dm.ad_market_dimension a1
     join dm.specialty_dimension s1 on s1.specialty_id = a1.specialty_id
     ) a on a.ad_market_id = v3.ad_market_id
left join rev on rev.year_month = d.year_month and rev.inventory_type = 'Sponsored' and rev.market_type = a.market_type and rev.ad_market_id = v3.ad_market_id
left join total_acv on total_acv.year_month = d.year_month and total_acv.inventory_type = 'Sponsored' and total_acv.market_type = a.market_type and total_acv.ad_market_id = v3.ad_market_id
left join m2_acv_old on m2_acv_old.year_month = d.year_month and m2_acv_old.inventory_type = 'Sponsored' and m2_acv_old.market_type = a.market_type and m2_acv_old.ad_market_id = v3.ad_market_id
left join m2_acv_new on m2_acv_new.year_month = d.year_month and m2_acv_new.inventory_type = 'Sponsored' and m2_acv_new.market_type = a.market_type and m2_acv_new.ad_market_id = v3.ad_market_id
  where d.year_month =201612
  and a.market_type = 'Block'  and a.ad_market_id = 719913 -- in (719913,720420,714583)
 group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
  
  union all
  
select 'Display' inventory_type
, d.year_month
, a.market_type
, a.ad_market_id
, a.state
, a.county
, a.region
, a.parent_pa
, a.PA
, chan_def.channel
, chan_def.lpv_page_type
, rev.revenue total_rev
, total_acv.acv total_acv
, m2_acv_old.sem_acv_old
, m2_acv_old.other_acv_old
, m2_acv_new.paid_acv_new
, m2_acv_new.other_acv_new
, sum(da_adcontact_value) ACV
from dm.ad_attribution_v3_all v3
  join chan_def 
  on chan_def.lpv_source = v3.lpv_source 
  and chan_def.lpv_medium = v3.lpv_medium 
  and chan_def.lpv_campaign = v3.lpv_campaign 
  and chan_def.lpv_content = v3.lpv_content
  AND chan_def.lpv_page_type = v3.lpv_page_type
join dm.date_dim d on d.actual_date = v3.event_date
join (select ad_market_id, case when ad_market_block_flag = 'Y' then 'Block' else 'Exclusive' end market_type,
      a1.ad_market_state_name state, a1.ad_market_county_name county, a1.ad_market_region_name region, s1.parent_specialty_name parent_pa, s1.specialty_name pa
      from dm.ad_market_dimension a1
     join dm.specialty_dimension s1 on s1.specialty_id = a1.specialty_id
     ) a on a.ad_market_id = v3.ad_market_id
left join rev on rev.year_month = d.year_month and rev.inventory_type = 'Display' and rev.market_type = a.market_type and rev.ad_market_id = v3.ad_market_id
left join total_acv on total_acv.year_month = d.year_month and total_acv.inventory_type = 'Display' and total_acv.market_type = a.market_type and total_acv.ad_market_id = v3.ad_market_id
left join m2_acv_old on m2_acv_old.year_month = d.year_month and m2_acv_old.inventory_type = 'Display' and m2_acv_old.market_type = a.market_type and m2_acv_old.ad_market_id = v3.ad_market_id
left join m2_acv_new on m2_acv_new.year_month = d.year_month and m2_acv_new.inventory_type = 'Display' and m2_acv_new.market_type = a.market_type and m2_acv_new.ad_market_id = v3.ad_market_id
  where d.year_month =201612
and a.market_type = 'Block'  and a.ad_market_id = 719913 -- in (719913,720420,714583)
 group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17

  ) t
  group by 1,2,3,4,5,6,7,8,9,10,11
-- ) test
-- group by 1