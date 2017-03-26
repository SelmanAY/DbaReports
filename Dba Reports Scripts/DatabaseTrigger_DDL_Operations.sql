USE [bankaccst]
GO

/****** Object:  DdlTrigger [DatabaseDDLTrigger]    Script Date: 26.03.2017 23:52:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [DatabaseDDLTrigger]
ON DATABASE
FOR 
    CREATE_FUNCTION, ALTER_FUNCTION, DROP_FUNCTION, CREATE_INDEX, ALTER_INDEX, DROP_INDEX, CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE, CREATE_SCHEMA, ALTER_SCHEMA, DROP_SCHEMA, CREATE_TABLE, ALTER_TABLE, DROP_TABLE, CREATE_TRIGGER, ALTER_TRIGGER, DROP_TRIGGER, CREATE_VIEW, ALTER_VIEW, DROP_VIEW
As
BEGIN
    set nocount on 

    DECLARE @data xml = EVENTDATA()
    DECLARE @hostname nvarchar(128) = HOST_NAME()
    DECLARE @appName nvarchar(128) = APP_NAME()

    INSERT INTO dbo.DDL_Operations (HostName, AppName, EventType, PostTime, SPID, ServerName, LoginName, UserName, DatabaseName, SchemaName, ObjectName, ObjectType, AnsiNulls, AnsiNullDefault, AnsiPadding, QuotedIdentifier, Encrypted, CommandText) 
    VALUES (
	   @hostname
	   , @appName
	   , @data.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(128)')
	   , @data.value('(/EVENT_INSTANCE/PostTime)[1]', 'datetime')
	   , @data.value('(/EVENT_INSTANCE/SPID)[1]', 'int')
	   , @data.value('(/EVENT_INSTANCE/ServerName)[1]', 'varchar(256)')
	   , @data.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(256)')
	   , @data.value('(/EVENT_INSTANCE/UserName)[1]', 'varchar(256)')
	   , @data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(256)')
	   , @data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'varchar(256)')
	   , @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(256)')
	   , @data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(256)')
	   , @data.value('(/EVENT_INSTANCE/TSQLCommand/SetOptions/@ANSI_NULLS)[1]', 'varchar(5)')
	   , @data.value('(/EVENT_INSTANCE/TSQLCommand/SetOptions/@ANSI_NULL_DEFAULT)[1]', 'varchar(5)')
	   , @data.value('(/EVENT_INSTANCE/TSQLCommand/SetOptions/@ANSI_PADDING)[1]', 'varchar(5)')
	   , @data.value('(/EVENT_INSTANCE/TSQLCommand/SetOptions/@QUOTED_IDENTIFIER)[1]', 'varchar(5)')
	   , @data.value('(/EVENT_INSTANCE/TSQLCommand/SetOptions/@ENCRYPTED)[1]', 'varchar(5)')
	   , @data.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'nvarchar(max)') )
END

GO

ENABLE TRIGGER [DatabaseDDLTrigger] ON DATABASE
GO


