
  select pd.professional_id
  ,ps.deceased
  ,ps.rateable
    ,MIN(opsl.score_date) MinScoreDate
    ,MAX(opsl.score_date) MaxScoreDAte
    ,COUNT(DISTINCT opsl.score_date) TotalScoreDAtes
    --,MAX(round(sum(opsl.displayable_score)+5,1)) Maxdisplayable_score
    --,MIN(round(sum(opsl.displayable_score)+5,1)) Maxdisplayable_score
  from dm.professional_dimension pd
    LEFT JOIN src.barrister_professional_status ps
  ON ps.professional_id = pd.professional_id
AND ps.professional_id < 1000
  LEFT JOIN src.history_barrister_professional_scoring_log  opsl
  ON opsl.professional_id = pd.professional_id
  AND opsl.professional_id < 1000
  left join src.barrister_scoring_category_attribute  osca 
  on opsl.scoring_category_attribute_id=osca.id
	--AND opsl.score_date >= '2015-05-01'

  left join src.barrister_scoring_category  osc on
  osca.scoring_category_id=osc.id

  WHERE pd.professional_id < 1000
  and osc.name='Overall'
  group by 1,2,3
  ORDER BY 1
