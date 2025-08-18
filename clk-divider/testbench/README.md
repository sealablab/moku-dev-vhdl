# clk_divider Testbench

## Overview
This directory contains the testbench for the `clk_divider` module. The testbench is designed to be clean, focused, and efficient, testing the key functionality without excessive output noise.

## Testbench Features

### **Clean Design**
- **Minimal Output**: Only essential test progress reports
- **Focused Testing**: Tests key divider ratios and functionality
- **Automatic Exit**: Simulation exits automatically when tests complete
- **Timeout Protection**: 100μs timeout prevents infinite simulation

### **Test Coverage**
- **Reset Functionality**: Verifies synchronous reset behavior
- **Key Divider Ratios**: Tests 0, 1, 2, 4, 8, 16 (representative samples)
- **Dynamic Changes**: Tests divider switching during operation
- **Pulse Counting**: Monitors clock enable pulse generation

### **Test Phases**
1. **Phase 1**: Reset functionality testing
2. **Phase 2**: Key divider ratio validation
3. **Phase 3**: Dynamic divider changes
4. **Phase 4**: Final verification and cleanup

## Usage

### **Quick Start**
```bash
cd testbench
make test          # Compile and run all tests
```

### **Available Commands**
```bash
make              # Run all tests (default)
make compile      # Compile only
make test         # Compile and test
make run_test     # Run tests (requires compilation)
make clean        # Clean generated files
make help         # Show available commands
```

### **Test Output**
The testbench provides clean, focused output:
```
========================================
Compiling clk_divider testbench...
========================================
Compiling DUT...
Compiling testbench...
Elaborating testbench...
========================================
Running clk_divider tests...
========================================
=== clk_divider Testbench Started ===
Phase 1: Testing reset functionality
Phase 2: Testing key divider ratios
Phase 3: Testing dynamic divider changes
Phase 4: Final verification
=== Test Complete ===
PASS: All clk_divider tests completed successfully
Simulation completed successfully. Exiting...
```

## Test Strategy

### **Efficient Testing**
- **Representative Samples**: Tests key divider ratios instead of all 16
- **Minimal Cycles**: Uses minimum cycles needed for validation
- **Smart Timeouts**: Prevents runaway simulations
- **Clean Exit**: Automatic termination when tests complete

### **What Gets Tested**
- ✅ **Reset**: Synchronous reset functionality
- ✅ **Divider 0**: No division (clk_en high every cycle)
- ✅ **Divider 1**: Divide by 2 (clk_en high every 2 cycles)
- ✅ **Divider 2**: Divide by 4 (clk_en high every 4 cycles)
- ✅ **Divider 4**: Divide by 16 (clk_en high every 16 cycles)
- ✅ **Dynamic Changes**: Divider switching during operation
- ✅ **Pulse Generation**: Correct timing of clk_en signals

### **What's NOT Tested**
- **All 16 Ratios**: Only key representatives for efficiency
- **Extreme Cases**: Very large dividers (1024, 2048, etc.)
- **Long Simulations**: Keeps test time under 100μs

## File Structure
```
testbench/
├── clk_divider_tb.vhd    # Main testbench file
├── Makefile              # Build system
└── README.md             # This documentation
```

## Dependencies

### **Required Files**
- `../clk_divider.vhd` - Device under test (DUT)
- `clk_divider_tb.vhd` - Testbench implementation

### **Tools**
- **GHDL**: VHDL simulator
- **Make**: Build system
- **VHDL-2008**: Language standard support

## Customization

### **Modifying Test Parameters**
To adjust test behavior, modify these constants in `clk_divider_tb.vhd`:
```vhdl
constant CLK_PERIOD : time := 10 ns;  -- Clock period
-- Timeout protection
wait for 100 us;  -- Simulation timeout
```

### **Adding More Tests**
To test additional divider ratios, add them to Phase 2:
```vhdl
-- Test divider 8 (divide by 256)
divider_sel <= "1000";
expected_pulses := 3;
test_cycles := expected_pulses * 256;
wait for CLK_PERIOD * test_cycles;
```

## Troubleshooting

### **Common Issues**
1. **Compilation Errors**: Check that `../clk_divider.vhd` exists
2. **Simulation Hangs**: Check for infinite loops in test logic
3. **Timeout Errors**: Increase timeout value if tests need more time

### **Debug Mode**
For more verbose output, modify the testbench to add debug reports:
```vhdl
-- Add debug output
if cycle_count mod 1000 = 0 then
    report "Cycle " & integer'image(cycle_count) & " completed";
end if;
```

## Performance

### **Test Duration**
- **Typical Runtime**: ~50-100μs
- **Timeout Protection**: 100μs maximum
- **Efficient**: Tests only essential functionality

### **Resource Usage**
- **Memory**: Minimal (simple test vectors)
- **CPU**: Low (focused test cases)
- **Output**: Clean (minimal console output)

## Integration

This testbench is designed to work with the main `clk_divider` module and can be easily integrated into larger test suites. The clean design makes it suitable for:

- **CI/CD Pipelines**: Automated testing
- **Development Workflow**: Quick validation during development
- **Regression Testing**: Part of larger test suites
- **Documentation**: Demonstrates module functionality
