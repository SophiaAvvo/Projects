WITH Ad2 AS (
SELECT a.professional_id
,FirstAdDate
,MAX(LastAdDate) LastAdDate
FROM srcmgd.tmp_professional_dates a
GROUP BY 1,2

)


,

Ad3 AS(

SELECT DISTINCT a1.professional_id
-- ,a1.firstaddate
,CASE WHEN a2.lastaddate BETWEEN a1.firstaddate AND a1.lastaddate THEN to_date(DATE_ADD(a2.lastaddate, 1)) ELSE a1.firstaddate END AdStartDate -- when there's a partially overlapping window, move start date to one day after last end date
,a1.lastaddate AS AdEndDate
,CASE WHEN a2.firstaddate <= a1.firstaddate AND a2.lastaddate > a1.lastaddate THEN 1 -- when exists another interval that forms a superset of the current one, flag row for deletion
ELSE 0
END DeleteFlag
-- ,a2.firstaddate
-- ,a2.lastaddate
FROM ad2 a1
LEFT JOIN ad2 a2
ON a1.professional_id = a2.professional_id
AND (CASE WHEN a1.firstaddate = a2.firstaddate AND a2.lastaddate = a1.lastaddate THEN 1 ELSE 0 END) = 0  -- don't join identical pairs
AND (CASE WHEN a2.firstaddate > a1.firstaddate AND a2.lastaddate <= a1.lastaddate THEN 1 ELSE 0 END) = 0 -- don't join a smaller window to a larger one
AND (CASE WHEN a2.firstaddate > a1.lastaddate THEN 1 ELSE 0 END) = 0 -- don't join when the window fully postdates
AND (CASE WHEN a2.lastaddate < a1.firstaddate THEN 1 ELSE 0 END) = 0 -- don't join when the window is the reverse of consecutive

-- ORDER BY 1,2

)

,

Ad4 AS (

SELECT DISTINCT a.professional_id -- do not add other fields or duplicates will emerge
,d.actual_date AS ad_date
FROM Ad3 a
JOIN dm.date_dim d
ON d.actual_date BETWEEN a.adstartdate AND a.adenddate
AND a.DeleteFlag = 0
)

-- ,

-- Ad5 AS (

CREATE TABLE SR_sparklers_ad_stats_by_day

AS 

SELECT a.professional_id
	,a.ad_date
    ,a3.FirstAdDate
	,COUNT(a2.ad_date) CumulativeAdvDays
FROM Ad4 a
LEFT JOIN ad4 a2
ON a2.professional_id = a.professional_id
AND a2.ad_date < a.ad_date
LEFT JOIN (SELECT professional_id
           ,MIN(ad_date) FirstAdDate
           FROM ad4
           GROUP BY 1
           ) a3
ON a.professional_id = a3.professional_id
GROUP BY 1,2,3
LIMIT 10;
-- )