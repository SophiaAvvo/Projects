SELECT professional_id
  ,COUNT(DISTINCT id) Review_Count
  ,SUM(recommended)/COUNT(recommended)*1.0 PercentRecommended
  ,AVG(overall_rating) AvgRating
FROM src.barrister_professional_review pr
WHERE created_at >= '01/01/2014'
GROUP BY professional_Id
LIMIT 10;
