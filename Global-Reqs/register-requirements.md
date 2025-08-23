# Control, Configuration, and Status Register Requirements

## Overview

This document defines the requirements for distinguishing between **Control**, **Configuration**, and **Status** registers in VHDL modules. This distinction is critical for proper module design and state management. All three register types must use VHDL records for better organization and type safety, and all three must receive equal documentation and implementation attention.

**Key Principle**: Control, Configuration, and Status registers are equally important and must be treated with equal visibility, documentation, and implementation detail.

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
- **Must be defined using VHDL records**

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
- **Must be defined using VHDL records**

### Status Registers

**Purpose**: Provide read-only information about the current state and operation of the module.

**Characteristics**:
- **Read-Only**: Cannot be written by external interfaces
- **Real-Time Updates**: Values change automatically based on module operation
- **State Indicators**: Reflect the current operational state
- **Error Reporting**: Indicate error conditions and operational status

**Examples**:
- Module operational state (IDLE, ARMED, FIRING, COOL_DOWN)
- Error flags and error codes
- Operation completion indicators
- Resource availability status

**Implementation Requirements**:
- Must be read-only (write attempts ignored)
- Must update automatically based on internal module state
- Should provide clear, meaningful status information
- Must be defined using VHDL records
- Should include error reporting capabilities

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

**Requirement**: Control, configuration, and status registers must be clearly separated in both design and documentation.

**Rationale**:
- Prevents confusion about register purpose and behavior
- Ensures proper validation timing
- Facilitates proper module integration

**Implementation**:
- Separate record definitions for control vs. configuration vs. status
- Clear naming conventions (e.g., `CTRL_*`, `CFG_*`, `STATUS_*`)
- Documentation must clearly indicate register category


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
