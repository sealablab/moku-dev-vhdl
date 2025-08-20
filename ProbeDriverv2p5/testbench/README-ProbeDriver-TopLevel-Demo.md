# ProbeDriver Top-Level Demonstration Testbench

## Overview

This testbench demonstrates how to drive the top-level ProbeDriver module (`CustomWrapper` with `ProbeDriver` architecture) and observe the state machine progress through status LEDs. It serves as a practical example for understanding the complete ProbeDriver system behavior.

## Purpose

The goal of this testbench is to:

1. **Illustrate how to drive the 'top' level ProbeDriver module** - Shows the complete interface and control register usage
2. **Load known good values into ControlRegisters** - Demonstrates proper configuration with safe, validated parameters
3. **Observe state machine progress through status LEDs** - Provides real-time visibility into the internal state transitions

## Key Features Demonstrated

### Configuration Values
- **IntensityIndex**: Set to `0x01` (1% intensity) - the smallest observable output
- **Pulse Duration**: Set to `ProbeConfig.Min_Duration` (100 clock cycles) - safe minimum value
- **Cooldown Period**: Set to `ProbeConfig.Min_Cooldown` (1000 clock cycles) - safe minimum value
- **Clock Divider**: Set to `0x1` (no division) - for maximum responsiveness

### State Machine Observation
The testbench monitors and reports on the complete state machine progression:
- **IDLE** → **ARMED** → **FIRING** → **FIRED** → **COOL_DOWN** → **ARMED**

### Status LED Monitoring
Real-time monitoring of the 5 status LEDs:
- LED 0: ARMED status
- LED 1: FIRING status  
- LED 2: FIRED status
- LED 3: COOL_DOWN status
- LED 4: ERROR status

## Test Phases

1. **INIT**: Initial setup and reset
2. **RESET_PHASE**: Release reset and initialize
3. **CONFIGURE_REGISTERS**: Load known good values into control registers
4. **ENABLE_SYSTEM**: Enable the module and wait for ARMED state
5. **TRIGGER_PROBE**: Assert soft trigger and observe firing sequence
6. **OBSERVE_STATES**: Monitor state transitions through status LEDs
7. **AUTO_ARM_TEST**: Test auto-arm feature for automatic re-arming
8. **VERIFICATION**: Final verification of system behavior
9. **COMPLETE**: Test completion and summary

## Usage

### Running the Testbench

```bash
# Navigate to the testbench directory
cd moku-dev-vhdl/ProbeDriver/testbench

# Run the demo testbench
make demo_test

# View waveforms (requires GTKWave)
make wave_demo
```

### Expected Output

The testbench provides detailed reporting of:
- Configuration loading verification
- Real-time status LED changes
- State machine transitions
- Output value monitoring
- Assertion checks for validation

### Waveform Analysis

The generated `demo_test.vcd` file can be viewed with GTKWave to observe:
- Control register values over time
- Status register (OutputA) changes
- OutputB (trigger threshold) and OutputC (intensity) behavior
- Clock and reset timing

## Technical Details

### Control Register Mapping
- **Control0[31]**: Global enable (active low)
- **Control0[30]**: Auto-arm feature
- **Control0[28]**: Status clear
- **Control0[27:24]**: Clock divider selection
- **Control0[23]**: Soft trigger (auto-de-asserted)
- **Control0[22:16]**: Intensity index (7-bit)
- **Control0[15:0]**: Pulse duration (16-bit)

- **Control1[31:16]**: Cooldown period (16-bit)
- **Control1[15:0]**: Reserved

### Status Register Interpretation
- **OutputA[4:0]**: Status LED states (latched)
- **OutputB**: Trigger threshold when firing (0x4000)
- **OutputC**: Intensity output (only valid during FIRING state)
- **OutputD**: Reserved for future use

## Safety Features Demonstrated

- **Minimum Duration**: Uses `PROBE_PULSE_MIN_DURATION` to prevent unsafe short pulses
- **Minimum Cooldown**: Uses `PROBE_COOLDOWN_MIN` to ensure proper recovery
- **Safe Intensity**: Uses index 0x01 (1%) which provides the smallest observable output
- **Auto-deassertion**: Soft trigger automatically de-asserts after one clock cycle

## Integration with Other Testbenches

This demo testbench complements the existing testbench suite:
- **Core Tests**: Focus on individual component behavior
- **Wrapper Tests**: Test the wrapper interface
- **High-Level Tests**: Test the complete CustomWrapper
- **Demo Testbench**: Demonstrate practical usage and configuration

## Troubleshooting

### Common Issues
1. **Compilation Errors**: Ensure all dependencies are properly analyzed
2. **Simulation Hangs**: Check that reset is properly released
3. **Unexpected States**: Verify control register configuration values

### Debugging Tips
- Use the detailed reporting to track state transitions
- Monitor status LED changes for unexpected behavior
- Check assertion failures for configuration validation issues

## Future Enhancements

Potential improvements for this testbench:
- Add more configuration value combinations
- Include error condition testing
- Add performance benchmarking
- Integrate with automated testing frameworks

## Related Documentation

- [ProbeDriver Package](../common/probe_driver_pkg.vhd)
- [Intensity LUT Package](../common/intensity_lut_pkg.vhd)
- [ProbeDriver Core](../core/probe_driver_core.vhd)
- [ProbeDriver Wrapper](../wrapper/probe_driver_wrapper.vhd)
- [Main ProbeDriver Module](../ProbeDriver.vhd)
