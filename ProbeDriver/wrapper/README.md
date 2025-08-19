# Probe Driver Wrapper - Interface and Control Documentation

## Overview

The `probe_driver_wrapper.vhd` serves as the top-level interface layer for the ProbeDriver system, providing the bridge between the Moku platform's standardized interface and the specialized probe driver core. This wrapper handles control register mapping, status LED management, clock division, and output formatting.

## Design Philosophy

### Interface Abstraction
The wrapper abstracts the complex probe driver functionality behind a simple, standardized interface that follows Moku platform conventions. It transforms high-level control register settings into the specific signals required by the probe driver core.

### Separation of Concerns
- **Wrapper**: Interface management, control register decoding, output formatting
- **Core**: State machine logic, timing control, probe operation
- **Clock Divider**: Frequency management and power control

## Interface Specification

### Platform Interface Ports

#### Clock and Control
| Port | Type | Width | Description |
|------|------|-------|-------------|
| `clk` | in | 1 | System clock input |
| `reset` | in | 1 | Active-high system reset |

#### Input Ports (Platform-Specific)
| Port | Type | Width | Description |
|------|------|-------|-------------|
| `InputA` | in | 16 | Input A (currently unused) |
| `InputB` | in | 16 | Input B (currently unused) |
| `InputC` | in | 16 | Input C (currently unused) |
| `InputD` | in | 16 | Input D (currently unused) |

**Note**: Input ports are included for platform compatibility but are not currently utilized by the probe driver system.

#### Output Ports (Platform-Specific)
| Port | Type | Width | Description |
|------|------|-------|-------------|
| `OutputA` | out | 16 | Probe driver status register |
| `OutputB` | out | 16 | Trigger threshold during firing |
| `OutputC` | out | 16 | Probe intensity output |
| `OutputD` | out | 16 | Reserved for future use |

#### Control Registers
| Port | Type | Width | Description |
|------|------|-------|-------------|
| `Control0` | in | 32 | Primary control register |
| `Control1` | in | 32 | Secondary control register |
| `Control2-Control15` | in | 32 | Reserved for future expansion |

## Control Register Mapping

### Control0 - Primary Control Register
```
Bit 31: Global Enable
Bit 30: Auto-arm Mode
Bit 29: Reserved
Bit 28: Status Clear
Bit 27-24: Clock Divider Selection
Bit 23: Soft Trigger
Bit 22-16: Intensity Index (7-bit)
Bit 15-0:  Pulse Duration (16-bit)
```

**Detailed Bit Functions:**
- **Bit 31 - Global Enable**: Master enable for the entire probe driver system
- **Bit 30 - Auto-arm**: When set, automatically re-arms after cooldown completion
- **Bit 28 - Status Clear**: Clears sticky status flags and resets LED indicators
- **Bits 27-24 - Clock Divider**: 4-bit divider selection (0-15) for power management
- **Bit 23 - Soft Trigger**: Software-controlled trigger signal for probe firing
- **Bits 22-16 - Intensity Index**: 7-bit index into intensity lookup table (0-100 range)
- **Bits 15-0 - Pulse Duration**: 16-bit pulse width in clock cycles

### Control1 - Secondary Control Register
```
Bit 31-16: Cooldown Period (16-bit)
Bit 15-0:  Reserved for future use
```

**Detailed Bit Functions:**
- **Bits 31-16 - Cooldown Period**: 16-bit cooldown duration in clock cycles
- **Bits 15-0 - Reserved**: Available for future configuration parameters

## Output Signal Mapping

### OutputA - Status Register
```
[15:5]: Reserved for future expansion (set to 0)
[4]:    Error indicator (future use)
[3]:    COOL_DOWN state active
[2]:    FIRED event occurred (sticky)
[1]:    FIRING state active
[0]:    ARMED state active
```

**Status Decoding Examples:**
- **0x0001**: ARMED - Ready to fire
- **0x0002**: FIRING - Actively driving probe
- **0x0004**: FIRED - Pulse completed (sticky flag)
- **0x0008**: COOL_DOWN - Cooling period active
- **0x000F**: All states active (error condition)

### OutputB - Trigger Threshold
- **During FIRING**: Shows `PROBE_TRIGGER_THRESHOLD` value
- **Other States**: Shows 0x0000
- **Purpose**: Provides real-time confirmation of trigger signal generation

### OutputC - Intensity Output
- **During FIRING**: Shows current probe intensity voltage
- **Other States**: Shows 0x0000
- **Purpose**: Real-time monitoring of probe drive level

### OutputD - Reserved
- **Current Value**: Always 0x0000
- **Future Use**: Available for additional status or control signals

## Internal Architecture


### Key Internal Signals
| Signal | Type | Width | Purpose |
|--------|------|-------|---------|
| `probe_trigger_output` | signed | 16 | Core trigger output |
| `probe_intensity_output` | signed | 16 | Core intensity output |
| `probe_status_register` | probe_status_type | 16 | Core status register |
| `probe_clk_en` | std_logic | 1 | Clock enable from divider |
| `status_leds` | std_logic_vector | 5 | LED status indicators |

## Status LED Management

### LED Mapping
| LED | Status Bit | Description |
|-----|------------|-------------|
| LED0 | Bit 0 | ARMED state indicator |
| LED1 | Bit 1 | FIRING state indicator |
| LED2 | Bit 2 | FIRED event indicator (sticky) |
| LED3 | Bit 3 | COOL_DOWN state indicator |
| LED4 | Bit 4 | Error indicator (future use) |

### LED Behavior
- **Latch Logic**: LEDs remain on once set until explicitly cleared
- **Clear Mechanism**: LEDs reset via `status_clear` signal (Control0[28])
- **Reset Behavior**: All LEDs clear on system reset
- **Visual Feedback**: Provides immediate visual status indication

## Clock Management

### Clock Divider Integration
```vhdl
u_clk_divider: entity work.clock_divider
    generic map (
        DIVIDER_WIDTH => 4,               -- 4-bit divider for ProbeDriver
        MAX_DIVIDER => 15
    )
    port map (
        clk_in      => clk,
        reset       => reset,
        divider     => "0000" & clock_divider_sel,  -- Extend 4-bit to 16-bit
        enable      => '1',                         -- Always enabled
        clk_out     => open,                        -- Not used in ProbeDriver
        clk_out_en  => probe_clk_en                 -- Clock enable for ProbeDriver
    );
```

**Purpose**: Enables power management by reducing clock frequency to the probe driver core
**Configuration**: 4-bit divider selection (0-15) provides 16 different frequency options
**Power Savings**: Lower frequency operation reduces dynamic power consumption

## Configuration Guidelines

### Recommended Settings

#### Clock Divider Selection
- **High Performance**: Use divider 0-3 for maximum responsiveness
- **Power Saving**: Use divider 8-15 for reduced power consumption
- **Balanced**: Use divider 4-7 for typical operation

#### Intensity Configuration
- **Safe Operation**: Start with intensity index 10-20
- **Normal Operation**: Use intensity index 30-70
- **High Power**: Use intensity index 80-100 (monitor thermal conditions)

#### Timing Parameters
- **Minimum Duration**: 100 clock cycles recommended
- **Minimum Cooldown**: 1000 clock cycles for thermal safety
- **Typical Values**: Duration 1000-10000, Cooldown 5000-50000

## Usage Patterns

### Basic Operation Sequence
1. **Initialize**: Set Control0[31] = '1' to enable system
2. **Configure**: Set intensity, duration, and cooldown parameters
3. **Arm**: System automatically arms after enable
4. **Trigger**: Use Control0[23] or external trigger to fire probe
5. **Monitor**: Observe status via OutputA and LED indicators
6. **Clear**: Use Control0[28] to clear sticky status flags

### Advanced Operation
- **Auto-Arm**: Set Control0[30] = '1' for auto-re-arming
- **Power Management**: Adjust clock divider based on performance requirements
- **Status Monitoring**: Use OutputA for real-time state monitoring
- **Event Detection**: Monitor OutputA[2] for pulse completion events

## Future Enhancements

### Planned Features
- **Error Detection**: Enhanced error reporting via reserved status bits
- **Configuration Validation**: Runtime parameter checking and validation

### Extension Points
- **Control Registers**: 14 reserved registers available for expansion
- **Output Ports**: OutputD available for additional status information
- **Input Ports**: All input ports available for external trigger integration
- **Status Register**: 11 reserved bits for future status indicators

## Integration Considerations

### Platform Compatibility
- **Interface Standard**: Follows Moku platform interface conventions
- **Clock Domain**: Single clock domain design for simplicity
- **Reset Strategy**: Synchronous reset with proper initialization
- **Power Management**: Clock divider support for power-sensitive applications

### System Integration
- **Status Monitoring**: Real-time status available via output ports
- **Control Interface**: Simple register-based control mechanism
- **Event Detection**: Sticky flags for event-driven systems
- **Visual Feedback**: LED indicators for immediate status recognition

## Conclusion

The `probe_driver_wrapper.vhd` provides a clean, standardized interface to the sophisticated probe driver core.

The wrapper's design emphasizes:
1. **Simplicity**: Easy-to-understand control register mapping
2. **Flexibility**: Configurable operation modes and timing parameters
3. **Monitoring**: Comprehensive status reporting and visual indicators
4. **Integration**: Standard platform interface with future expansion capability

This implementation demonstrates how complex functionality can be made accessible through well-designed interface layers while maintaining the performance and reliability of the underlying core system.
