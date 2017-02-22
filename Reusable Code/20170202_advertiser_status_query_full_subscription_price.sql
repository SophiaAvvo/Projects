SELECT DISTINCT professional_id
FROM dm.full_subscription_price_professional_daily_all_products
WHERE is_active = 'y' -- denotes whether the person has DA/SL, MRR, or both 
AND etl_load_date = (SELECT MAX(etl_load_date) FROM dm.full_subscription_price_professional_daily_all_products)
