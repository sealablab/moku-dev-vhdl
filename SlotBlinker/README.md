# Enhanced SlotBlinker

A configurable, feature-rich bitstream that generates distinct wave patterns on all four outputs (OutputA, OutputB, OutputC, OutputD) with comprehensive control over timing, patterns, amplitude, and phase.

## 🚀 **New Features**

- **5 Control Registers**: Complete control over all aspects of operation
- **Sign Control**: Safe unsigned mode (default) or full signed range
- **Global Clock Divider**: Scale all outputs down simultaneously
- **Individual Output Control**: Each output independently configurable
- **Multiple Pattern Types**: Sawtooth, square wave, sine approximation, random
- **Amplitude Scaling**: 0-100% amplitude control per output
- **Phase Offsets**: Stagger outputs for complex patterns
- **Software Reset**: Reset system without reloading bitstream

## 🎯 **Purpose**

This enhanced SlotBlinker serves as a powerful payload for:
- Testing logic analyzer instruments
- Verifying oscilloscope functionality
- Debugging output connections
- Development and testing workflows
- Educational demonstrations
- Complex pattern generation

## 🎛️ **Control Register Overview**

| Register | Purpose | Control |
|----------|---------|---------|
| **CR0** | Global Control | Enable, reset, sign control, global divider |
| **CR1** | Output A | Frequency, amplitude, pattern, phase |
| **CR2** | Output B | Frequency, amplitude, pattern, phase |
| **CR3** | Output C | Frequency, amplitude, pattern, phase |
| **CR4** | Output D | Frequency, amplitude, pattern, phase |

## 🔧 **Key Control Features**

### **CR0: Global Control**
- **Enable/Disable**: Master control (active-low)
- **Software Reset**: Pulse high to reset system
- **Sign Control**: Safe unsigned (0) or full range (1)
- **Global Divider**: Scale all outputs 1x to 32x slower

### **CR1-CR4: Individual Outputs**
- **Frequency Divider**: 1x to 256x speed control per output
- **Amplitude Scale**: 0% to 100% amplitude per output
- **Pattern Type**: Sawtooth, square, sine, random, + 252 reserved
- **Phase Offset**: 0° to 360° phase shift per output

## 📊 **Default Behavior (Backward Compatible)**

When all control registers are 0, the SlotBlinker behaves like the original:
- **OutputA**: Fast sawtooth (every clock cycle)
- **OutputB**: Medium sawtooth (every 4th cycle)
- **OutputC**: Slow sawtooth (every 16th cycle)
- **OutputD**: Very slow sawtooth (every 64th cycle)
- **Safe Mode**: All outputs unsigned (0 to +32767)

## 🎨 **Pattern Types Available**

1. **Sawtooth (0)**: Linear ramp from 0 to maximum
2. **Square Wave (1)**: Toggle between high and low
3. **Sine Approximation (2)**: 8-step sine wave approximation
4. **Random (3)**: Pseudo-random pattern
5. **Reserved (4-255)**: Future pattern types

## 🛡️ **Safety Features**

- **Default Safe Mode**: All outputs unsigned by default
- **Amplitude Limits**: Prevents accidental over-voltage
- **Frequency Bounds**: Reasonable ranges prevent extreme speeds
- **Backward Compatibility**: Original behavior preserved

## 📁 **Files**

- `SlotBlinker.vhd` - Enhanced entity with comprehensive control
- `top_slot_blinker.vhd` - Top-level wrapper for CustomWrapper
- `CONTROL_REGISTERS.md` - Complete control register documentation
- `Makefile` - Build configuration
- `README.md` - This file

## 🚀 **Usage Examples**

### **Basic Operation**
```python
# Enable all outputs in safe mode
CR0 = 0x80000000  # Enable = 1, Sign Control = 0
```

### **Slow Motion Debug**
```python
# Slow everything down 16x for debugging
CR0 = 0x90000000  # Enable = 1, Global Divider = 16
```

### **Different Patterns**
```python
# Output A: Fast sawtooth, Output B: Slow square wave
CR0 = 0x80000000  # Enable = 1
CR1 = 0x00000000  # Output A: sawtooth, full speed
CR2 = 0x01010000  # Output B: square wave, 16x slower
```

### **Phase-Shifted Outputs**
```python
# All outputs same frequency but 90° apart
CR0 = 0x80000000  # Enable = 1
CR1 = 0x00000000  # Output A: 0° phase
CR2 = 0x00004000  # Output B: 90° phase
CR3 = 0x00008000  # Output C: 180° phase
CR4 = 0x0000C000  # Output D: 270° phase
```

## 🔮 **Future Enhancements**

The control register design allows for:
- Additional pattern types (4-255)
- Global pattern presets
- Advanced timing control
- Extended control registers (CR5-CR15)
- Custom waveform uploads

## 📖 **Documentation**

For complete control register details, see `CONTROL_REGISTERS.md`.

## 🎉 **Getting Started**

1. **Build the project**: `make`
2. **Load bitstream** to your Moku device
3. **Set control registers** for desired behavior
4. **Connect instruments** to outputs
5. **Enjoy configurable patterns!**

The enhanced SlotBlinker transforms a simple test pattern generator into a powerful, flexible instrument for testing, debugging, and demonstration purposes! 🚀✨
