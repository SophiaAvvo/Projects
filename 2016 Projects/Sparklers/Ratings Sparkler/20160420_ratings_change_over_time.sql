  SELECT -- pd.professional_id ProfileCount
  ROUND(SUM(CAST(pd.professional_avvo_rating AS DOUBLE))/COUNT(pd.professional_id)*1.0) AvgRating
  ,COUNT(pd.professional_avvo_rating) RatingCount
  ,COUNT(DISTINCT pd.professional_id) ClaimedProfileCount
  ,dd.actual_date RatingDay
  -- ,pd.source_system_begin_date
FROM dm.historical_professional_dimension pd
JOIN dm.date_dim dd
   ON dd.actual_date >= pd.source_system_begin_date
   AND dd.actual_date <= ISNULL(pd.source_system_end_date, to_date(now()))
   -- AND dd.actual_date = '2016-04-01'
WHERE pd.professional_claim_date <= '2015-07-01'
AND pd.professional_claim_number IS NOT NULL
   AND pd.professional_avvo_rating IS NOT NULL
   -- AND pd.professional_id BETWEEN 10000 AND 10100
GROUP BY 4 -- ,5
-- ORDER BY pd.professional_id