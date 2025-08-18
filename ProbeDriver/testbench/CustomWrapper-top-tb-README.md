# CustomWrapper-top-tb Testbench

## Overview
The `CustomWrapper-top-tb.vhd` is a higher-level testbench designed to sanity check the OutputsABC values in simulation for the CustomWrapper entity. This testbench simulates real hardware behavior and provides comprehensive monitoring of the top-level interface.

## Purpose
This testbench addresses the requirements specified in `CustomWrapper-testbench-requirements.txt`:
- **Reset behavior**: Simulates hardware loading bitstream and handling reset
- **Real hardware timing**: Uses 32ns clock period (matching real hardware)
- **Zero-initialized control registers**: All control registers start at 0x00 as per hardware behavior
- **Output sanity checking**: Monitors and validates OutputsABC values throughout simulation

## Key Features

### 1. Real Hardware Simulation
- **Clock Period**: 32ns (matches real hardware specification)
- **Reset Behavior**: Simulates hardware bitstream loading and reset handling
- **Control Register Initialization**: All control registers start at 0x00 (hardware default)

### 2. Comprehensive Test Phases
- **Phase 1**: Initial Reset and Zero-Init Mode
- **Phase 2**: Zero-Init Mode Testing (all control registers = 0x00)
- **Phase 3**: Basic Functionality Testing
- **Phase 4**: Auto-arm Feature Testing (CR0[30])
- **Phase 5**: Verification and Summary

### 3. Output Monitoring and Sanity Checks
- **OutputA (Status Register)**: Monitors state machine status and error conditions
- **OutputB (Trigger Threshold)**: Validates trigger output during FIRING state
- **OutputC (Intensity)**: Monitors intensity output during FIRING state
- **Real-time Validation**: Checks for logical consistency between outputs and states

### 4. Advanced Monitoring
- **Cycle-by-cycle tracking**: Monitors all output changes with cycle counts
- **Status bit analysis**: Reports status register bit patterns and transitions
- **Phase-specific monitoring**: Different validation logic for each test phase
- **Periodic reporting**: Outputs status every 100 cycles for long simulations

## Test Scenarios

### Zero-Init Mode
- Tests behavior when all control registers are 0x00
- Validates auto-fire functionality with safe defaults
- Monitors expected state transitions (IDLE → ARMED)

### Basic Functionality
- Configures normal operation parameters
- Tests trigger functionality
- Validates complete firing cycle (ARMED → FIRING → COOL_DOWN → IDLE)

### Auto-arm Feature
- Tests CR0[30] auto-arm functionality
- Validates direct transition from COOL_DOWN → ARMED (skipping IDLE)
- Monitors state machine behavior with auto-arm enabled

## Usage

### Compilation and Execution
```bash
# Run only the CustomWrapper-top testbench
make test_customwrapper_top

# Run all testbenches (including this one)
make test_all

# Clean generated files
make clean
```

### Simulation Output
The testbench provides detailed simulation output including:
- Test phase transitions
- Output value changes with cycle counts
- Status register bit analysis
- Warning messages for potential issues
- Periodic status reports

### VCD Waveform Generation
Generates `customwrapper_top.vcd` for waveform analysis in tools like GTKWave.

## Expected Behavior

### OutputA (Status Register)
- **Bit 0**: ARMED state indicator
- **Bit 1**: FIRING state indicator  
- **Bit 2**: Pulse completed indicator
- **Bit 3**: COOL_DOWN state indicator
- **Bit 15**: Error bit (should remain 0 during normal operation)

### OutputB (Trigger Threshold)
- Should be 0x0000 when not in FIRING state
- Should show trigger threshold value (0x4000) during FIRING state

### OutputC (Intensity)
- Should be 0x0000 when not in FIRING state
- Should show intensity value during FIRING state (e.g., 0x0240 for intensity 50)

## Validation Results
The testbench successfully validates:
- ✅ Zero-init mode behavior
- ✅ Normal operation cycles
- ✅ Auto-arm functionality
- ✅ Output consistency
- ✅ State machine transitions
- ✅ Status register behavior

## Integration with Existing Test Suite
This testbench complements the existing test suite:
- **Unit Tests**: Focus on individual module functionality
- **Integration Tests**: Test complete top-level interface
- **CustomWrapper-top**: High-level sanity checking and real hardware simulation

## Benefits
1. **Real Hardware Simulation**: Accurately simulates actual hardware behavior
2. **Comprehensive Monitoring**: Provides detailed insight into system operation
3. **Sanity Checking**: Validates logical consistency of outputs
4. **Debugging Support**: Helps identify issues in top-level integration
5. **Documentation**: Serves as a reference for expected system behavior

## Future Enhancements
Potential improvements could include:
- Additional test scenarios for edge cases
- Performance benchmarking capabilities
- Automated regression testing
- Integration with formal verification tools
