select 
   COUNT(DISTINCT q.id) QuestionCount
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
--,q.subject
--,q.body
from src.content_question q
JOIN dm.date_dim d
ON d.actual_date = to_date(q.created_at)
WHERE approval_status_id in (1,2)
	AND q.created_at >= '2011-01-01'
    AND (LOWER(q.subject) LIKE '%free attorney%'
    OR LOWER(q.subject) LIKE '%pro bono%'
    OR LOWER(q.subject) LIKE '%probono%'
    OR LOWER(q.subject) LIKE '%free services%'
	OR LOWER(q.subject) LIKE '%free lawyer%'
	OR LOWER(q.subject) LIKE '%free legal advice%'
	OR LOWER(q.subject) LIKE '%free legal help%'
    OR LOWER(q.body) LIKE '%free attorney%'
    OR LOWER(q.body) LIKE '%pro bono%'
    OR LOWER(q.body) LIKE '%probono%'
    OR LOWER(q.body) LIKE '%free services%'
	OR LOWER(q.body) LIKE '%free lawyer%'
	OR LOWER(q.body) LIKE '%free legal advice%'
	OR LOWER(q.body) LIKE '%free legal help%'
             )
GROUP BY 2