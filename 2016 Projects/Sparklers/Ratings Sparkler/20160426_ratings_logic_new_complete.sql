WITH r1 AS (

select
  sd.professional_id
  ,(case when sd.displayable_score>10 then 10
  when sd.displayable_score<1 then 1 else
  sd.displayable_score end ) rating
  ,score_date
  ,ROW_NUMBER() OVER(PARTITION BY sd.professional_id ORDER BY score_date) Num
  from
  (
  select opsl.professional_id,opsl.score_date,round(sum(opsl.displayable_score)+5,1) displayable_score
  from
  src.history_barrister_professional_scoring_log  opsl
  join src.barrister_scoring_category_attribute  osca on
  opsl.scoring_category_attribute_id=osca.id
    AND opsl.score_date >= '2015-01-01'
    AND opsl.professional_id BETWEEN 10000 AND 10100
  join src.barrister_scoring_category  osc on
  osca.scoring_category_id=osc.id
  and osc.name='Overall'
  group by opsl.professional_id,opsl.score_date
  ) sd
  
  )
  
,
r2 AS (SELECT x.professional_id
,x.rating
,x.score_date AS ScoreDate1
,to_date(COALESCE(DATE_ADD(y.score_date, -1), now() - interval 1 day)) AS ScoreDate2
FROM r1 x
LEFT JOIN r1 y
ON x.professional_id = y.professional_id
AND x.Num = y.Num - 1
  -- ORDER BY 1,3,4   

)   

,

r3 AS (
SELECT r.professional_id
,r.rating
,d.actual_date RatingDate
FROM r2 r
JOIN dm.date_dim d
  ON d.actual_date BETWEEN r.scoredate1 AND r.scoredate2
 -- ORDER BY 1,3
  
)
