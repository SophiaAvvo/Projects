-- 86,599 total professionals with a bio

SELECT pb.professional_id
,pb.updated_at
,CASE
	WHEN instr(pb.plain_text, 'love ') > 0
,instr(LOWER(pb.plain_text), 'i ') first_I
,instr(LOWER(pb.plain_text), 'we ') first_we
,instr(LOWER(pb.plain_text), 'he ') first_he
,instr(LOWER(pb.plain_text), 'she ') first_she
,instr(LOWER(pb.plain_text), 'they ') first_they
,instr(LOWER(pb.plain_text), 'she ') first_she
,instr(LOWER(pb.plain_text), 'enjoy ') has_enjoy
,instr(LOWER(pb.plain_text), 'happy ') has_happy
,instr(LOWER(pb.plain_text), 'need') has_need
,instr(LOWER(pb.plain_text), 'you ') second_person
,instr(LOWER(pb.plain_text), 'success') has_success
,instr(LOWER(pb.plain_text), 'experience') has_experience
,instr(LOWER(pb.plain_text), 'help') has_help
,instr(LOWER(pb.plain_text), 'free ') has_free
,instr(LOWER(pb.plain_text), 'church ') has_church
,CASE 
	WHEN instr(LOWER(pb.plain_text), 'born ') > 0
		THEN 1
	WHEN instr(LOWER(pb.plain_text), 'native ') > 0
		THEN 1
	WHEN instr(LOWER(pb.plain_text), 'lifelong resident ') > 0
		THEN 1
	WHEN instr(LOWER(pb.plain_text), 'grew up ') > 0
		THEN 1
	ELSE 0
END has_roots
,CASE 
	WHEN instr(LOWER(pb.plain_text), 'prior ') > 0
		THEN 1
	WHEN instr(LOWER(pb.plain_text), 'former ') > 0
		THEN 1
	WHEN instr(LOWER(pb.plain_text), 'previous') > 0
		THEN 1
	WHEN instr(LOWER(pb.plain_text), 'history ') > 0
		THEN 1
	ELSE 0
END has_history
,CASE 
	WHEN instr(LOWER(pb.plain_text), 'degree ') > 0
		THEN 1
	WHEN instr(LOWER(pb.plain_text), 'university ') > 0
		THEN 1
	WHEN instr(LOWER(pb.plain_text), 'school ') > 0
		THEN 1
	WHEN instr(LOWER(pb.plain_text), 'college ') > 0
		THEN 1
	ELSE 0
END has_school
,CASE
	WHEN instr(LOWER(pb.plain_text), 'community ' > 0
		THEN 1
	ELSE 0
END has_community
,CASE
	WHEN instr(LOWER(pb.plain_text), 'charity ' > 0
		THEN 1
	WHEN instr(LOWER(pb.plain_text), 'charities ' > 0
		THEN 1
	ELSE 0
END has_charity
,length(pb.plain_text) length_of_bio
,pb.plain_text
FROM src.hist_barrister_professional_bio pb
LIMIT 100;

/* Next steps: combine some variables, e.g. plural, positive words, first/second/third person, etc */