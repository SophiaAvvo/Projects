SELECT lpv_source
,lpv_medium
,lpv_campaign
,lpv_content
,lpv_referring_domain
,lpv_page_type
,COUNT(DISTINCT session_id)
FROM ad_attribution_v3_all
WHERE lpv_referring_domain IN ('', 'N/A')
GROUP BY 1,2,3,4,5
ORDER BY 6 DESC