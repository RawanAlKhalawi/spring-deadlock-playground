
  -- Insert 20,000 rows with name = 'cases-3'
SET NOCOUNT ON;

DECLARE @i INT = 1;

WHILE @i <= 20000
BEGIN
    INSERT INTO Product (name, quantity, price)
    VALUES (
        'cases-5',
        ABS(CHECKSUM(NEWID())) % 100 + 1,
        CAST((ABS(CHECKSUM(NEWID())) % 10000) / 100.0 + 10 AS DECIMAL(10,2))
    );

    SET @i += 1;
END


SET NOCOUNT ON;

DECLARE @case INT = 1;
DECLARE @i INT;

WHILE @case <= 50
BEGIN
    SET @i = 1;

    WHILE @i <= 5000
    BEGIN
        INSERT INTO table_b (description, amount)
        VALUES (
            CONCAT('case-', @case),
            CAST((ABS(CHECKSUM(NEWID())) % 10000) / 100.0 + 10 AS DECIMAL(10,2))
        );

        SET @i += 1;
    END

    SET @case += 1;
END



SET NOCOUNT ON;

DECLARE @case INT = 1;
DECLARE @i INT;

WHILE @case <= 50
BEGIN
    SET @i = 1;

    WHILE @i <= 5000
    BEGIN
        INSERT INTO table_a (name, value)
        VALUES (
            CONCAT('case-', @case),
            CAST((ABS(CHECKSUM(NEWID())) % 10000) / 100.0 + 10 AS DECIMAL(10,2))
        );

        SET @i += 1;
    END

    SET @case += 1;
END


SELECT COUNT(*)
FROM Product
WHERE name = 'cases-3';


SELECT TOP(20) *
FROM Product

-- SELECT
--     L.request_session_id AS SessionID,
--     sp.blocked AS BlockedBy,
--     DB_NAME(L.resource_database_id) AS DatabaseName,
--     OBJECT_NAME(P.object_id, L.resource_database_id) AS LockedObject,
--     L.resource_type AS ResourceType,
--     L.request_mode AS LockMode,
--     L.request_status AS LockStatus,
--     sp.loginame AS LoginName,
--     sp.hostname AS HostName,
--     sp.program_name AS ProgramName,
--     sp.waittime AS WaitTimeMS,
--     st.text AS SQLText,
--     AT.transaction_begin_time,
--     DATEDIFF(SECOND, AT.transaction_begin_time, GETDATE()) AS TransactionDurationSeconds
-- FROM sys.dm_tran_locks L
-- LEFT JOIN sys.partitions P ON P.hobt_id = L.resource_associated_entity_id
-- LEFT JOIN sys.sysprocesses sp ON sp.spid = L.request_session_id
-- LEFT JOIN sys.dm_tran_session_transactions TST ON TST.session_id = L.request_session_id
-- LEFT JOIN sys.dm_tran_active_transactions AT ON AT.transaction_id = TST.transaction_id
-- OUTER APPLY sys.dm_exec_sql_text(sp.sql_handle) AS st
-- WHERE L.resource_database_id = DB_ID()
--   AND sp.open_tran > 0
-- ORDER BY L.request_session_id, TransactionDurationSeconds DESC;



-- SELECT
--     sp.status AS Status,
--     sp.spid AS [Session ID],
--     CASE
--         WHEN sp.spid <= 50 THEN 'System'
--         ELSE 'User'
--     END AS Type,
--     CASE
--         WHEN sp.blocked = 0 THEN NULL
--         ELSE sp.blocked
--     END AS [Blocked By],
--     CASE
--         WHEN EXISTS (SELECT 1 FROM sys.sysprocesses WHERE blocked = sp.spid)
--         THEN (SELECT TOP 1 blocked FROM sys.sysprocesses WHERE blocked = sp.spid)
--         ELSE NULL
--     END AS Blocking,
--     sp.cpu AS [CPU (ms)],
--     sp.memusage * 8 AS [Memory Usage (kb)],
--     sp.physical_io AS [Physical I/O],
--     sp.waittime AS [Wait Time (ms)],
--     sp.loginame AS [User],
--     sp.hostname AS Host,
--     DB_NAME(sp.dbid) AS [Database],
--     sp.status AS Status,
--     sp.open_tran AS [Open Transactions],
--     sp.cmd AS Command,
--     sp.program_name AS Application,
--     sp.lastwaittype AS [Wait Type],
--     sp.waitresource AS [Wait Resource],
--     sp.cpu - ISNULL(prev.cpu, 0) AS [CPU Delta (ms)],
--     sp.physical_io - ISNULL(prev.physical_io, 0) AS [Physical I/O Delta],
--     sp.login_time AS [Login Time],
--     sp.last_batch AS [Last Batch],
--     (SELECT COUNT(*) FROM sys.sysprocesses WHERE blocked = sp.spid) AS [Blocking Count],
--     sp.net_library AS [Net Library],
--     sp.net_address AS [Net Address],
--     ISNULL(DATEDIFF(SECOND, AT.transaction_begin_time, GETDATE()), 0) AS [Version Store Elapsed Seconds],
--     sp.cmd AS [Last Command]
-- FROM sys.sysprocesses sp
-- LEFT JOIN sys.dm_tran_session_transactions TST ON TST.session_id = sp.spid
-- LEFT JOIN sys.dm_tran_active_transactions AT ON AT.transaction_id = TST.transaction_id
-- LEFT JOIN (
--     -- Previous snapshot for delta calculations (you'd need to store this in a temp table for real deltas)
--     SELECT spid, cpu, physical_io
--     FROM sys.sysprocesses
--     WHERE 1 = 0  -- This is a placeholder; see note below
-- ) prev ON prev.spid = sp.spid
-- WHERE sp.spid > 50  -- Exclude system processes, adjust as needed
-- ORDER BY sp.spid;


SELECT
    sp.status AS Status,
    sp.spid AS [Session ID],
    CASE
        WHEN sp.spid <= 50 THEN 'System'
        ELSE 'User'
    END AS Type,
    CASE
        WHEN sp.blocked = 0 THEN NULL
        ELSE sp.blocked
    END AS [Blocked By],
    (SELECT COUNT(*) FROM sys.sysprocesses WHERE blocked = sp.spid) AS [Blocking Count],
    sp.cpu AS [CPU (ms)],
    sp.memusage * 8 AS [Memory Usage (kb)],
    sp.physical_io AS [Physical I/O],
    sp.waittime AS [Wait Time (ms)],
    sp.loginame AS [User],
    sp.hostname AS Host,
    DB_NAME(sp.dbid) AS [Database],
    sp.open_tran AS [Open Transactions],
    sp.cmd AS Command,
    sp.program_name AS Application,
    sp.lastwaittype AS [Wait Type],
    sp.waitresource AS [Wait Resource],
    sp.login_time AS [Login Time],
    sp.last_batch AS [Last Batch],
    sp.net_library AS [Net Library],
    sp.net_address AS [Net Address],
    ISNULL(DATEDIFF(SECOND, AT.transaction_begin_time, GETDATE()), 0) AS [Version Store Elapsed Seconds],
    AT.transaction_begin_time AS [Transaction Start Time],
    AT.name AS [Transaction Name],
    st.text AS [SQL Text],
    SUBSTRING(st.text,
        (sp.stmt_start/2) + 1,
        ((CASE sp.stmt_end
            WHEN -1 THEN DATALENGTH(st.text)
            ELSE sp.stmt_end
        END - sp.stmt_start)/2) + 1
    ) AS [Current Statement]
FROM sys.sysprocesses sp
LEFT JOIN sys.dm_tran_session_transactions TST ON TST.session_id = sp.spid
LEFT JOIN sys.dm_tran_active_transactions AT ON AT.transaction_id = TST.transaction_id
OUTER APPLY sys.dm_exec_sql_text(sp.sql_handle) AS st
WHERE sp.open_tran > 0
ORDER BY [Open Transactions] DESC, [Version Store Elapsed Seconds] DESC;






-- Find circular blocking chains that indicate deadlocks
WITH BlockingChain AS (
    SELECT
        spid,
        blocked,
        CAST(spid AS VARCHAR(1000)) AS chain,
        0 AS level
    FROM sys.sysprocesses
    WHERE blocked = 0
      AND spid IN (SELECT blocked FROM sys.sysprocesses WHERE blocked <> 0)

    UNION ALL

    SELECT
        sp.spid,
        sp.blocked,
        CAST(bc.chain + ' -> ' + CAST(sp.spid AS VARCHAR(10)) AS VARCHAR(1000)),
        bc.level + 1
    FROM sys.sysprocesses sp
    INNER JOIN BlockingChain bc ON sp.blocked = bc.spid
    WHERE bc.level < 50  -- Prevent infinite recursion
)
SELECT
    bc.spid AS [Session ID],
    bc.blocked AS [Blocked By],
    bc.chain AS [Blocking Chain],
    bc.level AS [Chain Level],
    sp.waittime AS [Wait Time (ms)],
    sp.lastwaittype AS [Wait Type],
    sp.waitresource AS [Wait Resource],
    DB_NAME(sp.dbid) AS [Database],
    st.text AS [SQL Text],
    -- Check if this is a circular wait (deadlock)
    CASE
        WHEN bc.chain LIKE '%' + CAST(sp.blocked AS VARCHAR(10)) + '%' + CAST(sp.spid AS VARCHAR(10)) + '%'
        THEN 'DEADLOCK DETECTED'
        ELSE 'Normal Blocking'
    END AS [Lock Type]
FROM BlockingChain bc
INNER JOIN sys.sysprocesses sp ON bc.spid = sp.spid
OUTER APPLY sys.dm_exec_sql_text(sp.sql_handle) AS st
ORDER BY bc.level DESC, bc.spid;





;WITH RB AS (
  SELECT CAST(t.target_data AS XML) AS target_data
  FROM sys.dm_xe_session_targets t
  JOIN sys.dm_xe_sessions s
    ON s.address = t.event_session_address
  WHERE s.name = 'CaptureDeadlocks'
    AND t.target_name = 'ring_buffer'
)
SELECT TOP (50)
  DATEADD(MINUTE, DATEDIFF(MINUTE, GETUTCDATE(), GETDATE()),
          E.value('(@timestamp)[1]', 'datetime2')) AS DeadlockTime,
  E.query('(data/value/deadlock)[1]') AS DeadlockXML
FROM RB
CROSS APPLY RB.target_data.nodes('//RingBufferTarget/event[@name="xml_deadlock_report"]') AS X(E)
ORDER BY DeadlockTime DESC;


-- Check if deadlocks happened recently (from system_health)
SELECT TOP (10)
    CAST(XEvent.query('.') AS XML) AS DeadlockGraph,
    XEvent.value('(@timestamp)[1]', 'datetime2') AS DeadlockTime,
    DATEDIFF(MINUTE, XEvent.value('(@timestamp)[1]', 'datetime2'), GETDATE()) AS [Minutes Ago]
FROM (
    SELECT CAST(target_data AS XML) AS target_data
    FROM sys.dm_xe_sessions AS s
    INNER JOIN sys.dm_xe_session_targets AS t
        ON t.event_session_address = s.address
    WHERE s.name = 'system_health'
      AND t.target_name = 'ring_buffer'
) AS data
CROSS APPLY target_data.nodes('//event[@name="xml_deadlock_report"]') AS XEventData(XEvent)
ORDER BY DeadlockTime DESC;



-- -- Connect via sqlcmd or Azure Data Studio first
-- -- Create Extended Events session
-- CREATE EVENT SESSION [TransactionTrace] ON SERVER
-- ADD EVENT sqlserver.transaction_log(
--     ACTION(sqlserver.client_app_name, sqlserver.database_name,
--            sqlserver.session_id, sqlserver.username)
-- ),
-- ADD EVENT sqlserver.sql_batch_starting(
--     ACTION(sqlserver.sql_text, sqlserver.session_id)
-- ),
-- ADD EVENT sqlserver.sql_batch_completed(
--     ACTION(sqlserver.sql_text, sqlserver.session_id)
--     WHERE duration > 1000  -- Only capture batches > 1ms
-- )
-- ADD TARGET package0.ring_buffer(SET max_memory=4096)
-- WITH (MAX_MEMORY=4096 KB, EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS);

-- -- Start the session
-- ALTER EVENT SESSION [TransactionTrace] ON SERVER STATE = START;


-- Query the ring buffer to see captured events
SELECT
    event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name,
    event_data.value('(event/@timestamp)[1]', 'datetime2') AS timestamp,
    event_data.value('(event/data[@name="duration"]/value)[1]', 'bigint') AS duration_microseconds,
    event_data.value('(event/action[@name="sql_text"]/value)[1]', 'varchar(max)') AS sql_text,
    event_data.value('(event/action[@name="session_id"]/value)[1]', 'int') AS session_id
FROM (
    SELECT CAST(target_data AS XML) AS target_data
    FROM sys.dm_xe_session_targets AS t
    INNER JOIN sys.dm_xe_sessions AS s ON s.address = t.event_session_address
    WHERE s.name = 'TransactionTrace' AND t.target_name = 'ring_buffer'
) AS data
CROSS APPLY target_data.nodes('RingBufferTarget/event') AS XEventData(event_data)
ORDER BY timestamp DESC;

SELECT s.session_id, s.login_name,
       DB_NAME(s.database_id) AS db_name,
       t.transaction_begin_time,
       DATEDIFF(ss, t.transaction_begin_time, GETDATE()) AS duration_sec
FROM sys.dm_tran_active_transactions t
JOIN sys.dm_tran_session_transactions st ON t.transaction_id = st.transaction_id
JOIN sys.dm_exec_sessions s ON st.session_id = s.session_id;


-- Get deadlock details
WITH DeadlockData AS (
    SELECT CAST(target_data AS XML) AS TargetData
    FROM sys.dm_xe_sessions AS s
    INNER JOIN sys.dm_xe_session_targets AS t
        ON t.event_session_address = s.address
    WHERE s.name = 'system_health'
      AND t.target_name = 'ring_buffer'
)
SELECT
    d.DeadlockGraph.value('(/deadlock/@timestamp)[1]', 'datetime') AS DeadlockTime,
    d.DeadlockGraph.query('/deadlock/process-list/process') AS ProcessInfo,
    d.DeadlockGraph.query('/deadlock/resource-list') AS ResourceInfo,
    d.DeadlockGraph AS FullDeadlockGraph
FROM (
    SELECT XEvent.query('.') AS DeadlockGraph
    FROM DeadlockData
    CROSS APPLY TargetData.nodes('/RingBufferTarget/event[@name="xml_deadlock_report"]') AS evt(XEvent)
) AS d
ORDER BY DeadlockTime DESC;


--
SELECT * FROM sys.sysprocesses WHERE open_tran = 1


-- Get deadlock details
WITH DeadlockData AS (
    SELECT CAST(target_data AS XML) AS TargetData
    FROM sys.dm_xe_sessions AS s
    INNER JOIN sys.dm_xe_session_targets AS t
        ON t.event_session_address = s.address
    WHERE s.name = 'system_health'
      AND t.target_name = 'ring_buffer'
)
SELECT
    d.DeadlockGraph.value('(/deadlock/@timestamp)[1]', 'datetime') AS DeadlockTime,
    d.DeadlockGraph.query('/deadlock/process-list/process') AS ProcessInfo,
    d.DeadlockGraph.query('/deadlock/resource-list') AS ResourceInfo,
    d.DeadlockGraph AS FullDeadlockGraph
FROM (
    SELECT XEvent.query('.') AS DeadlockGraph
    FROM DeadlockData
    CROSS APPLY TargetData.nodes('/RingBufferTarget/event[@name="xml_deadlock_report"]') AS evt(XEvent)
) AS d
ORDER BY DeadlockTime DESC;




SELECT  L.request_session_id AS SPID,
DB_NAME(L.resource_database_id) AS DatabaseName,
O.Name AS LockedObjectName,
P.object_id AS LockedObjectId,
L.resource_type AS LockedResource,
L.request_mode AS LockType,
ST.text AS SqlStatementText,
ES.login_name AS LoginName,
ES.host_name AS HostName,
TST.is_user_transaction as IsUserTransaction,
AT.name as TransactionName,
CN.auth_scheme as AuthenticationMethod
FROM    sys.dm_tran_locks L
JOIN sys.partitions P ON P.hobt_id = L.resource_associated_entity_id
JOIN sys.objects O ON O.object_id = P.object_id
JOIN sys.dm_exec_sessions ES ON ES.session_id = L.request_session_id
JOIN sys.dm_tran_session_transactions TST ON ES.session_id = TST.session_id
JOIN sys.dm_tran_active_transactions AT ON TST.transaction_id = AT.transaction_id
JOIN sys.dm_exec_connections CN ON CN.session_id = ES.session_id
CROSS APPLY sys.dm_exec_sql_text(CN.most_recent_sql_handle) AS ST
WHERE   resource_database_id = db_id()
ORDER BY L.request_session_id





SELECT count([id])
  FROM [deadlock_demo].[dbo].[order_item] where product_id = 3033074

  INSERT INTO order_item (item_name, quantity, product_id)
  VALUES ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
    ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074),
  ('OrderItem-44', 50, 3033074);
