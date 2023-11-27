USE [Task_1]
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
		order by date, vip_status desc
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
		order by date, vip_status desc
    END
END
GO


