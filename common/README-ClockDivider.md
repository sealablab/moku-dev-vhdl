# clock_divider - Unified Clock Divider Module

## Overview
`clock_divider` is a unified, generic-based clock divider module that replaces all existing clock divider implementations in the Moku VHDL codebase. It provides configurable bit width support and a clean, consistent interface.

## Features
- **Configurable bit width**: 1 to 16 bits via generic parameter
- **Flexible division ratios**: 1 to 2^DIVIDER_WIDTH - 1
- **Dual outputs**: Both divided clock and enable pulse
- **Enable/disable control**: Can be disabled when not needed
- **Synchronous reset**: Clean reset behavior
- **Resource efficient**: Uses only necessary bits for counter

## Generic Parameters

| Parameter | Type | Range | Default | Description |
|-----------|------|-------|---------|-------------|
| `DIVIDER_WIDTH` | positive | 1 to 16 | 4 | Bit width of divider input |
| `MAX_DIVIDER` | natural | auto | 2^DIVIDER_WIDTH - 1 | Maximum divider value (auto-calculated) |

## Port Interface

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clk_in` | in | std_logic | Input clock signal |
| `reset` | in | std_logic | Synchronous reset (active high) |
| `divider` | in | std_logic_vector(DIVIDER_WIDTH-1 downto 0) | Division factor |
| `enable` | in | std_logic | Enable/disable the divider |
| `clk_out` | out | std_logic | Divided clock output |
| `clk_out_en` | out | std_logic | Output enable pulse (high when clk_out is valid) |

## Usage Examples

### 4-bit Divider (ProbeDriver)
```vhdl
-- 4-bit divider with 16 possible ratios (1x to 16x)
simple_divider : clock_divider
    generic map (
        DIVIDER_WIDTH => 4,
        MAX_DIVIDER => 15
    )
    port map (
        clk_in => clk,
        reset => reset,
        divider => "0000" & divider_sel,  -- Extend 4-bit to 16-bit
        enable => '1',
        clk_out => clk_divided,
        clk_out_en => clk_enable
    );
```

### 16-bit Divider (BasicBlock)
```vhdl
-- 16-bit divider with 65536 possible ratios
full_divider : clock_divider
    generic map (
        DIVIDER_WIDTH => 16,
        MAX_DIVIDER => 65535
    )
    port map (
        clk_in => clk,
        reset => reset,
        divider => divider_ratio,    -- 16-bit ratio
        enable => divider_enable,
        clk_out => clk_divided,
        clk_out_en => clk_enable
    );
```

## Behavior

### Normal Operation
- When `enable = '1'` and `reset = '0'`:
  - Counter increments on each input clock edge
  - When counter reaches `divider - 1`, output toggles and counter resets
  - `clk_out_en` pulses high for one input clock cycle when output toggles

### Special Cases
- **`divider = 0`**: Output same as input (no division)
- **`enable = '0'**: Outputs held low, counter reset
- **`reset = '1'**: All outputs and counter reset

### Timing
```
Input Clock:     __|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|
Divider: 4
Divided Clock:  __|‾|________|‾|________|‾|________|‾|
Enable Pulse:   __|‾|________|‾|________|‾|________|‾|
```

## Migration from Old Implementations

### Old ProbeDriver clk_divider
```vhdl
-- OLD
u_clk_divider: entity work.clk_divider
    port map (
        clk_in => Clk,
        reset => Reset,
        divider_sel => clock_divider_sel,  -- 4-bit
        clk_en => probe_clk_en
    );

-- NEW
u_clk_divider: entity work.clock_divider
    generic map (DIVIDER_WIDTH => 4)
    port map (
        clk_in => Clk,
        reset => Reset,
        divider => "0000" & clock_divider_sel,  -- Extend to 16-bit
        enable => '1',
        clk_out => open,
        clk_out_en => probe_clk_en
    );
```

### Old BasicBlock clock_divider
```vhdl
-- OLD
clock_divider_inst : clock_divider
    port map (
        clk_in => clk,
        clk_out => clk_divider_output,
        ratio => clk_divider_ratio,
        enable => clk_divider_enable,
        reset => reset
    );

-- NEW
clock_divider_inst : ClockDivider
    generic map (DIVIDER_WIDTH => 16)
    port map (
        clk_in => clk,
        clk_out => clk_divider_output,
        divider => clk_divider_ratio,
        enable => clk_divider_enable,
        reset => reset
    );
```

## Benefits

1. **Unified interface**: All modules use the same component
2. **Configurable**: Choose appropriate bit width for each use case
3. **Resource efficient**: Smaller dividers use fewer FPGA resources
4. **Maintainable**: Single implementation to maintain and test
5. **Flexible**: Can handle both simple and complex division needs
6. **Backward compatible**: Existing functionality preserved

## File Location
`moku-dev-vhdl/common/clock_divider.vhd`

## Dependencies
- IEEE.Std_Logic_1164
- IEEE.Numeric_Std
