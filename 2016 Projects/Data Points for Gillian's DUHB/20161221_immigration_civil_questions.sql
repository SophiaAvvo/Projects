select 
   COUNT(DISTINCT q.id) QuestionCount
   ,COUNT(CASE
		WHEN sp.parent_specialty_name IN ('Immigration', 'Civil Rights')
			THEN q.id
		ELSE NULL
	END) AS immigration_civil_count
   /*,CASE
   WHEN LOWER(q.subject) LIKE '%free attorney%'
              OR LOWER(q.body) LIKE '%free attorney%'
                       THEN 'Free Attorney'
    WHEN LOWER(q.subject) LIKE '%pro bono%'
    OR LOWER(q.subject) LIKE '%probono%'
    OR LOWER(q.body) LIKE '%pro bono%'
    OR LOWER(q.body) LIKE '%probono%'
                       THEN 'Pro Bono'
WHEN LOWER(q.subject) LIKE '%free services%'
    OR LOWER(q.body) LIKE '%free services%'
                       THEN 'Free Services'
    END Phrase_Type */
,d.year_month
,sp.specialty_name
,sp.parent_specialty_name
,d.actual_date
,CASE
	WHEN d.actual_date >= '2016-11-09'
		THEN 'Post 2016 Election'
	WHEN d.actual_date >= '2012-11-09'
		then 'Post 2012 Election'
	ELSE 'Pre Election'
END Question_Timeframe
--,q.subject
--,q.body
from src.content_question q
JOIN dm.date_dim d
ON d.actual_date = to_date(q.created_at)
JOIN DM.SPECIALTY_DIMENSION sp ON sp.SPECIALTY_ID = q.SPECIALTY_ID
WHERE approval_status_id in (1,2)
	AND q.created_at >= '2011-01-01'
GROUP BY 3,4,5,6,7