# ProbeDriver Testbench Template System

## Overview

This document describes the new reusable testbench template system for ProbeDriver components. The system eliminates the duplication of CustomWrapper definitions and provides a consistent, scalable approach to testing at different layers.

## 🎯 **Goals**

1. **Eliminate CustomWrapper Duplication** - Use centralized `MokuModules_pkg.vhd`
2. **Provide Consistent Testing** - Standardized approach across all layers
3. **Enable Scalability** - Easy to add new testbenches following the pattern
4. **Maintain Flexibility** - Configurable for different testing needs

## 🏗️ **Architecture**

### **Core Components**

1. **`ProbeDriver_Testbench_Config_pkg.vhd`** - Configuration package with test parameters
2. **`ProbeDriver_Testbench_Template.vhd`** - Reusable template for all testbench layers
3. **Layer-Specific Testbenches** - Specialized testbenches using the template

### **Testing Layers**

```
CORE → WRAPPER → TOP_LEVEL
  ↓       ↓         ↓
Basic  Integration  Complete
Logic   Testing     System
```

## 📁 **File Structure**

```
testbench/
├── ProbeDriver_Testbench_Config_pkg.vhd      # Configuration package
├── ProbeDriver_Testbench_Template.vhd         # Reusable template
├── probe_driver_core_basic_tb.vhd            # Core layer tests
├── probe_driver_wrapper_integration_tb.vhd   # Wrapper layer tests
├── probe_driver_top_level_comprehensive_tb.vhd # Top-level tests
└── README-Testbench-Template-System.md      # This file
```

## 🔧 **Naming Convention**

### **Pattern: `{module}_{layer}_{purpose}_tb.vhd`**

- **`{module}`**: Module name (e.g., `probe_driver`, `clock_divider`)
- **`{layer}`**: Testing layer (`core`, `wrapper`, `top_level`)
- **`{purpose}`**: Test purpose (`basic`, `comprehensive`, `stress`, `demo`, `integration`)

### **Examples**

```
probe_driver_core_basic_tb.vhd              # Core basic functionality
probe_driver_wrapper_integration_tb.vhd      # Wrapper integration testing
probe_driver_top_level_comprehensive_tb.vhd  # Complete system testing
```

## 🚀 **Usage**

### **1. Using the Template**

The template can be configured using generics:

```vhdl
entity my_testbench is
end entity my_testbench;

architecture test of my_testbench is
    component ProbeDriver_Testbench_Template is
        generic (
            TEST_LAYER : test_layer_type := CORE;
            TEST_PURPOSE : test_purpose_type := BASIC;
            CLOCK_PERIOD_OVERRIDE : time := 0 ns;
            SIMULATION_TIME_OVERRIDE : time := 0 us;
            ENABLE_WAVEFORMS_OVERRIDE : boolean := true
        );
    end component;
begin
    uut: ProbeDriver_Testbench_Template
        generic map (
            TEST_LAYER => CORE,
            TEST_PURPOSE => BASIC
        );
end architecture;
```

### **2. Configuration Options**

#### **Test Layers**
- **`CORE`**: Test individual component logic
- **`WRAPPER`**: Test interface and integration
- **`TOP_LEVEL`**: Test complete system

#### **Test Purposes**
- **`BASIC`**: Fundamental functionality
- **`COMPREHENSIVE`**: Complete feature coverage
- **`STRESS`**: Edge cases and stress testing
- **`DEMO`**: Demonstration and examples
- **`INTEGRATION`**: Component integration testing

### **3. Override Options**

```vhdl
generic map (
    TEST_LAYER => CORE,
    TEST_PURPOSE => BASIC,
    CLOCK_PERIOD_OVERRIDE => 5 ns,        # Override default 10ns
    SIMULATION_TIME_OVERRIDE => 5 us,     # Override default 10us
    ENABLE_WAVEFORMS_OVERRIDE => false    # Disable waveforms
)
```

## 📋 **Template Features**

### **Automatic Configuration**
- Clock periods optimized for each layer
- Test parameters scaled appropriately
- Waveform filenames generated automatically

### **Layer-Specific Instantiation**
- Only relevant components are instantiated
- Signals are automatically configured
- Test parameters are layer-appropriate

### **Built-in Monitoring**
- Cycle counting
- Test phase tracking
- Basic assertion framework

### **Flexible Test Sequence**
- Standardized test phases
- Configurable timing
- Extensible for specific needs

## 🔍 **Test Phases**

All testbenches follow a consistent phase structure:

1. **`INIT`**: Initial setup and configuration
2. **`RESET_PHASE`**: Reset behavior testing
3. **`CONFIGURE_PHASE`**: Configuration and parameter setup
4. **`FUNCTIONALITY_PHASE`**: Core functionality testing
5. **`STRESS_PHASE`**: Edge case and stress testing
6. **`VERIFICATION_PHASE`**: Results verification
7. **`COMPLETE`**: Test completion

## 📊 **Configuration Parameters**

### **Core Layer (Fast Simulation)**
- Clock Period: 10ns
- Simulation Time: 10us
- Pulse Duration: 10 cycles
- Cooldown: 5 cycles
- Intensity: 1%

### **Wrapper Layer (Medium Simulation)**
- Clock Period: 10ns
- Simulation Time: 20us
- Pulse Duration: 20 cycles
- Cooldown: 10 cycles
- Intensity: 10%

### **Top-Level (Real Hardware Timing)**
- Clock Period: 32ns
- Simulation Time: 100us
- Pulse Duration: Min duration (100 cycles)
- Cooldown: Min cooldown (1000 cycles)
- Intensity: 1%

## 🛠️ **Creating New Testbenches**

### **Step 1: Choose Layer and Purpose**
```vhdl
-- For a new stress test at the wrapper level
entity probe_driver_wrapper_stress_tb is
end entity probe_driver_wrapper_stress_tb;
```

### **Step 2: Use Template**
```vhdl
architecture stress_test of probe_driver_wrapper_stress_tb is
    component ProbeDriver_Testbench_Template is
        generic (
            TEST_LAYER => WRAPPER,
            TEST_PURPOSE => STRESS
        );
    end component;
begin
    uut: ProbeDriver_Testbench_Template
        generic map (
            TEST_LAYER => WRAPPER,
            TEST_PURPOSE => STRESS
        );
end architecture;
```

### **Step 3: Add Custom Logic**
```vhdl
-- Override template processes or add new ones
custom_test_sequence: process
begin
    -- Wait for template initialization
    wait for 100 ns;
    
    -- Add custom test logic here
    report "Custom stress test started";
    
    -- Custom test steps...
    
    wait;
end process;
```

## 🔄 **Migration from Old Testbenches**

### **What to Keep**
- Custom test logic specific to your needs
- Specialized monitoring and assertions
- Unique test scenarios

### **What to Replace**
- CustomWrapper component definitions
- Duplicated signal declarations
- Repeated configuration code

### **Migration Steps**
1. Replace CustomWrapper component with template
2. Remove duplicated signal declarations
3. Use template's built-in monitoring
4. Add custom logic as needed

## 📈 **Scaling to Other Modules**

The template system can be extended to other modules:

### **Clock Divider Module**
```
clock_divider_core_basic_tb.vhd
clock_divider_integration_tb.vhd
```

### **Signal Generator Module**
```
siggen_core_basic_tb.vhd
siggen_wrapper_control_tb.vhd
siggen_top_level_comprehensive_tb.vhd
```

### **Basic Block Module**
```
basic_block_core_basic_tb.vhd
basic_block_wrapper_tb.vhd
```

## 🚨 **Troubleshooting**

### **Common Issues**

1. **Template Not Found**
   - Ensure `ProbeDriver_Testbench_Config_pkg.vhd` is compiled first
   - Check library dependencies

2. **Generic Type Mismatch**
   - Use correct enum types from config package
   - Check generic parameter names

3. **Signal Not Connected**
   - Template only instantiates relevant components
   - Check which layer you're testing

### **Debug Tips**

- Use template's built-in reporting
- Check test phase progression
- Verify layer-specific configuration
- Monitor cycle counter for timing issues

## 🔮 **Future Enhancements**

### **Planned Features**
- Automated test result analysis
- Performance benchmarking
- Coverage analysis integration
- Multi-module testing support

### **Extension Points**
- Custom test phase definitions
- Advanced assertion frameworks
- Integration with CI/CD systems
- Automated test generation

## 📚 **Related Documentation**

- [ProbeDriver Package](../common/probe_driver_pkg.vhd)
- [MokuModules Package](../../MokuModules/MokuModules_pkg.vhd)
- [ProbeDriver Core](../core/probe_driver_core.vhd)
- [ProbeDriver Wrapper](../wrapper/probe_driver_wrapper.vhd)
- [Main ProbeDriver Module](../ProbeDriver.vhd)

## 🤝 **Contributing**

When adding new testbenches:

1. Follow the naming convention
2. Use the template system
3. Add appropriate documentation
4. Update this README if needed
5. Test with multiple configurations

---

**This template system eliminates the CustomWrapper duplication problem and provides a scalable foundation for all future ProbeDriver testing needs.**
