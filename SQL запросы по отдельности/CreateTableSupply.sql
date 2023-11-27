USE [Task_1]
GO

/****** Object:  Table [dbo].[Supply]    Script Date: 27.11.2023 23:13:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Supply](
	[product_id] [int] NULL,
	[quantity] [int] NOT NULL,
	[date] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Supply] ADD  DEFAULT (getdate()) FOR [date]
GO

ALTER TABLE [dbo].[Supply]  WITH CHECK ADD FOREIGN KEY([product_id])
REFERENCES [dbo].[Products] ([id])
GO

ALTER TABLE [dbo].[Supply]  WITH CHECK ADD CHECK  (([quantity]>(0)))
GO






