# SQL Scripts for Bulk Data Insertion

This directory contains SQL scripts to insert 3 million records into the `product` table for deadlock simulation testing.

## Available Scripts

### 1. `insert_3million_products.sql` (Recommended)
- **Method**: Uses WHILE loop with batch inserts
- **Batch Size**: 10,000 records per batch
- **Features**:
  - Progress indicators every 100,000 records
  - Performance metrics (records/second)
  - Safe for large transactions
  - Works well with transaction logs

### 2. `insert_3million_products_optimized.sql`
- **Method**: Uses CTEs (Common Table Expressions) with recursive queries
- **Batch Size**: 50,000 records per batch
- **Features**:
  - Faster execution
  - Better for SQL Server 2005+
  - Uses more memory
  - Progress indicators

### 3. `insert_3million_products_simple.sql`
- **Method**: Simple WHILE loop with transactions
- **Batch Size**: 10,000 records per batch
- **Features**:
  - Easiest to understand
  - Explicit transactions
  - Good for troubleshooting
  - Progress updates

## Usage

### Option 1: SQL Server Management Studio (SSMS)
1. Open SQL Server Management Studio
2. Connect to your SQL Server instance
3. Open the script file
4. Make sure you're connected to the `deadlock_db` database
5. Execute the script (F5)

### Option 2: sqlcmd Command Line
```bash
sqlcmd -S localhost -d deadlock_db -U sa -P YourPassword123! -i insert_3million_products.sql
```

### Option 3: PowerShell
```powershell
Invoke-Sqlcmd -ServerInstance "localhost" -Database "deadlock_db" -Username "sa" -Password "YourPassword123!" -InputFile "insert_3million_products.sql"
```

## Performance Tips

1. **Before Running**:
   - Ensure you have enough disk space (approximately 500MB-1GB for 3 million records)
   - Check transaction log size settings
   - Consider running during off-peak hours

2. **During Execution**:
   - Monitor transaction log size
   - Watch for blocking/locking issues
   - Check CPU and memory usage

3. **After Running**:
   - Update statistics: `UPDATE STATISTICS product;`
   - Rebuild indexes if needed: `ALTER INDEX ALL ON product REBUILD;`
   - Verify record count: `SELECT COUNT(*) FROM product;`

## Expected Execution Time

- **Fast Server**: 5-15 minutes
- **Average Server**: 15-30 minutes
- **Slow Server**: 30-60 minutes

*Times vary based on hardware, SQL Server configuration, and concurrent load.*

## Troubleshooting

### Issue: Transaction log full
**Solution**: Increase transaction log size or use smaller batch sizes

### Issue: Out of memory
**Solution**: Use the simple version or reduce batch size

### Issue: Timeout errors
**Solution**: Increase command timeout in your SQL client

### Issue: Slow performance
**Solution**: 
- Disable indexes temporarily (uncomment lines in script)
- Run during off-peak hours
- Check for blocking processes

## Verification

After running the script, verify the data:

```sql
-- Check total count
SELECT COUNT(*) AS TotalProducts FROM product;

-- Check ID range
SELECT MIN(id) AS MinId, MAX(id) AS MaxId FROM product;

-- Sample data
SELECT TOP 10 * FROM product ORDER BY id DESC;

-- Check data distribution
SELECT 
    COUNT(*) AS Count,
    AVG(quantity) AS AvgQuantity,
    AVG(price) AS AvgPrice
FROM product;
```

## Notes

- All scripts generate random data for `quantity` (1-1000) and `price` (10.00-99.99)
- Product names follow the pattern: `Product-{number}` or `Product-Batch-{batch}-{number}`
- The `version` field starts at 0 (for optimistic locking)
- Scripts are designed to be idempotent - you can run them multiple times (they will add more records)

