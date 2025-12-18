# Test Scripts Documentation

This directory contains automated test scripts for the PicoRV32 AES Accelerator project.

## Available Scripts

### 1. `run_all_tests.sh` - Comprehensive Test Suite

Runs all available test targets and generates detailed reports.

**Usage:**

```bash
./run_all_tests.sh
```

**Features:**

- Runs all major test targets (test_mod, test, test_tb, test_wb, test_ez, test_sp, test_axi)
- Creates timestamped output directory with all results
- Generates individual log files for each test
- Extracts performance metrics (cycles, instructions, CPI)
- Creates summary report and CSV file for analysis
- Color-coded output for easy identification of pass/fail

**Output Files:**

- `test_results_YYYYMMDD_HHMMSS/` - Main results directory
  - `test_summary.log` - Summary of all test results
  - `all_tests_combined.log` - Combined output from all tests
  - `test_metrics.csv` - Performance metrics in CSV format
  - `<test_name>.log` - Individual test output
  - `<test_name>_metrics.txt` - Extracted performance metrics per test

**Example:**

```bash
./run_all_tests.sh

# Results will be saved in a directory like:
# test_results_20251218_143052/
```

### 2. `quick_test.sh` - Quick Test Runner

Runs the most important tests quickly, or a single specific test.

**Usage:**

```bash
# Run the 3 main tests
./quick_test.sh

# Run a specific test
./quick_test.sh test_mod
./quick_test.sh test
./quick_test.sh test_tb
```

**Features:**

- Fast execution (runs only essential tests)
- Single test execution option
- Creates timestamped output directory
- Real-time output display (using tee)
- Quick summary at the end

**Output Files:**

- `quick_test_YYYYMMDD_HHMMSS/` - Results directory
  - `<test_name>.log` - Test output

## Available Test Targets

| Test Target      | Description                                        |
| ---------------- | -------------------------------------------------- |
| `test_mod`       | Main test with AES accelerator integrated via AXI4 |
| `test_tb`        | Standalone AES hardware testbench                  |
| `test`           | Basic PicoRV32 testbench                           |
| `test_vcd`       | Basic test with VCD waveform generation            |
| `test_wb`        | Wishbone interface test                            |
| `test_wb_vcd`    | Wishbone test with VCD waveforms                   |
| `test_ez`        | Easy/simple testbench                              |
| `test_ez_vcd`    | Easy test with VCD waveforms                       |
| `test_sp`        | Stack pointer test                                 |
| `test_axi`       | AXI interface specific test                        |
| `test_rvf`       | RISC-V Formal verification (requires rvfimon.v)    |
| `test_synth`     | Synthesis test (requires synth.v)                  |
| `test_verilator` | Verilator-based test (requires Verilator)          |

**Note:** VCD tests generate large waveform files and are disabled by default in `run_all_tests.sh`.
You can enable them by uncommenting the lines in the TESTS array.

## Performance Metrics Extracted

The scripts automatically extract the following metrics from test output:

- **Cycle Count** - Total clock cycles
- **Instruction Count** - Total instructions executed
- **CPI** - Cycles per instruction
- **Software vs Hardware Performance** - Comparison for AES operations
- **Test Status** - PASSED/FAILED

## Example Output

### run_all_tests.sh output:

```
╔════════════════════════════════════════╗
║  PicoRV32 Test Suite Execution        ║
║  Output Directory: test_results_...   ║
╚════════════════════════════════════════╝

========================================
Running: make test_mod
========================================

✓ test_mod PASSED (25s)

========================================
Running: make test
========================================

✓ test PASSED (18s)

...

╔════════════════════════════════════════╗
║         Test Execution Complete        ║
╚════════════════════════════════════════╝

Total Tests:  8
Passed:       8
Failed:       0
Success Rate: 100%
```

### CSV Output (test_metrics.csv):

```csv
Test,Cycles,Instructions,CPI,Status
test_mod,372817,84456,4.41,PASSED
test,414158,N/A,N/A,PASSED
test_tb,N/A,N/A,N/A,PASSED
```

## Tips

1. **Store results systematically:**

   ```bash
   # Create a results archive directory
   mkdir -p test_archives
   ./run_all_tests.sh
   mv test_results_* test_archives/
   ```

2. **Compare results between runs:**

   ```bash
   # After making changes, compare CSV files
   diff test_archives/test_results_20251218_120000/test_metrics.csv \
        test_archives/test_results_20251218_140000/test_metrics.csv
   ```

3. **Extract specific metrics:**

   ```bash
   # Get CPI values from all test runs
   grep "CPI" test_archives/*/test_mod.log
   ```

4. **Monitor long-running tests:**
   ```bash
   # Run in background and monitor
   ./run_all_tests.sh &
   tail -f test_results_*/all_tests_combined.log
   ```

## Troubleshooting

**Issue:** Tests fail due to missing testbench files

- **Solution:** Run `make clean` then rebuild: `make testbench_mod.vvp`

**Issue:** VVP version mismatch error

- **Solution:** The testbench files need to be recompiled with your Icarus Verilog version
  ```bash
  make clean
  ./run_all_tests.sh
  ```

**Issue:** RISC-V toolchain not found

- **Solution:** Ensure `riscv64-unknown-elf-gcc` is in your PATH
  ```bash
  which riscv64-unknown-elf-gcc
  ```

## Requirements

- Icarus Verilog (iverilog, vvp)
- RISC-V GCC toolchain (riscv64-unknown-elf-gcc)
- Make
- Bash shell
- Python 3 (for firmware hex generation)

## Contributing

To add new tests to the automated suite:

1. Add the test target to the `TESTS` array in `run_all_tests.sh`
2. Ensure the test outputs standard success/failure messages
3. Update this README with the new test description
