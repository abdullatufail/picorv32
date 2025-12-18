#!/bin/bash

# Quick test script - runs only the main tests
# Usage: ./quick_test.sh [test_name]
#   If test_name is provided, runs only that test
#   Otherwise runs the most important tests

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="quick_test_${TIMESTAMP}"
mkdir -p "${OUTPUT_DIR}"

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ $# -eq 1 ]; then
    # Run single test
    TEST_NAME=$1
    echo -e "${BLUE}Running single test: ${TEST_NAME}${NC}"
    make ${TEST_NAME} 2>&1 | tee "${OUTPUT_DIR}/${TEST_NAME}.log"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo -e "${GREEN}✓ Test PASSED${NC}"
    else
        echo -e "${RED}✗ Test FAILED${NC}"
    fi
else
    # Run important tests
    echo -e "${BLUE}Running quick test suite...${NC}\n"
    
    # Test 1: Main test with AES accelerator
    echo -e "${BLUE}[1/3] Running test_mod (AES accelerator test)...${NC}"
    make test_mod 2>&1 | tee "${OUTPUT_DIR}/test_mod.log"
    TEST1=$?
    
    # Test 2: Basic test
    echo -e "\n${BLUE}[2/3] Running test (basic test)...${NC}"
    make test 2>&1 | tee "${OUTPUT_DIR}/test.log"
    TEST2=$?
    
    # Test 3: AES standalone
    echo -e "\n${BLUE}[3/3] Running test_tb (AES standalone)...${NC}"
    make test_tb 2>&1 | tee "${OUTPUT_DIR}/test_tb.log"
    TEST3=$?
    
    # Summary
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}Quick Test Summary${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    [ $TEST1 -eq 0 ] && echo -e "${GREEN}✓${NC} test_mod (AES accelerator)" || echo -e "${RED}✗${NC} test_mod (AES accelerator)"
    [ $TEST2 -eq 0 ] && echo -e "${GREEN}✓${NC} test (basic)" || echo -e "${RED}✗${NC} test (basic)"
    [ $TEST3 -eq 0 ] && echo -e "${GREEN}✓${NC} test_tb (AES standalone)" || echo -e "${RED}✗${NC} test_tb (AES standalone)"
    
    TOTAL=3
    PASSED=0
    [ $TEST1 -eq 0 ] && PASSED=$((PASSED + 1))
    [ $TEST2 -eq 0 ] && PASSED=$((PASSED + 1))
    [ $TEST3 -eq 0 ] && PASSED=$((PASSED + 1))
    
    echo -e "\nPassed: ${PASSED}/${TOTAL}"
    echo -e "Results in: ${OUTPUT_DIR}/"
fi
