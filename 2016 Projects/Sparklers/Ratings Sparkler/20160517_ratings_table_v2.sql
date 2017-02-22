WITH r2 AS (SELECT x.professional_id
,x.rating
,x.score_date AS ScoreDate1
,COALESCE(DATE_ADD(y.score_date, -1), '2016-04-30') ScoreDate2
FROM srcmgd.tmp_professional_score_date x
LEFT JOIN (SELECT professional_id
				,rating
				,score_date
				,Num - 1 AS Iterator
			FROM srcmgd.tmp_professional_score_date
            
			) y
ON x.professional_id = y.professional_id
AND x.Num = y.Iterator
WHERE (y.score_date >= '2015-05-01' OR y.score_date IS NULL)

  -- ORDER BY 1,3,4

)


/* now most profiles have ratings since we aren't date-restricting until the cross join */
CREATE TABLE tmp_data_src.SR_sparklers_ratings_from_May_2015 AS (

SELECT DISTINCT r.professional_id
,r.rating Rating
,d.actual_date RatingDate
FROM r2 r
JOIN dm.date_dim d
  ON d.actual_date BETWEEN r.scoredate1 AND r.scoredate2
  AND d.actual_date BETWEEN '2015-05-01' AND '2016-04-30')