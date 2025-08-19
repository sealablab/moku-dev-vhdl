# Enhanced SlotBlinker

A configurable, feature-rich bitstream that generates distinct wave patterns on all four outputs (OutputA, OutputB, OutputC, OutputD) with comprehensive control over timing, patterns, amplitude, and phase. **Pipelined architecture ensures timing closure.**

## 🚀 **New Features**

- **5 Control Registers**: Complete control over all aspects of operation
- **Sign Control**: Safe unsigned mode (default) or full signed range
- **Global Clock Divider**: Scale all outputs down simultaneously
- **Individual Output Control**: Each output independently configurable
- **Multiple Pattern Types**: Sawtooth, square wave, sine approximation, random
- **Amplitude Scaling**: 0-100% amplitude control per output
- **Phase Offsets**: Stagger outputs for complex patterns
- **Software Reset**: Reset system without reloading bitstream
- **Pipelined Architecture**: **3-stage pipeline for timing closure**

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
- **nEnable**: Master control (active-low: 0=enabled, 1=disabled)
- **Software Reset**: Pulse high to reset system
- **Sign Control**: Safe unsigned (0) or full range (1)
- **Global Divider**: Scale all outputs 1x to 32x slower

### **CR1-CR4: Individual Outputs**
- **Frequency Divider**: 1x to 256x speed control per output
- **Amplitude Scale**: 0% to 100% amplitude per output
- **Pattern Type**: Sawtooth, square, sine, random, + 252 reserved
- **Phase Offset**: 0° to 360° phase shift per output

## ⚡ **Pipelined Architecture**

The SlotBlinker uses a **3-stage pipeline** to ensure timing closure:

### **Pipeline Stage 1: Pattern Generation & Frequency/Phase**
- Generate raw patterns based on pattern type
- Apply frequency dividers and phase offsets
- **Latency**: 1 clock cycle

### **Pipeline Stage 2: Amplitude Scaling**
- Apply amplitude scaling with proper bit width handling
- **Latency**: 2 clock cycles

### **Pipeline Stage 3: Sign Control & Output**
- Apply sign control (unsigned vs signed)
- Generate final outputs
- **Latency**: 3 clock cycles

### **Benefits of Pipelining**
- ✅ **Timing Closure**: Breaks up critical path
- ✅ **High Performance**: Maintains clock frequency
- ✅ **Predictable Latency**: Fixed 3-cycle delay
- ✅ **Resource Efficient**: Better FPGA utilization

## 📊 **Default Behavior (Backward Compatible)**

When all control registers are 0, the SlotBlinker behaves like the original:
- **OutputA**: Fast sawtooth (every clock cycle)
- **OutputB**: Medium sawtooth (every 4th cycle)
- **OutputC**: Slow sawtooth (every 16th cycle)
- **OutputD**: Very slow sawtooth (every 64th cycle)
- **Safe Mode**: All outputs unsigned (0 to +32767)

## 🎨 **Pattern Types Available**

1. **Sawtooth (0)**: Linear ramp from 0 to maximum
2. **Square Wave (1)**: Toggle between high and low (simplified for timing)
3. **Sine Approximation (2)**: Simplified sine wave approximation
4. **Random (3)**: Simplified pseudo-random pattern
5. **Reserved (4-255)**: Future pattern types

## 🛡️ **Safety Features**

- **Default Safe Mode**: All outputs unsigned by default
- **Amplitude Limits**: Prevents accidental over-voltage
- **Frequency Bounds**: Reasonable ranges prevent extreme speeds
- **Backward Compatibility**: Original behavior preserved
- **Timing Closure**: Pipelined architecture ensures reliable operation

## 📁 **Files**

- `SlotBlinker.vhd` - Enhanced entity with comprehensive control and pipelining
- `top_slot_blinker.vhd` - Top-level wrapper for CustomWrapper
- `CONTROL_REGISTERS.md` - Complete control register documentation
- `Makefile` - Build configuration
- `README.md` - This file

## 🚀 **Usage Examples**

### **Basic Operation**
```python
# Enable all outputs in safe mode
CR0 = 0x00000000  # nEnable = 0 (enabled), Sign Control = 0
```

### **Slow Motion Debug**
```python
# Slow everything down 16x for debugging
CR0 = 0x10000000  # nEnable = 0 (enabled), Global Divider = 16
```

### **Different Patterns**
```python
# Output A: Fast sawtooth, Output B: Slow square wave
CR0 = 0x00000000  # nEnable = 0 (enabled)
CR1 = 0x00000000  # Output A: sawtooth, full speed
CR2 = 0x01010000  # Output B: square wave, 16x slower
```

### **Phase-Shifted Outputs**
```python
# All outputs same frequency but 90° apart
CR0 = 0x00000000  # nEnable = 0 (enabled)
CR1 = 0x00000000  # Output A: 0° phase
CR2 = 0x00004000  # Output B: 90° phase
CR3 = 0x00008000  # Output C: 180° phase
CR4 = 0x0000C000  # Output D: 270° phase
```

### **Full Range Mode**
```python
# Enable full signed range for advanced users
CR0 = 0x20000000  # nEnable = 0 (enabled), Sign Control = 1
```

### **Disable Module**
```python
# Disable all outputs (safe shutdown)
CR0 = 0x80000000  # nEnable = 1 (disabled)
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

## ⏱️ **Timing Considerations**

- **Pipeline Latency**: 3 clock cycles from input to output
- **Clock Frequency**: Optimized for 31.25 MHz operation
- **Timing Closure**: Pipelined architecture ensures reliable timing
- **Resource Usage**: Efficient FPGA utilization with DSP48 blocks

The enhanced SlotBlinker transforms a simple test pattern generator into a **powerful, flexible, and timing-optimized instrument** for testing, debugging, and demonstration purposes! 🚀✨
