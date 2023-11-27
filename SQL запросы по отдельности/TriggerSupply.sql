USE [Task_1]
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


