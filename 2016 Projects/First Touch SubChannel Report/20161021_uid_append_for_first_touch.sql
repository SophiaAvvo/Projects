WITH channels AS (

/* First, get all 11 separate channels: traffic, and a flag for whether they hit the channel, as well as the first time they visited through that channel.  
Join condition for further work is PID.  Need to count distinct because session_id will appear many times in weblog.  Doing this with unions because a case statement
would be messy and joins would be inefficient and messy. */

SELECT persistent_session_id
,1 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'Affiliates/Partners' AS Channel
,COUNT(DISTINCT w.session_id) AS Sessions_Affiliate_Partner
,0 AS Sessions_SEM_Brand
,0 AS Sessions_SEM_ALS
,0 AS Sessions_SEM_QA
,0 AS Sessions_Paid_Fb_RU
,0 AS Sessions_Paid_Fb_ALS
,0 AS Sessions_Display_RU_Acq_A
,0 AS Sessions_Display_RU_Acq_R
,0 AS Sessions_Display_ALS_A
,0 AS Sessions_Display_ALS_R
,0 AS Sessions_Taboola
,0 AS Sessions_Email
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-10-15' -- ALS product launch
  AND (LOWER(w.medium) LIKE '%affiliate%' 
  OR LOWER(w.medium) LIKE '%boomerater%' 
	OR LOWER(w.medium) LIKE '%lifecare%'
	)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22,23,24,25,26,27

	
UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,1 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'SEM - Brand' AS Channel
,0 AS Sessions_Affiliate_Partner
,COUNT(DISTINCT w.session_id) AS Sessions_SEM_Brand
,0 AS Sessions_SEM_ALS
,0 AS Sessions_SEM_QA
,0 AS Sessions_Paid_Fb_RU
,0 AS Sessions_Paid_Fb_ALS
,0 AS Sessions_Display_RU_Acq_A
,0 AS Sessions_Display_RU_Acq_R
,0 AS Sessions_Display_ALS_A
,0 AS Sessions_Display_ALS_R
,0 AS Sessions_Taboola
,0 AS Sessions_Email
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-10-15' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%branded_terms%'
		OR LOWER(w.campaign) = 'brand|rlsa%'
		OR LOWER(w.campaign) = 'brand'
	)
	AND LOWER(w.campaign) NOT LIKE "%fb%"
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,17,18,19,20,21,22,23,24,25,26,27

UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,1 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'SEM - ALS' AS Channel
,0 AS Sessions_Affiliate_Partner
,0 AS Sessions_SEM_Brand
,COUNT(DISTINCT w.session_id) AS Sessions_SEM_ALS
,0 AS Sessions_SEM_QA
,0 AS Sessions_Paid_Fb_RU
,0 AS Sessions_Paid_Fb_ALS
,0 AS Sessions_Display_RU_Acq_A
,0 AS Sessions_Display_RU_Acq_R
,0 AS Sessions_Display_ALS_A
,0 AS Sessions_Display_ALS_R
,0 AS Sessions_Taboola
,0 AS Sessions_Email
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-10-15' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%pls|%'
		OR LOWER(w.campaign) = 'pls'
		OR LOWER(w.campaign) = 'plsremarketing'
	)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,25,26,27
	
UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,1 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'SEM - Q&A' AS Channel
,0 AS Sessions_Affiliate_Partner
,0 AS Sessions_SEM_Brand
,0 AS Sessions_SEM_ALS
,COUNT(DISTINCT w.session_id) AS Sessions_SEM_QA
,0 AS Sessions_Paid_Fb_RU
,0 AS Sessions_Paid_Fb_ALS
,0 AS Sessions_Display_RU_Acq_A
,0 AS Sessions_Display_RU_Acq_R
,0 AS Sessions_Display_ALS_A
,0 AS Sessions_Display_ALS_R
,0 AS Sessions_Taboola
,0 AS Sessions_Email
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-10-15' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%legal_q_&_a_search%'
		OR LOWER(w.campaign) LIKE '%legalqa%'
		)
AND LOWER(w.campaign) NOT LIKE '%fb%'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,19,20,21,22,23,24,25,26,27
  


UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,1 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'Paid FB - RU' AS Channel
,0 AS Sessions_Affiliate_Partner
,0 AS Sessions_SEM_Brand
,0 AS Sessions_SEM_ALS
,0 AS Sessions_SEM_QA
,COUNT(DISTINCT w.session_id) AS Sessions_Paid_Fb_RU
,0 AS Sessions_Paid_Fb_ALS
,0 AS Sessions_Display_RU_Acq_A
,0 AS Sessions_Display_RU_Acq_R
,0 AS Sessions_Display_ALS_A
,0 AS Sessions_Display_ALS_R
,0 AS Sessions_Taboola
,0 AS Sessions_Email
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-10-15' -- ALS product launch
  AND (LOWER(w.medium) LIKE '%cpc%' 
	OR LOWER(w.medium) LIKE '%cpm%')	
  AND (LOWER(campaign) LIKE '%fb_%' 
	OR LOWER(campaign) LIKE '%acq%'
		)
  AND LOWER(w.source) NOT LIKE '%google%'		
  AND LOWER(w.campaign) NOT LIKE '%2016brandvideos_t_acq%'
  AND LOWER(w.campaign) NOT LIKE '%fb_boosted%'
  AND LOWER(w.campaign) NOT LIKE '%lawyer%'
  AND LOWER(w.campaign) NOT LIKE '%pokemon%'
  AND LOWER(w.campaign) NOT LIKE '%eng_%'
  AND LOWER(w.campaign) NOT LIKE '%pls%'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,20,21,22,23,24,25,26,27
  
 UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,1 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'Paid FB - ALS' AS Channel
,0 AS Sessions_Affiliate_Partner
,0 AS Sessions_SEM_Brand
,0 AS Sessions_SEM_ALS
,0 AS Sessions_SEM_QA
,0 AS Sessions_Paid_Fb_RU
,COUNT(DISTINCT w.session_id) AS Sessions_Paid_Fb_ALS
,0 AS Sessions_Display_RU_Acq_A
,0 AS Sessions_Display_RU_Acq_R
,0 AS Sessions_Display_ALS_A
,0 AS Sessions_Display_ALS_R
,0 AS Sessions_Taboola
,0 AS Sessions_Email
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-10-15' -- ALS product launch
  AND (LOWER(w.medium) LIKE '%cpc%' 
	OR LOWER(w.medium) LIKE '%cpm%')	
  AND (LOWER(campaign) LIKE '%pls_avvofb%'
	OR LOWER(campaign) LIKE '%pls_fb%'
	OR LOWER(campaign) LIKE '%pls_fbb%'
		)
  AND LOWER(w.source) NOT LIKE '%google%'		
  AND LOWER(w.campaign) NOT LIKE '%2016brandvideos_t_acq%'
  AND LOWER(w.campaign) NOT LIKE '%fbz_boosted%'
  AND LOWER(w.campaign) NOT LIKE '%lawyer%'
  AND LOWER(w.campaign) NOT LIKE '%pokemon%'
  AND LOWER(w.campaign) NOT LIKE '%eng_%'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,21,22,23,24,25,26,27
 
 UNION
 
 SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,1 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email 
,'Display_RU_Acq' AS Channel
,0 AS Sessions_Affiliate_Partner
,0 AS Sessions_SEM_Brand
,0 AS Sessions_SEM_ALS
,0 AS Sessions_SEM_QA
,0 AS Sessions_Paid_Fb_RU
,0 AS Sessions_Paid_Fb_ALS
,COUNT(DISTINCT w.session_id) AS Sessions_Display_RU_Acq_A
,0 AS Sessions_Display_RU_Acq_R
,0 AS Sessions_Display_ALS_A
,0 AS Sessions_Display_ALS_R
,0 AS Sessions_Taboola
,0 AS Sessions_Email
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-10-15' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%pls_%'
	OR LOWER(w.campaign) LIKE '%acq%')
	AND (LOWER(w.campaign) LIKE '%qa%'
		OR LOWER(w.campaign) LIKE '%lifecycle%'
		OR LOWER(w.campaign) LIKE '%form%'
		)
	AND LOWER(w.campaign) NOT LIKE '%fb%'
	AND LOWER(w.campaign) NOT LIKE '%_ret%'
-- note no traffic yet for forms or lifecycle
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27
  
UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,1 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'Display_RU_Ret' AS Channel
,0 AS Sessions_Affiliate_Partner
,0 AS Sessions_SEM_Brand
,0 AS Sessions_SEM_ALS
,0 AS Sessions_SEM_QA
,0 AS Sessions_Paid_Fb_RU
,0 AS Sessions_Paid_Fb_ALS
,0 AS Sessions_Display_RU_Acq_A
,COUNT(DISTINCT w.session_id) AS Sessions_Display_RU_Acq_R
,0 AS Sessions_Display_ALS_A
,0 AS Sessions_Display_ALS_R
,0 AS Sessions_Taboola
,0 AS Sessions_Email
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-10-15' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%pls_%'
	OR LOWER(w.campaign) LIKE '%_ret%')
	AND (LOWER(w.campaign) LIKE '%qa%'
		OR LOWER(w.campaign) LIKE '%lifecycle%'
		OR LOWER(w.campaign) LIKE '%form%'
		)
	AND LOWER(w.campaign) NOT LIKE '%fb%'
	AND LOWER(w.campaign) NOT LIKE '%acq%'
--note no traffic yet for forms or lifecycle
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,23,24,25,26,27

UNION

 SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,1 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email 
,'Display_ALS_Acq' AS channel
,0 AS Sessions_Affiliate_Partner
,0 AS Sessions_SEM_Brand
,0 AS Sessions_SEM_ALS
,0 AS Sessions_SEM_QA
,0 AS Sessions_Paid_Fb_RU
,0 AS Sessions_Paid_Fb_ALS
,0 AS Sessions_Display_RU_Acq_A
,0 AS Sessions_Display_RU_Acq_R
,COUNT(DISTINCT w.session_id) AS Sessions_Display_ALS_A
,0 AS Sessions_Display_ALS_R
,0 AS Sessions_Taboola
,0 AS Sessions_Email
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-10-15' -- ALS product launch
  AND LOWER(w.campaign) LIKE '%pls_%'
  AND (LOWER(w.campaign) LIKE '%_acq%'
	OR LOWER(w.campaign) LIKE '%acquisition%'
	OR LOWER(w.campaign) LIKE '%lookalike%')
	AND LOWER(w.campaign) NOT LIKE '%qa%'
	AND LOWER(w.campaign) NOT LIKE '%lifecycle%'
	AND LOWER(w.campaign) NOT LIKE '%form%'
	AND LOWER(w.campaign) NOT LIKE '%fb%'
-- note no traffic yet for forms or lifecycle
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,24,25,26,27
  
UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,1 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'Display_ALS_Ret' AS channel
,0 AS Sessions_Affiliate_Partner
,0 AS Sessions_SEM_Brand
,0 AS Sessions_SEM_ALS
,0 AS Sessions_SEM_QA
,0 AS Sessions_Paid_Fb_RU
,0 AS Sessions_Paid_Fb_ALS
,0 AS Sessions_Display_RU_Acq_A
,0 AS Sessions_Display_RU_Acq_R
,0 AS Sessions_Display_ALS_A
,COUNT(DISTINCT w.session_id) AS Sessions_Display_ALS_R
,0 AS Sessions_Taboola
,0 AS Sessions_Email
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-10-15' -- ALS product launch
  AND (LOWER(w.campaign) LIKE '%pls_%'
	OR LOWER(w.campaign) LIKE '%_abandoners%')
  AND LOWER(w.campaign) NOT LIKE '%_acq%'
	AND LOWER(w.campaign) NOT LIKE '%acquisition%'
	AND LOWER(w.campaign) NOT LIKE '%lookalike%'
	AND LOWER(w.campaign) NOT LIKE '%qa%'
	AND LOWER(w.campaign) NOT LIKE '%lifecycle%'
	AND LOWER(w.campaign) NOT LIKE '%form%'
	AND LOWER(w.campaign) NOT LIKE '%fb%'
	AND LOWER(w.source) NOT LIKE '%taboola%'
--note no traffic yet for forms or lifecycle
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27

UNION
 
SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,1 AS Is_Taboola
,0 AS Is_Email
,'Taboola' AS Channel
,0 AS Sessions_Affiliate_Partner
,0 AS Sessions_SEM_Brand
,0 AS Sessions_SEM_ALS
,0 AS Sessions_SEM_QA
,0 AS Sessions_Paid_Fb_RU
,0 AS Sessions_Paid_Fb_ALS
,0 AS Sessions_Display_RU_Acq_A
,0 AS Sessions_Display_RU_Acq_R
,0 AS Sessions_Display_ALS_A
,0 AS Sessions_Display_ALS_R
,COUNT(DISTINCT w.session_id) AS Sessions_Taboola
,0 AS Sessions_Email
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-04-24'
  AND w.source = 'taboola'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,26,27

UNION

SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,1 AS Is_Email
,'Email' AS Channel
,0 AS Sessions_Affiliate_Partner
,0 AS Sessions_SEM_Brand
,0 AS Sessions_SEM_ALS
,0 AS Sessions_SEM_QA
,0 AS Sessions_Paid_Fb_RU
,0 AS Sessions_Paid_Fb_ALS
,0 AS Sessions_Display_RU_Acq_A
,0 AS Sessions_Display_RU_Acq_R
,0 AS Sessions_Display_ALS_A
,0 AS Sessions_Display_ALS_R
,0 AS Sessions_Taboola
,COUNT(DISTINCT w.session_id) AS Sessions_Email
,1 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE w.event_date >= '2016-10-15' -- ALS product launch
  AND LOWER(w.medium) LIKE '%email%' 
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,27
)

/* Now we get the user_ids associated with each persistent session ID.  
We use a MAX() on the resolved_user_id to account for the rare possibility
that a user might have more than one account, and also for cases where the
user_id was not appended successfully to that PID.  */

, traffic AS (

SELECT t.persistent_session_id
	,MAX(t.resolved_user_id) AS user_id
	,COUNT(DISTINCT t.session_id) total_sessions
FROM dm.traffic t
WHERE t.event_date >= '2016-10-15'
--AND t.resolved_user_id IS NOT NULL
GROUP BY t.persistent_session_id
)

/* Now we create the self-join that allows us to append the correct user_id to each PID.
We create a "visitor id" to group by: if there is a valid user ID, then we group by that so that all affiliated PIDs can be rolled up under one user.
If there isn't a valid user ID, then we use the PID as our placeholder.  The important thing is that it's distinct for each profile and maximizes
the merge of single-user data to the best of our ability.  This could have been done in a later step, 
but doing it here makes the view cleaner and easier to test. This has been tested for duplicates and there are none showing.  */

,UID_add AS (
SELECT DISTINCT t.persistent_session_id
,CASE
	WHEN t2.user_id IS NULL
		THEN t.persistent_session_id
	ELSE t2.user_id
END AS visitor_id
,CASE
	WHEN t.user_id IS NULL
		THEN 1
	ELSE 0
END Is_RU
,t.total_sessions
-- ,MIN(event_date) min_date
FROM (SELECT DISTINCT persistent_session_id
		FROM channels
			) ch
	JOIN traffic t
		ON t.persistent_session_id = ch.persistent_session_id
	LEFT JOIN traffic t2
		ON t.user_id = t2.user_id
		
)

/* Now we look at *all* sessions, and since this is huge, we use UID_add to filter weblog so it
doesn't get too overwhelmed.  We're getting the first time that each PID visited for all sessions, 
regardless of whether they are associated with our defined channels.  If a user visited through e.g. 
direct at an earlier date than they hit any of our 11 channels, we will grab that timestamp.  If not,
then we will get a timestamp that's identical to one we're already pulling.  We'll deal with that case
later; for now, we call all these results "Other" because if we keep them, that's what they'll be. */

,first_visit AS (
SELECT persistent_session_id
,0 AS Is_Affiliate_Partner
,0 AS Is_SEM_Brand
,0 AS Is_SEM_ALS
,0 AS Is_SEM_QA
,0 AS Is_Paid_Fb_RU
,0 AS Is_Paid_Fb_ALS
,0 AS Is_Display_RU_Acq_A
,0 AS Is_Display_RU_Acq_R
,0 AS Is_Display_ALS_A
,0 AS Is_Display_ALS_R
,0 AS Is_Taboola
,0 AS Is_Email
,'Other' AS Channel
,0 AS Sessions_Affiliate_Partner
,0 AS Sessions_SEM_Brand
,0 AS Sessions_SEM_ALS
,0 AS Sessions_SEM_QA
,0 AS Sessions_Paid_Fb_RU
,0 AS Sessions_Paid_Fb_ALS
,0 AS Sessions_Display_RU_Acq_A
,0 AS Sessions_Display_RU_Acq_R
,0 AS Sessions_Display_ALS_A
,0 AS Sessions_Display_ALS_R
,0 AS Sessions_Taboola
,0 AS Sessions_Email
,2 AS Precedence
,MIN(w.`timestamp`) AS first_visit_timestamp
FROM src.weblog w
WHERE persistent_session_id IN (SELECT DISTINCT persistent_session_id FROM UID_add)
AND w.event_date >= '2016-10-15'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27

)

/*This is the big step.  Here we're unioning the channel data with the "other" data, and then
appending the visitor_id.  We now have PID and visitor_id side by side, so we can join/group with 
either one as we need to.  We use partitions to get our flags and sessions by visitor_id rather than
being limited to PID as our grouping.  Same goes for the first visit; we want that according to visitor_id.
Our last couple fields give a ranking to each row based on whether it's the first visit for that PID, or the
first visit for that visitor_id.  This allows us to deduplicate the results when joining them later, depending
on what we're joining on.  CHannel_order is for the final step of joining on visitor_id.  PID_order is so that
we can join with ALS purchase data, which is by PID.  We use our "precedence" field to ensure that if an identified
channel visit has the same timestamp as the first in our "Other" catch-all, "other" is always moved to the
bottom */

,channel_sort AS (
SELECT c.persistent_session_id
,ua.visitor_id
,ua.Is_RU
,SUM(ua.total_sessions) OVER(PARTITION BY ua.visitor_id) AS total_sessions
,c.Channel 
,SUM(c.Is_Affiliate_Partner) OVER(PARTITION BY ua.visitor_id) Is_Affiliate_Partner
,SUM(c.Is_SEM_Brand) OVER(PARTITION BY ua.visitor_id) Is_SEM_Brand
,SUM(c.Is_SEM_ALS) OVER(PARTITION BY ua.visitor_id) Is_SEM_ALS
,SUM(c.Is_SEM_QA) OVER(PARTITION BY ua.visitor_id) Is_SEM_QA
,SUM(c.Is_Paid_Fb_RU) OVER(PARTITION BY ua.visitor_id) Is_Paid_Fb_RU
,SUM(c.Is_Paid_Fb_ALS) OVER(PARTITION BY ua.visitor_id) Is_Paid_Fb_ALS
,SUM(c.Is_Display_RU_Acq_A) OVER(PARTITION BY ua.visitor_id) Is_Display_RU_Acq_A
,SUM(c.Is_Display_RU_Acq_R) OVER(PARTITION BY ua.visitor_id) Is_Display_RU_Acq_R
,SUM(c.Is_Display_ALS_A) OVER(PARTITION BY ua.visitor_id) Is_Display_ALS_A 
,SUM(c.Is_Display_ALS_R) OVER(PARTITION BY ua.visitor_id) Is_Display_ALS_R
,SUM(c.Is_Taboola) OVER(PARTITION BY ua.visitor_id) Is_Taboola
,SUM(c.Is_Email) OVER(PARTITION BY ua.visitor_id) Is_Email
,c.first_visit_timestamp
,SUM(c.Sessions_Affiliate_Partner) OVER(PARTITION BY ua.visitor_id) Sessions_Affiliate_Partner
,SUM(c.Sessions_SEM_Brand) OVER(PARTITION BY ua.visitor_id) Sessions_SEM_Brand
,SUM(c.Sessions_SEM_ALS) OVER(PARTITION BY ua.visitor_id) Sessions_SEM_ALS
,SUM(c.Sessions_SEM_QA) OVER(PARTITION BY ua.visitor_id) Sessions_SEM_QA
,SUM(c.Sessions_Paid_Fb_RU) OVER(PARTITION BY ua.visitor_id) Sessions_Paid_Fb_RU
,SUM(c.Sessions_Paid_Fb_ALS) OVER(PARTITION BY ua.visitor_id) Sessions_Paid_Fb_ALS
,SUM(c.Sessions_Display_RU_Acq_A) OVER(PARTITION BY ua.visitor_id) Sessions_Display_RU_Acq_A
,SUM(c.Sessions_Display_RU_Acq_R) OVER(PARTITION BY ua.visitor_id) Sessions_Display_RU_Acq_R
,SUM(c.Sessions_Display_ALS_A) OVER(PARTITION BY ua.visitor_id) Sessions_Display_ALS_A 
,SUM(c.Sessions_Display_ALS_R) OVER(PARTITION BY ua.visitor_id) Sessions_Display_ALS_R
,SUM(c.Sessions_Taboola) OVER(PARTITION BY ua.visitor_id) Sessions_Taboola
,SUM(c.Sessions_Email) OVER(PARTITION BY ua.visitor_id) Sessions_Email
,MIN(c.first_visit_timestamp) OVER(PARTITION BY ua.visitor_id) initial_visit_timestamp
,ROW_NUMBER() OVER(PARTITION BY ua.visitor_id ORDER BY c.first_visit_timestamp, c.Precedence) Channel_Order
,ROW_NUMBER() OVER(PARTITION BY c.persistent_session_id ORDER BY c.first_visit_timestamp, c.Precedence) PID_Order
FROM (SELECT *
		FROM channels ch
		
		UNION
		
		SELECT *
		FROM 
		first_visit fv
	)c
	JOIN UID_add ua
		ON ua.persistent_session_id = c.persistent_session_Id
)

/* Now we get transactions.  It's important to leave time out of the query results, and to use DISTINCT,
because there is some duplication in the order_ids that's likely due to page reloads.  These order_ids allow
us to bring in other data */

,als_transactions AS (
	select DISTINCT persistent_session_id
		,regexp_extract(url, 'thank_you\/([0-9]+)', 1) as order_id
	from src.page_view 
	where page_type IN ('LS-Thankyou', 'Advisor-thankyou')
	and event_date >= '2016-10-15'
  
)

/* here we use PID to join to the als_transactions off the channel data, using our ranking number to make sure we only
get one row per PID.  We then *group* by the visitor_id, since that's what we'll be ultimately using as our identifier.  
We get a PID count, making sure to count DISTINCT so that we don't get a duplicate PID for cases of multiple user purchases. */


, als_add AS (SELECT fv.visitor_id
,COUNT(DISTINCT fv.persistent_session_id) AS PID_count
,AVG(CASE
		WHEN fv.initial_visit_timestamp < oas.created_at
			THEN DATEDIFF(oas.created_at, fv.initial_visit_timestamp)
		ELSE NULL
	END) avg_days_to_purchase_all
,AVG(CASE 
		WHEN op.name LIKE '%advice session%' AND fv.initial_visit_timestamp < oas.created_at
			THEN DATEDIFF(oas.created_at, fv.initial_visit_timestamp)
		ELSE NULL
	END) avg_days_to_purchase_advisor
,AVG(CASE 
		WHEN op.name LIKE '%review%' AND fv.initial_visit_timestamp < oas.created_at
			THEN DATEDIFF(oas.created_at, fv.initial_visit_timestamp)
		ELSE NULL
	END) avg_days_to_purchase_doc_review
,AVG(CASE 
		WHEN op.name LIKE '%review%'
			THEN NULL
		WHEN op.name LIKE '%advice session%'
			THEN NULL
		WHEN fv.initial_visit_timestamp >= oas.created_at
			THEN NULL
		ELSE DATEDIFF(oas.created_at, fv.initial_visit_timestamp)
	END) avg_days_to_purchase_offline
,SUM(CASE 
		WHEN op.name LIKE '%advice session%' AND fv.initial_visit_timestamp < oas.created_at
			THEN 1
		ELSE 0
	END) Advice_Purchases
,SUM(CASE 
		WHEN op.name LIKE '%review%' AND fv.initial_visit_timestamp < oas.created_at
			THEN 1
		ELSE 0
	END) Doc_Review_Purchases
,SUM(CASE 
		WHEN op.name LIKE '%review%'
			THEN 0
		WHEN op.name LIKE '%advice session%'
			THEN 0
		WHEN op.name IS NOT NULL AND fv.initial_visit_timestamp < oas.created_at
			THEN 1
		ELSE 0
	END) Other_Offline_Purchases
,MIN(oas.created_at) First_Purchase_Date
,MAX(oas.created_at) Last_Purchase_Date
,COUNT(CASE
		WHEN fv.initial_visit_timestamp < oas.created_at
			THEN als.order_id
		ELSE NULL
		END) Total_Purchases
,COUNT(CASE
		WHEN fv.initial_visit_timestamp >= oas.created_at
			THEN als.order_id
		ELSE NULL
		END) Pre_Channel_Touch_Purchases
FROM channel_sort fv
JOIN als_transactions als
	ON als.persistent_session_id = fv.persistent_session_id
	AND fv.PID_Order = 1
left join src.ocato_advice_sessions oas 
	on cast(als.order_id as INT) = oas.id 
-- note that ocato advice sessions created_at is within a few seconds of src.page_view timestamp, and I think it might be more reliable anyway
left join src.ocato_offers oo 
	on oas.offer_id = oo.id 
left join src.ocato_packages op 
	on oo.package_id = op.id
GROUP BY fv.visitor_id

)

/*In the last step, we join our original channel_count table to our als_transactions table on *visitor_id*.  Both tables
have this id now, so we can easily group without having to re-aggregate any of the data.  We slice by Channel_Order, since that's the thing
that lets us eliminate duplicates according to visitor_id.  In joining to weblog to get additional channel information (which we didn't bring in
earlier since it might have created duplication), we demand that weblog only give us results based on the exact timestamp that we identified
as the first-touch visit.  We also restrict the page type.  This ensures that we will only get one result per visitor_id from weblog, although we still
test this to make sure it's working properly.  Note that the logic */

SELECT fv.visitor_id
,fv.first_visit_timestamp
,fv.Channel 
,fv.Is_RU
,fv.total_sessions
,fv.Is_Affiliate_Partner
,fv.Is_SEM_Brand
,fv.Is_SEM_ALS
,fv.Is_SEM_QA
,fv.Is_Paid_Fb_RU
,fv.Is_Paid_Fb_ALS
,fv.Is_Display_RU_Acq_A
,fv.Is_Display_RU_Acq_R
,fv.Is_Display_ALS_A 
,fv.Is_Display_ALS_R
,fv.Is_Taboola
,fv.Is_Email
,fv.Channel_Order
,fv.Sessions_Affiliate_Partner
,fv.Sessions_SEM_Brand
,fv.Sessions_SEM_ALS
,fv.Sessions_SEM_QA
,fv.Sessions_Paid_Fb_RU
,fv.Sessions_Paid_Fb_ALS
,fv.Sessions_Display_RU_Acq_A
,fv.Sessions_Display_RU_Acq_R
,fv.Sessions_Display_ALS_A
,fv.Sessions_Display_ALS_R
,fv.Sessions_Taboola
,fv.Sessions_Email
,CASE
	WHEN LOWER(w.referrer) LIKE '%facebook%'
	AND w.url LIKE '%logged_in=true%'
		THEN 1
	ELSE 0
END IsFacebookSignIn
,CASE
	WHEN w.source LIKE '%facebook%' 
	AND w.campaign IS NULL -- in GA it's "not set"; in Hadoop it's NULL
		THEN 'Unpaid Facebook'
	ELSE 'Paid Facebook'
END IsPaidFB
,w.campaign
,w.source
,w.medium
,w.event_date
,fv.total_sessions AS Session_Count
,als.PID_Count
,avg_days_to_purchase_all
,avg_days_to_purchase_advisor
,avg_days_to_purchase_doc_review
,avg_days_to_purchase_offline
,Advice_Purchases
,Doc_Review_Purchases
,Other_Offline_Purchases
,First_Purchase_Date
,Last_Purchase_Date
,Total_Purchases
,Pre_Channel_Touch_Purchases
FROM src.weblog w
JOIN channel_sort fv
	ON fv.persistent_session_id = w.persistent_session_id
	AND w.`timestamp` = fv.first_visit_timestamp
	AND fv.Channel_Order = 1
	AND w.event_type IN('page_view', 'service_session_payment')
LEFT JOIN als_add als
	ON als.visitor_id = fv.visitor_id
/* need to bring in session counts with partitions
