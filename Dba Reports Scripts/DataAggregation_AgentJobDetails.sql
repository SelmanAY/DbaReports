;with jobDetails
as
(
select 
	a.*
	, SUBSTRING(a.ApplicationName, CHARINDEX('0x', a.ApplicationName), 34) AS job_id_string
	, SUBSTRING(a.ApplicationName, CHARINDEX(': Step ', a.ApplicationName) + 7, CHARINDEX(')', a.ApplicationName, CHARINDEX(': Step ', a.ApplicationName)) - (CHARINDEX(': Step ', a.ApplicationName) + 7)) AS step_id
from 
	DbaTools.dbo.Applications a
where 
	a.Category = 'SQLAgent'
	and ApplicationName like 'SQLAgent - TSQL JobStep%'
	AND
	(
		[SqlAgent_JobCategoryName] IS NULL
		OR [SqlAgent_JobName] IS NULL
		OR [SqlAgent_JobStepName] IS NULL
	)
)
update jd
SET
	jd.[SqlAgent_JobCategoryName] = jc.name
	, jd.[SqlAgent_JobName] = j.name
	, jd.[SqlAgent_JobStepName] = js.step_name 
from jobDetails as jd
	left join msdb.dbo.sysjobs_view j on jd.job_id_string = CONVERT(varchar(36), CONVERT(varbinary(200), j.job_id), 1)
	left join msdb.dbo.syscategories as jc on j.category_id = jc.category_id
	left join msdb.dbo.sysjobsteps js on j.job_id = js.job_id and js.step_id = jd.step_id
