# Control and Configuration Register Requirements

## Overview

This document defines the requirements for distinguishing between **Control** and **Configuration** registers in the ProbeDriver module and other VHDL modules. This distinction is critical for proper module design and state management.

## Register Categories

### Control Registers

**Purpose**: Real-time manipulation of module state during operation.

**Characteristics**:
- **Synchronously Driven**: Control register fields are directly connected to the module's control logic
- **Immediate Effect**: Changes take effect on the next clock cycle after being written
- **Runtime Accessible**: Can be modified at any time during normal operation
- **State-Dependent**: Values may be overridden or ignored based on current module state

**Examples**:
- Global enable/disable flags
- Trigger signals
- Status clear commands
- Auto-arm controls

**Implementation Requirements**:
- Must be connected directly to control logic without intermediate storage
- Should include appropriate synchronization for cross-clock domain writes
- Must handle write attempts during invalid states gracefully

### Configuration Registers

**Purpose**: Define module parameters and operational characteristics that are set during initialization.

**Characteristics**:
- **Reset-Only Validation**: Values can only be validated/sanity-checked during reset
- **Module-Specific Validation**: Validation logic is entirely module-dependent
- **Persistent Values**: Once validated, values remain constant until next reset
- **No Runtime Changes**: Cannot be modified during normal operation

**Examples**:
- Clock division ratios
- Intensity levels
- Duration settings
- Cooldown periods

**Implementation Requirements**:
- Must be read-only after reset (write attempts ignored or generate errors)
- Must include module-specific validation logic in reset process
- Should provide clear error indication for invalid configuration values
- Values must be stable throughout normal operation

## Key Principles

### 1. No Assumptions About Control0

**Requirement**: Modules must not assume that a standard `Control0` register will always be exposed.

**Rationale**: 
- Top-level modules may expose control registers to external interfaces
- Sub-modules should define their own control register interfaces
- Promotes modular design and reduces coupling

**Implementation**:
- Each module defines its own control register interface
- Control register exposure is determined by the module's role in the hierarchy
- No hardcoded assumptions about register naming or availability

### 2. Validation Timing

**Requirement**: Configuration register validation can only occur during reset.

**Rationale**:
- Configuration values affect fundamental module behavior
- Runtime changes could create unstable or unsafe states
- Reset provides a clean, known state for validation

**Implementation**:
- Validation logic must be part of reset process
- Invalid configurations must prevent module from leaving reset state
- Clear error reporting for configuration validation failures

### 3. State Separation

**Requirement**: Control and configuration registers must be clearly separated in both design and documentation.

**Rationale**:
- Prevents confusion about register purpose and behavior
- Ensures proper validation timing
- Facilitates proper module integration

**Implementation**:
- Separate register definitions for control vs. configuration
- Clear naming conventions (e.g., `CTRL_*` vs. `CFG_*`)
- Documentation must clearly indicate register category

## Examples

### Control Register Definition
```vhdl
-- Control register fields (immediate actions, runtime accessible)
constant CTRL_GLOBAL_ENABLE     : natural := 31;
constant CTRL_AUTO_ARM          : natural := 30;
constant CTRL_STATUS_CLEAR      : natural := 28;
constant CTRL_SOFT_TRIGGER      : natural := 23;
```

### Configuration Register Definition
```vhdl
-- Configuration register fields (parameters, set during reset)
constant CFG_CLOCK_DIV_MSB      : natural := 27;
constant CFG_CLOCK_DIV_LSB      : natural := 24;
constant CFG_INTENSITY_MSB      : natural := 22;
constant CFG_INTENSITY_LSB      : natural := 16;
```

## Register Naming Convention Standards

### General Naming Patterns

All modules must follow these standardized naming conventions for register bit fields:

#### Control Register Fields
- **Prefix**: `CTRL_` for immediate actions, runtime accessible
- **Naming**: Descriptive action names in UPPER_CASE
- **Examples**: `CTRL_GLOBAL_ENABLE`, `CTRL_SOFT_TRIGGER`, `CTRL_STATUS_CLEAR`

#### Configuration Register Fields  
- **Prefix**: `CFG_` for parameters, set during reset
- **Naming**: Descriptive parameter names in UPPER_CASE
- **Examples**: `CFG_CLOCK_DIV_MSB`, `CFG_INTENSITY_LSB`, `CFG_DURATION_MSB`

#### Status Register Fields
- **Prefix**: `STATUS_` for read-only state indicators
- **Naming**: Descriptive state names in UPPER_CASE  
- **Examples**: `STATUS_ARMED`, `STATUS_FIRING`, `STATUS_ERROR`

### Bit Field Definition Standards

#### Constant Declarations
- **Type**: Use `natural` for bit positions
- **Naming**: Clear, descriptive names indicating bit position
- **Range**: Specify MSB/LSB for multi-bit fields

#### Example Implementation
```vhdl
-- CONTROL BIT FIELDS (immediate actions, runtime accessible)
constant CTRL_GLOBAL_ENABLE     : natural := 31;
constant CTRL_AUTO_ARM          : natural := 30;
constant CTRL_STATUS_CLEAR      : natural := 28;

-- CONFIGURATION BIT FIELDS (parameters, set during reset)
constant CFG_CLOCK_DIV_MSB      : natural := 27;
constant CFG_CLOCK_DIV_LSB      : natural := 24;
constant CFG_INTENSITY_MSB      : natural := 22;
constant CFG_INTENSITY_LSB      : natural := 16;

-- STATUS BIT FIELDS (read-only state indicators)
constant STATUS_ARMED           : natural := 0;
constant STATUS_FIRING          : natural := 1;
constant STATUS_ERROR           : natural := 4;
```

### Package Organization

Register definitions must be organized in the `common/` layer:
- **File**: `module_name_pkg.vhd` or dedicated `register_defs_pkg.vhd`
- **Location**: `module_name/common/` directory
- **Scope**: Module-specific register definitions only
- **No duplication**: Each module defines its own registers

## Standard Interface Requirements

### Core Interface Signals (Standard Order)

All VHDL modules must implement the following interface signals in the specified order:

1. **nEnable** - Global enable (active low)
2. **Clk** - Primary clock input
3. **Clk_en** - Clock enable for division control
4. **nReset** - Global reset (active low)

### Clock Domain Constraints

- **Single clock domain design** is the standard for all modules
- **No cross-clock domain synchronization** within individual modules
- **Clock domain crossing** (if needed) must be handled at the top level or in separate IP modules
- **Rationale**: Simpler design, fewer timing issues, more predictable behavior, industry standard approach

### Interface Standardization Benefits

- **Consistency** across all modules for easier integration
- **Predictability** for designers and verification engineers
- **Maintainability** through standardized interfaces
- **Future-proofing** - complexity can be added at higher levels if needed

## Compliance Requirements

1. **All modules** must clearly categorize their registers as either Control or Configuration
2. **Configuration registers** must include validation logic in reset process
3. **Control registers** must be directly connected to control logic
4. **No module** may assume the existence of a standard `Control0` register
5. **Documentation** must clearly indicate the category and behavior of each register
6. **All modules** must implement the standard interface signal order
7. **All modules** must operate on a single clock domain

## Validation Checklist

- [ ] All registers categorized as Control or Configuration
- [ ] Configuration registers include reset-time validation
- [ ] Control registers directly drive control logic
- [ ] No assumptions about standard control register names
- [ ] Clear separation in register definitions
- [ ] Documentation reflects register categories
- [ ] Error handling for invalid configurations
- [ ] Proper synchronization for control register writes
- [ ] MokuModules files properly referenced, never duplicated

## MokuModules Directory - Shared Resources

### Purpose
The `MokuModules/` directory contains **shared, platform-specific code** that must never be duplicated across modules.

### Contents
- **`CustomWrapper.vhd`** - Standard CustomWrapper entity definition
- **`MokuGo.vhd`** - MokuGo-specific hardware interface
- **`MokuModules_pkg.vhd`** - Package with standardized component declarations
- **`Makefile.template`** - Standard build system template
- **`Makefile.example`** - Example build system usage

### Critical Requirements
1. **NEVER duplicate** any files from `MokuModules/` directory
2. **ALWAYS reference** the shared files using relative paths
3. **Use the package** `MokuModules_pkg.vhd` for component declarations
4. **Follow the template** `Makefile.template` for build systems

### Proper Referencing
```vhdl
-- CORRECT: Use the shared package
use work.MokuModules_pkg.all;

-- CORRECT: Reference shared entity
entity work.CustomWrapper

-- WRONG: Never copy CustomWrapper.vhd into your module
-- WRONG: Never duplicate component declarations
```

### Build System Integration
- **Include** `../MokuModules/CustomWrapper.vhd` in your Makefile
- **Reference** the shared entity in your module
- **Use** the standardized component declarations from the package

### Benefits of Centralized MokuModules
1. **Eliminates Duplication** - No more copying 39+ lines of port definitions
2. **Centralized Updates** - Change CustomWrapper once, updates everywhere
3. **Consistency** - All modules use identical component definitions
4. **Maintainability** - Easier to keep interfaces in sync
5. **Standardization** - Common constants and types across all modules
