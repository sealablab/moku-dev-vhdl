# ProbeDriver MCC Synthesis Guide

## **Overview**
This document explains how to synthesize the refactored ProbeDriver using Moku Cloud Compile (MCC). The new architecture provides a clean, modular design that's ready for synthesis.

## **New Top-Level Module**
`ProbeDriver_Top.vhd` implements the `CustomWrapper` interface required by MCC and instantiates the refactored ProbeDriver components.

## **Architecture**
```
┌─────────────────────────────────────────────────────────────────┐
│                    ProbeDriver_Top.vhd                         │
│                    (CustomWrapper Interface)                   │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐ │
│  │   Clock Divider │    │  Probe Driver   │    │   Package   │ │
│  │                 │    │     Core        │    │             │ │
│  │ • Configurable  │◄──►│ • State Machine │◄──►│ • Types    │ │
│  │ • 16 divisions │    │ • Sticky Flags  │    │ • Constants │ │
│  └─────────────────┘    │ • Timing Logic  │    └─────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## **Files Required for Synthesis**

### **Core Components**
1. **`ProbeDriver_Top.vhd`** - Top-level CustomWrapper interface
2. **`core/probe_driver_core.vhd`** - State machine implementation
3. **`common/probe_driver_pkg.vhd`** - Shared types and constants
4. **`common/intensity_lut_pkg.vhd`** - Intensity lookup table (0-100 → precise voltage)
5. **`../clk-divider/clk_divider.vhd`** - Clock divider module

### **Legacy Files (Safe to Remove)**
- ❌ `CustomWrapper.vhd` - Just interface declaration
- ❌ `ProbeDriver.vhd` - Old monolithic implementation
- ❌ `top_probe_driver.vhd` - Old top-level implementation
- ❌ `IntensityLut.vhd` - Functionality moved to package
- ❌ `ProbeConfig.vhd` - Constants moved to package

## **Synthesis Steps**

### **1. Prepare Files**
```bash
cd moku-dev-vhdl/ProbeDriver
```

### **2. Compile with GHDL (Optional)**
```bash
make -f Makefile-MCC
```

### **3. Upload to MCC**
Upload these files to MCC in this order:
1. `../clk-divider/clk_divider.vhd`
2. `common/intensity_lut_pkg.vhd`
3. `common/probe_driver_pkg.vhd`
4. `core/probe_driver_core.vhd`
5. `ProbeDriver_Top.vhd`

### **4. Set Top Module**
Set `ProbeDriver_Top` as the top-level module in MCC.

## **Control Register Interface**

### **Control0 (32 bits)**
- `[31]`: Global Enable (1 = enabled)
- `[30]`: Auto-Arm (1 = auto-arm after cooldown)
- `[27:24]`: Clock Divider Selection (0-15)
- `[23]`: Soft Trigger
- `[22:16]`: Intensity Index (7 bits, 0-100)
- `[15:0]`: Pulse Duration (16 bits)

### **Control1 (32 bits)**
- `[31:16]`: Cooldown Period (16 bits)
- `[15]`: Status Clear (clears sticky flags)
- `[14:0]`: Reserved

## **Output Ports**

| Port | Description | Content |
|------|-------------|---------|
| **OutputA** | Status Register | 16-bit state machine status |
| **OutputB** | Trigger Threshold | `0x4000` when firing, `0x0000` otherwise |
| **OutputC** | Intensity Output | Current intensity during firing (precise voltage mapping) |
| **OutputD** | Reserved | Always `0x0000` |

## **Intensity Lookup Table (Restored)**

The **IntensityLut functionality has been restored** in the refactored architecture:

### **Precise Voltage Mapping**
- **0%**: 0V (x"0000") - Safe zero intensity
- **1%**: 0.576V (x"0240") - Smallest observable output
- **50%**: 1.65V (x"0190") - Mid-range intensity
- **100%**: 3.2V (x"0320") - Maximum safe output

### **Benefits of Restored IntensityLut**
- **Precise Control**: 101 discrete voltage levels (0-100%)
- **Safety Bounds**: Built-in voltage limits for probe safety
- **Custom Curves**: Non-linear mapping for optimal probe response
- **Consistent Behavior**: Same voltage values as original implementation

## **Common MCC Settings**

### **Clock Configuration**
- **Primary Clock**: Use the `Clk` input port
- **Clock Divider**: Configurable via Control0[27:24]
- **Available Divisions**: ÷1, ÷2, ÷4, ÷8, ÷16, ÷32, ÷64, ÷128, ÷256, ÷512, ÷1024, ÷2048, ÷4096, ÷8192, ÷16384, ÷32768

### **Reset Configuration**
- **Reset Type**: Synchronous
- **Reset Port**: `Reset` input port
- **Reset Polarity**: Active high

### **Timing Constraints**
- **Clock Period**: 10ns (100MHz) default
- **Setup Time**: 2ns
- **Hold Time**: 1ns

## **Example MCC Usage**

### **Basic Probe Operation**
```vhdl
-- Enable with auto-arm, 100 clock cycle duration
Control0 <= x"80000064";  -- EN=1, AA=1, Duration=100
Control1 <= x"03E80000";  -- Cooldown=1000
```

### **Slow Clock Debug Mode**
```vhdl
-- Enable with 1/8 clock speed for debugging
Control0 <= x"83000064";  -- EN=1, AA=1, CD=3 (÷8), Duration=100
Control1 <= x"03E80000";  -- Cooldown=1000
```

### **Manual Trigger Mode**
```vhdl
-- Enable without auto-arm
Control0 <= x"40000064";  -- EN=1, AA=0, Duration=100
-- Then trigger: Control0(23) <= '1';
```

## **Troubleshooting**

### **Common Issues**
1. **Compilation Errors**: Ensure files are uploaded in dependency order
2. **Timing Violations**: Check clock divider settings
3. **Reset Issues**: Verify reset polarity and timing
4. **Control Register**: Use the register description document for correct values

### **Debug Tips**
1. **Monitor Status**: Use OutputA to track state machine progression
2. **Clock Division**: Use Control0[27:24] to slow operation for debugging
3. **Status Clear**: Use Control1(15) to reset sticky flags
4. **LED Indicators**: Status LEDs provide visual feedback

## **Performance Characteristics**

### **Resource Usage (Estimated)**
- **LUTs**: ~200-300
- **FFs**: ~50-100
- **DSP**: 0
- **BRAM**: 0

### **Timing Performance**
- **Maximum Clock**: 100MHz (10ns period)
- **Minimum Pulse**: 100 clock cycles
- **Minimum Cooldown**: 1000 clock cycles
- **Clock Division**: Up to ÷32768

## **Support**
For issues with MCC synthesis:
1. Check the register description document
2. Verify file dependencies are correct
3. Use the Makefile for local compilation testing
4. Review the architecture documentation
