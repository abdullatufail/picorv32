# Benchmark Script Documentation

## benchmark_test_mod.sh

A comprehensive benchmarking tool for running `test_mod` multiple times and generating statistical analysis.

### Purpose

- **Performance benchmarking** - Run tests many times to get reliable performance data
- **Statistical analysis** - Calculate mean, min, max, and standard deviation
- **Variance detection** - Identify if performance is consistent across runs
- **Data generation** - Create CSV files ready for plotting and analysis

### Usage

```bash
# Run with default 100 iterations
./benchmark_test_mod.sh

# Run with custom number of iterations
./benchmark_test_mod.sh 50
./benchmark_test_mod.sh 1000
```

### What It Does

1. Runs `make test_mod` N times
2. Extracts performance metrics from each run:
   - Software encryption cycles
   - Software decryption cycles  
   - Hardware encryption cycles
   - Hardware decryption cycles
   - Total cycles
   - Total instructions
   - CPI (Cycles Per Instruction)
3. Calculates statistics (mean, min, max, standard deviation)
4. Computes hardware acceleration speedup
5. Generates formatted output files

### Output Files

Each benchmark run creates a timestamped directory: `benchmark_Nruns_YYYYMMDD_HHMMSS/`

#### 1. `raw_data.csv`
Complete dataset with all runs:
```csv
Run,SW_Encrypt_Cycles,SW_Decrypt_Cycles,HW_Encrypt_Cycles,HW_Decrypt_Cycles,Total_Cycles,Total_Instructions,CPI,Status
1,31456,277239,1132,1111,372817,84456,4.41,PASS
2,31456,277239,1132,1111,372817,84456,4.41,PASS
...
```

**Use for**: 
- Importing to Excel/LibreOffice
- Creating line charts
- Detailed analysis of individual runs

#### 2. `plot_data.csv`
Statistical summary optimized for plotting:
```csv
Metric,Mean,Min,Max,StdDev
SW_Encrypt,31456.00,31456,31456,0
SW_Decrypt,277239.00,277239,277239,0
HW_Encrypt,1132.00,1132,1132,0
HW_Decrypt,1111.00,1111,1111,0
Total_Cycles,372817.00,372817,372817,0
CPI,4.41,4.41,4.41,0
```

**Use for**:
- Creating bar charts comparing SW vs HW
- Visualizing mean values with error bars
- Quick statistical overview

#### 3. `statistics.txt`
Detailed formatted report:
```
======================================================================
  PicoRV32 AES Accelerator Benchmark Statistics
======================================================================

Test Configuration:
  Number of runs: 100
  Date: Thu Dec 18 11:09:17 PM PKT 2025
  
Software Encryption Cycles:
  Mean:    31456.00
  Min:     31456
  Max:     31456
  StdDev:  0.00

Hardware Acceleration Speedup:
  Encryption: 27.78x faster
  Decryption: 249.54x faster
```

**Use for**:
- Documentation
- Reports
- Performance analysis

#### 4. `summary.txt`
Quick summary:
```
Benchmark Summary
=================
Runs: 100
Passed: 100 (100%)
Failed: 0
```

#### 5. `run_N.log`
Individual log for each test run (for debugging)

### Understanding the Results

#### Software vs Hardware Performance

The benchmark shows the performance difference between:
- **Software AES**: Pure software implementation running on PicoRV32
- **Hardware AES**: Using the AES accelerator

**Typical Results:**
- **Encryption Speedup**: ~27-28x faster with hardware
- **Decryption Speedup**: ~200-250x faster with hardware

#### Why Decryption is Much Faster

Decryption shows a much larger speedup because:
1. Software AES decryption is more complex (inverse operations)
2. Hardware accelerator optimizes both equally well
3. Demonstrates the value of hardware acceleration

#### Standard Deviation

- **StdDev = 0**: Deterministic behavior (expected for single-threaded processor)
- **StdDev > 0**: Would indicate variance (could suggest timing issues, interrupts, etc.)

### Examples

#### Example 1: Quick Benchmark (10 runs)
```bash
./benchmark_test_mod.sh 10
```
Good for: Quick verification after code changes

#### Example 2: Standard Benchmark (100 runs)
```bash
./benchmark_test_mod.sh 100
```
Good for: Default benchmarking, documentation

#### Example 3: Extensive Benchmark (1000 runs)
```bash
./benchmark_test_mod.sh 1000
```
Good for: Publication-quality data, detailed statistics

### Analyzing Results

#### 1. View Statistics
```bash
cat benchmark_*/statistics.txt
```

#### 2. Import to Spreadsheet
Open `raw_data.csv` or `plot_data.csv` in Excel/LibreOffice Calc

#### 3. Create Charts
Use `plot_data.csv` for bar charts comparing SW vs HW performance

#### 4. Track Performance Over Time
```bash
# Save baseline
./benchmark_test_mod.sh 100
mv benchmark_* baseline_benchmark/

# After making optimizations
./benchmark_test_mod.sh 100

# Compare
diff baseline_benchmark/plot_data.csv benchmark_*/plot_data.csv
```

### Performance Metrics Explained

| Metric | Description |
|--------|-------------|
| **SW_Encrypt** | CPU cycles for software AES encryption |
| **SW_Decrypt** | CPU cycles for software AES decryption |
| **HW_Encrypt** | CPU cycles when using hardware accelerator for encryption |
| **HW_Decrypt** | CPU cycles when using hardware accelerator for decryption |
| **Total_Cycles** | Total CPU cycles for entire test |
| **Total_Instructions** | Total RISC-V instructions executed |
| **CPI** | Average cycles per instruction |

### Tips

1. **Run at least 100 iterations** for reliable statistics
2. **Close other applications** to minimize system interference
3. **Save results** before making code changes
4. **Use plot_data.csv** for creating graphs
5. **Check for variance** - StdDev > 0 might indicate issues

### Troubleshooting

**Problem**: High failure rate
```bash
# Check first failed run
cat benchmark_*/run_1.log
```

**Problem**: Unexpected variance (StdDev > 0)
- Check for system load
- Verify no interrupts are occurring
- Review test implementation

**Problem**: Script too slow
```bash
# Run fewer iterations
./benchmark_test_mod.sh 10
```

### Integration with Other Tools

#### Python Analysis
```python
import pandas as pd
df = pd.read_csv('benchmark_100runs_*/raw_data.csv')
print(df.describe())
```

#### R Analysis
```r
data <- read.csv('benchmark_100runs_*/plot_data.csv')
barplot(data$Mean, names.arg=data$Metric)
```

#### Gnuplot
```gnuplot
set datafile separator ','
plot 'raw_data.csv' using 1:6 with lines title 'Total Cycles'
```

### See Also

- `run_all_tests.sh` - Run all test targets
- `analyze_results.sh` - Analyze test results
- `TESTING_GUIDE.md` - General testing guide
