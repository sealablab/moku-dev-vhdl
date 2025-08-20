# State Machine Implementation Requirements

## Overview

This document defines the standardized approach for implementing state machines in VHDL modules. The **hybrid approach** combines the benefits of VHDL enumerated types for internal logic with **Status Register records** for external visibility, following the established architecture defined in `register-requirements.md`.

**Key Principle**: All state machines must use VHDL enumerated types internally while providing external visibility through **Status Register records** that follow the established register architecture standards.

**Reference Implementation**: See `rework-v3/ProbeDriver/` for a complete, working example of this approach.

## Core Requirements

### **1. Internal State Management (VHDL Enumerated Types)**

**Must use VHDL enumerated types** for all internal state machines:
```vhdl
type module_state_type is (IDLE, ARMED, FIRING, COOL_DOWN);
```

**Must include state-to-string functions** for debugging:
```vhdl
function module_state_to_string(state : module_state_type) return string;
```

### **2. External State Visibility (Status Register Records)**

**Must implement Status Register records** as defined in `register-requirements.md`:
```vhdl
type status_register_t is record
    ready         : std_logic;     -- Module is ready
    armed         : std_logic;     -- Module is armed
    firing        : std_logic;     -- Module is currently firing
    cooldown      : std_logic;     -- Module is in cooldown
    error         : std_logic;     -- Error condition active
    -- Reserved fields for future expansion
    reserved_5    : std_logic;     -- Reserved for future use
    reserved_6    : std_logic;     -- Reserved for future use
    reserved_7    : std_logic;     -- Reserved for future use
end record;
```

**Must provide status checking functions**:
```vhdl
function is_module_armed(status : status_register_t) return boolean;
function is_module_firing(status : status_register_t) return boolean;
-- etc.
```

### **3. State Machine Implementation**

**Must map internal states to Status Register record fields**:
```vhdl
-- Map internal state to status register fields
status_reg.armed <= '1' when current_state = ARMED else '0';
status_reg.firing <= '1' when current_state = FIRING else '0';
status_reg.cooldown <= '1' when current_state = COOL_DOWN else '0';
status_reg.ready <= '1' when current_state = IDLE else '0';
```

### **4. External Interface Integration**

**For external interfaces, convert Status Register record to std_logic_vector**:
```vhdl
-- Convert record to std_logic_vector for external interface
probe_status_register(0) <= probe_status_record.ready;
probe_status_register(1) <= probe_status_record.armed;
probe_status_register(2) <= probe_status_record.firing;
-- etc.
```

## Complete Working Example

**Reference**: `rework-v3/ProbeDriver/` contains a complete implementation of these requirements:

- **Package**: `common/probe_driver_pkg.vhd` - Defines state types and Status Register records
- **Core**: `core/probe_driver_core.vhd` - Implements state machine with record mapping
- **Main**: `ProbeDriver.vhd` - Shows record-to-vector conversion for external interface

This example demonstrates:
- ✅ VHDL enumerated types for internal state management
- ✅ Status Register records for structured status data
- ✅ State-to-status mapping in the core module
- ✅ Record-to-vector conversion for external interfaces
- ✅ Full synthesis compatibility

## Compliance Checklist

- [ ] State machine uses VHDL enumerated types internally
- [ ] Status Register record provides external state visibility
- [ ] State types defined in common package
- [ ] State-to-string functions implemented
- [ ] Reserved fields for future expansion
- [ ] Status Register record mapping implemented
- [ ] Record-to-vector conversion for external interfaces
- [ ] All modules compile and synthesize successfully

## Benefits

1. **Type Safety**: Compile-time checking prevents invalid state assignments
2. **Maintainability**: Easy to add/remove states with minimal code changes
3. **External Visibility**: Clear status monitoring through record fields
4. **Future Expansion**: Reserved fields allow growth without breaking changes
5. **Architecture Consistency**: Integrates with established three-register architecture
6. **Synthesis Compatibility**: Works with modern synthesis tools

## Conclusion

The hybrid approach combines VHDL enumerated types for internal logic with Status Register records for external visibility. This provides the best of both worlds: type safety internally and structured monitoring externally.

**For implementation details and examples, refer to the working ProbeDriver module in `rework-v3/ProbeDriver/`.**
