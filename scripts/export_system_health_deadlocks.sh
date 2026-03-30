#!/bin/bash
# Export all deadlocks from system_health to individual XML files
# Usage: ./export_system_health_deadlocks.sh <sa_password>

PASSWORD="Aa123456"
OUTPUT_DIR="./deadlocks_xml"

echo "============================================"
echo "SQL Server Deadlock Exporter (system_health)"
echo "============================================"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Export all deadlocks to one file first
echo "Extracting deadlocks from system_health..."

docker exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$PASSWORD" -C -Q "
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;

DECLARE @Counter INT = 1;
DECLARE @DeadlockXML NVARCHAR(MAX);
DECLARE @Timestamp DATETIME2;

DECLARE deadlock_cursor CURSOR FOR
SELECT
    XEvent.value('(@timestamp)[1]', 'datetime2') AS DeadlockTime,
    CAST(XEvent.query('.') AS NVARCHAR(MAX)) AS DeadlockXML
FROM (
    SELECT CAST(target_data AS XML) AS target_data
    FROM sys.dm_xe_sessions AS s
    INNER JOIN sys.dm_xe_session_targets AS t
        ON t.event_session_address = s.address
    WHERE s.name = 'system_health'
      AND t.target_name = 'ring_buffer'
) AS data
CROSS APPLY target_data.nodes('//event[@name=\"xml_deadlock_report\"]') AS XEventData(XEvent)
ORDER BY XEvent.value('(@timestamp)[1]', 'datetime2') DESC;

OPEN deadlock_cursor;
FETCH NEXT FROM deadlock_cursor INTO @Timestamp, @DeadlockXML;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '###DEADLOCK_START###' + CONVERT(VARCHAR, @Timestamp, 120) + '###';
    PRINT @DeadlockXML;
    PRINT '###DEADLOCK_END###';

    SET @Counter = @Counter + 1;
    FETCH NEXT FROM deadlock_cursor INTO @Timestamp, @DeadlockXML;
END;

CLOSE deadlock_cursor;
DEALLOCATE deadlock_cursor;
" -h -1 -w 65535 > "$OUTPUT_DIR/temp_all.txt" 2>&1

# Check if we got data
if [ ! -s "$OUTPUT_DIR/temp_all.txt" ]; then
    echo "❌ No deadlocks found in system_health"
    rm -f "$OUTPUT_DIR/temp_all.txt"
    exit 1
fi

# Split into individual files
echo "Splitting into individual XML files..."

counter=1
in_deadlock=0
current_timestamp=""

while IFS= read -r line; do
    if [[ $line == *"###DEADLOCK_START###"* ]]; then
        in_deadlock=1
        current_timestamp=$(echo "$line" | sed 's/.*###DEADLOCK_START###\(.*\)###.*/\1/' | tr ' ' '_' | tr ':' '-')
        filename="$OUTPUT_DIR/deadlock_${counter}_${current_timestamp}.xml"
        echo '<?xml version="1.0" encoding="utf-8"?>' > "$filename"
        echo "<!-- Deadlock #$counter captured at $current_timestamp -->" >> "$filename"
    elif [[ $line == *"###DEADLOCK_END###"* ]]; then
        in_deadlock=0
        echo "✓ Saved: deadlock_${counter}_${current_timestamp}.xml"
        counter=$((counter + 1))
    elif [ $in_deadlock -eq 1 ]; then
        echo "$line" >> "$filename"
    fi
done < "$OUTPUT_DIR/temp_all.txt"

# Clean up temp file
rm -f "$OUTPUT_DIR/temp_all.txt"

# Summary
total_files=$((counter - 1))
echo ""
echo "============================================"
echo "✓ Export Complete!"
echo "============================================"
echo "Total deadlocks: $total_files"
echo "Location: $OUTPUT_DIR/"
echo ""

if [ $total_files -gt 0 ]; then
    echo "Files:"
    ls -lh "$OUTPUT_DIR"/deadlock_*.xml | tail -10
    echo ""
    echo "To analyze a deadlock, run:"
    echo "  cat $OUTPUT_DIR/deadlock_1_*.xml | grep -E 'inputbuf|keylock|pagelock|objectlock'"
fi