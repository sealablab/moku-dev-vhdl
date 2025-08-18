# jc_CustomWrapper_top_tb.vhd - Testbench for CustomWrapper Entity

## Overview
This testbench demonstrates how to test the ProbeDriver module through the CustomWrapper interface. It's designed to be approachable for users unfamiliar with GHDL and focuses on **Test-01: Reset and State Machine Function**.

## What This Testbench Does
**Test-01** validates that the ProbeDriver correctly transitions through its state machine after a reset:

1. **Reset Phase**: Starts with reset active, all control registers at 0x00
2. **IDLE State**: After reset release, verifies the module enters IDLE state
3. **Enable**: Enables the module (Control0(31) = '0')
4. **ARMED State**: Verifies transition to ARMED state
5. **Auto-fire**: Waits for automatic firing sequence (safe defaults mode)
6. **FIRING State**: Monitors the firing process
7. **COOL_DOWN**: Observes cooldown period
8. **Return to IDLE**: Verifies successful return to initial state

## Key Features
- **Real Hardware Timing**: Uses 32ns clock period (matches actual hardware)
- **Status Register Monitoring**: Observes ProbeDriver state via `OutputA[3:0]`
- **Auto-fire Testing**: Tests the safe defaults mode when all controls are 0x00
- **Clear Reporting**: Step-by-step test progress with PASS/FAIL indicators
- **Timeout Protection**: Prevents infinite simulation loops

## Status Register Mapping
The testbench monitors the ProbeDriver state through `OutputA[3:0]`:

- **Bit 0**: ARMED state
- **Bit 1**: FIRING state  
- **Bit 2**: Pulse completed
- **Bit 3**: COOL_DOWN state
- **Bit 4**: Error bit

## Running the Testbench

### Prerequisites
- GHDL installed and accessible via `ghdl` command
- Optional: GTKWave for waveform viewing

### Quick Start
```bash
# Navigate to the testbench directory
cd moku-dev-vhdl/ProbeDriver/testbench

# Run the test
make run

# For waveforms (requires GTKWave)
make wave
```

### Manual GHDL Commands
If you prefer to run GHDL manually:

```bash
# 1. Analyze (compile) all source files
ghdl -a --std=08 --work=work ../ProbeConfig.vhd
ghdl -a --std=08 --work=work ../IntensityLut.vhd
ghdl -a --std=08 --work=work ../../clk-divider/clk_divider.vhd
ghdl -a --std=08 --work=work ../ProbeDriver.vhd
ghdl -a --std=08 --work=work ../CustomWrapper.vhd
ghdl -a --std=08 --work=work ../top_probe_driver.vhd
ghdl -a --std=08 --work=work jc_CustomWrapper_top_tb.vhd

# 2. Elaborate (link) the testbench
ghdl -e --std=08 --work=work jc_CustomWrapper_top_tb

# 3. Run the simulation
ghdl -r --std=08 --work=work jc_CustomWrapper_top_tb --stop-time=100us --vcd=jc_CustomWrapper_top_tb.vcd
```

## Expected Results
When the test passes, you should see output like:

```
=== TEST-01: Reset and State Machine Function ===
Goal: Observe ProbeDriver transition through state machine after reset
Step 1: Reset active, all controls at 0x00
Step 2: Release reset, observe IDLE state
PASS: Correctly in IDLE state after reset
Step 3: Enable module (Control0(31) = '0')
PASS: Correctly transitioned to ARMED state
Step 4: Wait for auto-fire sequence
PASS: Auto-fire initiated, entered FIRING state
Step 5: Wait for FIRING completion and COOL_DOWN
PASS: FIRING completed, entered COOL_DOWN state
Step 6: Wait for COOL_DOWN completion and return to IDLE
PASS: COOL_DOWN completed
PASS: Successfully returned to IDLE state
=== TEST-01 PASSED: State machine transitions working correctly ===
Simulation complete
```

## Understanding the Test
This testbench validates the **hardware behavior** of the ProbeDriver:

1. **Safe Defaults Mode**: When all control registers are 0x00, the module automatically fires once using safe minimum values
2. **State Transitions**: IDLE → ARMED → FIRING → COOL_DOWN → IDLE
3. **Status Reporting**: The `probe_driver_status_register` correctly reflects the current state
4. **Timing**: Uses actual hardware timing constants (minimum pulse duration, cooldown periods)

## Troubleshooting

### Common Issues
- **"ghdl: command not found"**: Install GHDL first
- **Compilation errors**: Check that all source files exist in the correct paths
- **Simulation hangs**: The timeout protection should prevent this (100μs limit)

### Getting Help
- Check the Makefile for the correct file paths
- Verify GHDL version: `ghdl --version`
- Look for error messages in the compilation output

## Next Steps
This testbench demonstrates the basic approach. You can extend it by:

1. **Adding more test cases** for different control register values
2. **Testing edge cases** like maximum duration/cooldown values
3. **Adding waveform analysis** for detailed timing verification
4. **Testing error conditions** and boundary conditions

## Files in This Test
- `jc_CustomWrapper_top_tb.vhd` - Main testbench file
- `Makefile` - Simple build system for GHDL
- `README-jc-CustomWrapper-top-tb.md` - This documentation file
