## Test Scripts - Quick Reference

I've created a comprehensive test automation suite for your PicoRV32 AES Accelerator project.

### 📋 What's Included

**Scripts:**

- `run_all_tests.sh` - Runs all tests and generates detailed reports
- `quick_test.sh` - Quick test runner for single or essential tests
- `analyze_results.sh` - Analyzes test results and extracts performance metrics
- `test_help.sh` - Shows help and current status

**Documentation:**

- `TESTING_GUIDE.md` - Quick reference guide
- `TEST_SCRIPTS_README.md` - Detailed documentation

### 🚀 Quick Start

```bash
# Show help and status
./test_help.sh

# Run a quick test
./quick_test.sh test_mod

# Run all tests and save results
./run_all_tests.sh

# Analyze the results
./analyze_results.sh test_results_*/
```

### 📊 What Gets Stored

Each test run creates a timestamped directory with:

- Individual test logs
- Performance metrics (cycles, instructions, CPI)
- Summary report
- CSV file for data analysis
- Combined output log

Example:

```
test_results_20251218_143052/
├── test_summary.log          # Pass/fail summary
├── test_metrics.csv          # Performance data
├── test_mod.log             # Individual test outputs
├── test_mod_metrics.txt     # Extracted metrics
└── all_tests_combined.log   # Everything combined
```

### 🎯 Common Use Cases

**1. Quick verification:**

```bash
./quick_test.sh test_mod
```

**2. Full regression testing:**

```bash
./run_all_tests.sh
```

**3. Performance analysis:**

```bash
./run_all_tests.sh
./analyze_results.sh test_results_*/
```

**4. Compare before/after:**

```bash
# Before changes
./run_all_tests.sh
mv test_results_* baseline/

# After changes
./run_all_tests.sh
./analyze_results.sh test_results_* baseline/test_results_*
```

### 📈 Performance Metrics Captured

- **Cycle counts** for software vs hardware AES
- **Instruction counts**
- **CPI** (Cycles Per Instruction)
- **Speedup factors** (how much faster hardware is)
- **Test pass/fail status**

### 💡 Pro Tips

1. **Archive your results:**

   ```bash
   mkdir test_archives
   ./run_all_tests.sh
   mv test_results_* test_archives/
   ```

2. **Track performance over time:**

   ```bash
   ./run_all_tests.sh
   cat test_results_*/test_metrics.csv >> performance_history.csv
   ```

3. **Import to spreadsheet:**
   - Open `test_results_*/test_metrics.csv` in Excel/LibreOffice
   - Create charts and graphs

### 📖 More Information

- Run `./test_help.sh` for interactive help
- Read `TESTING_GUIDE.md` for quick reference
- Read `TEST_SCRIPTS_README.md` for detailed documentation

---

**Ready to test?** Try: `./quick_test.sh test_mod`
