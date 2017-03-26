USE [msdb]
GO

/****** Object:  Job [DBA - WorkLoadAnalysis - Aggregation]    Script Date: 26.03.2017 23:30:13 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBA-Jobs]    Script Date: 26.03.2017 23:30:13 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBA-Jobs' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBA-Jobs'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - WorkLoadAnalysis - Aggregation', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'DBA-Jobs', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'bt operasyon', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Aggregate]    Script Date: 26.03.2017 23:30:13 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Aggregate', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @now datetime = DATEADD(HOUR, -1, getdate())
declare @day varchar(6) = convert(varchar(20), @now, 12)
declare @hour varchar(2) = CONVERT(varchar(2), DATEPART(HOUR, @now))
SET @hour = REPLICATE(''0'', 2 - LEN(@hour)) + @hour
declare @tableName varchar(200) = ''WhoIsActive_'' + @day + @hour

DECLARE @script nvarchar(4000) =
N''/* Generate Login Dimension */
INSERT INTO [DbaTools].[dbo].[Logins] ([LoginName])
(SELECT DISTINCT login_name FROM [DbaTools].[dbo].[<table_name>]
EXCEPT 
SELECT LoginName FROM [DbaTools].[dbo].[Logins])

/* Generate Host Dimension */
INSERT INTO [DbaTools].[dbo].[Hosts] (HostName)
(SELECT DISTINCT [host_name] FROM [DbaTools].[dbo].[<table_name>]
EXCEPT 
SELECT HostName FROM [DbaTools].[dbo].[Hosts])

/* Generate Database Dimension */
INSERT INTO [DbaTools].[dbo].[Databases] (DatabaseName)
(SELECT DISTINCT [database_name] FROM [DbaTools].[dbo].[<table_name>]
EXCEPT 
SELECT DatabaseName FROM [DbaTools].[dbo].[Databases])

/* Generate Application Dimension */
INSERT INTO [DbaTools].[dbo].[Applications] (ApplicationName, [Category])
select ApplicationName, [Category] = CASE 
			WHEN ApplicationName like ''''LOGO%'''' THEN ''''LOGO''''
			WHEN ApplicationName like ''''DatabaseMail%'''' THEN ''''DatabaseMail''''
			WHEN ApplicationName like ''''%Management Studio%'''' THEN ''''SSMS''''
			WHEN ApplicationName like ''''SQLAgent%'''' THEN ''''SQLAgent''''
			ELSE ApplicationName
		END
FROM 
(SELECT DISTINCT [program_name] as ApplicationName FROM [DbaTools].[dbo].[<table_name>]
EXCEPT 
SELECT ApplicationName FROM [DbaTools].[dbo].[Applications]) as a

/* Populate Date Dimension */
INSERT INTO [DbaTools].[dbo].[Dates] ([Date], [Year], [Month], [Day], [WeekOfYear], [WeekOfMonth])
SELECT 
	d.[Date]
	, DATEPART(YEAR, d.[Date]) as [Year]
	, DATEPART(MONTH, d.[Date]) as [Month]
	, DATEPART(DAY, d.[Date]) as [Day]
	, DATEPART(WEEK, d.[Date]) as [WeekOfYear]
	, (datepart(day, datediff(day, 0, d.[Date])/7 * 7)/7 + 1) as [WeekOfMonth] /* http://stackoverflow.com/a/13119920/328648 */ 
FROM (
	select distinct(CAST(collection_time as date)) as [Date] from [DbaTools].[dbo].[<table_name>]
	EXCEPT 
	SELECT [Date] FROM [DbaTools].[dbo].[Dates]
) as d''

SET @script = REPLACE(@script, ''<table_name>'', @tableName)

select @tableName
select LEN(@script)
EXEC sp_executesql @script

SET @script = N''; with orderedSessions
as
(
	select  row_number() OVER(partition by session_id, login_name, [program_name], [host_name], [login_time] order by collection_time desc) as rn
        , login_name
		, l.ID as LoginId
		, CPU
		, tempdb_allocations
		, reads
		, writes
		, physical_reads
		, used_memory
		, host_name
		, h.ID as HostId
		, database_name
		, d.ID as DatabaseId
		, program_name
		, p.ID as ApplicationId
		, login_time
		, request_id
		, collection_time
    from 
		[DbaTools].[dbo].[<table_name>] as w
		inner join [DbaTools].[dbo].[Databases] as d on w.[database_name] = d.DatabaseName
		inner join [DbaTools].[dbo].[Applications] as p on w.[program_name] = p.ApplicationName
		inner join [DbaTools].[dbo].[Hosts] as h on w.[host_name] = h.HostName
		inner join [DbaTools].[dbo].[Logins] as l on w.[login_name] = l.LoginName
),
sessionss 
as 
(
	SELECT 
		LoginId
		, CPU
		, (tempdb_allocations * 8) as tempdb_allocations
		, (reads * 8) as reads
		, (writes * 8) as writes
		, (physical_reads * 8) as physical_reads
		, (used_memory * 8) as used_memory
		, HostId
		, DatabaseId
		, ApplicationId
		, login_time
		, request_id
		, DATEDIFF(SECOND, login_time, collection_time) as Duration
		, CAST(collection_time as date) as CollectionDate
		, CAST(DATEADD(HOUR, DATEPART(HOUR, collection_time), ''''00:00:00'''') as time(0)) as CollectionTime 
	FROM orderedSessions
	where rn = 1
) 
INSERT INTO DbaTools.[dbo].[WorkLoadAnalysis] ([HostId], [ApplicationId], [DatabaseId], [LoginId], [CollectionDate], [CollectionTime], [CPU], [TempDB], [Reads], [Writes], [PhysicalReads], [Memory], [Duration])
select 
	[HostId] 
	, [ApplicationId]  
	, [DatabaseId] 
	, [LoginId]
	, CollectionDate
	, CollectionTime
	, SUM(CPU) AS CPU 
	, SUM(tempdb_allocations) AS TempDB 
	, SUM(reads) AS Reads 
	, SUM(writes) AS Writes 
	, SUM(physical_reads) AS PhysicalReads 
	, SUM(used_memory) AS Memory 
	, SUM(Duration) AS Duration 
from 
	sessionss
group by 
	[HostId] 
	, [ApplicationId]  
	, [DatabaseId] 
	, [LoginId]
	, CollectionDate
	, CollectionTime''

SET @script = REPLACE(@script, ''<table_name>'', @tableName)

select @tableName
select LEN(@script)

EXEC sp_executesql @script

SET @script = N''DROP TABLE [DbaTools].[dbo].['' + @tableName + '']''
EXEC sp_executesql @script', 
		@database_name=N'DbaTools', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Populate Agent Job Details]    Script Date: 26.03.2017 23:30:13 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Populate Agent Job Details', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N';with jobDetails
as
(
select 
	a.*
	, SUBSTRING(a.ApplicationName, CHARINDEX(''0x'', a.ApplicationName), 34) AS job_id_string
	, SUBSTRING(a.ApplicationName, CHARINDEX('': Step '', a.ApplicationName) + 7, CHARINDEX('')'', a.ApplicationName, CHARINDEX('': Step '', a.ApplicationName)) - (CHARINDEX('': Step '', a.ApplicationName) + 7)) AS step_id
from 
	DbaTools.dbo.Applications a
where 
	a.Category = ''SQLAgent''
	and ApplicationName like ''SQLAgent - TSQL JobStep%''
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
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Her1Saat', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170310, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235959, 
		@schedule_uid=N'a7509e40-9dfa-4b89-bcca-10d8365caff6'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


