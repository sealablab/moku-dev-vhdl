# TopLevel Status Register

## Overview
The TopLevel status register is a 16-bit consolidated status register that provides a clean, unified interface for monitoring the probe driver system status.

## Register Structure

```
Bits: [15] [14] [13] [12] [11] [10] [9] [8] [7] [6] [5] [4] [3] [2] [1] [0]
      |Error| Reserved (11 bits) | State Machine Status (4 bits) |
```

## Bit Definitions

### Bit 15: Error Flag
- **Source**: Probe driver status register bit 4
- **Meaning**: Set when any parameter validation error occurs
- **Details**: 
  - Intensity error (exceeded maximum)
  - Duration error (below minimum)
  - Cooldown error (below minimum)

### Bits 14-4: Reserved
- **Value**: Always 0
- **Purpose**: Reserved for future expansion
- **Usage**: Can be used for additional status bits, counters, or flags

### Bits 3-0: State Machine Status
- **Source**: Probe driver status register bits [3:0]
- **Mapping**:
  - **Bit 3**: COOL_DOWN state active
  - **Bit 2**: FIRED state active  
  - **Bit 1**: FIRING state active
  - **Bit 0**: ARMED state active

## State Machine Status Values

| State | Bit 3 | Bit 2 | Bit 1 | Bit 0 | Hex Value | Description |
|-------|-------|-------|-------|-------|-----------|-------------|
| IDLE  |   0   |   0   |   0   |   0   |    0x0    | Waiting for enable |
| ARMED |   0   |   0   |   0   |   1   |    0x1    | Enabled, waiting for trigger |
| FIRING|   0   |   0   |   1   |   1   |    0x3    | Actively firing probe |
| FIRED |   0   |   1   |   1   |   1   |    0x7    | Pulse completed |
| COOL_DOWN| 1   |   1   |   1   |   1   |    0xF    | Cooling down |

## Error Conditions

When bit 15 is set (1), the following conditions may have occurred:

1. **Intensity Error**: User-specified intensity exceeded maximum (100)
2. **Duration Error**: User-specified pulse duration below minimum (16 cycles)
3. **Cooldown Error**: User-specified cooldown below minimum (24 cycles)

## Usage Examples

### Reading the Status Register
```vhdl
-- In VHDL
signal status : std_logic_vector(15 downto 0);
status <= toplevel_status_register;

-- Check for errors
if status(15) = '1' then
    -- Handle error condition
end if;

-- Check current state
case status(3 downto 0) is
    when "0001" => -- ARMED
    when "0011" => -- FIRING  
    when "0111" => -- FIRED
    when "1111" => -- COOL_DOWN
    when others =>  -- IDLE
end case;
```

### Python/Software Interface
```python
# Read 16-bit status register
status = read_status_register()

# Extract components
error_flag = (status >> 15) & 0x01
reserved_bits = (status >> 4) & 0x7FF
state_status = status & 0x0F

# Check for errors
if error_flag:
    print("Error detected in probe driver")

# Check state
state_names = {
    0x0: "IDLE",
    0x1: "ARMED", 
    0x3: "FIRING",
    0x7: "FIRED",
    0xF: "COOL_DOWN"
}
current_state = state_names.get(state_status, "UNKNOWN")
print(f"Current state: {current_state}")
```

## Benefits

1. **Clean Interface**: Single 16-bit register for all status information
2. **Future-Proof**: Reserved bits allow for expansion
3. **Error Visibility**: Clear error flag for monitoring
4. **State Tracking**: Easy state machine monitoring
5. **Standard Width**: 16-bit aligns with common register sizes

## Implementation

The TopLevel status register is constructed in the top-level architecture:

```vhdl
-- Construct 16-bit TopLevel status register
toplevel_status_register <= probe_driver_status_register(4) & 
                           "00000000000" & 
                           probe_driver_status_register(3 downto 0);
```

This register is available on OutputD for external monitoring and control systems.
