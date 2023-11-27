USE [Task_1]
GO

/****** Object:  Table [dbo].[OrderDetails]    Script Date: 27.11.2023 23:16:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[OrderDetails](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[customer_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[quantity] [int] NOT NULL,
	[date] [datetime] NOT NULL,
	[status] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[OrderDetails] ADD  DEFAULT ((0)) FOR [quantity]
GO

ALTER TABLE [dbo].[OrderDetails] ADD  DEFAULT (getdate()) FOR [date]
GO

ALTER TABLE [dbo].[OrderDetails] ADD  DEFAULT ('processing') FOR [status]
GO

ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [fk_customer_id] FOREIGN KEY([customer_id])
REFERENCES [dbo].[Customers] ([id])
GO

ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [fk_customer_id]
GO

ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [fk_product_id] FOREIGN KEY([product_id])
REFERENCES [dbo].[Products] ([id])
GO

ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [fk_product_id]
GO

ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD CHECK  (([status]='cancelled' OR [status]='delivered' OR [status]='shipped' OR [status]='processing'))
GO


