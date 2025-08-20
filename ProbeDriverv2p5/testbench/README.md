# ProbeDriver Testbench - Human Interface Code Restored

## Overview
This directory contains the **restored human-interface testbench code** that was moved to `testbench.old/` during recent cleanup efforts. These files provide comprehensive testing capabilities with human-friendly interfaces and detailed monitoring.

## What Was Restored
During cleanup, several useful testbench files were moved to `testbench.old/` to preserve them. We've now restored the key human-interface components:

### 🔧 Core Testing Files
- **`probe_driver_core_tb.vhd`** - Unit testbench for the core ProbeDriver module
- **`probe_driver_wrapper_tb.vhd`** - Integration testbench for the wrapper interface
- **`CustomWrapper-top-tb.vhd`** - High-level testbench for CustomWrapper entity

### 🎯 Human Interface Components
- **`HumanInterface_pkg.vhd`** - **CRITICAL**: Human-friendly display and decoding package
- **`jc_CustomWrapper_top_tb.vhd`** - Human-interface focused testbench by "jc"

## Key Features of Restored Code

### 1. HumanInterface_pkg.vhd
This package provides **human-friendly functions** for:
- **Timing Conversion**: Convert clock cycles to human-readable time
- **Control Register Decoding**: Human-readable control register descriptions
- **Status Register Decoding**: Clear status bit explanations
- **Display Formatting**: Formatted output with headers and separators
- **Clock Divider Decoding**: Human-readable clock divider descriptions
- **Intensity & Duration Decoding**: Percentage and time-based displays

### 2. jc_CustomWrapper_top_tb.vhd
A **human-interface focused testbench** that:
- Uses real hardware timing (32ns clock period)
- Provides clear, step-by-step test progress
- Includes comprehensive status monitoring
- Offers human-readable output and error reporting
- Mirrors internal signal names for clarity

### 3. CustomWrapper-top-tb.vhd
A **higher-level testbench** that:
- Focuses on sanity checking OutputsABC values
- Simulates real hardware behavior
- Provides comprehensive monitoring and validation
- Tests multiple phases of operation

## Why This Code Was Important
The human-interface testbench code was **essential for**:
- **Debugging**: Human-readable output makes debugging much easier
- **Education**: Clear explanations help users understand system behavior
- **Development**: Formatted output speeds up development and testing
- **Documentation**: Serves as living documentation of expected behavior
- **User Experience**: Makes testbenches approachable for non-experts

## Usage

### Quick Start
```bash
# Navigate to testbench directory
cd moku-dev-vhdl/ProbeDriver/testbench

# Test core functionality
ghdl -a --std=08 --work=work ../common/intensity_lut_pkg.vhd
ghdl -a --std=08 --work=work ../common/probe_driver_pkg.vhd
ghdl -a --std=08 --work=work ../core/probe_driver_core.vhd
ghdl -a --std=08 --work=work HumanInterface_pkg.vhd
ghdl -a --std=08 --work=work jc_CustomWrapper_top_tb.vhd
ghdl -e --std=08 --work=work jc_CustomWrapper_top_tb
ghdl -r --std=08 --work=work jc_CustomWrapper_top_tb --stop-time=100us
```

### Available Testbenches
1. **Core Unit Test**: `probe_driver_core_tb.vhd`
2. **Wrapper Integration**: `probe_driver_wrapper_tb.vhd`
3. **Human Interface**: `jc_CustomWrapper_top_tb.vhd`
4. **High-Level Testing**: `CustomWrapper-top-tb.vhd`

## Lessons Learned
This restoration highlights the importance of:
- **Preserving useful code** during cleanup operations
- **Maintaining human-interface components** for better usability
- **Documenting the purpose** of each testbench file
- **Creating clear READMEs** to explain what each file does

## Future Recommendations
1. **Keep HumanInterface_pkg.vhd** as a core component
2. **Maintain human-readable testbenches** alongside technical ones
3. **Document the purpose** of each testbench clearly
4. **Use consistent naming** for human-interface components
5. **Include usage examples** in README files

## File Status
- ✅ **Restored**: HumanInterface_pkg.vhd (critical for human interface)
- ✅ **Restored**: jc_CustomWrapper_top_tb.vhd (human-focused testing)
- ✅ **Restored**: CustomWrapper-top-tb.vhd (high-level testing)
- ✅ **Restored**: probe_driver_core_tb.vhd (unit testing)
- ✅ **Restored**: probe_driver_wrapper_tb.vhd (integration testing)
- 📝 **Created**: This README.md (documentation)

The human-interface testbench code is now fully restored and ready for use!
