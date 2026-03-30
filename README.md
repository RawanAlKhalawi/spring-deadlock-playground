# Database Deadlock Simulation Project

This Spring Boot project demonstrates four common database deadlock scenarios with SQL Server. It's designed to help developers understand, reproduce, and fix deadlock issues.

## Prerequisites

- Java 17 or higher
- Maven 3.6+
- SQL Server (local or remote instance)
- SQL Server JDBC Driver (included in pom.xml)

## Setup Instructions

### 1. Database Configuration

1. Create a SQL Server database:
   ```sql
   CREATE DATABASE deadlock_db;
   ```

2. Update `src/main/resources/application.properties` with your SQL Server credentials:
   ```properties
   spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=deadlock_db;encrypt=false;trustServerCertificate=true
   spring.datasource.username=sa
   spring.datasource.password=YourPassword123!
   ```

### 2. Build and Run

```bash
# Build the project
mvn clean install

# Run the application
mvn spring-boot:run
```

The application will start on `http://localhost:8080`

### 3. Initialize Test Data

Before running deadlock scenarios, initialize test data:

```bash
# Using curl
curl -X POST http://localhost:8080/api/init/setup

# Or use the script (it will initialize automatically)
./scripts/trigger_deadlocks.sh
```

## Deadlock Scenarios

### Scenario 1: Long-Lived Transaction with External API Call

**Problem**: A transaction is opened, then an external API call is made. During the API call delay, database locks remain held, causing deadlocks when concurrent requests access the same resources.

**Endpoint**: `POST /api/scenario1/process-transaction?userId=1&amount=100.00`

**How to trigger**:
```bash
# Send 5 concurrent requests
for i in {1..5}; do
  curl -X POST "http://localhost:8080/api/scenario1/process-transaction?userId=1&amount=100.00" &
done
wait
```

### Scenario 2: Inconsistent Read–Write Order Across Transactions

**Problem**: 
- Transaction T1: Reads TableA, then updates TableB
- Transaction T2: Reads TableB, then updates TableA
- When both run concurrently, each holds a lock the other needs → deadlock

**Endpoints**: 
- `POST /api/scenario2/transaction-t1?tableAId=1&tableBId=1`
- `POST /api/scenario2/transaction-t2?tableAId=1&tableBId=1`

**How to trigger**:
```bash
# Send T1 and T2 transactions concurrently
for i in {1..5}; do
  curl -X POST "http://localhost:8080/api/scenario2/transaction-t1?tableAId=1&tableBId=1" &
  curl -X POST "http://localhost:8080/api/scenario2/transaction-t2?tableAId=1&tableBId=1" &
done
wait
```

### Scenario 3: Concurrent Write and Delete on the Same Table

**Problem**: Multiple transactions perform both UPDATE and DELETE operations on the same table concurrently. Each transaction acquires different row or index locks, causing deadlocks.

**Endpoints**:
- `POST /api/scenario3/update-and-delete?productIdToUpdate=1&productIdToDelete=2`
- `POST /api/scenario3/process-multiple` (with JSON body: `[1,2,3]`)

**How to trigger**:
```bash
# Send concurrent update-and-delete operations
for i in {1..10}; do
  curl -X POST "http://localhost:8080/api/scenario3/update-and-delete?productIdToUpdate=1&productIdToDelete=2" &
done
wait
```

### Scenario 4: Unnecessary JPA Join Due to Lazy ManyToOne Mapping

**Problem**: Entity A (OrderItem) is queried using the ID of entity B (Product). JPA generates a JOIN between A and B, even though the ManyToOne B association is lazy. Concurrent updates to the Product table cause lock contention and deadlocks.

**Endpoints**:
- `GET /api/scenario4/order-items-with-join/{productId}` (problematic)
- `GET /api/scenario4/order-items-direct/{productId}` (fixed version)
- `PUT /api/scenario4/update-product?productId=1&newName=NewName&newPrice=29.99`

**How to trigger**:
```bash
# Send queries with JOIN and simultaneously update products
for i in {1..10}; do
  curl -X GET "http://localhost:8080/api/scenario4/order-items-with-join/1" &
done

for i in {1..5}; do
  curl -X PUT "http://localhost:8080/api/scenario4/update-product?productId=1&newName=UpdatedProduct$i&newPrice=29.99" &
done
wait
```

## Using the Test Scripts

### Linux/Mac (Bash)

```bash
# Make script executable
chmod +x scripts/trigger_deadlocks.sh

# Run all scenarios
./scripts/trigger_deadlocks.sh

# Run specific scenario
./scripts/trigger_deadlocks.sh 1
./scripts/trigger_deadlocks.sh 2
./scripts/trigger_deadlocks.sh 3
./scripts/trigger_deadlocks.sh 4
```

### Windows (PowerShell)

```powershell
# Run all scenarios
.\scripts\trigger_deadlocks.ps1

# Run specific scenario
.\scripts\trigger_deadlocks.ps1 1
.\scripts\trigger_deadlocks.ps1 2
.\scripts\trigger_deadlocks.ps1 3
.\scripts\trigger_deadlocks.ps1 4
```

## Monitoring Deadlocks

### SQL Server Deadlock Graph

Enable deadlock monitoring in SQL Server:

```sql
-- Enable trace flag to capture deadlock information
DBCC TRACEON(1222, -1);

-- View deadlock information in SQL Server logs
-- Or use SQL Server Profiler/Extended Events
```

### Application Logs

The application logs will show:
- Transaction start/end
- Lock acquisition
- Deadlock errors (if caught)
- SQL queries being executed

Check logs for messages like:
- `Starting transaction...`
- `Lock acquired...`
- `Deadlock detected...`

### SQL Server Extended Events

Create an Extended Events session to capture deadlocks:

```sql
CREATE EVENT SESSION [Deadlock_Monitor] ON SERVER
ADD EVENT sqlserver.xml_deadlock_report
ADD TARGET package0.event_file(SET filename = N'deadlock.xel')
WITH (MAX_MEMORY = 4 MB, EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS, MAX_DISPATCH_LATENCY = 30 SECONDS, MAX_EVENT_SIZE = 0 KB, MEMORY_PARTITION_MODE = NONE, TRACK_CAUSALITY = OFF, STARTUP_STATE = ON);

ALTER EVENT SESSION [Deadlock_Monitor] ON SERVER STATE = START;
```

## Solutions and Best Practices

### Scenario 1 Solution
- Move external API calls outside the transaction
- Use asynchronous processing
- Implement retry logic with exponential backoff

### Scenario 2 Solution
- Always access tables in the same order across all transactions
- Use application-level locking (e.g., synchronized blocks)
- Implement deadlock retry logic

### Scenario 3 Solution
- Batch operations when possible
- Use optimistic locking (@Version)
- Minimize transaction scope
- Consider using database-level locking hints if necessary

### Scenario 4 Solution
- Use direct queries on foreign keys instead of JOINs
- Use native queries when appropriate
- Avoid accessing lazy-loaded associations unnecessarily
- Use DTO projections instead of entity graphs

## Project Structure

```
src/
├── main/
│   ├── java/com/deadlock/
│   │   ├── controller/          # REST controllers for each scenario
│   │   ├── entity/              # JPA entities
│   │   ├── repository/          # JPA repositories
│   │   ├── service/             # Business logic for deadlock scenarios
│   │   └── DeadlockSimulationApplication.java
│   └── resources/
│       └── application.properties
scripts/
├── trigger_deadlocks.sh         # Bash script for Linux/Mac
└── trigger_deadlocks.ps1        # PowerShell script for Windows
```

## Troubleshooting

### Connection Issues
- Verify SQL Server is running and accessible
- Check firewall settings
- Verify credentials in `application.properties`
- Ensure SQL Server authentication is enabled

### No Deadlocks Occurring
- Increase the number of concurrent requests
- Add more delays in the code
- Ensure multiple transactions are running simultaneously
- Check SQL Server isolation level settings

### Build Errors
- Ensure Java 17 is installed: `java -version`
- Verify Maven is installed: `mvn -version`
- Clean and rebuild: `mvn clean install`

## License

This project is for educational purposes to demonstrate database deadlock scenarios.



