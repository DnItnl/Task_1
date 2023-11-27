USE [Task_1]
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

    -- Insert statements for procedure here
	IF (@status in ('processing', 'shipped', 'delivered', 'cancelled'))
	BEGIN
		DECLARE @sql NVARCHAR(MAX);
		SET @sql = N'UPDATE OrderDetails SET status = @status WHERE id IN (' + @ids + ')';
		
		EXEC sp_executesql @sql, N'@status NVARCHAR(50)', @status = @status;
	END
END
GO


