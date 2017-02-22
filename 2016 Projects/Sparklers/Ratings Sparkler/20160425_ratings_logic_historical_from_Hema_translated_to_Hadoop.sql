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
pd.professional_id AS profnl_id
from DM.professional_dimension pd
-- where pd.profnl_key=-1 
) inner_p 
left join
(
select
sl.professional_id AS profnl_id
,sl.score_date
,sc.id AS score_cat_id
,sc.name AS score_cat_name 
,sa.id AS score_attrib_id
,sa.name AS score_attrib_name
,sl.raw_score
,sl.normalized_score AS norml_score
,sl.weighted_normalized_score AS wghtd_norml_score
,sl.displayable_score AS displybl_score
from
src.history_barrister_professional_scoring_log sl 
join src.barrister_scoring_category_attribute sca on
sl.scoring_category_attribute_id=sca.scoring_attribute_id
join src.barrister_scoring_attribute sa on
sa.id=sca.scoring_attribute_id
join src.barrister_scoring_category sc on
sc.id=sca.scoring_category_id
/*where 
sl.professional_id=?n_PROFNL_ID?  and
sl.score_date>=?n_BUSINESS_START_DATE?  and
sl.score_date<=?n_BUSINESS_END_DATE? */
) outer_p on
outer_p.profnl_id>inner_p.profnl_id

/*
Netezza	Hadoop	Database in Hadoop
ods_profnl_score_log	history_barrister_professional_scoring_log 	src
ods_score_cat_attrib	barrister_scoring_category_attribute	src
ods_score_attrib	barrister_scoring_attribute	src
ods_score_cat	barrister_scoring_category	src
profnl_dim 	professional_dimension	dm
*/