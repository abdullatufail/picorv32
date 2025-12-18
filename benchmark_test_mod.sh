#!/bin/bash

# Script to run test_mod multiple times and generate statistical analysis
# Usage: ./benchmark_test_mod.sh [number_of_runs]
#
# This is useful for:
# - Performance benchmarking
# - Statistical analysis of cycle counts
# - Detecting variance in execution
# - Generating data for performance graphs

# Default number of runs
DEFAULT_RUNS=100
N=${1:-$DEFAULT_RUNS}

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Validate input
if ! [[ "$N" =~ ^[0-9]+$ ]] || [ "$N" -lt 1 ]; then
    echo -e "${RED}Error: Number of runs must be a positive integer${NC}"
    echo "Usage: $0 [number_of_runs]"
    echo "Example: $0 100"
    exit 1
fi

# Create output directory
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="benchmark_${N}runs_${TIMESTAMP}"
mkdir -p "${OUTPUT_DIR}"

RAW_DATA="${OUTPUT_DIR}/raw_data.csv"
STATS_FILE="${OUTPUT_DIR}/statistics.txt"
SUMMARY_FILE="${OUTPUT_DIR}/summary.txt"
PLOT_DATA="${OUTPUT_DIR}/plot_data.csv"

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     PicoRV32 AES Accelerator Benchmark Suite         ║${NC}"
echo -e "${BLUE}║                                                        ║${NC}"
echo -e "${BLUE}║  Running test_mod ${N} times...                          ${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Initialize CSV files
echo "Run,SW_Encrypt_Cycles,SW_Decrypt_Cycles,HW_Encrypt_Cycles,HW_Decrypt_Cycles,Total_Cycles,Total_Instructions,CPI,Status" > "${RAW_DATA}"

# Arrays to store data for statistics
declare -a sw_encrypt_cycles_arr
declare -a sw_decrypt_cycles_arr
declare -a hw_encrypt_cycles_arr
declare -a hw_decrypt_cycles_arr
declare -a total_cycles_arr
declare -a total_instrs_arr
declare -a cpi_arr

passed=0
failed=0

# Progress bar function
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\r${CYAN}Progress: [${NC}"
    printf "%${completed}s" | tr ' ' '█'
    printf "%${remaining}s" | tr ' ' '░'
    printf "${CYAN}] ${percentage}%% (${current}/${total})${NC}"
}

echo -e "${YELLOW}Running tests...${NC}"
echo ""

# Run test_mod N times
for ((i=1; i<=N; i++)); do
    show_progress $i $N
    
    # Run test and capture output
    log_file="${OUTPUT_DIR}/run_${i}.log"
    
    if make test_mod > "${log_file}" 2>&1; then
        status="PASS"
        passed=$((passed + 1))
        
        # Extract metrics
        sw_encrypt=$(grep -A2 "Encrypting\.\.\." "${log_file}" | grep "Cycles:" | grep -o "[0-9]\+")
        sw_decrypt=$(grep -A2 "Decrypting\.\.\." "${log_file}" | grep "Cycles:" | grep -o "[0-9]\+")
        hw_encrypt=$(grep "Number of cycles taken" "${log_file}" | head -1 | grep -o "[0-9]\+")
        hw_decrypt=$(grep "Number of cycles taken" "${log_file}" | tail -1 | grep -o "[0-9]\+")
        total_cycles=$(grep "Cycle counter" "${log_file}" | grep -o "[0-9]\+" | head -1)
        total_instrs=$(grep "Instruction counter" "${log_file}" | grep -o "[0-9]\+" | head -1)
        cpi=$(grep "CPI:" "${log_file}" | grep -o "[0-9.]\+" | head -1)
        
        # Store in arrays for statistics
        sw_encrypt_cycles_arr+=($sw_encrypt)
        sw_decrypt_cycles_arr+=($sw_decrypt)
        hw_encrypt_cycles_arr+=($hw_encrypt)
        hw_decrypt_cycles_arr+=($hw_decrypt)
        total_cycles_arr+=($total_cycles)
        total_instrs_arr+=($total_instrs)
        cpi_arr+=($cpi)
        
    else
        status="FAIL"
        failed=$((failed + 1))
        sw_encrypt="N/A"
        sw_decrypt="N/A"
        hw_encrypt="N/A"
        hw_decrypt="N/A"
        total_cycles="N/A"
        total_instrs="N/A"
        cpi="N/A"
    fi
    
    # Write to CSV
    echo "$i,$sw_encrypt,$sw_decrypt,$hw_encrypt,$hw_decrypt,$total_cycles,$total_instrs,$cpi,$status" >> "${RAW_DATA}"
done

echo ""
echo ""
echo -e "${GREEN}✓ Benchmark complete!${NC}"
echo ""

# Calculate statistics
calculate_stats() {
    local arr=("$@")
    local sum=0
    local count=${#arr[@]}
    
    if [ $count -eq 0 ]; then
        echo "0,0,0,0"
        return
    fi
    
    # Calculate mean
    for val in "${arr[@]}"; do
        sum=$(echo "$sum + $val" | bc)
    done
    local mean=$(echo "scale=2; $sum / $count" | bc)
    
    # Find min and max
    local min=${arr[0]}
    local max=${arr[0]}
    for val in "${arr[@]}"; do
        if (( $(echo "$val < $min" | bc -l) )); then
            min=$val
        fi
        if (( $(echo "$val > $max" | bc -l) )); then
            max=$val
        fi
    done
    
    # Calculate standard deviation
    local sum_sq_diff=0
    for val in "${arr[@]}"; do
        local diff=$(echo "$val - $mean" | bc)
        local sq_diff=$(echo "$diff * $diff" | bc)
        sum_sq_diff=$(echo "$sum_sq_diff + $sq_diff" | bc)
    done
    local variance=$(echo "scale=2; $sum_sq_diff / $count" | bc)
    local stddev=$(echo "scale=2; sqrt($variance)" | bc)
    
    echo "$mean,$min,$max,$stddev"
}

# Generate statistics file
{
    echo "======================================================================"
    echo "  PicoRV32 AES Accelerator Benchmark Statistics"
    echo "======================================================================"
    echo ""
    echo "Test Configuration:"
    echo "  Number of runs: $N"
    echo "  Date: $(date)"
    echo "  Output directory: $OUTPUT_DIR"
    echo ""
    echo "Test Results:"
    echo "  Passed: $passed"
    echo "  Failed: $failed"
    echo "  Success Rate: $(echo "scale=2; $passed * 100 / $N" | bc)%"
    echo ""
    echo "======================================================================"
    echo "  Performance Statistics"
    echo "======================================================================"
    echo ""
    
    if [ $passed -gt 0 ]; then
        # Software Encryption
        stats=($(calculate_stats "${sw_encrypt_cycles_arr[@]}"))
        IFS=',' read -ra STATS <<< "$stats"
        echo "Software Encryption Cycles:"
        echo "  Mean:    ${STATS[0]}"
        echo "  Min:     ${STATS[1]}"
        echo "  Max:     ${STATS[2]}"
        echo "  StdDev:  ${STATS[3]}"
        echo ""
        
        # Software Decryption
        stats=($(calculate_stats "${sw_decrypt_cycles_arr[@]}"))
        IFS=',' read -ra STATS <<< "$stats"
        echo "Software Decryption Cycles:"
        echo "  Mean:    ${STATS[0]}"
        echo "  Min:     ${STATS[1]}"
        echo "  Max:     ${STATS[2]}"
        echo "  StdDev:  ${STATS[3]}"
        echo ""
        
        # Hardware Encryption
        stats=($(calculate_stats "${hw_encrypt_cycles_arr[@]}"))
        IFS=',' read -ra STATS <<< "$stats"
        echo "Hardware Encryption Cycles:"
        echo "  Mean:    ${STATS[0]}"
        echo "  Min:     ${STATS[1]}"
        echo "  Max:     ${STATS[2]}"
        echo "  StdDev:  ${STATS[3]}"
        hw_enc_mean=${STATS[0]}
        echo ""
        
        # Hardware Decryption
        stats=($(calculate_stats "${hw_decrypt_cycles_arr[@]}"))
        IFS=',' read -ra STATS <<< "$stats"
        echo "Hardware Decryption Cycles:"
        echo "  Mean:    ${STATS[0]}"
        echo "  Min:     ${STATS[1]}"
        echo "  Max:     ${STATS[2]}"
        echo "  StdDev:  ${STATS[3]}"
        hw_dec_mean=${STATS[0]}
        echo ""
        
        # Total Cycles
        stats=($(calculate_stats "${total_cycles_arr[@]}"))
        IFS=',' read -ra STATS <<< "$stats"
        echo "Total Cycles:"
        echo "  Mean:    ${STATS[0]}"
        echo "  Min:     ${STATS[1]}"
        echo "  Max:     ${STATS[2]}"
        echo "  StdDev:  ${STATS[3]}"
        echo ""
        
        # Total Instructions
        stats=($(calculate_stats "${total_instrs_arr[@]}"))
        IFS=',' read -ra STATS <<< "$stats"
        echo "Total Instructions:"
        echo "  Mean:    ${STATS[0]}"
        echo "  Min:     ${STATS[1]}"
        echo "  Max:     ${STATS[2]}"
        echo "  StdDev:  ${STATS[3]}"
        echo ""
        
        # CPI
        stats=($(calculate_stats "${cpi_arr[@]}"))
        IFS=',' read -ra STATS <<< "$stats"
        echo "CPI (Cycles Per Instruction):"
        echo "  Mean:    ${STATS[0]}"
        echo "  Min:     ${STATS[1]}"
        echo "  Max:     ${STATS[2]}"
        echo "  StdDev:  ${STATS[3]}"
        echo ""
        
        # Calculate speedup
        if [ -n "$hw_enc_mean" ] && [ "$hw_enc_mean" != "0" ]; then
            sw_enc_mean=$(calculate_stats "${sw_encrypt_cycles_arr[@]}" | cut -d',' -f1)
            sw_dec_mean=$(calculate_stats "${sw_decrypt_cycles_arr[@]}" | cut -d',' -f1)
            
            enc_speedup=$(echo "scale=2; $sw_enc_mean / $hw_enc_mean" | bc)
            dec_speedup=$(echo "scale=2; $sw_dec_mean / $hw_dec_mean" | bc)
            
            echo "======================================================================"
            echo "  Hardware Acceleration Speedup"
            echo "======================================================================"
            echo ""
            echo "Encryption Speedup: ${enc_speedup}x faster"
            echo "Decryption Speedup: ${dec_speedup}x faster"
            echo ""
        fi
    else
        echo "No successful runs to analyze."
    fi
    
    echo "======================================================================"
    echo ""
} | tee "${STATS_FILE}"

# Create plot-ready data (for easy import to plotting tools)
{
    echo "Metric,Mean,Min,Max,StdDev"
    
    stats=($(calculate_stats "${sw_encrypt_cycles_arr[@]}"))
    IFS=',' read -ra STATS <<< "$stats"
    echo "SW_Encrypt,${STATS[0]},${STATS[1]},${STATS[2]},${STATS[3]}"
    
    stats=($(calculate_stats "${sw_decrypt_cycles_arr[@]}"))
    IFS=',' read -ra STATS <<< "$stats"
    echo "SW_Decrypt,${STATS[0]},${STATS[1]},${STATS[2]},${STATS[3]}"
    
    stats=($(calculate_stats "${hw_encrypt_cycles_arr[@]}"))
    IFS=',' read -ra STATS <<< "$stats"
    echo "HW_Encrypt,${STATS[0]},${STATS[1]},${STATS[2]},${STATS[3]}"
    
    stats=($(calculate_stats "${hw_decrypt_cycles_arr[@]}"))
    IFS=',' read -ra STATS <<< "$stats"
    echo "HW_Decrypt,${STATS[0]},${STATS[1]},${STATS[2]},${STATS[3]}"
    
    stats=($(calculate_stats "${total_cycles_arr[@]}"))
    IFS=',' read -ra STATS <<< "$stats"
    echo "Total_Cycles,${STATS[0]},${STATS[1]},${STATS[2]},${STATS[3]}"
    
    stats=($(calculate_stats "${cpi_arr[@]}"))
    IFS=',' read -ra STATS <<< "$stats"
    echo "CPI,${STATS[0]},${STATS[1]},${STATS[2]},${STATS[3]}"
} > "${PLOT_DATA}"

# Create summary
{
    echo "Benchmark Summary"
    echo "================="
    echo "Runs: $N"
    echo "Passed: $passed ($((passed * 100 / N))%)"
    echo "Failed: $failed"
    echo ""
    echo "Output Files:"
    echo "  Raw Data:    ${RAW_DATA}"
    echo "  Statistics:  ${STATS_FILE}"
    echo "  Plot Data:   ${PLOT_DATA}"
    echo "  Individual:  ${OUTPUT_DIR}/run_*.log"
} > "${SUMMARY_FILE}"

# Display final summary
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Final Summary${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Total Runs:${NC}     $N"
echo -e "${GREEN}Passed:${NC}        $passed ($(echo "scale=1; $passed * 100 / $N" | bc)%)"
if [ $failed -gt 0 ]; then
    echo -e "${RED}Failed:${NC}        $failed ($(echo "scale=1; $failed * 100 / $N" | bc)%)"
fi
echo ""
echo -e "${YELLOW}Output Directory:${NC} ${OUTPUT_DIR}/"
echo ""
echo -e "${CYAN}Generated Files:${NC}"
echo -e "  📊 Raw data CSV:        ${RAW_DATA}"
echo -e "  📈 Statistics report:   ${STATS_FILE}"
echo -e "  📉 Plot data CSV:       ${PLOT_DATA}"
echo -e "  📝 Summary:             ${SUMMARY_FILE}"
echo -e "  📁 Individual logs:     ${OUTPUT_DIR}/run_*.log"
echo ""
echo -e "${YELLOW}Quick View:${NC}"
echo -e "  cat ${STATS_FILE}"
echo -e "  cat ${PLOT_DATA}"
echo ""
echo -e "${GREEN}✓ Benchmark complete!${NC}"
echo ""

exit 0
