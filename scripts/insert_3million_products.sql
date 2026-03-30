-- SQL Script to Insert 3 Million Records into Product Table
-- This script uses batch inserts for better performance
-- Run this script in SQL Server Management Studio or sqlcmd

USE deadlock_db;
GO

-- Check if table exists and has data
SELECT COUNT(*) AS CurrentProductCount FROM product;
GO

-- Disable indexes temporarily for faster inserts (optional, uncomment if needed)
-- ALTER INDEX ALL ON product DISABLE;
-- GO

PRINT 'Starting bulk insert of 3,000,000 products...';
PRINT 'This may take several minutes depending on your server performance.';
GO

-- Method 1: Using WHILE loop with batch inserts (recommended for SQL Server)
-- This method inserts in batches of 10,000 records to avoid transaction log issues

DECLARE @BatchSize INT = 10000;
DECLARE @TotalRecords INT = 3000000;
DECLARE @CurrentBatch INT = 0;
DECLARE @StartTime DATETIME = GETDATE();

WHILE @CurrentBatch < @TotalRecords
BEGIN
    INSERT INTO product (name, quantity, price, version)
    SELECT 
        'Product-' + CAST((@CurrentBatch + ROW_NUMBER() OVER (ORDER BY (SELECT NULL))) AS VARCHAR(20)),
        ABS(CHECKSUM(NEWID())) % 1000 + 1,  -- Random quantity between 1 and 1000
        CAST((ABS(CHECKSUM(NEWID())) % 9000 + 1000) AS DECIMAL(10,2)) / 100.0,  -- Random price between 10.00 and 99.99
        0  -- Version starts at 0
    FROM (
        SELECT TOP (@BatchSize) 
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
        FROM sys.objects o1
        CROSS JOIN sys.objects o2
        CROSS JOIN sys.objects o3
        CROSS JOIN sys.objects o4
    ) AS x
    WHERE @CurrentBatch + rn <= @TotalRecords;
    
    SET @CurrentBatch = @CurrentBatch + @BatchSize;
    
    -- Progress indicator every 100,000 records
    IF @CurrentBatch % 100000 = 0
    BEGIN
        DECLARE @ElapsedTime INT = DATEDIFF(SECOND, @StartTime, GETDATE());
        DECLARE @RecordsPerSecond DECIMAL(10,2) = CAST(@CurrentBatch AS DECIMAL) / NULLIF(@ElapsedTime, 0);
        PRINT 'Inserted ' + CAST(@CurrentBatch AS VARCHAR(20)) + ' records. Elapsed: ' + 
              CAST(@ElapsedTime AS VARCHAR(10)) + ' seconds. Rate: ' + 
              CAST(@RecordsPerSecond AS VARCHAR(20)) + ' records/sec';
    END
END

DECLARE @EndTime DATETIME = GETDATE();
DECLARE @TotalTime INT = DATEDIFF(SECOND, @StartTime, @EndTime);
DECLARE @FinalCount INT = (SELECT COUNT(*) FROM product);

PRINT '========================================';
PRINT 'Bulk insert completed!';
PRINT 'Total records inserted: ' + CAST(@FinalCount AS VARCHAR(20));
PRINT 'Total time: ' + CAST(@TotalTime AS VARCHAR(10)) + ' seconds';
PRINT 'Average rate: ' + CAST(CAST(@FinalCount AS DECIMAL) / NULLIF(@TotalTime, 0) AS VARCHAR(20)) + ' records/sec';
PRINT '========================================';
GO

-- Re-enable indexes if they were disabled
-- ALTER INDEX ALL ON product REBUILD;
-- GO

-- Verify the insert
SELECT COUNT(*) AS TotalProducts FROM product;
SELECT MIN(id) AS MinId, MAX(id) AS MaxId FROM product;
SELECT TOP 10 * FROM product ORDER BY id DESC;
GO

