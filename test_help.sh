#!/bin/bash

# Helper script to display available test commands
# Usage: ./test_help.sh

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  PicoRV32 AES Accelerator - Test Scripts Help        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Available Test Scripts:${NC}"
echo ""
echo -e "${GREEN}1. Quick Single Test${NC}"
echo "   ./quick_test.sh test_mod"
echo "   Run the main AES accelerator test quickly"
echo ""

echo -e "${GREEN}2. Quick Test Suite${NC}"
echo "   ./quick_test.sh"
echo "   Run the 3 most important tests (test_mod, test, test_tb)"
echo ""

echo -e "${GREEN}3. Full Test Suite${NC}"
echo "   ./run_all_tests.sh"
echo "   Run all available tests and generate detailed reports"
echo ""

echo -e "${GREEN}4. Analyze Results${NC}"
echo "   ./analyze_results.sh test_results_YYYYMMDD_HHMMSS/"
echo "   Analyze test results and show performance metrics"
echo ""

echo -e "${GREEN}5. Benchmark test_mod${NC}"
echo "   ./benchmark_test_mod.sh 100"
echo "   Run test_mod 100 times and generate statistical analysis"
echo ""

echo -e "${YELLOW}Individual Make Targets:${NC}"
echo ""
echo "   make test_mod      - Main test with AES accelerator"
echo "   make test_tb       - AES standalone testbench"
echo "   make test          - Basic PicoRV32 test"
echo "   make test_wb       - Wishbone interface test"
echo "   make test_ez       - Simple testbench"
echo "   make test_sp       - Stack pointer test"
echo "   make test_axi      - AXI interface test"
echo ""

echo -e "${YELLOW}Common Workflows:${NC}"
echo ""
echo -e "${BLUE}First Time Setup:${NC}"
echo "   make                    # Build firmware and tests"
echo "   ./quick_test.sh         # Verify everything works"
echo ""

echo -e "${BLUE}Daily Testing:${NC}"
echo "   ./quick_test.sh test_mod    # Quick verification"
echo ""

echo -e "${BLUE}Before Committing Changes:${NC}"
echo "   ./run_all_tests.sh          # Full test suite"
echo "   ./analyze_results.sh test_results_*/  # Review results"
echo ""

echo -e "${BLUE}Performance Comparison:${NC}"
echo "   ./run_all_tests.sh"
echo "   mv test_results_* baseline/"
echo "   # Make changes..."
echo "   ./run_all_tests.sh"
echo "   ./analyze_results.sh test_results_* baseline/test_results_*"
echo ""

echo -e "${YELLOW}Output Directories:${NC}"
echo ""
echo "   test_results_*/     - Full test suite results"
echo "   quick_test_*/       - Quick test results"
echo ""

echo -e "${YELLOW}Documentation:${NC}"
echo ""
echo "   cat TESTING_GUIDE.md          - Quick reference guide"
echo "   cat TEST_SCRIPTS_README.md    - Detailed documentation"
echo "   cat BENCHMARK_GUIDE.md        - Benchmark script guide"
echo ""

echo -e "${YELLOW}Need Help?${NC}"
echo ""
echo "   ./test_help.sh                - Show this help"
echo "   ./quick_test.sh --help        - Quick test help (not implemented)"
echo "   ./run_all_tests.sh --help     - Full suite help (not implemented)"
echo ""

# Show current status
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Current Status${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""

# Check if firmware is built
if [ -f "firmware/firmware.hex" ]; then
    echo -e "${GREEN}✓${NC} Firmware built (firmware/firmware.hex)"
else
    echo -e "${YELLOW}✗${NC} Firmware not built - run 'make' first"
fi

# Check if testbenches are compiled
if [ -f "testbench_mod.vvp" ]; then
    echo -e "${GREEN}✓${NC} Main testbench compiled (testbench_mod.vvp)"
else
    echo -e "${YELLOW}✗${NC} Main testbench not compiled - run 'make testbench_mod.vvp'"
fi

# Check for recent test results
recent_results=$(ls -dt test_results_* 2>/dev/null | head -1)
if [ -n "$recent_results" ]; then
    echo -e "${GREEN}✓${NC} Recent test results: $recent_results"
else
    echo -e "${YELLOW}✗${NC} No test results found - run tests to generate results"
fi

echo ""
echo -e "${GREEN}Ready to test!${NC} Try: ${BLUE}./quick_test.sh test_mod${NC}"
echo ""
