# Slot2 Register Reference & Testing Guide

## Overview
This document provides a complete reference for the Control1-Control4 registers used to control the probe driver module from the TOP level. All registers can be set over the network for convenient testing and control.

## Register Layout Summary

### Control0 (32 bits) - RESERVED for TOP Module
- **Purpose**: Reserved for TOP module functionality
- **Access**: Read/Write by TOP module
- **Usage**: Not used by probe driver

### Control1 (32 bits) - Control & Status
```
[31:16] = Reserved for future expansion
[15]    = Reset signal (1 = reset, 0 = normal operation)
[14]    = Enable signal (1 = enabled, 0 = disabled)
[13]    = Trigger input signal (1 = trigger, 0 = no trigger)
[12:8]  = Mode selection (5 bits for future operating modes)
[7:0]   = Status readback (probe driver status register)
```

### Control2 (32 bits) - Intensity Configuration
```
[31:16] = Reserved for future expansion
[15:8]  = Intensity index (8 bits, 0-100)
[7:0]   = Reserved for future expansion
```

### Control3 (32 bits) - Pulse Duration
```
[31:0] = Pulse duration in clock cycles (full 32-bit range)
```

### Control4 (32 bits) - Cooldown Period
```
[31:0] = Cooldown period in clock cycles (full 32-bit range)
```

## Testing Configurations

### 1. Basic Probe Driver Test
```bash
# Control1: Enable probe driver
Control1 = 0x00004000  # [14] = 1 (enable), others = 0

# Control2: Set intensity to 50%
Control2 = 0x00003200  # [15:8] = 0x32 (50), others = 0

# Control3: Set pulse duration to 100 cycles
Control3 = 0x00000064  # 100 decimal

# Control4: Set cooldown to 256 cycles
Control4 = 0x00000100  # 256 decimal
```

### 2. High-Intensity Test
```bash
# Control1: Enable probe driver
Control1 = 0x00004000  # [14] = 1 (enable)

# Control2: Set intensity to maximum (100%)
Control2 = 0x00006400  # [15:8] = 0x64 (100)

# Control3: Short pulse duration
Control3 = 0x00000020  # 32 cycles

# Control4: Short cooldown
Control4 = 0x00000040  # 64 cycles
```

### 3. Low-Intensity Test
```bash
# Control1: Enable probe driver
Control1 = 0x00004000  # [14] = 1 (enable)

# Control2: Set intensity to minimum (0%)
Control2 = 0x00000000  # [15:8] = 0x00 (0)

# Control3: Long pulse duration
Control3 = 0x00000100  # 256 cycles

# Control4: Long cooldown
Control4 = 0x00000200  # 512 cycles
```

### 4. Rapid-Fire Test
```bash
# Control1: Enable probe driver
Control1 = 0x00004000  # [14] = 1 (enable)

# Control2: Medium intensity
Control2 = 0x00003200  # [15:8] = 0x32 (50)

# Control3: Very short pulse
Control3 = 0x00000010  # 16 cycles

# Control4: Very short cooldown
Control4 = 0x00000020  # 32 cycles
```

### 5. Reset & Parameter Change Test
```bash
# Step 1: Set new parameters
Control2 = 0x00005000  # Intensity = 80
Control3 = 0x00000080  # Pulse = 128 cycles
Control4 = 0x00000100  # Cooldown = 256 cycles

# Step 2: Reset to load new parameters
Control1 = 0x00008000  # [15] = 1 (reset)

# Step 3: Clear reset and enable
Control1 = 0x00004000  # [14] = 1 (enable), [15] = 0 (no reset)
```

## Network Testing Commands

### Using set_regs API (example)
```bash
# Enable probe driver with 50% intensity
set_regs 1 0x00004000  # Control1: enable
set_regs 2 0x00003200  # Control2: intensity 50
set_regs 3 0x00000064  # Control3: pulse 100 cycles
set_regs 4 0x00000100  # Control4: cooldown 256 cycles

# Trigger the probe driver
set_regs 1 0x00006000  # Control1: enable + trigger

# Clear trigger
set_regs 1 0x00004000  # Control1: enable only
```

### Using get_regs API (example)
```bash
# Read current status
get_regs 1  # Read Control1 (includes status bits [7:0])

# Read current intensity setting
get_regs 2  # Read Control2 (intensity in bits [15:8])
```

## Status Register Decoding

### Control1[7:0] - Probe Driver Status
```
[7:4] = Reserved
[3]   = COOL_DOWN state (1 = in cooldown, 0 = not in cooldown)
[2]   = FIRED state (1 = pulse completed, 0 = not fired)
[1]   = FIRING state (1 = actively firing, 0 = not firing)
[0]   = ARMED state (1 = armed and ready, 0 = not armed)
```

### Status State Machine
```
IDLE → ARMED → FIRING → FIRED → COOL_DOWN → IDLE
  ↓      ↓       ↓       ↓        ↓         ↓
  0      1       2       3        4         0
```

## Output Signal Mapping

### OutputA
- **Content**: Probe driver intensity output
- **Timing**: Only valid during FIRING state
- **Note**: Shows 0 when not firing (normal behavior)

### OutputB
- **Content**: Probe intensity when firing, 0 otherwise
- **Usage**: Indicates when probe is actively firing

### OutputC
- **Content**: Control0[10:0] & probe driver status register
- **Usage**: Debug information and status monitoring

### OutputD
- **Content**: Status register & control state
- **Format**: [15:8] = status, [7:0] = control bits
- **Usage**: Real-time status and control monitoring

## Testing Workflow

### 1. Initialization
```bash
# Set desired parameters
set_regs 2 <intensity_value>
set_regs 3 <pulse_duration>
set_regs 4 <cooldown_period>

# Reset to load parameters
set_regs 1 0x00008000  # Assert reset
set_regs 1 0x00000000  # Clear reset
```

### 2. Operation
```bash
# Enable probe driver
set_regs 1 0x00004000  # Enable

# Trigger firing
set_regs 1 0x00006000  # Enable + trigger

# Monitor status via OutputD or Control1[7:0]
# Wait for cycle completion
```

### 3. Parameter Changes
```bash
# Set new parameters
set_regs 2 <new_intensity>
set_regs 3 <new_pulse_duration>
set_regs 4 <new_cooldown>

# Reset to reload parameters
set_regs 1 0x00008000  # Assert reset
set_regs 1 0x00000000  # Clear reset
set_regs 1 0x00004000  # Re-enable
```

## Common Test Scenarios

### Scenario 1: Basic Functionality
1. Set intensity = 50, pulse = 100, cooldown = 256
2. Reset to load parameters
3. Enable probe driver
4. Trigger and observe OutputA during firing
5. Verify OutputD status transitions

### Scenario 2: Intensity Sweep
1. Loop through intensities: 0, 25, 50, 75, 100
2. For each intensity: reset, enable, trigger, observe
3. Verify OutputA shows correct IntensityLut values

### Scenario 3: Timing Variations
1. Test different pulse durations: 16, 32, 64, 128, 256 cycles
2. Test different cooldown periods: 32, 64, 128, 256, 512 cycles
3. Verify timing accuracy and state transitions

### Scenario 4: Error Conditions
1. Test invalid intensity values (>100)
2. Test very short pulse durations (<2 cycles)
3. Test very short cooldown periods (<1 cycle)
4. Verify error bits in status register

## Troubleshooting

### Issue: OutputA always shows 0
- **Cause**: Checking output after firing cycle completes
- **Solution**: Monitor OutputA during FIRING state only
- **Verification**: Check OutputD status bits [1] for FIRING state

### Issue: Parameters not taking effect
- **Cause**: Parameters not loaded due to missing reset
- **Solution**: Always reset after changing parameters
- **Verification**: Check that reset bit [15] is properly toggled

### Issue: Probe driver not responding
- **Cause**: Enable signal not set
- **Solution**: Ensure Control1[14] = 1
- **Verification**: Check OutputD for proper state transitions

## Future Expansion

### Reserved Bits Available
- **Control1[31:16]**: 16 bits for additional control signals
- **Control1[12:8]**: 5 bits for operating modes
- **Control2[31:16]**: 16 bits for additional intensity parameters
- **Control2[7:0]**: 8 bits for intensity sub-parameters

### Potential Additions
- Auto-reset functionality
- Multiple operating modes
- Advanced timing controls
- Intensity ramping
- Burst mode operations
- Safety interlocks

---

*This document provides complete reference for testing the probe driver module over the network. All register values are in hexadecimal format and can be set using the set_regs API.*
