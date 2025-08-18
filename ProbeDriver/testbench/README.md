# ProbeDriver Testbench - Clean Implementation

## Overview
This directory contains the clean, focused testbench implementation for the updated ProbeDriver interface.

## Reorganization
The old testbench files have been moved to `old_testbenches/` directory to preserve them while we create a clean, focused approach.

## New Testbench Structure

### 1. **ProbeDriver Unit Test** (`probe_driver_tb.vhd`)
- Tests the core ProbeDriver module directly
- Uses new bit widths: 7-bit intensity, 16-bit duration/cooldown
- Focuses on core functionality and state machine behavior

### 2. **Top-Level Integration Test** (`top_probe_driver_improved_tb.vhd`)
- Tests the complete top-level interface using `top_probe_driver_improved.vhd`
- Validates the new CR0/CR1 control register layout
- Tests the global enable, soft trigger, and parameter mapping

### 3. **Control Register Test** (`control_register_tb.vhd`)
- Tests the new control register interface
- Validates bit field assignments and parameter ranges
- Tests edge cases and boundary conditions

## Key Features
- **Clean separation** of concerns
- **Proper bit width handling** (7-bit intensity, 16-bit duration/cooldown)
- **Focused test scenarios** without duplication
- **Easy maintenance** and extension

## Build System
Simple Makefile with clear targets:
- `make test_unit` - Run unit tests
- `make test_integration` - Run integration tests
- `make test_all` - Run all tests
- `make clean` - Clean build artifacts

## Next Steps
1. Implement focused testbenches
2. Create clean Makefile
3. Add comprehensive test coverage
4. Validate new interface thoroughly
