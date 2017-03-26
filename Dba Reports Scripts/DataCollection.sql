SET ANSI_WARNINGS OFF;

declare @now datetime = getdate()
declare @day varchar(6) = convert(varchar(20), @now, 12)
declare @hour varchar(2) = CONVERT(varchar(2), DATEPART(HOUR, @now))
SET @hour = REPLICATE('0', 2 - LEN(@hour)) + @hour
declare @tableName varchar(200) = 'WhoIsActive_' + @day + @hour

IF NOT EXISTS (select * from sys.tables where [name] = @tableName)
BEGIN
	DECLARE @tableScript nvarchar(4000)
	EXEC dbo.sp_WhoIsActive @get_transaction_info = 1, @format_output = 0, @destination_table = @tableName, @return_schema = 1, @schema = @tableScript output
	SET @tableScript = REPLACE(@tableScript, '<table_name>', @tableName)

	exec sp_executesql @tableScript
END

EXEC dbo.sp_WhoIsActive @get_transaction_info = 1, @format_output = 0, @destination_table = @tableName;