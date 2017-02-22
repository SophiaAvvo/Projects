questions as
(
	select distinct q.created_by AS user_id
	,'Ask a Question' as ActionType
	,CASE
		WHEN sd.parent_specialty_name IN ('Family', 'Immigration', 'Estate Planning', 'Real Estate', 'Business')
			THEN sd.parent_specialty_name
		ELSE 'Other'
	END ParentPA
		,MIN(q.created_at) as FirstAction
		,MAX(q.created_at) as LastAction
	from src.content_question q
	JOIN tmp_data_dm.sr_ru_user_id_and_reg_date ui
		ON ui.user_id = q.created_by
		AND q.created_at BETWEEN from_unixtime(unix_timestamp(cast(ui.reg_time as timestamp) - interval 1 days), 'yyyy-MM-dd HH:mm:ss') AND ui.reg_time
	left join dm.specialty_dimension sd on sd.specialty_id = q.specialty_id
	where to_date(q.created_at) >= '2013-01-01' 
       and q.approval_status_id in (1,2)
	   AND (q.created_by <> 1 OR q.updated_by <> 1)
	GROUP BY 1,2,3
)

,question_rank AS (
  
  SELECT *
  ,ROW_NUMBER() OVER(PARTITION BY question_id ORDER BY answer_id) Num
  FROM questions
  
)

/*
, returned_asker as
(
	select x1.asker
	from
	(
		select distinct x.asker
		from questions x
		join
		(
		   select distinct d.year_month     
		   from DM.DATE_DIM d
		   where d.actual_date = to_date(now()- interval 1 month)
		) dt on dt.year_month = x.question_year_month
	) x1
	left join
	(
		select distinct x.asker
		from questions x
		join
		(
		   select distinct d.year_month     
		   from DM.DATE_DIM d
		   where d.actual_date <= to_date(now()- interval 2 month)
			and d.actual_date >= to_date(now()- interval 4 month)
		) dt on dt.year_month = x.question_year_month
	) x2 on x1.asker = x2.asker
	left join
	(
		select distinct x.asker
		from questions x
		join
		(
		   select distinct d.year_month     
		   from DM.DATE_DIM d
		   where d.actual_date < to_date(now()- interval 4 month)
		) dt on dt.year_month = x.question_year_month
	) x3 on x1.asker = x3.asker
	where x2.asker is null and x3.asker is not null
)

*/

select qs.asker user_id
    , to_date(uad.user_account_register_datetime) as user_account_register_datetime
	-- , qs.question_date
	,CASE
		WHEN to_date(uad.user_account_register_datetime) < qs.question_date
			THEN 'Post-Registration'
		WHEN to_date(uad.user_account_register_datetime) = qs.question_date
			THEN 'Day of Registration'
		WHEN to_date(uad.user_account_register_datetime) > qs.question_date
			THEN 'Pre-Registration'
		ELSE 'Missing'
		END timewindow
	,COUNT(DISTINCT qs.question_id) DistinctQuestionCount
	,COUNT(qs.answer_id) AnswerCount
	,MIN(qs.question_date) FirstQuestionDate
	,MAX(qs.question_date) LastQuestionDate
	,SUM(CASE WHEN qs.Num = 1 THEN FamilyQuestionFlag ELSE 0 END) FamilyQuestionCount
	,SUM(CASE WHEN qs.Num = 1 THEN ImmigrationQuestionFlag ELSE 0 END) ImmigrationQuestionCount	
	,SUM(CASE WHEN qs.Num = 1 THEN BusinessQuestionFlag ELSE 0 END) BusinessQuestionCount
	,SUM(CASE WHEN qs.Num = 1 THEN EstatePlanQuestionFlag ELSE 0 END) EstatePlanQuestionCount
	,SUM(CASE WHEN qs.Num = 1 THEN RealEstateQuestionFlag ELSE 0 END) RealEstateQuestionCount
	,SUM(CASE WHEN qs.Num = 1 THEN OtherQuestionFlag ELSE 0 END) OtherQuestionCount	
	,SUM(FamilyAnswerFlag) FamilyAnswerCount
	,SUM(ImmigrationAnswerFlag) ImmigrationAnswerCount	
	,SUM(BusinessAnswerFlag) BusinessAnswerCount
	,SUM(EstatePlanAnswerFlag) EstatePlanAnswerCount
	,SUM(RealEstateAnswerFlag) RealEstateAnswerCount
	,SUM(OtherAnswerFlag) OtherAnswerCount	
	--, qs.asker
	-- , case when ra.asker is null then "N" else "Y" end as asker_returned_3month_later
	--, qs.answer_date

	--, qs.answer_year_month
	--, qs.question_year_month
	,AVG(CASE WHEN FamilyAnswerFlag = 1 THEN ast.answertime_mins ELSE NULL END) AvgMinsToAnswerFamily
	,AVG(CASE WHEN BusinessAnswerFlag = 1 THEN ast.answertime_mins ELSE NULL END) AvgMinsToAnswerBusiness
	,AVG(CASE WHEN ImmigrationAnswerFlag = 1 THEN ast.answertime_mins ELSE NULL END) AvgMinsToAnswerImmigration
	,AVG(CASE WHEN EstatePlanAnswerFlag = 1 THEN ast.answertime_mins ELSE NULL END) AvgMinsToAnswerEstatePlan
	,AVG(CASE WHEN RealEstateAnswerFlag = 1 THEN ast.answertime_mins ELSE NULL END) AvgMinsToAnswerRealEstate
	,AVG(CASE WHEN OtherAnswerFlag = 1 THEN ast.answertime_mins ELSE NULL END) AvgMinsToAnswerOther
        -- , dt.year_month as registration_year_month
from question_rank qs 
left join answertime ast on ast.question_id = qs.question_id

-- left join returned_asker ra on qs.asker = ra.asker
left join dm.user_account_dimension uad on uad.user_account_id = qs.asker
-- join dm.date_dim dt on to_date(dt.actual_date)=to_date(uad.user_account_register_datetime)
GROUP BY 1,2,3