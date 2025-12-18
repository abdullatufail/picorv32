#!/bin/bash

# Script to analyze and compare test results
# Usage: ./analyze_results.sh <test_results_directory>

if [ $# -lt 1 ]; then
    echo "Usage: $0 <test_results_directory> [comparison_directory]"
    echo ""
    echo "Examples:"
    echo "  $0 test_results_20251218_143052"
    echo "  $0 test_results_20251218_143052 test_results_20251218_120000"
    exit 1
fi

RESULT_DIR=$1
COMPARE_DIR=${2:-""}

if [ ! -d "$RESULT_DIR" ]; then
    echo "Error: Directory $RESULT_DIR not found"
    exit 1
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     PicoRV32 Test Results Analysis    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Display summary
if [ -f "$RESULT_DIR/test_summary.log" ]; then
    echo -e "${YELLOW}Test Summary:${NC}"
    cat "$RESULT_DIR/test_summary.log"
    echo ""
fi

# Analyze test_mod (AES accelerator) performance
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}AES Accelerator Performance (test_mod)${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"

if [ -f "$RESULT_DIR/test_mod.log" ]; then
    echo ""
    echo -e "${YELLOW}Software Implementation:${NC}"
    grep -A1 "Expanding key\|Encrypting\|Decrypting" "$RESULT_DIR/test_mod.log" | grep "Instr\|Cycles" | head -6
    
    echo ""
    echo -e "${YELLOW}Hardware Accelerator:${NC}"
    grep "Number of cycles taken\|Number of instrucs taken\|CPI =" "$RESULT_DIR/test_mod.log" | head -6
    
    echo ""
    echo -e "${YELLOW}Total Performance:${NC}"
    grep "Cycle counter\|Instruction counter\|CPI:" "$RESULT_DIR/test_mod.log"
    
    # Calculate speedup
    echo ""
    echo -e "${YELLOW}Performance Analysis:${NC}"
    
    # Extract software encryption cycles
    sw_encrypt_cycles=$(grep -A1 "Encrypting..." "$RESULT_DIR/test_mod.log" | grep "Cycles" | grep -o "[0-9]\+" | head -1)
    sw_decrypt_cycles=$(grep -A1 "Decrypting..." "$RESULT_DIR/test_mod.log" | grep "Cycles" | grep -o "[0-9]\+" | head -1)
    
    # Extract hardware cycles
    hw_encrypt_cycles=$(grep "Number of cycles taken" "$RESULT_DIR/test_mod.log" | head -1 | grep -o "[0-9]\+")
    hw_decrypt_cycles=$(grep "Number of cycles taken" "$RESULT_DIR/test_mod.log" | tail -1 | grep -o "[0-9]\+")
    
    if [ -n "$sw_encrypt_cycles" ] && [ -n "$hw_encrypt_cycles" ]; then
        speedup_encrypt=$(echo "scale=2; $sw_encrypt_cycles / $hw_encrypt_cycles" | bc)
        echo -e "  Encryption Speedup: ${GREEN}${speedup_encrypt}x${NC} (SW: $sw_encrypt_cycles cycles → HW: $hw_encrypt_cycles cycles)"
    fi
    
    if [ -n "$sw_decrypt_cycles" ] && [ -n "$hw_decrypt_cycles" ]; then
        speedup_decrypt=$(echo "scale=2; $sw_decrypt_cycles / $hw_decrypt_cycles" | bc)
        echo -e "  Decryption Speedup: ${GREEN}${speedup_decrypt}x${NC} (SW: $sw_decrypt_cycles cycles → HW: $hw_decrypt_cycles cycles)"
    fi
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}All Tests Performance Metrics${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

# Display CSV if available
if [ -f "$RESULT_DIR/test_metrics.csv" ]; then
    # Pretty print the CSV
    column -t -s',' "$RESULT_DIR/test_metrics.csv"
fi

# Comparison mode
if [ -n "$COMPARE_DIR" ] && [ -d "$COMPARE_DIR" ]; then
    echo ""
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}Comparison with $COMPARE_DIR${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo ""
    
    if [ -f "$RESULT_DIR/test_metrics.csv" ] && [ -f "$COMPARE_DIR/test_metrics.csv" ]; then
        echo -e "${YELLOW}Current Results:${NC}"
        column -t -s',' "$RESULT_DIR/test_metrics.csv"
        echo ""
        echo -e "${YELLOW}Previous Results:${NC}"
        column -t -s',' "$COMPARE_DIR/test_metrics.csv"
        echo ""
        
        # Calculate differences
        echo -e "${YELLOW}Changes:${NC}"
        
        # Compare test_mod cycles
        current_cycles=$(grep "test_mod" "$RESULT_DIR/test_metrics.csv" | cut -d',' -f2)
        previous_cycles=$(grep "test_mod" "$COMPARE_DIR/test_metrics.csv" | cut -d',' -f2)
        
        if [ "$current_cycles" != "N/A" ] && [ "$previous_cycles" != "N/A" ] && [ -n "$current_cycles" ] && [ -n "$previous_cycles" ]; then
            diff_cycles=$((current_cycles - previous_cycles))
            if [ $diff_cycles -lt 0 ]; then
                echo -e "  test_mod cycles: ${GREEN}${diff_cycles}${NC} (improved)"
            elif [ $diff_cycles -gt 0 ]; then
                echo -e "  test_mod cycles: ${RED}+${diff_cycles}${NC} (regressed)"
            else
                echo -e "  test_mod cycles: ${BLUE}No change${NC}"
            fi
        fi
    fi
fi

# Find and display any errors or failures
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}Error Summary${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

error_count=0
for logfile in "$RESULT_DIR"/*.log; do
    if [ -f "$logfile" ]; then
        test_name=$(basename "$logfile" .log)
        if grep -qi "error\|failed\|trap" "$logfile" 2>/dev/null; then
            if ! grep -q "ALL TESTS PASSED" "$logfile" 2>/dev/null; then
                echo -e "${RED}✗${NC} $test_name may have errors (check $logfile)"
                error_count=$((error_count + 1))
            fi
        fi
    fi
done

if [ $error_count -eq 0 ]; then
    echo -e "${GREEN}No errors detected in test outputs${NC}"
fi

# List all available log files
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}Available Log Files${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""
ls -lh "$RESULT_DIR"/*.log 2>/dev/null | awk '{print $9, "(" $5 ")"}'

echo ""
echo -e "${YELLOW}For detailed analysis, view:${NC}"
echo -e "  All tests:       cat $RESULT_DIR/all_tests_combined.log"
echo -e "  Specific test:   cat $RESULT_DIR/<test_name>.log"
echo -e "  Metrics:         cat $RESULT_DIR/<test_name>_metrics.txt"
echo ""
