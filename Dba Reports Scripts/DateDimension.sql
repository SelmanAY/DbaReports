;with [days]
as
(
	select CAST('20170101' as date) as [Date]
	union all
	select DATEADD(DAY, 1, c.[Date]) from [days] as c where DATEADD(DAY, 1, c.[Date]) < '20190101'
)
INSERT INTO [DbaTools].[dbo].[Dates] ([Date], [Year], [Month], [Day], [WeekOfYear], [WeekOfMonth])
SELECT 
	d.[Date]
	, DATEPART(YEAR, d.[Date]) as [Year]
	, DATEPART(MONTH, d.[Date]) as [Month]
	, DATEPART(DAY, d.[Date]) as [Day]
	, DATEPART(WEEK, d.[Date]) as [WeekOfYear]
	, (datepart(day, datediff(day, 0, d.[Date])/7 * 7)/7 + 1) as [WeekOfMonth] /* http://stackoverflow.com/a/13119920/328648 */ 
FROM [days] as d
option ( MaxRecursion 3000 )
