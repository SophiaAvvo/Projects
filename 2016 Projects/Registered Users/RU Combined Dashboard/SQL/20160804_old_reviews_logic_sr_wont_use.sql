select 
ci.created_by user_id
	,CASE
		WHEN to_date(uad.user_account_register_datetime) < ci.created_at
			THEN 'Post-Registration'
		WHEN to_date(uad.user_account_register_datetime) = ci.created_at
			THEN 'Day of Registration'
		WHEN to_date(uad.user_account_register_datetime) > ci.created_at
			THEN 'Pre-Registration'
		ELSE 'Missing'
		END timewindow
	,SUM(CASE WHEN sd.parent_specialty_name = 'Business'
		THEN 1
		ELSE 0
		END) as BusinessReviewCount
	,SUM(CASE WHEN sd.parent_specialty_name = 'Family'
		THEN 1
		ELSE 0
		END) as FamilyReviewCount
	,SUM(CASE WHEN sd.parent_specialty_name = 'Immigration'
		THEN 1
		ELSE 0
		END) as ImmigrationReviewCount
	,SUM(CASE WHEN sd.parent_specialty_name = 'Estate Planning'
		THEN 1
		ELSE 0
		END) as EstatePlanReviewCount
	,SUM(CASE WHEN sd.parent_specialty_name = 'Real Estate'
		THEN 1
		ELSE 0
		END) as RealEstateReviewCount
	,SUM(CASE WHEN sd.parent_specialty_name NOT IN ('Family', 'Immigration', 'Estate Planning', 'Real Estate', 'Business')
		THEN 1
		ELSE 0
		END) as OtherReviewCount
	,COUNT(ci.professional_id) TotalReviews
	,AVG(overall_rating) AvgRating
	,SUM(recommended)/COUNT(ci.professional_id) PctRecommended
,min(created_at) FirstReview
, max(created_at) as LastReview
from src.barrister_professional_review ci
JOIN dm.user_account_dimension uad
ON uad.user_account_id = ci.created_by
-- AND uad.user_account_id < 100000
AND ci.created_at BETWEEN '2011-01-01' AND '2016-04-30'
left join dm.specialty_dimension sd 
	on sd.specialty_id = ci.specialty_id

group by 1,2-- ,3,4
-- ORDER BY 1