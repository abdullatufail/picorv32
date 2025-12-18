#!/bin/bash

# Script to run all available make test targets and save output
# Author: Automated test runner
# Date: December 18, 2025

# Create output directory with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="test_results_${TIMESTAMP}"
mkdir -p "${OUTPUT_DIR}"

# Log file for summary
SUMMARY_LOG="${OUTPUT_DIR}/test_summary.log"
MAIN_LOG="${OUTPUT_DIR}/all_tests_combined.log"

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to run a test and capture output
run_test() {
    local test_name=$1
    local output_file="${OUTPUT_DIR}/${test_name}.log"
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Running: make ${test_name}${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    # Record start time
    start_time=$(date +%s)
    
    # Run the test and capture output
    if make ${test_name} > "${output_file}" 2>&1; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        echo -e "${GREEN}✓ ${test_name} PASSED${NC} (${duration}s)"
        echo "[PASS] ${test_name} (${duration}s)" >> "${SUMMARY_LOG}"
        return 0
    else
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        echo -e "${RED}✗ ${test_name} FAILED${NC} (${duration}s)"
        echo "[FAIL] ${test_name} (${duration}s)" >> "${SUMMARY_LOG}"
        return 1
    fi
}

# Function to extract performance metrics from test output
extract_metrics() {
    local test_name=$1
    local output_file="${OUTPUT_DIR}/${test_name}.log"
    local metrics_file="${OUTPUT_DIR}/${test_name}_metrics.txt"
    
    echo "=== Performance Metrics for ${test_name} ===" > "${metrics_file}"
    
    # Extract cycle counts
    grep -i "cycle" "${output_file}" >> "${metrics_file}" 2>/dev/null
    
    # Extract instruction counts
    grep -i "instr" "${output_file}" >> "${metrics_file}" 2>/dev/null
    
    # Extract CPI
    grep -i "CPI" "${output_file}" >> "${metrics_file}" 2>/dev/null
    
    # Extract timing information
    grep -i "time" "${output_file}" >> "${metrics_file}" 2>/dev/null
    
    # Extract test results
    grep -i "PASSED\|FAILED\|ERROR" "${output_file}" >> "${metrics_file}" 2>/dev/null
    
    echo "" >> "${metrics_file}"
}

# Initialize summary log
echo "=====================================" > "${SUMMARY_LOG}"
echo "PicoRV32 Test Suite Execution Report" >> "${SUMMARY_LOG}"
echo "Date: $(date)" >> "${SUMMARY_LOG}"
echo "=====================================" >> "${SUMMARY_LOG}"
echo "" >> "${SUMMARY_LOG}"

# Start main log
echo "=====================================" > "${MAIN_LOG}"
echo "Combined Test Output" >> "${MAIN_LOG}"
echo "=====================================" >> "${MAIN_LOG}"
echo "" >> "${MAIN_LOG}"

# Counter for passed/failed tests
passed=0
failed=0
total=0

# Array of test targets to run
# Note: Excluding VCD tests to avoid generating large waveform files
# You can add them back if needed by uncommenting the lines
TESTS=(
    "test_mod"      # Main test with AES accelerator
    "test_tb"       # AES standalone testbench
    "test"          # Basic testbench
    # "test_vcd"    # Uncomment to generate VCD waveforms
    "test_wb"       # Wishbone interface test
    # "test_wb_vcd" # Uncomment to generate VCD waveforms
    "test_ez"       # Easy testbench
    # "test_ez_vcd" # Uncomment to generate VCD waveforms
    "test_sp"       # Stack pointer test
    "test_axi"      # AXI interface test
)

# Optional tests that might not always work
OPTIONAL_TESTS=(
    # "test_rvf"      # RISC-V Formal verification (requires rvfimon.v)
    # "test_synth"    # Synthesis test (requires synth.v)
    # "test_verilator" # Verilator test (requires Verilator)
)

echo -e "${YELLOW}╔════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║  PicoRV32 Test Suite Execution        ║${NC}"
echo -e "${YELLOW}║  Output Directory: ${OUTPUT_DIR}  ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════╝${NC}"
echo ""

# Run all tests
for test in "${TESTS[@]}"; do
    total=$((total + 1))
    if run_test "${test}"; then
        passed=$((passed + 1))
        extract_metrics "${test}"
    else
        failed=$((failed + 1))
        extract_metrics "${test}"
    fi
    echo ""
    
    # Append to combined log
    echo "========================================" >> "${MAIN_LOG}"
    echo "Test: ${test}" >> "${MAIN_LOG}"
    echo "========================================" >> "${MAIN_LOG}"
    cat "${OUTPUT_DIR}/${test}.log" >> "${MAIN_LOG}"
    echo "" >> "${MAIN_LOG}"
    echo "" >> "${MAIN_LOG}"
done

# Generate summary statistics
echo "" >> "${SUMMARY_LOG}"
echo "=====================================" >> "${SUMMARY_LOG}"
echo "Test Summary" >> "${SUMMARY_LOG}"
echo "=====================================" >> "${SUMMARY_LOG}"
echo "Total Tests: ${total}" >> "${SUMMARY_LOG}"
echo "Passed: ${passed}" >> "${SUMMARY_LOG}"
echo "Failed: ${failed}" >> "${SUMMARY_LOG}"
if [ ${total} -gt 0 ]; then
    success_rate=$((passed * 100 / total))
    echo "Success Rate: ${success_rate}%" >> "${SUMMARY_LOG}"
fi
echo "=====================================" >> "${SUMMARY_LOG}"

# Create a CSV file with metrics for easy analysis
CSV_FILE="${OUTPUT_DIR}/test_metrics.csv"
echo "Test,Cycles,Instructions,CPI,Status" > "${CSV_FILE}"

for test in "${TESTS[@]}"; do
    metrics_file="${OUTPUT_DIR}/${test}_metrics.txt"
    if [ -f "${metrics_file}" ]; then
        # Extract numerical values (this is a simple extraction, may need refinement)
        cycles=$(grep -o "Cycle counter.*[0-9]\+" "${metrics_file}" | grep -o "[0-9]\+" | head -1)
        instrs=$(grep -o "Instruction counter.*[0-9]\+" "${metrics_file}" | grep -o "[0-9]\+" | head -1)
        cpi=$(grep -o "CPI:.*[0-9.]\+" "${metrics_file}" | grep -o "[0-9.]\+" | head -1)
        
        # Check if test passed by looking at the summary log
        if grep -q "^\[PASS\] ${test}" "${SUMMARY_LOG}"; then
            status="PASSED"
        elif grep -q "^\[FAIL\] ${test}" "${SUMMARY_LOG}"; then
            status="FAILED"
        else
            # Fallback: check for common success indicators in the log
            if grep -qi "ALL TESTS PASSED\|DONE" "${OUTPUT_DIR}/${test}.log" && ! grep -qi "ERROR\|FAILED" "${OUTPUT_DIR}/${test}.log"; then
                status="PASSED"
            else
                status="UNKNOWN"
            fi
        fi
        
        echo "${test},${cycles:-N/A},${instrs:-N/A},${cpi:-N/A},${status}" >> "${CSV_FILE}"
    fi
done

# Print final summary to console
echo ""
echo -e "${YELLOW}╔════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║         Test Execution Complete        ║${NC}"
echo -e "${YELLOW}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "Total Tests:  ${total}"
echo -e "${GREEN}Passed:       ${passed}${NC}"
echo -e "${RED}Failed:       ${failed}${NC}"
if [ ${total} -gt 0 ]; then
    success_rate=$((passed * 100 / total))
    if [ ${success_rate} -ge 80 ]; then
        echo -e "${GREEN}Success Rate: ${success_rate}%${NC}"
    elif [ ${success_rate} -ge 50 ]; then
        echo -e "${YELLOW}Success Rate: ${success_rate}%${NC}"
    else
        echo -e "${RED}Success Rate: ${success_rate}%${NC}"
    fi
fi
echo ""
echo -e "Results saved in: ${BLUE}${OUTPUT_DIR}/${NC}"
echo -e "  - Summary:      ${SUMMARY_LOG}"
echo -e "  - Combined Log: ${MAIN_LOG}"
echo -e "  - Metrics CSV:  ${CSV_FILE}"
echo -e "  - Individual test logs and metrics in ${OUTPUT_DIR}/"
echo ""

# Display summary log
echo -e "${YELLOW}════════════════════════════════════════${NC}"
cat "${SUMMARY_LOG}"
echo -e "${YELLOW}════════════════════════════════════════${NC}"

exit 0
