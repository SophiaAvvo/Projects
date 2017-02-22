select 
ROW_NUMBER()OVER(order by inner_p.profnl_id asc) unique_key
,outer_p.score_date 
,outer_p.score_cat_id 
,outer_p.score_cat_name 
,outer_p.score_attrib_id 
,outer_p.score_attrib_name 
,outer_p.raw_score 
,outer_p.norml_score 
,outer_p.wghtd_norml_score 
,outer_p.displybl_score 
from
(
select 
pd.profnl_id
from DM..profnl_dim pd
where pd.profnl_key=-1 
) inner_p 
left join
(
select
sl.profnl_id
,sl.score_date
,sc.score_cat_id
,sc.score_cat_name 
,sa.score_attrib_id
,sa.score_attrib_name
,sl.raw_score
,sl.norml_score
,sl.wghtd_norml_score
,sl.displybl_score
from
ods_profnl_score_log sl 
join ods_score_cat_attrib sca on
sl.score_cat_attrib_id=sca.score_cat_attrib_id
join ods_score_attrib sa on
sa.score_attrib_id=sca.score_attrib_id
join ods_score_cat sc on
sc.score_cat_id=sca.score_cat_id
where 
sl.profnl_id=?n_PROFNL_ID?  and
sl.score_date>=?n_BUSINESS_START_DATE?  and
sl.score_date<=?n_BUSINESS_END_DATE?
) outer_p on
outer_p.profnl_id>inner_p.profnl_id
