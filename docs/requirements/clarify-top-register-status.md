# Probe Status Register Refactor Requirements

## Overview
This document outlines the proposed refactor to expand the probe status register from 5 bits to 16 bits, eliminating the redundant intermediate status register and creating a cleaner, more intuitive interface.

## Current Issues

### 1. Redundant Status Registers
The current implementation creates unnecessary complexity with two separate status registers:
```vhdl
-- ProbeDriverStatusRegister (PDSR)
signal probe_driver_status_register : std_logic_vector(4 downto 0);
-- TopLevel Status Register (16 bits) 
signal toplevel_status_register : std_logic_vector(15 downto 0);
```

### 2. Complex Bit Manipulation
Current status register construction requires complex bit manipulation:
```vhdl
toplevel_status_register <= probe_driver_status_register(4) & 
                           "00000000000" & 
                           probe_driver_status_register(3 downto 0);
```

### 3. Wasted Bits
11 bits (14:4) are reserved but serve no immediate purpose, creating confusion about the interface.

## Proposed Solution

### 1. Expand Probe Status Register to 16 Bits
Modify the `probe_driver` entity to output a full 16-bit status register:
```vhdl
-- OLD: 5-bit status register
status_register : out std_logic_vector(4 downto 0)

-- NEW: 16-bit status register with room for expansion
status_register : out std_logic_vector(15 downto 0)
```

### 2. Direct Status Register Mapping
Eliminate the intermediate `toplevel_status_register` and directly route the expanded probe status register:
```vhdl
-- OLD: Complex bit construction
toplevel_status_register <= probe_driver_status_register(4) & 
                           "00000000000" & 
                           probe_driver_status_register(3 downto 0);
OutputA <= signed(toplevel_status_register);

-- NEW: Direct mapping
OutputA <= signed(probe_driver_status_register);
```

### 3. Simplified Signal Declaration
Remove the redundant signal:
```vhdl
-- OLD: Two status registers
signal probe_driver_status_register : std_logic_vector(4 downto 0);
signal toplevel_status_register : std_logic_vector(15 downto 0);

-- NEW: Single expanded status register
signal probe_driver_status_register : std_logic_vector(15 downto 0);
```

## New Status Register Layout

### Bits [4:0] - Core State Machine Status (Existing)
- **Bit 4**: Error flag (parameter validation errors)
- **Bit 3**: COOL_DOWN state active
- **Bit 2**: PULSE_COMPLETE state active  
- **Bit 1**: FIRING state active
- **Bit 0**: ARMED state active

### Bits [15:5] - Reserved for Future Expansion
- **Bits 15:5**: Reserved for future status bits, counters, or flags
- **Current Value**: Set to 0 (all reserved bits low)
- **Future Use**: Can be used for:
  - Pulse counter values
  - Error codes
  - Performance metrics
  - Additional state information
  - Debug flags

## Implementation Benefits

### 1. **Eliminates Redundancy**
- Single source of truth for status information
- No more intermediate signal construction
- Cleaner signal flow

### 2. **Improves Readability**
- Direct bit mapping from probe driver to output
- No complex bit manipulation logic
- Obvious relationship between internal state and external status

### 3. **Future-Proof Design**
- 11 reserved bits available for expansion
- No breaking changes to existing functionality
- Easy to add new status features

### 4. **Better Debugging**
- Status values are directly readable
- No bit shifting required to interpret values
- Consistent with existing HumanInterface package expectations

## Required Changes

### 1. ProbeDriver.vhd
- Modify `status_register` port from `std_logic_vector(4 downto 0)` to `std_logic_vector(15 downto 0)`
- Update internal `status_reg` signal to 16 bits
- Initialize reserved bits [15:5] to '0'

### 2. top_probe_driver.vhd
- Remove `toplevel_status_register` signal
- Update `probe_driver_status_register` to 16 bits
- Simplify OutputA assignment to direct mapping
- Update OutputB logic to use expanded status register

### 3. Testbench Updates (Future)
- Update testbench signal declarations
- Modify status checking logic for 16-bit values
- Update HumanInterface package if needed

## Compatibility Notes

### 1. **No Breaking Changes to Core Functionality**
- Bits [4:0] maintain exact same behavior
- All existing state machine logic unchanged
- OutputA still provides same information in same bit positions

### 2. **Reserved Bits Behavior**
- Bits [15:5] always read as 0
- Future expansion can set these bits without affecting existing code
- Testbenches can safely ignore reserved bits

### 3. **HumanInterface Package**
- Existing `decode_toplevel_status` function continues to work
- `probe_state_to_string` function unchanged
- All existing debugging output preserved

## Migration Path

### Phase 1: Core Changes
1. Update ProbeDriver entity and implementation
2. Modify top_probe_driver.vhd signal declarations
3. Simplify status register routing

### Phase 2: Testing and Validation
1. Verify all existing functionality works
2. Confirm status register bits [4:0] behave identically
3. Test reserved bits [15:5] read as 0

### Phase 3: Future Expansion
1. Add new status bits to reserved positions
2. Update documentation for new bits
3. Enhance testbenches to validate new functionality

## Conclusion

This refactor significantly improves the code quality by:
- **Eliminating redundant signals and logic**
- **Creating a cleaner, more maintainable interface**
- **Providing room for future expansion**
- **Maintaining full backward compatibility**

The proposed changes make the interface easier for both testbenches and humans while preserving all existing functionality and creating a foundation for future enhancements.
