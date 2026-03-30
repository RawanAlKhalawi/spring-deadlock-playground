# PowerShell script to trigger deadlock scenarios by sending concurrent requests
# Usage: .\trigger_deadlocks.ps1 [scenario_number]
# If no scenario is specified, all scenarios will be tested

$BaseUrl = "http://localhost:8080/api"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Send-ConcurrentRequests {
    param(
        [string]$Endpoint,
        [string]$Method = "POST",
        [string]$Data = "",
        [int]$Count = 5,
        [string]$Description
    )
    
    Write-ColorOutput Yellow "Testing: $Description"
    Write-Output "Sending $Count concurrent requests to $Endpoint"
    Write-Output ""
    
    $jobs = @()
    
    for ($i = 1; $i -le $Count; $i++) {
        $url = "$BaseUrl$Endpoint"
        if ($Data -ne "") {
            $url += "?$Data"
        }
        
        $job = Start-Job -ScriptBlock {
            param($url, $method)
            try {
                if ($method -eq "POST") {
                    Invoke-RestMethod -Uri $url -Method Post -ErrorAction Stop
                }
                elseif ($method -eq "GET") {
                    Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
                }
                elseif ($method -eq "PUT") {
                    Invoke-RestMethod -Uri $url -Method Put -ErrorAction Stop
                }
            }
            catch {
                Write-Output "Error: $_"
            }
        } -ArgumentList $url, $Method
        
        $jobs += $job
    }
    
    Wait-Job -Job $jobs | Out-Null
    Receive-Job -Job $jobs
    Remove-Job -Job $jobs
    
    Write-ColorOutput Green "All requests sent"
    Write-Output ""
    Start-Sleep -Seconds 2
}

function Test-Scenario1 {
    Write-ColorOutput Red "=== Scenario 1: Long-Lived Transaction with External API Call ==="
    Write-Output "This scenario simulates transactions that hold locks while calling external APIs"
    Write-Output "Concurrent POST (write) and GET (read) requests will cause deadlocks"
    Write-Output ""
    
    # Send POST requests that hold locks during external API call
    Write-ColorOutput Yellow "Sending POST requests (process-transaction) that hold locks..."
    $postJobs = @()
    for ($i = 1; $i -le 5; $i++) {
        $amount = 100 + $i
        $url = "$BaseUrl/scenario1/process-transaction?userId=1&amount=$amount.00"
        $job = Start-Job -ScriptBlock {
            param($url)
            try {
                Invoke-RestMethod -Uri $url -Method Post -ErrorAction Stop
            }
            catch {
                Write-Output "Error: $_"
            }
        } -ArgumentList $url
        $postJobs += $job
    }
    
    # Simultaneously send GET requests that try to read from the same table
    Write-ColorOutput Yellow "Simultaneously sending GET requests (get all transactions)..."
    $getAllJobs = @()
    for ($i = 1; $i -le 10; $i++) {
        $job = Start-Job -ScriptBlock {
            param($url)
            try {
                Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
            }
            catch {
                Write-Output "Error: $_"
            }
        } -ArgumentList "$BaseUrl/scenario1/transactions"
        $getAllJobs += $job
    }
    
    # Also send GET requests for specific user
    Write-ColorOutput Yellow "Also sending GET requests for specific user..."
    $getUserJobs = @()
    for ($i = 1; $i -le 5; $i++) {
        $job = Start-Job -ScriptBlock {
            param($url)
            try {
                Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
            }
            catch {
                Write-Output "Error: $_"
            }
        } -ArgumentList "$BaseUrl/scenario1/transactions/user/1"
        $getUserJobs += $job
    }
    
    Wait-Job -Job ($postJobs + $getAllJobs + $getUserJobs) | Out-Null
    Receive-Job -Job ($postJobs + $getAllJobs + $getUserJobs)
    Remove-Job -Job ($postJobs + $getAllJobs + $getUserJobs)
    
    Write-ColorOutput Green "All requests sent"
    Write-Output ""
    Start-Sleep -Seconds 2
}

function Test-Scenario2 {
    Write-ColorOutput Red "=== Scenario 2: Inconsistent Read–Write Order Across Transactions ==="
    Write-Output "T1: Reads TableA, then updates TableB"
    Write-Output "T2: Reads TableB, then updates TableA"
    Write-Output ""
    
    Write-ColorOutput Yellow "Sending T1 transactions..."
    $t1Jobs = @()
    for ($i = 1; $i -le 5; $i++) {
        $job = Start-Job -ScriptBlock {
            param($url)
            try {
                Invoke-RestMethod -Uri $url -Method Post -ErrorAction Stop
            }
            catch {
                Write-Output "Error: $_"
            }
        } -ArgumentList "$BaseUrl/scenario2/transaction-t1?tableAId=1&tableBId=1"
        $t1Jobs += $job
    }
    
    Write-ColorOutput Yellow "Sending T2 transactions..."
    $t2Jobs = @()
    for ($i = 1; $i -le 5; $i++) {
        $job = Start-Job -ScriptBlock {
            param($url)
            try {
                Invoke-RestMethod -Uri $url -Method Post -ErrorAction Stop
            }
            catch {
                Write-Output "Error: $_"
            }
        } -ArgumentList "$BaseUrl/scenario2/transaction-t2?tableAId=1&tableBId=1"
        $t2Jobs += $job
    }
    
    Wait-Job -Job ($t1Jobs + $t2Jobs) | Out-Null
    Receive-Job -Job ($t1Jobs + $t2Jobs)
    Remove-Job -Job ($t1Jobs + $t2Jobs)
    
    Write-ColorOutput Green "All requests sent"
    Write-Output ""
    Start-Sleep -Seconds 2
}

function Test-Scenario3 {
    Write-ColorOutput Red "=== Scenario 3: Concurrent Delete and Insert on the Same Table ==="
    Write-Output "Multiple transactions deleting 20000 rows and inserting 20000 new rows concurrently"
    Write-Output ""
    
    # Initialize bulk products if needed
    Write-ColorOutput Yellow "Initializing bulk products (25000) for Scenario 3..."
    try {
        Invoke-RestMethod -Uri "$BaseUrl/init/setup-bulk-products?count=25000" -Method Post
    }
    catch {
        Write-Output "Error initializing bulk products: $_"
    }
    Write-Output ""
    Start-Sleep -Seconds 1
    
    # Send concurrent delete-and-insert operations
    Write-ColorOutput Yellow "Sending concurrent delete-and-insert operations..."
    $jobs = @()
    for ($i = 1; $i -le 5; $i++) {
        $job = Start-Job -ScriptBlock {
            param($url)
            try {
                Invoke-RestMethod -Uri $url -Method Post -ErrorAction Stop
            }
            catch {
                Write-Output "Error: $_"
            }
        } -ArgumentList "$BaseUrl/scenario3/delete-and-insert"
        $jobs += $job
    }
    
    # Also send operations with different prefixes
    Write-ColorOutput Yellow "Also sending operations with different prefixes..."
    for ($i = 1; $i -le 3; $i++) {
        $job = Start-Job -ScriptBlock {
            param($url)
            try {
                Invoke-RestMethod -Uri $url -Method Post -ErrorAction Stop
            }
            catch {
                Write-Output "Error: $_"
            }
        } -ArgumentList "$BaseUrl/scenario3/delete-and-insert-by-prefix?namePrefix=Product$i"
        $jobs += $job
    }
    
    Wait-Job -Job $jobs | Out-Null
    Receive-Job -Job $jobs
    Remove-Job -Job $jobs
    
    Write-ColorOutput Green "All requests sent"
    Write-Output ""
    Start-Sleep -Seconds 2
}

function Test-Scenario4 {
    Write-ColorOutput Red "=== Scenario 4: Unnecessary JPA Join Due to Lazy ManyToOne Mapping ==="
    Write-Output "Concurrent queries with JOIN and product updates"
    Write-Output ""
    
    Write-ColorOutput Yellow "Sending queries with JOIN..."
    $queryJobs = @()
    for ($i = 1; $i -le 10; $i++) {
        $job = Start-Job -ScriptBlock {
            param($url)
            try {
                Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
            }
            catch {
                Write-Output "Error: $_"
            }
        } -ArgumentList "$BaseUrl/scenario4/order-items-with-join/1"
        $queryJobs += $job
    }
    
    Write-ColorOutput Yellow "Simultaneously updating products..."
    $updateJobs = @()
    for ($i = 1; $i -le 5; $i++) {
        $price = 20 + $i
        $url = "$BaseUrl/scenario4/update-product?productId=1&newName=UpdatedProduct$i&newPrice=$price.99"
        $job = Start-Job -ScriptBlock {
            param($url)
            try {
                Invoke-RestMethod -Uri $url -Method Put -ErrorAction Stop
            }
            catch {
                Write-Output "Error: $_"
            }
        } -ArgumentList $url
        $updateJobs += $job
    }
    
    Wait-Job -Job ($queryJobs + $updateJobs) | Out-Null
    Receive-Job -Job ($queryJobs + $updateJobs)
    Remove-Job -Job ($queryJobs + $updateJobs)
    
    Write-ColorOutput Green "All requests sent"
    Write-Output ""
    Start-Sleep -Seconds 2
}

function Initialize-Data {
    Write-ColorOutput Green "Initializing test data..."
    try {
        Invoke-RestMethod -Uri "$BaseUrl/init/setup" -Method Post
    }
    catch {
        Write-Output "Error initializing data: $_"
    }
    Write-Output ""
    Start-Sleep -Seconds 1
}

# Main execution
$scenario = $args[0]

# Initialize data first
Initialize-Data

if ([string]::IsNullOrEmpty($scenario)) {
    Write-ColorOutput Yellow "No specific scenario specified. Testing all scenarios..."
    Write-Output ""
    Test-Scenario1
    Test-Scenario2
    Test-Scenario3
    Test-Scenario4
}
else {
    switch ($scenario) {
        "1" { Test-Scenario1 }
        "2" { Test-Scenario2 }
        "3" { Test-Scenario3 }
        "4" { Test-Scenario4 }
        default {
            Write-ColorOutput Red "Invalid scenario number. Use 1, 2, 3, or 4"
            exit 1
        }
    }
}

Write-ColorOutput Green "================================="
Write-ColorOutput Green "All tests completed!"
Write-ColorOutput Yellow "Check your application logs and SQL Server logs for deadlock information"

