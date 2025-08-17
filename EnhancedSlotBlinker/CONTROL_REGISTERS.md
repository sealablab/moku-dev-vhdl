# Enhanced SlotBlinker Control Registers

The enhanced SlotBlinker provides comprehensive control over all four outputs through five control registers (CR0-CR4). This document explains each bit field and provides usage examples.

## Control Register Overview

| Register | Purpose | Bit Range | Description |
|----------|---------|-----------|-------------|
| **CR0** | Global Control & Timing | 31-0 | Master enable, reset, sign control, global divider |
| **CR1** | Output A Configuration | 31-0 | Frequency, amplitude, pattern, phase for Output A |
| **CR2** | Output B Configuration | 31-0 | Frequency, amplitude, pattern, phase for Output B |
| **CR3** | Output C Configuration | 31-0 | Frequency, amplitude, pattern, phase for Output C |
| **CR4** | Output D Configuration | 31-0 | Frequency, amplitude, pattern, phase for Output D |

## CR0: Global Control & Timing

```
CR0(31): Enable (active-low)
CR0(30): Software Reset (pulse high to reset)
CR0(29): Sign Control (0=unsigned, 1=signed)
CR0(28-24): Global Clock Divider (1-32)
CR0(23-16): Pattern Selector (0-255)
CR0(15-8):  Reserved
CR0(7-0):   Reserved
```

### CR0 Bit Field Details

#### **CR0(31): Enable**
- **0**: Disabled (all outputs = 0)
- **1**: Enabled (normal operation)
- **Note**: Active-low for compatibility with existing designs

#### **CR0(30): Software Reset**
- **0**: Normal operation
- **1**: Reset all counters and outputs (pulse high to reset)
- **Usage**: Set to 1, then back to 0 to reset the system

#### **CR0(29): Sign Control**
- **0**: **Safe Mode** - All outputs are unsigned (0 to +32767)
- **1**: **Full Range** - All outputs can be signed (-32768 to +32767)
- **Recommendation**: Use 0 for safe operation, 1 for advanced users

#### **CR0(28-24): Global Clock Divider**
- **Range**: 1 to 32 (0 = 1, 1 = 1, 2 = 2, ..., 31 = 32)
- **Effect**: Scales ALL outputs down by the same factor
- **Example**: Setting to 16 makes all patterns 16x slower
- **Usage**: Easy way to slow down everything for debugging

#### **CR0(23-16): Pattern Selector**
- **Range**: 0-255
- **Current**: Reserved for future global pattern modes
- **Future**: Could select preset configurations

## CR1-CR4: Individual Output Configuration

Each output (A, B, C, D) has identical configuration in CR1-CR4:

```
CRx(31-24): Frequency Divider (1-256)
CRx(23-16): Amplitude Scale (0-255)
CRx(15-8):  Pattern Type (0-255)
CRx(7-0):   Phase Offset (0-255)
```

### Frequency Divider (Bits 31-24)
- **Range**: 1 to 256 (0 = 1, 1 = 1, 2 = 2, ..., 255 = 256)
- **Effect**: Controls how fast this specific output changes
- **Formula**: Output frequency = (Global Clock / Global Divider) / Frequency Divider
- **Example**: If global divider = 4 and freq_div = 16, output changes every 64 clock cycles

### Amplitude Scale (Bits 23-16)
- **Range**: 0 to 255
- **Effect**: Scales the output amplitude
- **Formula**: Final amplitude = (Raw pattern × Amplitude Scale) / 255
- **Example**: 
  - Amplitude Scale = 128 → 50% of full scale
  - Amplitude Scale = 255 → 100% of full scale
  - Amplitude Scale = 0 → Output = 0

### Pattern Type (Bits 15-8)
- **Range**: 0-255
- **Current Patterns**:
  - **0**: Sawtooth (default) - Linear ramp from 0 to max
  - **1**: Square Wave - Toggle between high and low
  - **2**: Sine Approximation - 8-step sine wave approximation
  - **3**: Random - Pseudo-random pattern
  - **4-255**: Reserved for future patterns

### Phase Offset (Bits 7-0)
- **Range**: 0 to 255
- **Effect**: Shifts the pattern in time
- **Formula**: Phase shift = (Phase Offset × 256) / Frequency Divider
- **Example**: 
  - Phase Offset = 64 with Freq Div = 128 → 90° phase shift
  - Phase Offset = 128 with Freq Div = 256 → 180° phase shift

## Default Configuration (Backward Compatible)

When all control registers are 0, the SlotBlinker behaves like the original:

- **CR0**: Enable = 1 (enabled), Sign Control = 0 (safe unsigned mode)
- **CR1-CR4**: All outputs use default values
  - Frequency Divider = 1 (fastest)
  - Amplitude Scale = 255 (full scale)
  - Pattern Type = 0 (sawtooth)
  - Phase Offset = 0 (no phase shift)

## Usage Examples

### Example 1: Safe Default Operation
```python
# All outputs enabled, safe unsigned mode, normal speed
CR0 = 0x80000000  # Enable = 1, Sign Control = 0
CR1 = 0x00000000  # Output A: default settings
CR2 = 0x00000000  # Output B: default settings
CR3 = 0x00000000  # Output C: default settings
CR4 = 0x00000000  # Output D: default settings
```

### Example 2: Slow Motion Debug Mode
```python
# Slow everything down 16x for debugging
CR0 = 0x90000000  # Enable = 1, Global Divider = 16
CR1 = 0x00000000  # Output A: default settings
CR2 = 0x00000000  # Output B: default settings
CR3 = 0x00000000  # Output C: default settings
CR4 = 0x00000000  # Output D: default settings
```

### Example 3: Different Pattern Types
```python
# Output A: Fast sawtooth, Output B: Slow square wave
CR0 = 0x80000000  # Enable = 1, normal speed
CR1 = 0x00000000  # Output A: sawtooth, full speed
CR2 = 0x01010000  # Output B: square wave, 16x slower
CR3 = 0x00000000  # Output C: default
CR4 = 0x00000000  # Output D: default
```

### Example 4: Phase-Shifted Outputs
```python
# All outputs same frequency but 90° apart
CR0 = 0x80000000  # Enable = 1, normal speed
CR1 = 0x00000000  # Output A: 0° phase
CR2 = 0x00004000  # Output B: 90° phase
CR3 = 0x00008000  # Output C: 180° phase
CR4 = 0x0000C000  # Output D: 270° phase
```

### Example 5: Full Range Mode
```python
# Enable full signed range for advanced users
CR0 = 0xA0000000  # Enable = 1, Sign Control = 1
CR1 = 0x00000000  # Output A: default settings
CR2 = 0x00000000  # Output B: default settings
CR3 = 0x00000000  # Output C: default settings
CR4 = 0x00000000  # Output D: default settings
```

## Safety Features

1. **Sign Control (CR0(29))**: Defaults to 0 (safe unsigned mode)
2. **Amplitude Scaling**: Prevents accidental over-voltage
3. **Frequency Limits**: Reasonable ranges prevent extreme frequencies
4. **Backward Compatibility**: Original behavior preserved when CRs = 0

## Future Extensions

The control register design allows for future enhancements:
- **CR5-CR15**: Reserved for advanced features
- **Pattern Types 4-255**: Additional waveform types
- **Global Pattern Selector**: Preset configurations
- **Advanced Timing**: More sophisticated clock control
