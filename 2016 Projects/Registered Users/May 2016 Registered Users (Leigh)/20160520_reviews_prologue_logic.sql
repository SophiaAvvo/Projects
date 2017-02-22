SELECT professional_id
	,to_date(created_at) ReviewDate
	,created_by user_id
  ,recommended
  ,overall_rating
FROM src.barrister_professional_review pr
WHERE created_at >= '01/01/2011'
GROUP BY professional_Id
LIMIT 10;
