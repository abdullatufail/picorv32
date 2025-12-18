#!/bin/bash

# Script to regenerate CSV from existing test results
# Usage: ./regenerate_csv.sh <test_results_directory>

if [ $# -lt 1 ]; then
    echo "Usage: $0 <test_results_directory>"
    exit 1
fi

RESULT_DIR=$1

if [ ! -d "$RESULT_DIR" ]; then
    echo "Error: Directory $RESULT_DIR not found"
    exit 1
fi

SUMMARY_LOG="${RESULT_DIR}/test_summary.log"
CSV_FILE="${RESULT_DIR}/test_metrics.csv"

if [ ! -f "$SUMMARY_LOG" ]; then
    echo "Error: Summary log not found in $RESULT_DIR"
    exit 1
fi

echo "Regenerating CSV for $RESULT_DIR..."

# Create CSV header
echo "Test,Cycles,Instructions,CPI,Status" > "${CSV_FILE}"

# Process each test that has a metrics file
for metrics_file in "${RESULT_DIR}"/*_metrics.txt; do
    if [ -f "$metrics_file" ]; then
        test_name=$(basename "$metrics_file" _metrics.txt)
        
        # Extract numerical values
        cycles=$(grep -o "Cycle counter.*[0-9]\+" "${metrics_file}" | grep -o "[0-9]\+" | head -1)
        instrs=$(grep -o "Instruction counter.*[0-9]\+" "${metrics_file}" | grep -o "[0-9]\+" | head -1)
        cpi=$(grep -o "CPI:.*[0-9.]\+" "${metrics_file}" | grep -o "[0-9.]\+" | head -1)
        
        # Check if test passed by looking at the summary log
        if grep -q "^\[PASS\] ${test_name}" "${SUMMARY_LOG}"; then
            status="PASSED"
        elif grep -q "^\[FAIL\] ${test_name}" "${SUMMARY_LOG}"; then
            status="FAILED"
        else
            # Fallback: check for common success indicators in the log
            if [ -f "${RESULT_DIR}/${test_name}.log" ]; then
                if grep -qi "ALL TESTS PASSED\|DONE" "${RESULT_DIR}/${test_name}.log" && ! grep -qi "ERROR.*FAILED" "${RESULT_DIR}/${test_name}.log"; then
                    status="PASSED"
                else
                    status="UNKNOWN"
                fi
            else
                status="UNKNOWN"
            fi
        fi
        
        echo "${test_name},${cycles:-N/A},${instrs:-N/A},${cpi:-N/A},${status}" >> "${CSV_FILE}"
    fi
done

echo "CSV regenerated: $CSV_FILE"
echo ""
column -t -s',' "${CSV_FILE}"
