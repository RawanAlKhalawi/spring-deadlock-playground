#!/bin/bash

# Script to trigger deadlock scenarios by sending concurrent requests
# Usage: ./trigger_deadlocks.sh [scenario_number]
# If no scenario is specified, all scenarios will be tested

BASE_URL="http://localhost:8080/api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Deadlock Simulation Script${NC}"
echo "================================"
echo ""

# Function to send concurrent requests
send_concurrent_requests() {
    local endpoint=$1
    local method=$2
    local data=$3
    local count=$4
    local description=$5
    
    echo -e "${YELLOW}Testing: ${description}${NC}"
    echo "Sending $count concurrent requests to $endpoint"
    echo ""
    
    for i in $(seq 1 $count); do
        if [ "$method" = "POST" ]; then
            if [ -z "$data" ]; then
                curl -X POST "$BASE_URL$endpoint" -w "\n" -s &
            else
                curl -X POST "$BASE_URL$endpoint?$data" -w "\n" -s &
            fi
        elif [ "$method" = "GET" ]; then
            curl -X GET "$BASE_URL$endpoint" -w "\n" -s &
        elif [ "$method" = "PUT" ]; then
            curl -X PUT "$BASE_URL$endpoint?$data" -w "\n" -s &
        fi
    done
    
    wait
    echo -e "${GREEN}All requests sent${NC}"
    echo ""
    sleep 2
}

# Scenario 1: Long-Lived Transaction with External API Call
test_scenario1() {
    echo -e "${RED}=== Scenario 1: Long-Lived Transaction with External API Call ===${NC}"
    echo "This scenario simulates transactions that hold locks while calling external APIs"
    echo "Sending 50 POST + 50 GET requests concurrently (100+ total)"
    echo ""

    echo -e "${YELLOW}Sending 50 POST requests (process-transaction) that hold locks...${NC}"
    for i in {1..50}; do
        curl -X POST "$BASE_URL/scenario1/process-transaction?userId=$i&amount=$((100 + i)).00" -w "\n" -s &
        curl -X GET "$BASE_URL/scenario1/transactions/user/$i" -w "\n" -s &
    done

    wait
    echo -e "${GREEN}All 100 requests completed${NC}"
    echo ""
    sleep 2
}

# Scenario 2: Inconsistent Read–Write Order
test_scenario2() {
    echo -e "${RED}=== Scenario 2: Inconsistent Read–Write Order Across Transactions ===${NC}"
    echo "Sending concurrent requests..."
    echo ""

    # Send both T1 and T2 requests simultaneously (interleaved for maximum collision)
    for i in {1..2}; do
        curl -X POST "$BASE_URL/scenario2/transaction-t1?tableAName=case-$i&tableBDescription=case-$i" -w "\n" -s &
        curl -X POST "$BASE_URL/scenario2/transaction-t2?tableAName=case-$i&tableBDescription=case-$i" -w "\n" -s &
    done

    wait
    echo -e "${GREEN}All requests sent${NC}"
    echo ""
    sleep 2
}

# Scenario 3: Concurrent Delete and Insert
test_scenario3() {
    echo -e "${RED}=== Scenario 3: Concurrent Delete and Insert on the Same Table ===${NC}"
    echo "Multiple transactions deleting 20000 rows and inserting 20000 new rows concurrently"
    echo ""

    # Send concurrent delete-and-insert operations
    echo -e "${YELLOW}Sending concurrent delete-and-insert operations...${NC}"
    for i in {1..20}; do
        curl -X POST "$BASE_URL/scenario3/delete-and-insert?name=cases-$i" -w "\n" -s &
    done

    wait
    echo -e "${GREEN}All requests sent${NC}"
    echo ""
    sleep 2
}

# Scenario 4: Unnecessary JPA Join
test_scenario4() {
    echo -e "${RED}=== Scenario 4: Unnecessary JPA Join Due to Lazy ManyToOne Mapping ===${NC}"
    echo "Concurrent queries with JOIN and product updates"
    echo ""

#     # Simultaneously update products
#     echo -e "${YELLOW}Simultaneously updating products...${NC}"
#     for i in {1..20}; do
#         curl -X PUT "$BASE_URL/scenario4/update-product?productId=3033074&newName=UpdatedProduct$i&newPrice=$((20 + i)).99" -w "\n" -s &
#     done
#
#    # Send queries that cause JOIN
#    echo -e "${YELLOW}Sending queries with JOIN...${NC}"
#    for i in {1..20}; do
#        curl -X GET "$BASE_URL/scenario4/order-items-with-join/3033074" -w "\n" -s &
#    done
#
#    # Simultaneously update products
#    echo -e "${YELLOW}Simultaneously updating products...${NC}"
#    for i in {1..20}; do
#        curl -X PUT "$BASE_URL/scenario4/update-product?productId=3033074&newName=UpdatedProduct$i&newPrice=$((20 + i)).99" -w "\n" -s &
#    done

    for i in {1..100}; do
      curl -s "$BASE_URL/scenario4/order-items-with-join/3033074" > /dev/null &
      curl -s -X PUT "$BASE_URL/scenario4/update-product?productId=3033074&newName=U$i&newPrice=99.99" > /dev/null &
    done

    wait
    echo -e "${GREEN}All requests sent${NC}"
    echo ""
    sleep 2
}

# Initialize test data
initialize_data() {
    echo -e "${GREEN}Initializing test data...${NC}"
    curl -X POST "$BASE_URL/init/setup" -w "\n"
    echo ""
    sleep 1
}

# Main execution
main() {
    scenario=$1
    
    # Initialize data first
    initialize_data
    
    if [ -z "$scenario" ]; then
        echo -e "${YELLOW}No specific scenario specified. Testing all scenarios...${NC}"
        echo ""
        test_scenario1
        test_scenario2
        test_scenario3
        test_scenario4
    else
        case $scenario in
            1)
                test_scenario1
                ;;
            2)
                test_scenario2
                ;;
            3)
                test_scenario3
                ;;
            4)
                test_scenario4
                ;;
            *)
                echo -e "${RED}Invalid scenario number. Use 1, 2, 3, or 4${NC}"
                exit 1
                ;;
        esac
    fi
    
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}All tests completed!${NC}"
    echo -e "${YELLOW}Check your application logs and SQL Server logs for deadlock information${NC}"
}

# Run main function
main "$@"

