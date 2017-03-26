USE [DbaTools]
GO

/****** Object:  Table [dbo].[Applications]    Script Date: 26.03.2017 23:40:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Applications](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[ApplicationName] [nvarchar](128) NULL,
	[Category] [nvarchar](128) NULL,
	[SqlAgent_JobCategoryName] [nvarchar](128) NULL,
	[SqlAgent_JobName] [nvarchar](128) NULL,
	[SqlAgent_JobStepName] [nvarchar](128) NULL,
 CONSTRAINT [PK_ApplicationNames] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


