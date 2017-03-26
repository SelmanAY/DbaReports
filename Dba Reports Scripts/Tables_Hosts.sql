USE [DbaTools]
GO

/****** Object:  Table [dbo].[Hosts]    Script Date: 26.03.2017 23:40:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Hosts](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[HostName] [nvarchar](128) NULL,
	[Type] [varchar](50) NULL,
	[Environment] [varchar](50) NULL,
 CONSTRAINT [PK_HostNames] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


