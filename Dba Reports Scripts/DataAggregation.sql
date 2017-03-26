declare @now datetime = DATEADD(HOUR, -1, getdate())
declare @day varchar(6) = convert(varchar(20), @now, 12)
declare @hour varchar(2) = CONVERT(varchar(2), DATEPART(HOUR, @now))
SET @hour = REPLICATE('0', 2 - LEN(@hour)) + @hour
declare @tableName varchar(200) = 'WhoIsActive_' + @day + @hour

DECLARE @script nvarchar(4000) =
N'/* Generate Login Dimension */
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
			WHEN ApplicationName like ''LOGO%'' THEN ''LOGO''
			WHEN ApplicationName like ''DatabaseMail%'' THEN ''DatabaseMail''
			WHEN ApplicationName like ''%Management Studio%'' THEN ''SSMS''
			WHEN ApplicationName like ''SQLAgent%'' THEN ''SQLAgent''
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
) as d'

SET @script = REPLACE(@script, '<table_name>', @tableName)

select @tableName
select LEN(@script)
EXEC sp_executesql @script

SET @script = N'; with orderedSessions
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
		, CAST(DATEADD(HOUR, DATEPART(HOUR, collection_time), ''00:00:00'') as time(0)) as CollectionTime 
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
	, CollectionTime'

SET @script = REPLACE(@script, '<table_name>', @tableName)

select @tableName
select LEN(@script)

EXEC sp_executesql @script

SET @script = N'DROP TABLE [DbaTools].[dbo].[' + @tableName + ']'
EXEC sp_executesql @script