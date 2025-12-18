# 🚀 Complete Testing & Benchmarking Suite

Automated testing and performance analysis for PicoRV32 AES Accelerator.

## Quick Start

```bash
# Show help
./test_help.sh

# Run a quick test
./quick_test.sh test_mod

# Run full test suite
./run_all_tests.sh

# Benchmark (100 runs)
./benchmark_test_mod.sh 100
```

## 📁 Scripts

| Script | Purpose | Time | Output |
|--------|---------|------|--------|
| `test_help.sh` | Show available commands | Instant | Help screen |
| `quick_test.sh` | Quick verification | ~30s | `quick_test_*/` |
| `run_all_tests.sh` | Full test suite | ~2min | `test_results_*/` |
| `analyze_results.sh` | Analyze test results | Instant | Console output |
| `benchmark_test_mod.sh` | Statistical benchmark | N×30s | `benchmark_*/` |
| `regenerate_csv.sh` | Fix old CSV files | Instant | Updated CSV |

## 📊 Use Cases

### 1. Development - Quick Verification
```bash
./quick_test.sh test_mod
```
**When**: After making code changes  
**Time**: ~30 seconds  
**Output**: Pass/fail status

### 2. Testing - Full Validation
```bash
./run_all_tests.sh
./analyze_results.sh test_results_*/
```
**When**: Before committing code  
**Time**: ~2 minutes  
**Output**: Complete test coverage, metrics

### 3. Benchmarking - Performance Analysis
```bash
./benchmark_test_mod.sh 100
```
**When**: Publishing results, performance analysis  
**Time**: ~50 minutes (100 runs × 30s)  
**Output**: Statistical data, CSV files for plotting

### 4. Comparison - Before/After
```bash
# Baseline
./benchmark_test_mod.sh 50
mv benchmark_* baseline/

# After changes
./benchmark_test_mod.sh 50

# Compare CSVs
diff baseline/plot_data.csv benchmark_*/plot_data.csv
```

## 📈 Understanding Output

### Test Status
- ✅ **PASSED** - Test completed successfully
- ❌ **FAILED** - Test encountered errors
- ⚠️  **N/A** - Metrics not available (test may still pass)

### Performance Metrics (test_mod only)

| Metric | Typical Value | Meaning |
|--------|--------------|---------|
| SW Encrypt | ~31,456 cycles | Software AES encryption |
| SW Decrypt | ~277,239 cycles | Software AES decryption |
| HW Encrypt | ~1,132 cycles | Hardware AES encryption |
| HW Decrypt | ~1,111 cycles | Hardware AES decryption |
| **Speedup** | **27x encrypt, 249x decrypt** | **Hardware acceleration** |
| Total Cycles | ~372,817 | Complete test execution |
| CPI | ~4.41 | Cycles per instruction |

## 📂 Output Files

### run_all_tests.sh generates:
```
test_results_YYYYMMDD_HHMMSS/
├── test_summary.log       # Pass/fail summary
├── test_metrics.csv       # Metrics for all tests
├── all_tests_combined.log # Complete output
├── test_mod.log          # Individual logs
├── test_mod_metrics.txt  # Extracted metrics
└── ...
```

### benchmark_test_mod.sh generates:
```
benchmark_100runs_YYYYMMDD_HHMMSS/
├── raw_data.csv          # All 100 runs (for Excel)
├── plot_data.csv         # Statistics (for graphs)
├── statistics.txt        # Detailed report
├── summary.txt           # Quick summary
└── run_*.log            # Individual run logs
```

## 📖 Documentation

| File | Description |
|------|-------------|
| `TESTING_GUIDE.md` | Quick reference guide |
| `TEST_SCRIPTS_README.md` | Detailed documentation |
| `BENCHMARK_GUIDE.md` | Benchmarking guide |
| `CSV_FIX_NOTES.md` | CSV status fix notes |
| `TEST_SCRIPTS_QUICKSTART.md` | Quick start guide |

## 🎯 Common Workflows

### Daily Development
```bash
# Make changes to code
vim firmware/AES_mem_mapped.c

# Quick test
./quick_test.sh test_mod
```

### Pre-Commit Check
```bash
# Full test suite
./run_all_tests.sh

# Check results
./analyze_results.sh test_results_*/

# If all passed, commit
git add .
git commit -m "Your changes"
```

### Performance Analysis
```bash
# Baseline benchmark
./benchmark_test_mod.sh 100
mv benchmark_* baseline_v1/

# Make optimization
# ...

# New benchmark
./benchmark_test_mod.sh 100

# Compare
echo "Baseline:"
cat baseline_v1/plot_data.csv
echo "Current:"
cat benchmark_*/plot_data.csv
```

### Data Collection for Paper/Presentation
```bash
# Run extensive benchmark
./benchmark_test_mod.sh 1000

# Import to spreadsheet
# Open benchmark_*/raw_data.csv in Excel

# Create graphs from plot_data.csv
# - Bar chart: SW vs HW performance
# - Error bars using StdDev
```

## 💡 Pro Tips

1. **Start small**: Use `./quick_test.sh` during development
2. **Benchmark overnight**: `./benchmark_test_mod.sh 1000` while you sleep
3. **Save baselines**: Keep benchmark results before major changes
4. **Use CSV files**: Import to Excel/LibreOffice for graphs
5. **Archive results**: `mv test_results_* archives/$(date +%Y%m)`

## 🔧 Troubleshooting

### Script Permission Errors
```bash
chmod +x *.sh
```

### Tests Fail to Build
```bash
make clean
make
./quick_test.sh test_mod
```

### Old CSV Shows Wrong Status
```bash
./regenerate_csv.sh test_results_YYYYMMDD_HHMMSS/
```

### Want More Verbose Output
```bash
# Use make directly
make test_mod

# Or check individual logs
cat test_results_*/test_mod.log
```

## 📞 Quick Reference

```bash
# Help
./test_help.sh

# Quick test (30s)
./quick_test.sh test_mod

# Full tests (2min)
./run_all_tests.sh

# Benchmark (50min for 100 runs)
./benchmark_test_mod.sh 100

# Analyze
./analyze_results.sh test_results_*/
```

## 🎓 Learning Path

1. **First time**: `./test_help.sh` - Understand available tools
2. **Try it**: `./quick_test.sh test_mod` - See a test run
3. **Full test**: `./run_all_tests.sh` - Run all tests
4. **Analyze**: `./analyze_results.sh test_results_*/` - View results
5. **Benchmark**: `./benchmark_test_mod.sh 10` - Small benchmark
6. **Production**: `./benchmark_test_mod.sh 100` - Real benchmark

## 📚 See Also

- **Main README**: Project overview
- **Makefile**: Individual test targets
- **firmware/**: Test firmware code
- **AES/**: Hardware AES modules

---

**Ready to start?** Run `./test_help.sh` for interactive help!
