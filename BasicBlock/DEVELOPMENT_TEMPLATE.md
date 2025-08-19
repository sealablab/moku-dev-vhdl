# BasicBlock Development Template

## 🎯 Purpose

This document explains how to use **BasicBlock** as a **template and starting point** for developing new VHDL modules. BasicBlock demonstrates a complete, working implementation of the 3-tier modular architecture that can be easily adapted for other projects.

## 🏗️ Template Structure

### Directory Organization
```
YourNewModule/
├── common/                    # Shared packages and utilities
│   ├── your_pattern_pkg.vhd  # Pattern/function generation
│   └── yourmodule_pkg.vhd    # Main types and utilities
├── core/                     # Core business logic
│   └── yourmodule_core.vhd   # Main processing logic
├── wrapper/                  # Interface layer
│   └── yourmodule_wrapper.vhd # Control register parsing
├── YourModule_Top.vhd        # Platform interface (CustomWrapper)
├── Makefile                  # Build automation
├── README.md                 # Module documentation
└── DEVELOPMENT_TEMPLATE.md   # This template guide
```

### File Naming Convention
- **Packages**: `yourmodule_pkg.vhd` (lowercase with underscores)
- **Core**: `yourmodule_core.vhd` (lowercase with underscores)
- **Wrapper**: `yourmodule_wrapper.vhd` (lowercase with underscores)
- **Top**: `YourModule_Top.vhd` (PascalCase)
- **Directory**: `YourModule/` (PascalCase)

## 📋 Step-by-Step Development Process

### Step 1: Copy BasicBlock Structure
```bash
# Copy the entire BasicBlock directory
cp -r BasicBlock YourNewModule

# Navigate to your new module
cd YourNewModule

# Clean up BasicBlock-specific files
rm -rf common/* core/* wrapper/* BasicBlock_Top.vhd
```

### Step 2: Create Your Module Files

#### 2.1 Common Layer (`common/`)
Create packages that define:
- **Types**: Data structures for your module
- **Constants**: Configuration limits and defaults
- **Functions**: Utility functions and validation
- **Patterns**: If applicable to your application

**Template for `yourmodule_pkg.vhd`**:
```vhdl
-- =============================================================================
-- yourmodule_pkg.vhd
-- =============================================================================
-- 
-- Main Package for YourNewModule
-- 
-- PURPOSE: [Describe what your module does]
-- 
-- TARGET PLATFORM: Moku-Go (Liquid Instruments)
--                  - [List platform-specific details]
-- 
-- LEARNING OBJECTIVES:
--   [List what students will learn from this module]
-- 
-- =============================================================================

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

package yourmodule_pkg is
    -- Constants
    -- [Define your constants]
    
    -- Types
    -- [Define your record types]
    
    -- Functions
    -- [Declare your functions]
    
end package yourmodule_pkg;

package body yourmodule_pkg is
    -- [Implement your functions]
end package body yourmodule_pkg;
```

#### 2.2 Core Layer (`core/`)
Create the main processing logic:
- **Entity**: Define inputs/outputs
- **Architecture**: Implement your core algorithm
- **Processes**: Handle timing and state changes
- **Component Integration**: Use existing modules if needed

**Template for `yourmodule_core.vhd`**:
```vhdl
-- =============================================================================
-- yourmodule_core.vhd
-- =============================================================================
-- 
-- Core Processing Logic for YourNewModule
-- 
-- PURPOSE: [Describe the core functionality]
-- 
-- =============================================================================

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.yourmodule_pkg.all;

entity yourmodule_core is
    port (
        -- Clock and Control
        clk        : in  std_logic;
        reset      : in  std_logic;
        enable     : in  std_logic;
        
        -- Configuration Inputs
        config     : in  your_config_type;
        
        -- Output Signals
        output_a   : out signed(15 downto 0);
        output_b   : out signed(15 downto 0);
        output_c   : out signed(15 downto 0);
        output_d   : out signed(15 downto 0)
    );
end entity yourmodule_core;

architecture rtl of yourmodule_core is
    -- [Define your internal signals]
begin
    -- [Implement your core logic]
end architecture rtl;
```

#### 2.3 Wrapper Layer (`wrapper/`)
Create the interface layer:
- **Control Register Parsing**: Convert raw registers to structured data
- **Component Instantiation**: Connect to your core module
- **Signal Routing**: Manage data flow between layers

**Template for `yourmodule_wrapper.vhd`**:
```vhdl
-- =============================================================================
-- yourmodule_wrapper.vhd
-- =============================================================================
-- 
-- Interface Wrapper for YourNewModule
-- 
-- PURPOSE: [Describe the interface functionality]
-- 
-- =============================================================================

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.yourmodule_pkg.all;

entity yourmodule_wrapper is
    port (
        -- Clock and Control
        clk        : in  std_logic;
        reset      : in  std_logic;
        
        -- Control Registers
        control0   : in  std_logic_vector(31 downto 0);
        control1   : in  std_logic_vector(31 downto 0);
        control2   : in  std_logic_vector(31 downto 0);
        control3   : in  std_logic_vector(31 downto 0);
        control4   : in  std_logic_vector(31 downto 0);
        
        -- Output Signals
        output_a   : out signed(15 downto 0);
        output_b   : out signed(15 downto 0);
        output_c   : out signed(15 downto 0);
        output_d   : out signed(15 downto 0)
    );
end entity yourmodule_wrapper;

architecture rtl of yourmodule_wrapper is
    -- [Define your internal signals and components]
begin
    -- [Implement your wrapper logic]
end architecture rtl;
```

#### 2.4 Top Layer (`YourModule_Top.vhd`)
Create the platform interface:
- **CustomWrapper Implementation**: Moku-Go platform compatibility
- **Signal Routing**: Connect wrapper to platform outputs
- **Future Expansion**: Reserve unused control registers

**Template for `YourModule_Top.vhd`**:
```vhdl
-- =============================================================================
-- YourModule_Top.vhd
-- =============================================================================
-- 
-- Top-Level Module for YourNewModule
-- 
-- PURPOSE: [Describe the top-level functionality]
-- 
-- =============================================================================

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity CustomWrapper is
    port (
        -- [Copy the exact port declaration from BasicBlock_Top.vhd]
        -- [Modify only the comments to reflect your module]
    );
end entity CustomWrapper;

architecture Behavioural of CustomWrapper is
    -- [Define your component and signals]
begin
    -- [Instantiate your wrapper module]
    -- [Connect to platform outputs]
end architecture Behavioural;
```

### Step 3: Update Configuration Files

#### 3.1 Update Makefile
```makefile
# Update VHDL_FILES list
VHDL_FILES = \
	common/your_pattern_pkg.vhd \
	common/yourmodule_pkg.vhd \
	core/yourmodule_core.vhd \
	wrapper/yourmodule_wrapper.vhd \
	YourModule_Top.vhd

# Update TOP_LEVEL if needed
TOP_LEVEL = CustomWrapper

# Update dependency rules
common/yourmodule_pkg.vhd: common/your_pattern_pkg.vhd
core/yourmodule_core.vhd: common/your_pattern_pkg.vhd common/yourmodule_pkg.vhd
wrapper/yourmodule_wrapper.vhd: common/yourmodule_pkg.vhd core/yourmodule_core.vhd
YourModule_Top.vhd: wrapper/yourmodule_wrapper.vhd
```

#### 3.2 Update README.md
- **Module Name**: Change from BasicBlock to YourNewModule
- **Purpose**: Describe what your module does
- **Features**: List your module's capabilities
- **Patterns**: If applicable, describe your patterns
- **Examples**: Provide usage examples for your module

### Step 4: Test Your Module

#### 4.1 Syntax Check
```bash
make syntax
```

#### 4.2 Compilation
```bash
make analyze
```

#### 4.3 Elaboration
```bash
make elaborate
```

#### 4.4 Clean Build
```bash
make clean
make analyze
make elaborate
```

## 🔧 Common Modifications

### Adding New Patterns
If your module generates patterns:

1. **Add constants** in your pattern package:
```vhdl
constant PATTERN_NEW : std_logic_vector(3 downto 0) := "1000";
```

2. **Add function declaration**:
```vhdl
function generate_new_pattern(counter_val : unsigned(15 downto 0); output_select : unsigned(1 downto 0)) return unsigned;
```

3. **Implement function** in package body:
```vhdl
function generate_new_pattern(counter_val : unsigned(15 downto 0); output_select : unsigned(1 downto 0)) return unsigned is
begin
    -- [Your pattern logic here]
    return pattern_value;
end function;
```

4. **Add to main pattern function**:
```vhdl
case pattern_type is
    when PATTERN_OFF       => return generate_off(counter_val);
    when PATTERN_NEW       => return generate_new_pattern(counter_val, output_select);
    -- [Other patterns]
    when others            => return generate_off(counter_val);
end case;
```

### Adding New Control Registers
If you need more configuration:

1. **Extend your configuration types**:
```vhdl
type extended_config_type is record
    -- [Existing fields]
    new_feature : std_logic_vector(7 downto 0);
    -- [More fields]
end record;
```

2. **Update parsing functions**:
```vhdl
function parse_extended_config(control_reg : std_logic_vector(31 downto 0)) return extended_config_type is
    variable config : extended_config_type;
begin
    -- [Existing parsing]
    config.new_feature := control_reg(23 downto 16);
    -- [More parsing]
    return config;
end function;
```

3. **Use Control5-15** for additional registers:
```vhdl
Control5 : in std_logic_vector(31 downto 0);   -- Extended configuration
Control6 : in std_logic_vector(31 downto 0);   -- More features
```

### Integrating External Modules
If you need to use existing modules:

1. **Add component declaration**:
```vhdl
component external_module is
    port (
        -- [Port declaration]
    );
end component;
```

2. **Instantiate the module**:
```vhdl
external_module_inst : external_module
    port map (
        -- [Port mapping]
    );
```

3. **Update Makefile dependencies**:
```makefile
# Ensure external module is compiled first
yourmodule_core.vhd: ../ExternalModule/external_module.vhd
```

## 📚 Best Practices

### 1. Documentation
- **Extensive commenting** for student understanding
- **Clear purpose statements** in each file
- **Learning objectives** for educational value
- **Usage examples** for practical application

### 2. Code Organization
- **Consistent naming** conventions
- **Logical grouping** of related functionality
- **Clear separation** between layers
- **Future expansion** planning

### 3. Error Handling
- **Input validation** functions
- **Safe default values** for invalid inputs
- **Boundary checking** for configuration values
- **Graceful degradation** when possible

### 4. Testing
- **Syntax validation** before full compilation
- **Dependency checking** for correct build order
- **Clean builds** to verify dependencies
- **Future testbench** planning

## 🚀 Quick Start Checklist

- [ ] Copy BasicBlock directory structure
- [ ] Rename files and directories
- [ ] Update package names and entity names
- [ ] Implement your core logic
- [ ] Update control register parsing
- [ ] Modify Makefile for your files
- [ ] Update README.md with your module details
- [ ] Test syntax and compilation
- [ ] Verify elaboration works
- [ ] Document your module thoroughly

## 🔮 Future Enhancements

### For Your Module
- **Testbench creation** for simulation
- **Synthesis constraints** for FPGA implementation
- **Automated testing** scripts
- **Performance optimization** techniques

### For the Template
- **Additional pattern types** for common applications
- **Advanced timing controls** for complex sequences
- **External interface** examples (UART, SPI, etc.)
- **Platform-specific** optimizations

## 📖 Example: Creating a "WaveGen" Module

Here's how you might create a waveform generator module:

1. **Copy BasicBlock**: `cp -r BasicBlock WaveGen`
2. **Rename files**: `wavegen_pkg.vhd`, `wavegen_core.vhd`, etc.
3. **Add waveform types**: SINE, SQUARE, TRIANGLE, SAW
4. **Implement waveform generation** functions
5. **Add frequency and amplitude controls**
6. **Update control register parsing**
7. **Test and document**

## 🤝 Contributing Back

When you create a new module using this template:

1. **Share your module** with the community
2. **Document any improvements** to the template
3. **Suggest new pattern types** for common applications
4. **Provide feedback** on the development process

---

**BasicBlock Template** - Your foundation for modular VHDL development! 🚀✨

Use this template to create your own modules and contribute to the growing ecosystem of Moku-Go VHDL modules.
