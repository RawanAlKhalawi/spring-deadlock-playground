-- SQL Script to Insert 3 Million Records into Product Table (Optimized Version)
-- This version uses a more efficient approach with CTEs and cross joins
-- Better performance but uses more memory

USE deadlock_db;
GO

PRINT 'Starting optimized bulk insert of 3,000,000 products...';
PRINT 'This version uses CTEs for better performance.';
GO

DECLARE @StartTime DATETIME = GETDATE();
DECLARE @BatchSize INT = 50000;  -- Larger batches for better performance
DECLARE @TotalRecords INT = 3000000;
DECLARE @CurrentBatch INT = 0;

-- Create a numbers table using recursive CTE (for SQL Server 2005+)
-- This is more efficient than using sys.objects

WHILE @CurrentBatch < @TotalRecords
BEGIN
    WITH Numbers AS (
        SELECT 1 AS n
        UNION ALL
        SELECT n + 1
        FROM Numbers
        WHERE n < @BatchSize
    )
    INSERT INTO product (name, quantity, price, version)
    SELECT 
        'Product-Batch-' + CAST(@CurrentBatch AS VARCHAR(20)) + '-' + CAST(n AS VARCHAR(20)),
        ABS(CHECKSUM(NEWID())) % 1000 + 1,
        CAST((ABS(CHECKSUM(NEWID())) % 9000 + 1000) AS DECIMAL(10,2)) / 100.0,
        0
    FROM Numbers
    WHERE @CurrentBatch + n <= @TotalRecords
    OPTION (MAXRECURSION 0);
    
    SET @CurrentBatch = @CurrentBatch + @BatchSize;
    
    IF @CurrentBatch % 100000 = 0
    BEGIN
        DECLARE @Elapsed INT = DATEDIFF(SECOND, @StartTime, GETDATE());
        PRINT 'Progress: ' + CAST(@CurrentBatch AS VARCHAR(20)) + ' / ' + CAST(@TotalRecords AS VARCHAR(20)) + 
              ' (' + CAST(CAST(@CurrentBatch * 100.0 / @TotalRecords AS DECIMAL(5,2)) AS VARCHAR(10)) + '%)' +
              ' - Elapsed: ' + CAST(@Elapsed AS VARCHAR(10)) + ' seconds';
    END
END

DECLARE @EndTime DATETIME = GETDATE();
DECLARE @TotalTime INT = DATEDIFF(SECOND, @StartTime, @EndTime);
DECLARE @FinalCount INT = (SELECT COUNT(*) FROM product);

PRINT '========================================';
PRINT 'Bulk insert completed!';
PRINT 'Total records: ' + CAST(@FinalCount AS VARCHAR(20));
PRINT 'Total time: ' + CAST(@TotalTime AS VARCHAR(10)) + ' seconds';
PRINT '========================================';
GO

