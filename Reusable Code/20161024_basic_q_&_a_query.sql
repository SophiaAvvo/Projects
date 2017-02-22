select 
   q.created_by AS user_id
   ,count(distinct q.id) as num_questions
from src.content_question q
WHERE approval_status_id in (1,2)
	AND q.created_by <> -1
	AND q.created_at >= '2016-02-08'