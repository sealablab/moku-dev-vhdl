# Probe Driver Core - Design Documentation

## Overview

The `probe_driver_core.vhd` implements a sophisticated finite state machine for controlling fault injection probe operations. This core represents the culmination of several design iterations, evolving from basic requirements to a production-ready implementation that addresses real-world usability and operational needs.

## Design Evolution

### Initial Requirements (Iteration 1)
- Basic state machine: IDLE → ARMED → FIRING → COOL_DOWN → IDLE
- Simple trigger-based firing mechanism
- Fixed timing parameters
- Basic status reporting

### Enhanced Requirements (Iteration 2)
- Auto-initialization after system reset
- Configurable auto-re-arm behavior
- Enhanced status register with event tracking
- Safe default configuration handling

### Current Implementation (Iteration 3)
- **Complete operational lifecycle management**
- **Smart initialization with safe defaults**
- **Flexible re-arming strategies**
- **Comprehensive status monitoring**
- **Robust configuration validation**

## Architecture

### State Machine Design
```
IDLE → ARMED → FIRING → COOL_DOWN → (ARMED/IDLE)
  ↑                                    ↓
  └─────────── Auto-re-arm ───────────┘
```

**State Descriptions:**
- **IDLE**: System disabled, waiting for enable signal
- **ARMED**: Ready to fire, waiting for trigger input
- **FIRING**: Actively driving probe with configured intensity and duration
- **COOL_DOWN**: Mandatory cooling period before re-arming

### Key Design Features

#### 1. Auto-Initialization Logic
```vhdl
-- Auto-fire on reset: fires once using safe defaults after first enable
signal reset_fired : std_logic := '0';

-- After reset, automatically go to ARMED state
if reset_fired = '0' then
    current_state <= ARMED;
    reset_fired <= '1';
end if;
```
**Purpose**: Eliminates manual arming after system reset, providing immediate operational readiness.

#### 2. Sticky Event Tracking
```vhdl
-- Sticky FIRED flag (bit 2) - set after a completed pulse, cleared by reset or status_clear
signal fired_flag : std_logic := '0';

-- Set sticky FIRED flag on completion
fired_flag <= '1';
```
**Purpose**: Maintains event history until explicitly cleared, enabling event-driven systems to detect completed operations.

#### 3. Flexible Re-arming Strategy
```vhdl
-- Auto-arm: go directly to ARMED
if probe_auto_arm = '1' then
    current_state <= ARMED;
else
    -- Normal behavior: go to IDLE
    current_state <= IDLE;
end if;
```
**Purpose**: Supports both manual and automatic re-arming based on operational requirements.

#### 4. Safe Configuration Management
```vhdl
-- Apply safe defaults using package functions
intensity_index <= get_safe_intensity_index(config_intensity_index);
pulse_duration <= get_safe_duration(config_pulse_duration);
cooldown_period <= get_safe_cooldown(config_cooldown_period);
```
**Purpose**: Ensures system operates within safe parameters even with invalid configuration inputs.

## Interface Specification

### Input Ports
| Port | Type | Width | Description |
|------|------|-------|-------------|
| `clk` | in | 1 | System clock |
| `reset` | in | 1 | Active-high reset |
| `enable` | in | 1 | System enable |
| `clk_en` | in | 1 | Clock enable for power management |
| `status_clear` | in | 1 | Clear sticky status flags |
| `config_intensity_index` | in | 7 | Intensity setting (0-100) |
| `config_pulse_duration` | in | 16 | Pulse duration in clock cycles |
| `config_cooldown_period` | in | 16 | Cooldown period in clock cycles |
| `probe_trigger_input` | in | 1 | Trigger signal to fire probe |
| `probe_auto_arm` | in | 1 | Auto-re-arm after cooldown |

### Output Ports
| Port | Type | Width | Description |
|------|------|-------|-------------|
| `probe_trigger_output` | out | 16 | Trigger output signal |
| `probe_intensity_output` | out | 16 | Intensity output voltage |
| `probe_status_register` | out | 16 | Current status and events |

## Status Register Format

### Bit Mapping
```
Bit 15-4: Reserved for future expansion
Bit 3:    COOL_DOWN state indicator
Bit 2:    FIRED event flag (sticky)
Bit 1:    FIRING state indicator  
Bit 0:    ARMED state indicator
```

### Status Decoding
- **0x01**: ARMED - Ready to fire
- **0x02**: FIRING - Actively driving probe
- **0x04**: FIRED - Pulse completed (sticky)
- **0x08**: COOL_DOWN - Cooling period active
- **0x0F**: All states active (error condition)

## Operational Characteristics

### Timing Precision
- **Pulse Duration**: Controlled via 16-bit counter for precise timing
- **Cooldown Period**: Enforced minimum cooling time
- **State Transitions**: Synchronized to clock edges with enable control

### Safety Features
- **Minimum Duration**: 100 clock cycles minimum pulse width
- **Minimum Cooldown**: 1000 clock cycles minimum cooling time
- **Safe Defaults**: Package functions provide validated configuration values
- **Reset Recovery**: Automatic return to safe operational state

### Performance Considerations
- **Single Clock Domain**: All logic operates on rising edge of system clock
- **Clock Enable**: Power management support via `clk_en` signal
- **Combinational Outputs**: Status and control signals updated every clock cycle
- **Minimal Latency**: State transitions occur within one clock cycle

## Usage Patterns

### Typical Operation Sequence
1. **System Reset**: Core automatically initializes to safe state
2. **Enable**: System becomes operational, core moves to ARMED state
3. **Trigger**: External trigger fires probe, moves to FIRING state
4. **Pulse**: Core drives probe for configured duration
5. **Cooldown**: Mandatory cooling period enforced
6. **Re-arm**: Automatic or manual re-arming based on configuration

### Configuration Guidelines
- **Intensity**: Use 0-100 range for safe operation
- **Duration**: Minimum 100 clock cycles recommended
- **Cooldown**: Minimum 1000 clock cycles for thermal safety
- **Auto-arm**: Enable for continuous operation, disable for manual control

## Design Decisions and Rationale

### Why Auto-Initialization?
**Problem**: Manual arming after reset creates operational delays
**Solution**: Automatic transition to ARMED state after first enable
**Benefit**: Immediate operational readiness without user intervention

### Why Sticky Event Flags?
**Problem**: Event detection requires continuous monitoring
**Solution**: Sticky flags that persist until explicitly cleared
**Benefit**: Event-driven systems can detect completed operations asynchronously

### Why Flexible Re-arming?
**Problem**: Different operational modes require different re-arming strategies
**Solution**: Configurable auto-re-arm behavior
**Benefit**: Supports both continuous operation and manual control modes

### Why Safe Defaults?
**Problem**: Invalid configuration can cause unsafe operation
**Solution**: Package functions provide validated default values
**Benefit**: System remains safe even with configuration errors

## Future Enhancements

### Planned Features
- **Error Detection**: Enhanced error reporting and recovery
- **Performance Monitoring**: Timing and efficiency metrics
- **Configuration Validation**: Runtime parameter checking
- **Power Management**: Advanced clock gating and power states

### Extension Points
- **Status Register**: 16-bit design allows for future status bits
- **Configuration Types**: Consistent data widths support parameter expansion
- **State Machine**: Modular design enables additional operational states
- **Package Functions**: Utility functions can be extended for new features

## Testing and Validation

### Test Scenarios
1. **Reset Recovery**: Verify automatic initialization
2. **Timing Accuracy**: Validate pulse duration and cooldown periods
3. **Status Reflection**: Confirm status register accuracy
4. **Configuration Handling**: Test safe defaults and parameter validation
5. **Auto-re-arm**: Verify both manual and automatic re-arming modes

### Validation Criteria
- **Functional Correctness**: All state transitions occur as specified
- **Timing Compliance**: Pulse and cooldown durations meet requirements
- **Safety Compliance**: System operates within safe parameter ranges
- **Interface Compliance**: All ports behave according to specification

## Conclusion

The `probe_driver_core.vhd` represents a mature, production-ready design that evolved through careful consideration of real-world operational requirements. The implementation demonstrates several key principles:

1. **User Experience**: Auto-initialization and flexible operation modes
2. **System Integration**: Comprehensive status reporting and event tracking
3. **Robustness**: Safe defaults and configuration validation
4. **Maintainability**: Clear state machine with well-defined transitions
5. **Extensibility**: Modular design supporting future enhancements

This core serves as a foundation for reliable fault injection probe control, addressing both immediate operational needs and long-term system requirements.
```

This README.md captures the design evolution, explains the key design decisions, and provides comprehensive documentation for future developers (including yourself) to understand the implementation. It emphasizes the sophisticated features that evolved from basic requirements and explains why each design decision was made.
