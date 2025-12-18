# CSV Status Fix

## Issue
The test metrics CSV was incorrectly showing all tests as "FAILED" even when they passed.

## Root Cause
The original script checked for the exact word "PASSED" in test log files, but most tests output different success messages like:
- `$finish called at...` (test_ez, test_tb)
- `DONE` (test_mod)
- No explicit "PASSED" message

## Solution
Updated `run_all_tests.sh` to:
1. **Primary method**: Check the summary log for `[PASS]` or `[FAIL]` tags
2. **Fallback**: Look for common success indicators if not found in summary

## How to Fix Existing Results

If you have old test results with incorrect CSV status, regenerate them:

```bash
./regenerate_csv.sh test_results_YYYYMMDD_HHMMSS/
```

This will update the CSV file with correct PASSED/FAILED status.

## Understanding the CSV

The CSV file shows:
- **Test**: Test name
- **Cycles**: Clock cycles (only for test_mod)
- **Instructions**: Instruction count (only for test_mod)
- **CPI**: Cycles per instruction (only for test_mod)
- **Status**: PASSED or FAILED

**Why N/A for some metrics?**
Most tests don't output detailed performance metrics. Only `test_mod` includes the AES accelerator performance comparison, so it's the only test with cycle/instruction counts.

**Status is what matters!**
Even if metrics show N/A, the Status column correctly indicates if the test passed or failed.

## Example Correct Output

```
Test      Cycles  Instructions  CPI   Status
test_mod  372817  84456         4.41  PASSED
test_tb   N/A     N/A           N/A   PASSED
test      N/A     N/A           N/A   PASSED
test_wb   N/A     N/A           N/A   FAILED
test_ez   N/A     N/A           N/A   PASSED
test_sp   N/A     N/A           N/A   PASSED
test_axi  N/A     N/A           N/A   PASSED
```

This correctly shows:
- 6 tests passed
- 1 test failed (test_wb)
- 85% success rate
- Only test_mod has performance metrics
