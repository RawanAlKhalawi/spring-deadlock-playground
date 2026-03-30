-- SQL Script to Insert 3 Million Records into Product Table (Simple Version)
-- This is a simpler version that uses a straightforward approach
-- Use this if the other versions are too complex

USE deadlock_db;
GO

SET NOCOUNT ON;
GO

PRINT 'Starting simple bulk insert of 3,000,000 products...';
DECLARE @StartTime DATETIME = GETDATE();
DECLARE @Counter INT = 1;
DECLARE @BatchSize INT = 10000;
DECLARE @TotalRecords INT = 3000000;

WHILE @Counter <= @TotalRecords
BEGIN
    BEGIN TRANSACTION;
    
    WITH Numbers AS (
        SELECT TOP (@BatchSize) 
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
        FROM sys.objects o1
        CROSS JOIN sys.objects o2
        CROSS JOIN sys.objects o3
        CROSS JOIN sys.objects o4
    )
    INSERT INTO product (name, quantity, price, version)
    SELECT 
        'Product-' + CAST(@Counter + rn - 1 AS VARCHAR(20)),
        ABS(CHECKSUM(NEWID())) % 1000 + 1,
        CAST((ABS(CHECKSUM(NEWID())) % 9000 + 1000) AS DECIMAL(10,2)) / 100.0,
        0
    FROM Numbers
    WHERE @Counter + rn - 1 <= @TotalRecords;
    
    COMMIT TRANSACTION;
    
    SET @Counter = @Counter + @BatchSize;
    
    -- Progress update every 100,000 records
    IF @Counter % 100000 = 1 OR @Counter > @TotalRecords
    BEGIN
        DECLARE @Elapsed INT = DATEDIFF(SECOND, @StartTime, GETDATE());
        DECLARE @Progress DECIMAL(5,2) = CAST(@Counter * 100.0 / @TotalRecords AS DECIMAL(5,2));
        IF @Progress > 100 SET @Progress = 100;
        PRINT 'Progress: ' + CAST(@Counter AS VARCHAR(20)) + ' records (' + 
              CAST(@Progress AS VARCHAR(10)) + '%) - Elapsed: ' + CAST(@Elapsed AS VARCHAR(10)) + ' seconds';
    END
END

DECLARE @EndTime DATETIME = GETDATE();
DECLARE @TotalTime INT = DATEDIFF(SECOND, @StartTime, @EndTime);
DECLARE @FinalCount INT = (SELECT COUNT(*) FROM product);

PRINT '========================================';
PRINT 'Insert completed!';
PRINT 'Total records in table: ' + CAST(@FinalCount AS VARCHAR(20));
PRINT 'Total time: ' + CAST(@TotalTime AS VARCHAR(10)) + ' seconds';
IF @TotalTime > 0
    PRINT 'Average rate: ' + CAST(CAST(@FinalCount AS DECIMAL) / @TotalTime AS VARCHAR(20)) + ' records/sec';
PRINT '========================================';
GO

SET NOCOUNT OFF;
GO

-- Verify
SELECT COUNT(*) AS TotalProducts FROM product;
GO

