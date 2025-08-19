# ProbeDriver Reset Mechanism Analysis

## Overview
The ProbeDriver implements a sophisticated reset mechanism that serves multiple purposes: system initialization, parameter validation, error detection, and runtime reconfiguration. The reset signal (`reset = '1'`) triggers a comprehensive initialization sequence that loads and validates all input parameters.

## Reset Signal Characteristics
- **Active High**: Reset is asserted when `reset = '1'`
- **Synchronous**: Reset is sampled on the rising edge of the clock
- **Comprehensive**: Affects all internal state machines, counters, and registers
- **Parameter Loading**: Input parameters are only read during reset
- **Validation**: All parameters are validated against configuration limits during reset

## Reset-Triggered Initialization Sequence

### 1. State Machine Reset
```vhdl
current_state <= IDLE;                    -- Return to idle state
pulse_counter <= (others => '0');         -- Clear pulse timing counter
cooldown_counter <= (others => '0');      -- Clear cooldown counter
cnt <= (others => '0');                   -- Clear general counter
status_reg <= (others => '0');            -- Clear status register
```

### 2. Error Signal Initialization
```vhdl
intensity_error <= '0';                   -- Clear intensity error flag
duration_error <= '0';                    -- Clear duration error flag
cooldown_error <= '0';                    -- Clear cooldown error flag
```

### 3. Parameter Loading and Validation

#### Intensity Parameter
```vhdl
Intensity <= unsigned(Intensity_index);   -- Load 8-bit intensity index

-- Clamp intensity to valid range (0-100)
if to_integer(unsigned(Intensity_index)) <= ProbeIntensityMax then
    clamped_intensity <= to_integer(unsigned(Intensity_index));
    intensity_error <= '0';               -- No error
else
    clamped_intensity <= ProbeIntensityMax; -- Clamp to maximum
    intensity_error <= '1';               -- Error: exceeded maximum
end if;
```

#### Pulse Duration Parameter
```vhdl
PulseDuration <= unsigned(PulseDuration_in(15 downto 0)); -- Load 16-bit duration

-- Calculate effective duration (max of input and minimum)
if unsigned(PulseDuration_in(15 downto 0)) > ProbeMinDuration then
    effective_duration <= unsigned(PulseDuration_in(15 downto 0));
    duration_error <= '0';                -- No error
else
    effective_duration <= ProbeMinDuration; -- Use minimum duration
    duration_error <= '1';                -- Error: below minimum
end if;
```

#### Cooldown Parameter
```vhdl
CoolDown <= unsigned(CoolDown_in);        -- Load 32-bit cooldown

-- Calculate effective cooldown (max of input and minimum)
if CoolDown_in > std_logic_vector(ProbeCoolDownMin) then
    CoolDown <= unsigned(CoolDown_in);
    cooldown_error <= '0';                -- No error
else
    CoolDown <= ProbeCoolDownMin;         -- Use minimum cooldown
    cooldown_error <= '1';                -- Error: below minimum
end if;
```

### 4. Status Register Update
```vhdl
-- Set error bit (bit 4) if any error is detected
if (intensity_error = '1') or (duration_error = '1') or (cooldown_error = '1') then
    status_reg(4) <= '1';                -- Set bit 4 high when any error detected
else
    status_reg(4) <= '0';                -- Clear bit 4 when no errors
end if;
```

## Configuration Constants and Limits

### From ProbeConfig.vhd
```vhdl
constant ProbeIntensityMax : integer := 100;           -- Maximum valid intensity index
constant ProbeMinDuration : unsigned(15 downto 0) := to_unsigned(2, 16);      -- Minimum pulse duration (2 cycles)
constant ProbeMaxDuration : unsigned(15 downto 0) := to_unsigned(32, 16);     -- Maximum pulse duration (32 cycles)
constant ProbeCoolDownMin : unsigned(31 downto 0) := to_unsigned(1, 32);      -- Minimum cooldown (1 cycle)
constant ProbeTrigger_Threshold : signed(15 downto 0) := x"4000";             -- 2.5V threshold
```

### From IntensityLut.vhd
- **Intensity Range**: 0 to 100 (101 discrete levels)
- **Voltage Range**: 0V to 3.3V
- **Resolution**: 0.033V per intensity level
- **Key Values**:
  - 0% = 0x0000 (0V)
  - 50% = 0x0190 (1.65V)
  - 100% = 0x0320 (3.3V)

## Sanity Checking Examples

### Example 1: Valid Parameters
```vhdl
-- Input values during reset
Intensity_index = "00110010"     -- 50 (decimal) - Valid range
PulseDuration_in = x"0000000A"   -- 10 cycles - Above minimum (2)
CoolDown_in = x"00000005"        -- 5 cycles - Above minimum (1)

-- Expected initialization results
clamped_intensity = 50            -- No clamping needed
effective_duration = 10           -- Use input value
CoolDown = 5                      -- Use input value
intensity_error = '0'             -- No error
duration_error = '0'              -- No error
cooldown_error = '0'              -- No error
status_reg(4) = '0'              -- No errors in status
```

### Example 2: Intensity Out of Range
```vhdl
-- Input values during reset
Intensity_index = "01100101"     -- 101 (decimal) - Above maximum (100)
PulseDuration_in = x"0000000A"   -- 10 cycles - Valid
CoolDown_in = x"00000005"        -- 5 cycles - Valid

-- Expected initialization results
clamped_intensity = 100           -- Clamped to maximum
effective_duration = 10           -- Use input value
CoolDown = 5                      -- Use input value
intensity_error = '1'             -- Error detected
duration_error = '0'              -- No error
cooldown_error = '0'              -- No error
status_reg(4) = '1'              -- Error bit set in status
```

### Example 3: Duration Below Minimum
```vhdl
-- Input values during reset
Intensity_index = "00110010"     -- 50 (decimal) - Valid
PulseDuration_in = x"00000001"   -- 1 cycle - Below minimum (2)
CoolDown_in = x"00000005"        -- 5 cycles - Valid

-- Expected initialization results
clamped_intensity = 50            -- No clamping needed
effective_duration = 2            -- Clamped to minimum
CoolDown = 5                      -- Use input value
intensity_error = '0'             -- No error
duration_error = '1'              -- Error detected
cooldown_error = '0'              -- No error
status_reg(4) = '1'              -- Error bit set in status
```

### Example 4: Cooldown Below Minimum
```vhdl
-- Input values during reset
Intensity_index = "00110010"     -- 50 (decimal) - Valid
PulseDuration_in = x"0000000A"   -- 10 cycles - Valid
CoolDown_in = x"00000000"        -- 0 cycles - Below minimum (1)

-- Expected initialization results
clamped_intensity = 50            -- No clamping needed
effective_duration = 10           -- Use input value
CoolDown = 1                      -- Clamped to minimum
intensity_error = '0'             -- No error
duration_error = '0'              -- No error
cooldown_error = '1'              -- Error detected
status_reg(4) = '1'              -- Error bit set in status
```

### Example 5: Multiple Errors
```vhdl
-- Input values during reset
Intensity_index = "01100101"     -- 101 (decimal) - Above maximum
PulseDuration_in = x"00000001"   -- 1 cycle - Below minimum
CoolDown_in = x"00000000"        -- 0 cycles - Below minimum

-- Expected initialization results
clamped_intensity = 100           -- Clamped to maximum
effective_duration = 2            -- Clamped to minimum
CoolDown = 1                      -- Clamped to minimum
intensity_error = '1'             -- Error detected
duration_error = '1'              -- Error detected
cooldown_error = '1'              -- Error detected
status_reg(4) = '1'              -- Error bit set in status
```

## Status Register Bit Definitions

| Bit | Name | Description | Set When |
|-----|------|-------------|----------|
| 4   | Error | Any parameter validation error | Any error detected during reset |
| 3   | COOL_DOWN | Probe in cooldown state | Entering COOL_DOWN state |
| 2   | FIRED | Pulse completed | Entering FIRED state |
| 1   | FIRING | Probe actively firing | Entering FIRING state |
| 0   | ARMED | Probe armed and waiting | Entering ARMED state |

## Reset Timing Considerations

- **Clock Domain**: Reset is synchronous to the main clock
- **Setup Time**: Input parameters must be stable before reset assertion
- **Hold Time**: Input parameters must remain stable during reset
- **Recovery**: Reset deassertion must meet setup time requirements
- **Minimum Reset Duration**: At least one clock cycle required

## Runtime Reconfiguration

The reset mechanism enables runtime reconfiguration by:
1. **Parameter Reloading**: All input parameters are reloaded on each reset
2. **State Reset**: System returns to known IDLE state
3. **Error Clearing**: Previous error conditions are cleared
4. **Validation**: New parameters are immediately validated
5. **Immediate Effect**: New configuration takes effect immediately after reset

## Error Handling Strategy

- **Graceful Degradation**: Invalid parameters are clamped to valid ranges
- **Error Reporting**: Status register bit 4 indicates validation errors
- **Non-Destructive**: System continues operation with clamped values
- **Audit Trail**: Error conditions are captured in status register
- **Future Enhancement**: TODO comments indicate planned error counting

## Conclusion

The ProbeDriver reset mechanism provides a robust foundation for system initialization and runtime reconfiguration. It ensures all parameters are validated against configuration limits while maintaining system stability through graceful error handling. The comprehensive status reporting enables monitoring and debugging of parameter validation issues.
