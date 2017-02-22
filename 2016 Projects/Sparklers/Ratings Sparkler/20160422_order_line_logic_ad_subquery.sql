WITH adv as
(
select o.professional_id
  ,EXTRACT(month FROm o.order_line_begin_date) OrderMonth
  ,MIN(o.order_line_begin_date) AS ad_start_date
  ,MAX(CASE WHEN o.order_line_cancelled_date = -1 THEN NULL ELSE o.order_line_cancelled_date END) AS cancelled_date
from dm.order_line_accumulation_fact o

					,MAX(CASE
						WHEN o.order_line_cancelled_date <> -1 AND o.order_line_end_date <> -1 AND o.order_line_end_date > o.order_line_cancelled_date -- if cancelled date prior to end of month date
							THEN o.order_line_cancelled_date
                        WHEN o.order_line_cancelled_date <> -1 AND o.order_line_end_date = -1 AND d1.month_end_date > o.order_line_cancelled_date -- if cancelled date prior to end of month date
							THEN o.order_line_cancelled_date
						ELSE d1.month_end_date
					END) ad_end_date
            	from dm.order_line_accumulation_fact o
				JOIN (SELECT DISTINCT month_begin_date
						,month_end_date
						FROM dm.date_dim
						WHERE year_month = 201501) d1
					ON d1.month_begin_date = o.order_line_begin_date
  AND o.professional_id BETWEEN 10000 AND 11000
  
                GROUP BY 1,2
)

SELECT *
,ROW_NUMBER() OVER(PARTITION BY a.professional_id, a.ad_start_date) IsDupe
FROM adv a
ORDER BY a.professional_id, a.ad_start_date, a.ad_end_date
