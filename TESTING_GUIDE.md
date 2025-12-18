# PicoRV32 AES Accelerator Test Scripts

Quick reference guide for running and analyzing tests.

## Quick Start

### Run a Single Test

```bash
./quick_test.sh test_mod
```

### Run All Tests

```bash
./run_all_tests.sh
```

### Analyze Results

```bash
./analyze_results.sh test_results_YYYYMMDD_HHMMSS/
```

## Script Overview

| Script                  | Purpose                                  | Output                                              |
| ----------------------- | ---------------------------------------- | --------------------------------------------------- |
| `run_all_tests.sh`      | Run comprehensive test suite             | `test_results_*/` directory with logs, metrics, CSV |
| `quick_test.sh`         | Run quick tests or single test           | `quick_test_*/` directory with logs                 |
| `analyze_results.sh`    | Analyze test results and extract metrics | Console output with performance analysis            |
| `benchmark_test_mod.sh` | Run test_mod N times for statistics      | `benchmark_*/` with detailed stats and CSV          |

## Common Workflows

### 1. Quick Verification

Test that everything works:

```bash
./quick_test.sh test_mod
```

### 2. Full Test Run

Run all tests and save results:

```bash
./run_all_tests.sh
# Results saved in test_results_YYYYMMDD_HHMMSS/
```

### 3. Analyze Performance

View performance metrics:

```bash
./analyze_results.sh test_results_YYYYMMDD_HHMMSS/
```

### 4. Compare Before/After Changes

Compare results from two test runs:

```bash
# Save baseline
./run_all_tests.sh
mv test_results_* baseline_results/

# Make your code changes
# ...

# Run tests again
./run_all_tests.sh

# Compare
./analyze_results.sh test_results_* baseline_results/test_results_*
```

### 5. Archive Results

Save test results for future reference:

```bash
mkdir -p test_archives
./run_all_tests.sh
mv test_results_* test_archives/
```

### 6. Benchmark Performance

Run test_mod multiple times for statistical analysis:

```bash
# Run 100 times (default)
./benchmark_test_mod.sh 100

# Results in benchmark_100runs_*/
# - raw_data.csv (all runs)
# - plot_data.csv (statistics)
# - statistics.txt (detailed report)
```

See `BENCHMARK_GUIDE.md` for details.

## Understanding Test Output

### test_mod (Main Test)

Shows AES accelerator performance:

- **Software AES**: Baseline performance (pure software)
- **Hardware AES**: Accelerated performance
- **Speedup**: How much faster hardware is vs software

Example output:

```
Software Encryption: 31,456 cycles
Hardware Encryption: 1,132 cycles
Speedup: ~27.8x faster
```

### Performance Metrics

- **Cycles**: Total clock cycles
- **Instructions**: Total instructions executed
- **CPI**: Cycles per instruction (lower is better)

**Note**: Not all tests output detailed performance metrics. Only `test_mod` provides comprehensive cycle/instruction counts because it includes the AES performance comparison. Other tests may show "N/A" for metrics but still report PASSED/FAILED status correctly.

## Files Generated

```
test_results_YYYYMMDD_HHMMSS/
├── test_summary.log          # Overall summary
├── all_tests_combined.log    # All test outputs combined
├── test_metrics.csv          # Performance data in CSV format
├── test_mod.log             # Individual test logs
├── test_mod_metrics.txt     # Extracted metrics
├── test.log
├── test_tb.log
└── ...
```

## Available Tests

- `test_mod` - **Main test** with AES accelerator (RECOMMENDED)
- `test_tb` - AES standalone testbench
- `test` - Basic PicoRV32 test
- `test_wb` - Wishbone interface test
- `test_ez` - Simple testbench
- `test_sp` - Stack pointer test
- `test_axi` - AXI interface test

## Tips

1. **Always run `test_mod` first** - it's the most comprehensive test
2. **Save results** before making changes to compare performance
3. **Use CSV files** for importing into spreadsheets/plotting tools
4. **Check summary logs** for quick pass/fail status

## Troubleshooting

**Problem**: Script fails with permission error

```bash
chmod +x run_all_tests.sh quick_test.sh analyze_results.sh
```

**Problem**: Tests fail to compile

```bash
make clean
./run_all_tests.sh
```

**Problem**: Can't find results

```bash
ls -ltr test_results_*  # List by time, most recent last
```

## Examples

### Export metrics to spreadsheet:

```bash
./run_all_tests.sh
# Open test_results_*/test_metrics.csv in Excel/LibreOffice
```

### Monitor performance over time:

```bash
# Run daily and track
./run_all_tests.sh
cat test_results_*/test_metrics.csv >> performance_history.csv
```

### Quick regression test:

```bash
# Before changes
./quick_test.sh test_mod > before.txt

# After changes
./quick_test.sh test_mod > after.txt

# Compare
diff before.txt after.txt
```

## See Also

- `TEST_SCRIPTS_README.md` - Detailed documentation
- `Makefile` - Individual test targets
- `README.md` - Project documentation
