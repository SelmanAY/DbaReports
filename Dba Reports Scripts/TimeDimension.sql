;with [counter]
as
(
	select 0 as [x]
	union all
	select c.[x] + 1 from [counter] as c where c.[x] + 1  < 1440
),
[Time]
as
(
	select DATEADD(MINUTE, c.[x], CAST('00:00:00' as time(0))) as Time from [counter] as c
),
TimeDim
as
(	
	SELECT
		d.[Time]
		, DATEPART(HOUR, d.[Time]) as [Hour]
		, CASE WHEN DATEPART(MINUTE, d.[Time]) < 30 THEN 1 ELSE 2 END AS HalfHour
		, (DATEPART(MINUTE, d.[Time]) / 10) + 1 as [TenMinute] 
		, DATEPART(MINUTE, d.[Time]) as [Minute]
		, case 
			when DATEPART(HOUR, d.[Time]) between 0 and 7 then 'Gece' -- Night (between 00:00 and 08:00)
			when DATEPART(HOUR, d.[Time]) between 8 and 16 then 'Mesai' -- WorkHours (between 08:00 and 17:00)
			when DATEPART(HOUR, d.[Time]) between 17 and 23 then 'Aksam' -- Evenning (between 17:00 and 00:00)
		end as DayPart
	FROM
		[Time] as d
)
INSERT INTO [DbaTools].[dbo].[Times] ([Time], [Hour], [HalfHour], [TenMinute], [Minute], [DayPart])
select * 
from TimeDim
option ( MaxRecursion 3000 )