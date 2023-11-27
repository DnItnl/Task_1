
GO

/****** Object:  Table [dbo].[Customers]    Script Date: 27.11.2023 23:09:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Customers](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[vip] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Customers] ADD  DEFAULT ((0)) FOR [vip]
GO


GO

/****** Object:  Table [dbo].[Products]    Script Date: 27.11.2023 23:11:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Products](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NOT NULL,
	[stock] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Products] ADD  DEFAULT ((0)) FOR [stock]
GO



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







GO

/****** Object:  Trigger [dbo].[UpdateStockOnSupplyInsert]    Script Date: 27.11.2023 23:15:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[UpdateStockOnSupplyInsert]
ON [dbo].[Supply]
AFTER INSERT
AS
BEGIN
    DECLARE @product_id INT, @quantity INT;

    SELECT @product_id = inserted.product_id, @quantity = inserted.quantity
    FROM inserted;

    UPDATE Products
    SET stock = stock + @quantity
    WHERE id = @product_id;
END;
GO

ALTER TABLE [dbo].[Supply] ENABLE TRIGGER [UpdateStockOnSupplyInsert]
GO



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



GO

/****** Object:  Trigger [dbo].[tStatusUpdate]    Script Date: 27.11.2023 23:17:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[tStatusUpdate]
ON [dbo].[OrderDetails]
AFTER UPDATE
AS
BEGIN
    IF (UPDATE(status))
    BEGIN
        DECLARE @status NVARCHAR(50), @quantity INT, @stock INT;
		
        SELECT @status = i.status, @quantity = i.quantity, @stock = p.stock
        FROM inserted i
        INNER JOIN Products p ON i.product_id = p.id 
		if (@status = 'shipped')
		update Products set stock = stock - @quantity where id in (select Product_id from inserted)

        IF (@status = 'shipped' AND @quantity > @stock - @quantity)
        BEGIN
            RAISERROR ('impossible to change the status to "shipped". The quantity of ordered products exceeds the available in stock.', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
END

GO

ALTER TABLE [dbo].[OrderDetails] ENABLE TRIGGER [tStatusUpdate]
GO



GO

/****** Object:  StoredProcedure [dbo].[pGetOrders]    Script Date: 27.11.2023 23:19:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[pGetOrders]
	@status nvarchar(50) = null
AS
BEGIN
	SET NOCOUNT ON;
	 IF (@status in ('processing', 'shipped', 'delivered', 'cancelled'))
    BEGIN
        select	O.Id,
				C.name Customer, 
				P.name Product, 
				O.quantity order_quantity, 
				P.stock available, 
				O.date,
				case 
					when c.vip = 1 then 'vip'
				else ''
				end vip_status,
				O.status 
		from OrderDetails O 
		join Products P on O.product_id=P.id 
		join Customers C on  O.customer_id=C.id
		where status = @status
		order by vip_status desc, date
    END
    ELSE
    BEGIN
        select	O.Id,
				C.name Customer, 
				P.name Product, 
				O.quantity order_quantity, 
				P.stock available, 
				O.date, 
				case 
					when c.vip = 1 then 'vip'
				else ''
				end vip_status,
				O.status 
		from OrderDetails O 
		join Products P on O.product_id=P.id 
		join Customers C on  O.customer_id=C.id
		order by vip_status desc, date
    END
END
GO



GO

/****** Object:  StoredProcedure [dbo].[pUpdateStatus]    Script Date: 27.11.2023 23:20:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pUpdateStatus] 
	@status nvarchar(50) = null,
	@ids nvarchar(MAX) = null
AS
BEGIN
	
	SET NOCOUNT ON;

	IF (@status in ('processing', 'shipped', 'delivered', 'cancelled'))
	BEGIN
		DECLARE @sql NVARCHAR(MAX);
		SET @sql = N'UPDATE OrderDetails SET status = @status WHERE id IN (' + @ids + ')';
		
		EXEC sp_executesql @sql, N'@status NVARCHAR(50)', @status = @status;
	END
END
GO


