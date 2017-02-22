with headshot_attnys as (
> 	select professional_id
> 		, cj.year_month
> 		, case when cj.year_month >= a.year_month then 'Has Headshot' else 'Missing Headshot' end as headshot_status
> 	from
> 		(
> 			select headshots.professional_id
> 				, dd.year_month
> 			from
> 				(
> 					select professional_id
> 						, min(to_date(created_at)) as headshot_date
> 					from src.barrister_professional_media
> 					where media_use_type_id = 1 and record_flag = 'I'
> 					group by 1
> 				) headshots
> 				inner join dm.date_dim dd on headshots.headshot_date = dd.actual_date
> 		) a
> 		cross join (
> 			select distinct year_month
> 			from dm.date_dim
> 			where actual_date between '2015-05-01' and '2016-02-29'
> 		) cj
> )
> 

