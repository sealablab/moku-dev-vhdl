# Enhanced SlotBlinker

A **professional-grade, feature-rich signal generator** that transforms a simple test pattern generator into a powerful, configurable instrument for testing, debugging, and demonstration purposes.

## 🚀 **Key Enhancements Over Original SlotBlinker**

- **5 Control Registers**: Complete control over all aspects of operation
- **nEnable Control**: Professional active-low enable via CR0[31] for safe operation
- **Safe Defaults**: All registers = 0x0000 generates valid, visible outputs
- **Pipelined Architecture**: 3-stage pipeline ensures timing closure
- **Multiple Pattern Types**: Sawtooth, square wave, sine approximation, random
- **Individual Output Control**: Each output independently configurable
- **Amplitude & Phase Control**: Full control over signal characteristics
- **Sign Control**: Safe unsigned mode or full signed range

## 🎯 **Purpose & Use Cases**

This enhanced module serves as a **powerful payload for**:
- Testing logic analyzer instruments
- Verifying oscilloscope functionality  
- Debugging output connections
- Development and testing workflows
- Educational demonstrations
- Complex pattern generation
- **Signal source for other devices expecting inputs**

## 🎛️ **Control Register Architecture**

### **CR0: Global Control & Timing**
| Bit Range | Field | Function | Default | Notes |
|-----------|-------|----------|---------|-------|
| **31** | **nEnable** | **Module Enable** | **0 (ENABLED)** | **Active-low: 0=enabled, 1=disabled** |
| 30 | Soft Reset | Software reset | 0 (normal) | Pulse high to reset |
| 29 | Sign Control | Output sign mode | 0 (unsigned) | 0=safe, 1=full range |
| 28-24 | Global Divider | Clock scaling | 1x | 1-32x, safe default |
| 23-16 | Pattern Select | Reserved | 0 | Future use |

### **CR1-CR4: Individual Output Configuration**
| Bit Range | Field | Function | Default | Safe Default |
|-----------|-------|----------|---------|--------------|
| 31-24 | Freq Divider | Speed control | 0 | **1, 4, 16, 64** |
| 23-16 | Amplitude | Signal strength | 0 | **100%** |
| 15-8 | Pattern Type | Waveform type | 0 | **Sawtooth** |
| 7-0 | Phase Offset | Phase shift | 0 | **0°** |

## 🔒 **nEnable Safety Feature (CR0[31])**

### **Why nEnable?**
- **Safety First**: When disabled, outputs are guaranteed to be in a known state
- **Standard Practice**: Many signal generators use active-low enable signals
- **Clear Control**: Other devices can easily enable/disable the signal source
- **Fail-Safe**: If control registers are uninitialized, the module is disabled by default

### **nEnable Truth Table**
| CR0[31] | nEnable | Module State | Outputs | Safety |
|----------|---------|--------------|---------|---------|
| **0** | **1** | **ENABLED** | Generating patterns | ✅ Active |
| **1** | **0** | **DISABLED** | Safe shutdown | 🛡️ Protected |

## ✅ **Safe Defaults: All Registers = 0x0000**

### **What Happens When Everything is Zero**

| Register | Field | Value | Safe Default | Result |
|----------|-------|-------|--------------|---------|
| **CR0** | nEnable | 0 | N/A | **ENABLED** ✅ |
| **CR0** | Global Divider | 0 | 1x | ✅ Safe |
| **CR1** | Freq Divider | 0 | 1x | ✅ Fast sawtooth |
| **CR1** | Amplitude | 0 | 100% | ✅ Full amplitude |
| **CR2** | Freq Divider | 0 | 4x | ✅ Medium sawtooth |
| **CR2** | Amplitude | 0 | 100% | ✅ Full amplitude |
| **CR3** | Freq Divider | 0 | 16x | ✅ Slow sawtooth |
| **CR3** | Amplitude | 0 | 100% | ✅ Full amplitude |
| **CR4** | Freq Divider | 0 | 64x | ✅ Very slow sawtooth |
| **CR4** | Amplitude | 0 | 100% | ✅ Full amplitude |

### **Result: Working Signal Generator Out-of-the-Box**
- **No configuration required** - just load and run
- **All outputs active** with different frequencies
- **Safe voltage ranges** (unsigned mode)
- **Visible patterns** for immediate testing

## ⚡ **Pipelined Architecture**

### **3-Stage Pipeline for Timing Closure**
1. **Stage 1**: Pattern generation & frequency/phase (1 cycle latency)
2. **Stage 2**: Amplitude scaling (2 cycle latency)  
3. **Stage 3**: Sign control & output (3 cycle latency)

### **Benefits**
- ✅ **Timing Closure**: Breaks up critical path
- ✅ **High Performance**: Maintains clock frequency
- ✅ **Predictable Latency**: Fixed 3-cycle delay
- ✅ **Resource Efficient**: Better FPGA utilization

## 🎨 **Pattern Types Available**

| Type | Code | Description | Use Case |
|------|------|-------------|----------|
| **Sawtooth** | 0x00 | Linear ramp 0→max | Frequency analysis |
| **Square Wave** | 0x01 | High/low toggle | Digital testing |
| **Sine Approximation** | 0x02 | Simplified sine | Analog simulation |
| **Random** | 0x03 | Pseudo-random | Noise testing |
| **Reserved** | 0x04-FF | Future patterns | Extensibility |

## 🚀 **Quick Start Guide**

### **1. Load Bitstream**
```bash
# Load to your Moku device
# No configuration required for basic operation
```

### **2. Basic Operation (All Defaults)**
```python
# All registers = 0x0000 (safe defaults)
CR0 = 0x00000000  # nEnable = 0 (enabled), all defaults
CR1 = 0x00000000  # 1x speed, 100% amplitude, sawtooth
CR2 = 0x00000000  # 4x speed, 100% amplitude, sawtooth
CR3 = 0x00000000  # 16x speed, 100% amplitude, sawtooth
CR4 = 0x00000000  # 64x speed, 100% amplitude, sawtooth
```

### **3. Enable/Disable Control**
```python
# Enable module
CR0 = 0x00000000  # nEnable = 0 (enabled)

# Disable module (safe shutdown)
CR0 = 0x80000000  # nEnable = 1 (disabled)
```

## 🧪 **Advanced Configurations**

### **Fast Patterns (Debug Mode)**
```python
CR0 = 0x00000000  # Enable
CR1 = 0x01000000  # 1x speed
CR2 = 0x02000000  # 2x speed
CR3 = 0x04000000  # 4x speed
CR4 = 0x08000000  # 8x speed
```

### **Different Waveforms**
```python
CR0 = 0x00000000  # Enable
CR1 = 0x00010000  # Sawtooth
CR2 = 0x00020000  # Square wave
CR3 = 0x00030000  # Sine approximation
CR4 = 0x00040000  # Random
```

### **Slow Motion Analysis**
```python
CR0 = 0x10000000  # Enable + 16x global divider
# All outputs 16x slower for detailed analysis
```

### **Phase-Shifted Outputs**
```python
CR0 = 0x00000000  # Enable
CR1 = 0x00000000  # 0° phase
CR2 = 0x00004000  # 90° phase
CR3 = 0x00008000  # 180° phase
CR4 = 0x0000C000  # 270° phase
```

### **Full Range Mode (Advanced)**
```python
CR0 = 0x20000000  # Enable + signed mode
# Full -32768 to +32767 range
```

## 🛡️ **Safety Features**

- **Default Disabled**: If CR0[31] uninitialized (1), module is disabled
- **Safe Shutdown**: When disabled, no signal generation occurs
- **Amplitude Limits**: Prevents accidental over-voltage
- **Frequency Bounds**: Reasonable ranges prevent extreme speeds
- **Unsigned Default**: Safe voltage range (0 to +32767)
- **Clear Control**: Explicit enable/disable via nEnable

## 📁 **File Structure**

```
EnhancedSlotBlinker/
├── SlotBlinker.vhd          # Enhanced entity with all features
├── top_slot_blinker.vhd     # Top-level wrapper
├── Makefile                 # Build configuration
├── README.md                # This file
├── test_control_registers.py # Control register analysis tool
├── testbench/               # Comprehensive testbench
│   ├── SlotBlinker_tb.vhd  # Enhanced testbench
│   └── Makefile            # Testbench build
└── CONTROL_REGISTERS.md     # Detailed register documentation
```

## 🔧 **Build & Test**

### **Compilation**
```bash
make                    # Build main project
make syntax_check       # Check VHDL syntax
make elaborate          # Elaborate design
```

### **Testbench**
```bash
cd testbench
make                    # Build and run testbench
make view_wave          # View waveforms (GTKWave)
```

### **Control Register Analysis**
```bash
python3 test_control_registers.py  # Analyze register behavior
```

## 📊 **Performance Characteristics**

- **Clock Frequency**: Optimized for 31.25 MHz operation
- **Pipeline Latency**: 3 clock cycles from input to output
- **Resource Usage**: Efficient FPGA utilization with DSP48 blocks
- **Timing Closure**: Pipelined architecture ensures reliable timing
- **Pattern Generation**: Real-time, configurable waveform generation

## 🔮 **Future Enhancements**

The control register design allows for:
- Additional pattern types (4-255)
- Global pattern presets
- Advanced timing control
- Extended control registers (CR5-CR15)
- Custom waveform uploads
- Real-time parameter adjustment

## 🎉 **Getting Started**

1. **Load bitstream** to your Moku device
2. **Set CR0 = 0x00000000** to enable (or leave all zeros)
3. **Connect instruments** to outputs
4. **Enjoy professional-grade signal generation!**

---

## 📖 **Documentation References**

- **CONTROL_REGISTERS.md**: Complete control register details
- **test_control_registers.py**: Interactive analysis tool
- **testbench/**: Comprehensive testing and validation

The Enhanced SlotBlinker transforms a simple test pattern generator into a **powerful, flexible, and timing-optimized instrument** for professional testing, debugging, and demonstration purposes! 🚀✨

---

*This enhanced version maintains full backward compatibility while adding professional-grade features for modern signal generation applications.*
