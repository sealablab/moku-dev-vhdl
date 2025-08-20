# Module Naming Scheme and Layer Responsibilities Requirements

## Overview

This document defines the standardized naming scheme, directory structure, and layer responsibilities for all VHDL modules in the project. This standardization ensures consistency, maintainability, and clear separation of concerns across the codebase while maintaining Verilog portability.

## Directory Structure Standard

All VHDL modules must follow this standardized directory structure:

```
module_name/
├── common/          # Shared packages, constants, types, and subtypes
├── core/           # Pure algorithmic/logic implementation
├── interface/      # External interface, register parsing, clock handling
└── top/           # Top-level integration (if applicable)
```

### Directory Naming Convention

- **`common/`** - Contains shared packages and utilities
- **`core/`** - Contains the main algorithmic/logic implementation
- **`interface/`** - Contains the external interface layer
- **`top/`** - Contains top-level integration (only for top-level modules)

## Layer Responsibilities

### 1. Common Layer (`common/`)

**Purpose**: Define shared types, constants, and utilities used across the module.

**Responsibilities**:
- Define **extensive subtypes** for all data types used in the module
- Provide package files with type definitions
- Define constants and utility functions
- Ensure type safety and range checking
- **Prefer std_logic types for better Verilog portability**
- **Define all three register types: Control, Configuration, and Status**

**Required Files**:
- `module_name_pkg.vhd` - Main package with types and constants
- Additional package files as needed for specific functionality

**Subtype Requirements**:
- **All data types** must use meaningful subtypes with appropriate ranges
- **Prefer std_logic_vector subtypes** over natural subtypes for better Verilog portability
- **Range checking** must be enforced through subtype constraints
- **Register bit fields** must use natural subtypes for bit positions
- **Multi-bit fields** must define MSB/LSB subtypes for range checking

**Register Record Requirements**:
- **Control registers** must be defined using VHDL records
- **Configuration registers** must be defined using VHDL records  
- **Status registers** must be defined using VHDL records
- **All three register types** must have equal documentation and visibility
- **All register definitions** must use records for better organization and type safety

**Example**:
```vhdl
-- In module_name_pkg.vhd
-- Prefer std_logic_vector subtypes for Verilog portability
subtype intensity_t is std_logic_vector(7 downto 0);  -- Range: 0-255
subtype clock_div_t is std_logic_vector(15 downto 0); -- Range: 1-65535
subtype duration_t is std_logic_vector(15 downto 0);  -- Range: 0-65535

-- Register bit field subtypes
subtype ctrl_global_enable_t is natural range 31 to 31;
subtype ctrl_auto_arm_t is natural range 30 to 30;
subtype cfg_clock_div_msb_t is natural range 27 to 24;
subtype cfg_intensity_t is natural range 22 to 16;
subtype status_armed_t is natural range 0 to 0;
subtype status_firing_t is natural range 1 to 1;

-- Record definitions for ALL THREE register types
type control_register_t is record
    global_enable : std_logic;
    auto_arm      : std_logic;
    soft_trigger  : std_logic;
    status_clear  : std_logic;
end record;

type configuration_register_t is record
    clock_divider : std_logic_vector(15 downto 0);
    intensity     : std_logic_vector(7 downto 0);
    duration      : std_logic_vector(15 downto 0);
    cooldown      : std_logic_vector(15 downto 0);
end record;

type status_register_t is record
    armed         : std_logic;
    firing        : std_logic;
    cooldown      : std_logic;
    error         : std_logic;
    ready         : std_logic;
end record;
```

### 2. Core Layer (`core/`)

**Purpose**: Implement the pure algorithmic/logic functionality of the module.

**Responsibilities**:
- Implement the core algorithm or logic
- **No external interface concerns** (registers, I/O, clock division)
- **No platform-specific code** (Moku-Go specific features)
- Pure, testable, reusable logic
- **Generate status information** for status registers

**Required Files**:
- `module_name_core.vhd` - Main core implementation
- Additional core files as needed for complex functionality

**Design Principles**:
- **Interface-agnostic** - Core should work with any interface
- **Testable** - Easy to create testbenches for core logic
- **Reusable** - Core can be used in different contexts
- **Clean interfaces** - Well-defined input/output types using subtypes
- **Status generation** - Core must provide status information for status registers

### 3. Interface Layer (`interface/`)

**Purpose**: Handle external interface concerns and adapt external signals to core requirements.

**Responsibilities**:
- **Control register parsing** - Convert raw register bits to structured record types
- **Configuration register parsing** - Convert raw register bits to structured record types
- **Status register generation** - Convert internal status to external status register format
- **Clock division integration** - Handle clock dividers and timing control
- **Core instantiation** - Connect external interface to core module
- **Signal synchronization** - Handle any cross-domain issues
- **Configuration validation** - Basic sanity checking of register values
- **Status mapping** - Convert internal status to external format

**Required Files**:
- `module_name_interface.vhd` - Main interface implementation

**Clock Divider Integration**:
- **All modules** must integrate with clock dividers in the interface layer
- **Standardized approach** to clock division across all modules
- **Clock enable signals** must be properly routed to core modules

**Register Handling**:
- Parse control registers into structured record types defined in common packages
- Parse configuration registers into structured record types defined in common packages
- Generate status registers from internal module state
- Validate configuration values during reset
- Route control signals to appropriate core inputs
- **Use records for all register data structures**
- **Handle all three register types equally**

### 4. Top Layer (`top/`)

**Purpose**: Integrate multiple modules and handle system-level concerns.

**Responsibilities**:
- **Module integration** - Connect multiple interface modules
- **System-level routing** - Handle inter-module communication
- **Platform-specific features** - Moku-Go specific integration
- **External interface** - Connect to platform control system
- **Register exposure** - Expose appropriate control, configuration, and status registers

**Required Files**:
- `module_name_top.vhd` - Top-level integration (only for top-level modules)

**Usage**:
- **Not required** for all modules
- **Only used** when multiple modules need integration
- **Handles** system-level concerns, not individual module logic
- **Must expose** all three register types as appropriate for the module's role

## File Naming Convention

### Entity Names
- **Core**: `module_name_core`
- **Interface**: `module_name_interface`
- **Top**: `module_name_top`

### File Names
- **Core**: `module_name_core.vhd`
- **Interface**: `module_name_interface.vhd`
- **Top**: `module_name_top.vhd`

### Package Names
- **Main Package**: `module_name_pkg.vhd`
- **Additional Packages**: `module_name_specific_pkg.vhd`

## Implementation Requirements

### 1. Subtype Usage
- **Extensive use** of subtypes for all data types
- **Prefer std_logic_vector subtypes** for better Verilog portability
- **Range checking** through subtype constraints
- **Meaningful names** that describe the data purpose

### 2. Register Record Usage
- **All register definitions** must use VHDL records
- **Control registers** must be defined as records for runtime actions
- **Configuration registers** must be defined as records for initialization parameters
- **Status registers** must be defined as records for operational state information
- **All three register types** must have equal documentation and implementation detail
- **Records provide type safety** and better organization

### 3. Clock Divider Integration
- **All modules** must integrate clock dividers in interface layer
- **Standardized approach** to clock division
- **Clock enable signals** properly routed to core modules

### 4. Register Handling
- **Control registers** parsed in interface layer for immediate actions
- **Configuration registers** parsed in interface layer for initialization parameters
- **Status registers** generated in interface layer from internal module state
- **Configuration validation** during reset only
- **Structured record types** used for all register data
- **Equal treatment** of all three register types

### 5. Layer Separation
- **Clear boundaries** between layers
- **No cross-layer dependencies** (common → core → interface → top)
- **Interface layer** handles all external concerns
- **Core layer** contains only pure logic
- **Status information** flows from core through interface to external status registers

## Compliance Checklist

- [ ] Directory structure follows standard naming convention
- [ ] Common layer contains extensive subtypes for all data types
- [ ] **Prefer std_logic_vector subtypes** for Verilog portability
- [ ] **All register definitions use VHDL records**
- [ ] **Control registers properly defined and documented**
- [ ] **Configuration registers properly defined and documented**
- [ ] **Status registers properly defined and documented**
- [ ] **All three register types have equal implementation detail**
- [ ] Core layer contains only pure algorithmic/logic code
- [ ] Core layer generates status information for status registers
- [ ] Interface layer handles all external interface concerns
- [ ] Interface layer parses control and configuration registers
- [ ] Interface layer generates status registers from internal state
- [ ] Clock dividers integrated in interface layer
- [ ] No raw std_logic_vector without subtypes
- [ ] Clear separation between layers
- [ ] File naming follows convention
- [ ] Entity naming follows convention
- [ ] Package files properly organized in common layer
- [ ] Register naming follows CTRL_/CFG_/STATUS_ conventions
- [ ] Register bit fields use natural subtypes for bit positions
- [ ] Status information flows properly from core through interface

## Benefits of This Structure

1. **Consistency** - All modules follow the same pattern
2. **Maintainability** - Clear separation of concerns
3. **Testability** - Core logic can be tested independently
4. **Reusability** - Core logic can be used in different contexts
5. **Readability** - Clear structure makes code easier to understand
6. **Type Safety** - Extensive use of subtypes and records prevents errors
7. **Clock Management** - Standardized approach to timing control
8. **Verilog Portability** - std_logic types are easier to convert
9. **Record Benefits** - Better organization and type safety for registers
10. **Equal Register Treatment** - Control, Configuration, and Status registers all receive equal attention
11. **Status Visibility** - Operational state is clearly visible and accessible
12. **Complete State Management** - All aspects of module operation are properly tracked and reported
