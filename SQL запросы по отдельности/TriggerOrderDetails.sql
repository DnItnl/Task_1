USE [Task_1]
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


