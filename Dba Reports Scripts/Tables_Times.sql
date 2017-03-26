USE [DbaTools]
GO

/****** Object:  Table [dbo].[Times]    Script Date: 26.03.2017 23:40:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Times](
	[Time] [time](0) NOT NULL,
	[Hour] [int] NULL,
	[HalfHour] [int] NULL,
	[TenMinute] [int] NULL,
	[Minute] [int] NULL,
	[DayPart] [varchar](5) NULL,
 CONSTRAINT [PK_Times] PRIMARY KEY CLUSTERED 
(
	[Time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO


