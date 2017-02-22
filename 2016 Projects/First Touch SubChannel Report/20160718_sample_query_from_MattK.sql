select a.order_id
	, op.name
	, b.*
from (
	select persistent_session_id
		, regexp_extract(url, 'thank_you\/([0-9]+)', 1) as order_id
	from src.page_view where page_type = 'LS-Thankyou' and event_date between '2016-04-24' and '2016-04-30'
) a
cross join (
	select persistent_session_id
		, session_id
		, `timestamp`
		, event_type
		, page_type
		, url
		, referrer
		, render_instance_guid
	from src.weblog web
	where event_date between '2016-04-24' and '2016-04-30' and event_type in ('page_view', 'service_session_payment')
		and persistent_session_id in (
		'10e3cd53-3d8a-4df3-9eda-31418f1588a7'
		, 'a9597ae2-25da-4f47-8d83-c72f451bbcf0'
		, 'eb591ec7-9f8a-4750-a300-ad1d5fe575cb'
		)
) b
left join src.ocato_advice_sessions oas on cast(a.order_id as INT) = oas.id left join src.ocato_offers oo on oas.offer_id = oo.id left join src.ocato_packages op on oo.package_id = op.id where a.persistent_session_id = b.persistent_session_id order by b.persistent_session_id, `timestamp`;
