USE [msdb]
GO

/****** Object:  Job [DBA - WorkLoadAnalysis - Collection]    Script Date: 26.03.2017 23:28:54 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [DBA-Jobs]    Script Date: 26.03.2017 23:28:54 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'DBA-Jobs' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'DBA-Jobs'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - WorkLoadAnalysis - Collection', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'sp_WhoIsActive sp sini kullanarak veritbanındakini işlem activitesine ilişkin bilgiler toplar.', 
		@category_name=N'DBA-Jobs', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Exec SP]    Script Date: 26.03.2017 23:28:55 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Exec SP', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET ANSI_WARNINGS OFF;

declare @now datetime = getdate()
declare @day varchar(6) = convert(varchar(20), @now, 12)
declare @hour varchar(2) = CONVERT(varchar(2), DATEPART(HOUR, @now))
SET @hour = REPLICATE(''0'', 2 - LEN(@hour)) + @hour
declare @tableName varchar(200) = ''WhoIsActive_'' + @day + @hour

IF NOT EXISTS (select * from sys.tables where [name] = @tableName)
BEGIN
	DECLARE @tableScript nvarchar(4000)
	EXEC dbo.sp_WhoIsActive @get_transaction_info = 1, @format_output = 0, @destination_table = @tableName, @return_schema = 1, @schema = @tableScript output
	SET @tableScript = REPLACE(@tableScript, ''<table_name>'', @tableName)

	exec sp_executesql @tableScript
END

EXEC dbo.sp_WhoIsActive @get_transaction_info = 1, @format_output = 0, @destination_table = @tableName;', 
		@database_name=N'DbaTools', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Dba-Her1dk', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20151125, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'8784f3a6-056f-4da4-a20b-5a5a4e707799'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


