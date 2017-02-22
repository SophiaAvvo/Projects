select --ac.event_date
            --prof_ad_bridge.professional_id
            product_line_id
            , count(ai.ad_id) as total_ad_clicks
            ,COUNT(CASE 
                      WHEN product_line_id = 2
                         THEN ai.ad_id
                      ELSE NULL
                   END) DA_clicks
            ,COUNT(CASE 
                      WHEN product_line_id = 7
                         THEN ai.ad_id
                      ELSE NULL
                   END) SL_clicks
from src.ad_click ac
            inner join src.ad_impression ai 
               on ac.event_date = ai.event_date 
               and ac.ad_impression_guid = ai.ad_impression_guid
            left join (
                        select distinct am.ad_id
                                    , am.professional_id
                                    --, p.product_line_item_name
                                    , p.product_line_id
                        from dm.order_line_ad_market_fact am
             join dm.order_line_accumulation_fact f 
                on f.order_line_number = am.order_line_number
             join dm.product_line_dimension p 
                on p.product_line_id = f.product_line_id
             --WHERE p.product_line_id IN (2, 7)
            ) prof_ad_bridge 
            on ai.ad_id = prof_ad_bridge.ad_id
where ac.event_date BETWEEN '2015-05-01' AND '2016-02-29'
group by 1 -- , 2,3
order by 1 -- , 2,3
