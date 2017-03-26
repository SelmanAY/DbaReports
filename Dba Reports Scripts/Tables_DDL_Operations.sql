USE [bankaccst]
GO

/****** Object:  Table [dbo].[DDL_Operations]    Script Date: 26.03.2017 23:52:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DDL_Operations](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[HostName] [nvarchar](128) NULL,
	[AppName] [nvarchar](128) NULL,
	[EventType] [varchar](128) NULL,
	[PostTime] [datetime] NULL,
	[SPID] [int] NULL,
	[ServerName] [varchar](128) NULL,
	[LoginName] [varchar](128) NULL,
	[UserName] [varchar](128) NULL,
	[DatabaseName] [varchar](128) NULL,
	[SchemaName] [varchar](128) NULL,
	[ObjectName] [varchar](128) NULL,
	[ObjectType] [varchar](128) NULL,
	[AnsiNulls] [varchar](5) NULL,
	[AnsiNullDefault] [varchar](5) NULL,
	[AnsiPadding] [varchar](5) NULL,
	[QuotedIdentifier] [varchar](5) NULL,
	[Encrypted] [varchar](5) NULL,
	[CommandText] [nvarchar](max) NULL,
	[SourceState] [int] NOT NULL,
 CONSTRAINT [PK_DDL_Operations] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[DDL_Operations] ADD  DEFAULT ((0)) FOR [SourceState]
GO


