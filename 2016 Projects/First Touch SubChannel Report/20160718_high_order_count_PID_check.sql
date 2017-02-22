select DISTINCT a.*
,oas.*
	, op.name
from (
	select DISTINCT persistent_session_id
		, regexp_extract(url, 'thank_you\/([0-9]+)', 1) as order_id
  ,event_date
	from src.page_view where page_type = 'LS-Thankyou' AND event_date >= '2016-02-08' and persistent_session_id = '51836885-5c9b-4205-b186-c9befd10d6a3'
) a

left join src.ocato_advice_sessions oas on cast(a.order_id as INT) = oas.id left join src.ocato_offers oo on oas.offer_id = oo.id left join src.ocato_packages op on oo.package_id = op.id
order by a.order_id

/* 41 distinct order ids.... Nadine says there's a thing about this, not sure what */
