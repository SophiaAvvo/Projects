SELECT professional_id
  ,r2.year_month
	,MIN(ReviewYearMonth) FirstReviewMonth
  ,COUNT(DISTINCT Review_Id) CumulativeMonthlyReviews -- the count distinct keeps the second crossjoin out of the count
  ,SUM(NewReviewFlag) NewReviewCount 
  ,SUM(recommended)/COUNT(recommended) Pct_Recommended
  ,AVG(overall_rating) AvgRating
FROM (      
      SELECT professional_id,
             Review_Id
             ,recommended
             ,overall_rating
             ,ReviewYearMonth
             ,cal.year_month
             ,CASE
                 WHEN cal.year_month = ReviewYearMonth
                     THEN 1
                 ELSE 0
              END NewReviewFlag
      FROM (SELECT pr.professional_id
                   ,pr.id AS Review_Id
                   ,pr.recommended
                   ,pr.overall_rating
                   ,CASE
                     WHEN EXTRACT(MONTH FROM pr.created_at) < 10 THEN CAST(CONCAT (CAST(EXTRACT(YEAR FROM pr.created_at) AS VARCHAR),'0',CAST(EXTRACT(MONTH FROM pr.created_at) AS VARCHAR)) AS INT)
                     ELSE CAST(CONCAT (CAST(EXTRACT(YEAR FROM pr.created_at) AS VARCHAR),CAST(EXTRACT(MONTH FROM pr.created_at) AS VARCHAR)) AS INT)
                   END ReviewYearMonth
                   FROM src.barrister_professional_review pr
WHERE pr.approval_status_id = 2 -- approved
            ) r
		-- This first cross join is to get a calendar that shows which reviews are associated with which months.  A review that was made in January will be associated with every month thereafter
        CROSS JOIN (SELECT DISTINCT year_month
                    FROM dm.date_dim d
                    WHERE d.actual_date BETWEEN '2000-01-01' AND '2016-05-31'
                    AND   year_month > 0) cal
      WHERE cal.year_month >= r.ReviewYearMonth
      )r2
WHERE r2.year_month <= 201605
GROUP BY 1,2--,3,4     