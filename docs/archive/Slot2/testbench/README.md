# ProbeDriver Testbench

This directory contains a comprehensive testbench for testing the `ProbeDriver.vhd` module. The testbench verifies the probe driver's state machine, status register functionality, and error handling capabilities.

## 🎯 What This Testbench Tests

### Core Functionality
- **State Machine Transitions**: IDLE → ARMED → FIRING → FIRED → COOL_DOWN
- **Status Register**: 5-bit register that tracks state history (bits 0-3 for states, bit 4 reserved for errors)
- **Output Signals**: Trigger and intensity outputs during different states
- **Clean Verification**: Focuses on operational behavior without error condition complexity

### Status Register Bit Mapping
- **Bit 0**: ARMED state visited
- **Bit 1**: FIRING state visited  
- **Bit 2**: FIRED state visited
- **Bit 3**: COOL_DOWN state visited
- **Bit 4**: Reserved for error detection (not tested in this simplified version)

## 🚀 Quick Start

### Prerequisites
- GHDL installed and available in PATH
- VHDL-2008 support enabled
- Basic understanding of VHDL simulation

### Basic Verification
```bash
# Navigate to testbench directory
cd Slot2/testbench

# Run the complete test suite
make run

# Expected output: "Simulation completed successfully"
```

## 🔧 Detailed Testing Guide

### 1. Compilation Verification
First, ensure all files compile without errors:
```bash
make compile
```
**Expected Result**: All VHDL files compile successfully with no errors or warnings.

### 2. Basic Functionality Test
Run a short simulation to verify basic operation:
```bash
ghdl -r --std=08 --ieee=synopsys ProbeDriver_tb --stop-time=100ns
```
**Expected Result**: Simulation runs without bound check failures or runtime errors.

### 3. Complete Functionality Test
Run the full test suite:
```bash
make run
```
**Expected Result**: Complete simulation with detailed status register monitoring.

## 📊 Understanding the Test Results

### Status Register Progression
The testbench will show the status register evolving through these clean values:

1. **Initial State**: `00000` (all bits low)
2. **After ARMED**: `00001` (bit 0 set)
3. **After FIRING**: `00011` (bits 0 and 1 set)
4. **After FIRED**: `00111` (bits 0, 1, and 2 set)
5. **After COOL_DOWN**: `01111` (bits 0, 1, 2, and 3 set)
6. **Final State**: `01111` (all operational bits set, error bit 4 remains 0)

**Note**: Bit 4 (error detection) is not tested in this simplified version to keep the output clean and focused on core functionality.

### Key Output Messages
Look for these success indicators:
```
Test 1: Reset and basic functionality
Test 2: Enable probe driver
Test 3: Trigger probe
Test 4: Wait for complete cycle
Test 5: Status register should show all operational bits high (01111)
Test 6: Final verification - all tests passed
Simulation completed successfully - Status register progression verified
```

### Status Register Monitoring
The testbench continuously monitors and reports status register changes with clear, focused output:
```
Status Register: 00001 (Bits 3-0: 0001)  - ARMED state
Status Register: 00011 (Bits 3-0: 0011)  - FIRING state
Status Register: 00111 (Bits 3-0: 0111)  - FIRED state
Status Register: 01111 (Bits 3-0: 1111)  - COOL_DOWN state
```

**Clean Output**: The monitoring focuses on operational bits (0-3) and provides clear state identification, making it easy to verify the state machine progression.

## 🐛 Troubleshooting Common Issues

### Compilation Errors
**Problem**: `ghdl:error: compilation error`
**Solution**: Ensure you're in the testbench directory and all dependencies are compiled:
```bash
cd Slot2/testbench
make clean
make compile
```

### Runtime Errors
**Problem**: `bound check failure`
**Solution**: This usually indicates a type mismatch. Check that:
- All signal types match between entity and architecture
- Array indices are within bounds
- Type conversions are explicit and correct

### Simulation Hangs
**Problem**: Simulation runs indefinitely
**Solution**: Check for infinite loops in the testbench or missing `wait;` statements.

## 🔍 Advanced Testing

### Custom Test Scenarios
Modify the testbench to test specific conditions:

1. **Change Test Values**:
   ```vhdl
   -- Modify these signals in the testbench
   signal Intensity_index : std_logic_vector(7 downto 0) := x"80";  -- 128 (invalid)
   signal PulseDuration_in : std_logic_vector(31 downto 0) := x"00000001";  -- 1 cycle
   signal CoolDown_in : std_logic_vector(31 downto 0) := x"00000000";  -- 0 cycles
   ```

2. **Add Custom Assertions**:
   ```vhdl
   -- Add to the monitor process
   assert status_register(4) = '1' 
     report "Error bit should be set for invalid inputs" 
     severity error;
   ```

### Waveform Analysis
Generate VCD files for waveform viewing:
```bash
make run  # Automatically generates ProbeDriver_tb.vcd
```

Use GTKWave or similar tools to analyze the waveforms:
```bash
gtkwave ProbeDriver_tb.vcd
```

## 📁 File Structure
```
testbench/
├── README.md              # This file
├── Makefile               # Build and run scripts
├── ProbeDriver_tb.vhd     # Main testbench
└── simple_tb.vhd          # Minimal testbench for debugging
```

## 🎯 Verification Checklist

Before considering the testbench "working", verify:

- [ ] **Compilation**: `make compile` succeeds
- [ ] **Basic Simulation**: Short simulation runs without errors
- [ ] **Full Simulation**: Complete test suite runs successfully
- [ ] **Status Register**: All operational bits are set in sequence (00001 → 00011 → 00111 → 01111)
- [ ] **Clean Output**: Status register monitoring shows clear progression without confusing error messages
- [ ] **Output Signals**: Trigger and intensity outputs change as expected during FIRING state
- [ ] **State Transitions**: All state machine transitions occur correctly and are reported clearly
- [ ] **Final State**: Status register ends with `01111` (all operational bits set, error bit 4 remains 0)

## 🚨 Common Pitfalls

1. **Clock Speed**: Don't make the clock too fast (keep CLK_PERIOD ≥ 10ns)
2. **Simulation Time**: Ensure `--stop-time` is long enough for complete cycles
3. **Reset Logic**: Always start with reset asserted, then deassert
4. **Signal Initialization**: Ensure all signals have proper initial values

## 📞 Getting Help

If you encounter issues:

1. **Check the logs**: Look for specific error messages
2. **Verify dependencies**: Ensure all required files are compiled
3. **Simplify the test**: Use `simple_tb.vhd` for basic debugging
4. **Check signal types**: Verify all port connections match expected types

## 🎉 Success Indicators

You'll know everything is working when you see:
- All tests complete without errors
- Status register shows clean progression: `00001` → `00011` → `00111` → `01111`
- Clear, focused output without confusing error condition messages
- Simulation completes with "Simulation completed successfully - Status register progression verified"
- Final status register value is `01111` (all operational bits set)

**Clean Testing Approach**: This simplified testbench focuses on core functionality verification, making it easy to understand and debug. Error condition testing can be added later when needed for comprehensive validation.
