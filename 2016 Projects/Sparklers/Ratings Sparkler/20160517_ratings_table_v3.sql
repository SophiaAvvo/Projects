


/* now most profiles have ratings since we aren't date-restricting until the cross join */
CREATE TABLE tmp_data_src.SR_sparklers_ratings_from_May_2015 AS

WITH profile as -- duplicates across professional_id due to practice area and specialty percent
(
        select distinct p.professional_id
        	from dm.professional_dimension p
				WHERE p.professional_delete_indicator = 'Not Deleted'
        		and p.professional_practice_indicator = 'Practicing'
        		and p.professional_name = 'lawyer'
        		and p.industry_name = 'Legal'


)

, r2 AS (
SELECT x.professional_id
,x.rating
,x.score_date AS ScoreDate1
,COALESCE(DATE_ADD(y.score_date, -1), '2016-04-30') ScoreDate2
FROM srcmgd.tmp_professional_score_date x
JOIN profile p
ON p.professional_id = x.professional_id
LEFT JOIN (SELECT professional_id
				,rating
				,score_date
				,Num - 1 AS Iterator
			FROM srcmgd.tmp_professional_score_date
            
			) y
ON x.professional_id = y.professional_id
AND x.Num = y.Iterator
WHERE (y.score_date >= '2015-05-01' OR y.score_date IS NULL)

)

SELECT DISTINCT r.professional_id
,r.rating Rating
,d.actual_date RatingDate
FROM r2 r
JOIN dm.date_dim d
  ON d.actual_date BETWEEN r.scoredate1 AND r.scoredate2
  AND d.actual_date BETWEEN '2015-05-01' AND '2016-04-30';