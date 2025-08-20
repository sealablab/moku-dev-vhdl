# State Machine Implementation Requirements

## Overview

This document defines the standardized approach for implementing state machines in VHDL modules. The **hybrid approach** combines the benefits of VHDL enumerated types for internal logic with **Status Register records** for external visibility, following the established architecture defined in `register-requirements.md`.

**Key Principle**: All state machines must use VHDL enumerated types internally while providing external visibility through **Status Register records** that follow the established register architecture standards.

**Architecture Integration**: This document extends the three-register architecture (Control, Configuration, Status) by defining how state machines integrate with Status Register records for complete external visibility.

## Integration with Three-Register Architecture

### **Architecture Compliance Requirements**

**All state machine implementations must integrate with the established three-register architecture defined in `register-requirements.md`:**

1. **Control Registers**: Handle state machine control inputs (enable, trigger, reset, etc.)
2. **Configuration Registers**: Define state machine parameters (timing, thresholds, etc.)
3. **Status Registers**: Provide state machine visibility and monitoring

**Equal Treatment Mandate**: Status Registers for state machines must receive the same level of documentation, implementation effort, and testing coverage as Control and Configuration registers.

### **Complete Register Integration Example**

```vhdl
-- In common/module_name_pkg.vhd
-- All three register types following established architecture

-- Control Register: State machine control inputs
type control_register_t is record
    global_enable : std_logic;     -- Enable/disable state machine
    soft_trigger  : std_logic;     -- Software trigger for state transitions
    status_clear  : std_logic;     -- Clear status flags
    auto_arm      : std_logic;     -- Auto-rearm after completion
end record;

-- Configuration Register: State machine parameters
type configuration_register_t is record
    delay_value   : std_logic_vector(15 downto 0);  -- Delay before state transition
    timeout_value : std_logic_vector(15 downto 0);  -- Timeout for state operations
    retry_count   : std_logic_vector(7 downto 0);   -- Retry attempts on failure
end record;

-- Status Register: State machine visibility
type status_register_t is record
    armed         : std_logic;     -- State machine is armed
    firing        : std_logic;     -- State machine is actively firing
    cooldown      : std_logic;     -- State machine is in cooldown
    error         : std_logic;     -- Error condition detected
    ready         : std_logic;     -- State machine is ready
    timeout       : std_logic;     -- Timeout condition occurred
    retry_active  : std_logic;     -- Retry operation in progress
    reserved_7    : std_logic;     -- Reserved for future expansion
end record;

-- Required functions for all three register types
function get_default_control_register return control_register_t;
function get_default_configuration_register return configuration_register_t;
function get_default_status_register return status_register_t;

function is_valid_control_register(ctrl : control_register_t) return boolean;
function is_valid_configuration_register(cfg : configuration_register_t) return boolean;
function is_valid_status_register(status : status_register_t) return boolean;
```

## Hybrid State Machine Architecture

### **Internal State Management (VHDL Enumerated Types)**

**Purpose**: Provide type-safe, maintainable state machine logic within the module core.

**Requirements**:
- **Must use VHDL enumerated types** for all internal state machines
- **Must define state types in common packages** for consistency across modules
- **Must use descriptive state names** that clearly indicate the module's purpose
- **Must include state-to-string functions** for debugging and simulation
- **Must follow consistent naming conventions** across all modules

**Implementation Pattern**:
```vhdl
-- In common/module_name_pkg.vhd
type module_state_type is (IDLE, ARMED, FIRING, COOL_DOWN);

-- State-to-string function for debugging
function module_state_to_string(state : module_state_type) return string;

-- In core/module_name_core.vhd
signal current_state : module_state_type := IDLE;

-- Clean, readable state machine
case current_state is
    when IDLE => 
        if enable = '1' then
            current_state <= ARMED;
        end if;
    when ARMED =>
        if trigger = '1' then
            current_state <= FIRING;
        end if;
    when FIRING =>
        if pulse_complete = '1' then
            current_state <= COOL_DOWN;
        end if;
    when COOL_DOWN =>
        if cooldown_complete = '1' then
            current_state <= ARMED;
        end if;
    when others =>
        current_state <= IDLE;  -- Safety default
end case;
```

### **External State Visibility (Status Register Records)**

**Purpose**: Provide external monitoring and debugging capabilities for module state using the established Status Register record architecture.

**Requirements**:
- **Must implement Status Register records** as defined in `register-requirements.md`
- **Must map internal states to Status Register record fields** using std_logic types
- **Must follow the established naming conventions** (STATUS_* prefix)
- **Must provide clear status information** for external interfaces
- **Must receive equal treatment** with Control and Configuration registers

**Implementation Pattern**:
```vhdl
-- In common/module_name_pkg.vhd
-- Status Register record following established architecture
type status_register_t is record
    armed         : std_logic;     -- Module is armed
    firing        : std_logic;     -- Module is currently firing
    cooldown      : std_logic;     -- Module is in cooldown
    error         : std_logic;     -- Error condition active
    ready         : std_logic;     -- Module is ready for operation
    -- Reserved fields for future expansion
    reserved_5    : std_logic;     -- Reserved for future use
    reserved_6    : std_logic;     -- Reserved for future use
    reserved_7    : std_logic;     -- Reserved for future use
end record;

-- Default status register function (required by architecture)
function get_default_status_register return status_register_t;

-- Status checking functions using record fields
function is_module_armed(status : status_register_t) return boolean;
function is_module_firing(status : status_register_t) return boolean;
function is_module_cooldown(status : status_register_t) return boolean;
function is_module_error(status : status_register_t) return boolean;
function is_module_ready(status : status_register_t) return boolean;

-- In core/module_name_core.vhd
signal status_reg : status_register_t;

-- Map internal state to status register fields
status_reg.armed <= '1' when current_state = ARMED else '0';
status_reg.firing <= '1' when current_state = FIRING else '0';
status_reg.cooldown <= '1' when current_state = COOL_DOWN else '0';
status_reg.ready <= '1' when current_state = IDLE else '0';
status_reg.error <= '0';  -- Set based on error conditions
status_reg.reserved_5 <= '0';  -- Reserved bits always '0'
status_reg.reserved_6 <= '0';  -- Reserved bits always '0'
status_reg.reserved_7 <= '0';  -- Reserved bits always '0';
```

## Standard State Machine Patterns

### **1. Basic State Machine Pattern**

**Use Case**: Simple state machines with 2-4 states.

**Template**:
```vhdl
-- State type definition
type basic_state_type is (IDLE, RUNNING, COMPLETE);

-- State machine implementation
signal current_state : basic_state_type := IDLE;

process(clk) is
begin
    if rising_edge(clk) then
        if reset = '1' then
            current_state <= IDLE;
        else
            case current_state is
                when IDLE =>
                    if start = '1' then
                        current_state <= RUNNING;
                    end if;
                when RUNNING =>
                    if done = '1' then
                        current_state <= COMPLETE;
                    end if;
                when COMPLETE =>
                    if clear = '1' then
                        current_state <= IDLE;
                    end if;
                when others =>
                    current_state <= IDLE;
            end case;
        end if;
    end if;
end process;

-- Status register mapping using record fields
status_reg.ready <= '1' when current_state = IDLE else '0';
status_reg.running <= '1' when current_state = RUNNING else '0';
status_reg.complete <= '1' when current_state = COMPLETE else '0';
```





## Status Register Record Standards

### **Consistent Field Naming Across Modules**

To maintain consistency and reduce confusion, similar modules should use similar field names for common states:

#### **Standard Field Names for Common States**
```vhdl
-- Common state field names (recommended for all modules)
type common_status_fields_t is record
    ready         : std_logic;     -- Module is idle/ready
    armed         : std_logic;     -- Module is armed/ready
    running       : std_logic;     -- Module is actively running
    paused        : std_logic;     -- Module is paused
    complete      : std_logic;     -- Operation completed
    error         : std_logic;     -- Error condition active
    busy          : std_logic;     -- Module is busy/processing
    timeout       : std_logic;     -- Timeout condition occurred
end record;
```

#### **Module-Specific State Fields**
```vhdl
-- Example: Module-specific state fields
type module_status_fields_t is record
    -- Common fields (use consistent naming)
    ready         : std_logic;     -- Module is ready
    armed         : std_logic;     -- Module is armed
    error         : std_logic;     -- Error condition
    -- Module-specific fields (customize as needed)
    active        : std_logic;     -- Module-specific active state
    processing    : std_logic;     -- Module-specific processing state
    -- Reserved fields for future expansion
    reserved_5    : std_logic;     -- Reserved for future use
    reserved_6    : std_logic;     -- Reserved for future use
    reserved_7    : std_logic;     -- Reserved for future use
end record;
```

### **Reserved Fields for Future Expansion**

**Requirement**: All Status Register records must include reserved fields for future expansion.

**Implementation**:
```vhdl
-- Status register with reserved fields
type status_register_t is record
    -- Current implementation fields
    ready         : std_logic;     -- Module is ready
    armed         : std_logic;     -- Module is armed
    active        : std_logic;     -- Module is active
    error         : std_logic;     -- Error condition
    -- Reserved fields for future expansion
    reserved_4    : std_logic;     -- Reserved for future use
    reserved_5    : std_logic;     -- Reserved for future use
    reserved_6    : std_logic;     -- Reserved for future use
    reserved_7    : std_logic;     -- Reserved for future use
end record;

-- Reserved fields must always read as '0' in current implementation
status_reg.reserved_4 <= '0';
status_reg.reserved_5 <= '0';
status_reg.reserved_6 <= '0';
status_reg.reserved_7 <= '0';
```

### **External Interface Integration**

**For modules that need to expose status to external interfaces, the Status Register record can be converted to std_logic_vector:**

```vhdl
-- Convert record to std_logic_vector for external interface
signal external_status : std_logic_vector(7 downto 0);

-- Map record fields to external interface
external_status(0) <= status_reg.ready;
external_status(1) <= status_reg.armed;
external_status(2) <= status_reg.active;
external_status(3) <= status_reg.error;
external_status(4) <= status_reg.reserved_4;
external_status(5) <= status_reg.reserved_5;
external_status(6) <= status_reg.reserved_6;
external_status(7) <= status_reg.reserved_7;
```

## State Machine Documentation Requirements

### **Package Documentation**

All state machine types must be documented in the common package:

```vhdl
-- =============================================================================
-- STATE MACHINE DEFINITIONS
-- =============================================================================

-- Main operational state machine
-- States: IDLE -> ARMED -> ACTIVE -> IDLE
-- Error handling: Any state -> ERROR -> IDLE
type module_state_type is (IDLE, ARMED, ACTIVE, ERROR);

-- State descriptions for documentation
-- IDLE: System disabled, waiting for enable signal
-- ARMED: Ready to operate, waiting for trigger input  
-- ACTIVE: Actively performing operation
-- ERROR: Error condition detected, requires manual intervention
```

### **README Documentation**

Each module must document its state machine in the README:

```markdown
## State Machine Operation

### States
- **IDLE**: System disabled, waiting for enable
- **ARMED**: Ready to operate, waiting for trigger
- **ACTIVE**: Actively performing operation
- **ERROR**: Error condition detected

### State Transitions
```
IDLE → ARMED : enable = '1'
ARMED → ACTIVE : trigger = '1'
ACTIVE → IDLE : operation_complete = '1'
```

### Status Register Mapping
- **Field 0**: ARMED state active
- **Field 1**: ACTIVE state active
- **Field 2**: ERROR condition active
- **Fields 4-7**: Reserved for future expansion
```

## Compliance Requirements

### **Mandatory Requirements**

1. **All state machines must use VHDL enumerated types** for internal logic
2. **All state machines must provide external visibility** through Status Register records
3. **State types must be defined in common packages** for consistency
4. **Status Register records must use consistent field naming** across similar modules
5. **All state machines must include state-to-string functions** for debugging
6. **Status Register records must include reserved fields** for future additions
7. **State machine documentation must be complete** in both packages and READMEs
8. **Status Register records must receive equal treatment** with Control and Configuration registers

### **Implementation Standards**

1. **Use descriptive state names** that clearly indicate purpose
2. **Include safety default cases** in all state machines
3. **Map internal states to Status Register record fields** in a clear, consistent manner
4. **Provide status checking functions** for external interfaces
5. **Use consistent naming conventions** for state types and Status Register fields
6. **Include comprehensive error handling** in state machines
7. **Document all state transitions** and conditions
8. **Follow established record architecture** for all register definitions

### **Testing Requirements**

1. **All state transitions must be tested** in testbenches
2. **Status Register record mapping must be verified** for all states
3. **Error conditions must be tested** and verified
4. **State-to-string functions must be validated** for all states
5. **Reserved Status Register fields must read as '0'** in all test cases
6. **All three register types must receive equal testing coverage**

## Validation Checklist

- [ ] State machine uses VHDL enumerated types internally
- [ ] Status Register record provides external state visibility
- [ ] State types defined in common package
- [ ] Consistent field naming across similar modules
- [ ] State-to-string functions implemented
- [ ] Reserved fields for future expansion
- [ ] Complete state machine documentation
- [ ] All state transitions tested
- [ ] Status Register record mapping verified
- [ ] Error handling implemented and tested
- [ ] Reserved fields read as '0' in tests
- [ ] Naming conventions followed consistently
- [ ] Safety default cases included
- [ ] Status checking functions provided
- [ ] Status Register records receive equal treatment with Control/Configuration registers
- [ ] All three register types follow established record architecture

## Benefits of Hybrid Approach

### **1. Type Safety and Maintainability**
- **Compile-time checking** prevents invalid state assignments
- **Easy state addition/removal** with minimal code changes
- **Clear, readable code** that's easy to understand and modify

### **2. External Visibility and Debugging**
- **Record field access** for monitoring and debugging
- **Hardware-friendly interface** for external systems
- **Future expansion** without breaking existing code

### **3. Industry Standard Compliance**
- **Follows VHDL best practices** for internal logic
- **Provides standard interfaces** for external monitoring
- **Aligns with commercial IP** development practices

### **4. Team Development Benefits**
- **Hardware engineers** can read status fields directly
- **Software engineers** get clean register interfaces
- **Test engineers** can verify both internal logic and external behavior

### **5. Architecture Consistency**
- **Integrates seamlessly** with established three-register architecture
- **Equal treatment** for all register types
- **Consistent naming conventions** across all modules
- **Standardized record definitions** for better maintainability

### **6. Verilog Portability Considerations**
- **Status checking functions** provide excellent VHDL developer experience
- **Verilog conversion** requires function-to-module transformation
- **Record-to-struct conversion** provides clean Verilog mapping
- **Industry standard practice** justifies the portability trade-off

## Conclusion

The hybrid state machine approach combines the best of both worlds:
- **VHDL enumerated types** for internal type safety and maintainability
- **Status Register records** for external visibility and debugging
- **Industry standard practice** that's widely adopted and well-supported
- **Future-proof design** that scales with module complexity
- **Architecture consistency** with established Control/Configuration/Status register standards

This approach ensures that all VHDL modules in the project maintain high code quality while providing excellent external monitoring capabilities and maintaining consistency with the established three-register architecture.
