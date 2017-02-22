select dt.year_month
,ci.event_date -- day of email
					, ci.professional_id -- lawyer identifier
                  ,persistent_session_id -- tied to the cookie
                  ,`timestamp` -- so that you can see how the repeats are stacked in time
                  ,session_id -- this resets every 30 minutes or if the session is interrupted
					--, count(DISTINCT CONCAT(ci.persistent_session_id, CAST(ci.event_date AS VARCHAR))) as emailers_by_day -- concatenation is useful if you're e.g. aggregating by month
					--, COUNT(ci.session_id) AS all_email_contacts -- this counts every single email, regardless of whether the same user e.g. double-sent it
				from src.contact_impression ci
				  join DM.DATE_DIM d  -- easiest way to get date info like year_month
				    on d.actual_date = ci.event_date
				  join (
					       select distinct d.year_month     
					       from DM.DATE_DIM d
					       where d.actual_date >= '2016-05-01' -- data begins in very late April 2015, so I generally start in May 2015
							   and d.actual_date <= '2016-05-31'
					     ) dt 
					    on dt.year_month = d.year_month
				where ci.contact_type = 'email' -- you can also set this to website visit or phone call
                AND persistent_session_id = '005e5222-79fc-4985-883e-6dd5d302cc9a' -- example of repeat email; get rid of this if you want to generalize
				-- group by 1,2
                ORDER BY persistent_session_id -- order by is just for the purpose of this example
                ,session_id
                ,professional_id