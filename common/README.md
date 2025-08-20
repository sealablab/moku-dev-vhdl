# Common Components

This directory contains reusable components and packages that are intended to be used across multiple modules within the `moku-dev-vhdl` project.

## Available Components

### `clock_divider.vhd`
**Purpose**: Unified, generic-based clock divider module for all Moku VHDL modules.

**Key Features**:
- **Configurable bit width**: 1 to 16 bits via generic parameter
- **Flexible division ratios**: 1 to 2^DIVIDER_WIDTH - 1
- **Dual outputs**: Both divided clock and enable pulse
- **Enable/disable control**: Can be disabled when not needed
- **Synchronous reset**: Clean reset behavior

**Usage Examples**:
```vhdl
-- 4-bit divider (ProbeDriver)
u_clk_divider: entity work.clock_divider
    generic map (DIVIDER_WIDTH => 4)
    port map (
        clk_in => Clk,
        reset => Reset,
        divider => clock_divider_sel,
        enable => '1',
        clk_out => open,
        clk_out_en => probe_clk_en
    );

-- 16-bit divider (BasicBlock)
clock_divider_inst : clock_divider
    generic map (DIVIDER_WIDTH => 16)
    port map (
        clk_in => clk,
        reset => reset,
        divider => clk_divider_ratio,
        enable => clk_divider_enable,
        clk_out => clk_divider_output,
        clk_out_en => clk_enable
    );
```

**File**: `clock_divider.vhd`  
**Documentation**: `README-ClockDivider.md` (detailed usage and migration guide)

---

### `percent_lut_pkg.vhd`
**Purpose**: Generic percentage lookup table type definition for 0-100% mappings.

**Key Features**:
- **Generic data type**: Flexible bit widths for different applications
- **Human-friendly range**: 0-100% (101 values total)
- **7-bit indexing**: Efficient indexing with `std_logic_vector(6 downto 0)`
- **No default tables**: Modules define their own specific mappings

**Usage Example**:
```vhdl
-- In your module's package
use work.percent_lut_pkg.all;

-- Define a 16-bit intensity LUT
constant IntensityLut : percent_lut_type := (
    x"0000",  -- 0% = 0V (off)
    x"0240",  -- 1% = smallest observable
    -- ... define all 101 values
    x"0320"   -- 100% = maximum safe output
);

-- Use the LUT
signal intensity_output : std_logic_vector(15 downto 0);
intensity_output <= get_percent_value_safe(IntensityLut, intensity_index);
```

**Common Applications**:
- **Intensity mapping**: 0% = 0V, 100% = MaxVoltage
- **Frequency scaling**: 0% = 0Hz, 100% = MaxFrequency  
- **Duration scaling**: 0% = 0ms, 100% = MaxDuration
- **Amplitude scaling**: 0% = 0V, 100% = MaxAmplitude

**File**: `percent_lut_pkg.vhd`

---

## Adding New Common Components

When adding new common components:

1. **Follow naming convention**: `component_name.vhd` or `package_name_pkg.vhd`
2. **Include comprehensive header comments** explaining purpose and usage
3. **Provide utility functions** for common operations
4. **Update this README** with component description and examples
5. **Test with multiple modules** to ensure reusability

## Component Dependencies

Common components should have minimal dependencies:
- **Primary**: IEEE standard libraries (`std_logic_1164`, `numeric_std`)
- **Avoid**: Dependencies on other project-specific packages
- **Goal**: Self-contained, reusable components

## Benefits

1. **Consistent interface** across all modules
2. **Single source of truth** for common functionality
3. **Easier maintenance** and updates
4. **Reduced duplication** across the project
5. **Standardized patterns** for common VHDL operations

## File Organization

```
common/
├── README.md                    # This file - overview of all components
├── README-ClockDivider.md      # Detailed clock divider documentation
├── clock_divider.vhd           # Unified clock divider component
└── percent_lut_pkg.vhd        # Generic percentage LUT package
```

## Future Considerations

As the project grows, consider:
- **Versioning**: Component version numbers for compatibility
- **Generic parameters**: More flexible type definitions
- **Validation**: Built-in bounds checking and error handling
- **Documentation**: More detailed usage examples and best practices
