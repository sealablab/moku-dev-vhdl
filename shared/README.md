# Shared Packages

This directory contains packages that are intended to be used across multiple modules within the `moku-dev-vhdl` project.

## Available Packages

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
constant IntensityLut : percent_lut_type(0 to 100) of std_logic_vector(15 downto 0) := (
    x"0000",  -- 0% = 0V (off)
    x"0240",  -- 1% = smallest observable
    x"0320",  -- 100% = maximum safe output
    -- ... define all 101 values
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

**Benefits**:
1. **Consistent interface** across all modules
2. **Human-friendly percentages** (0-100%) for configuration
3. **Efficient 7-bit indexing** for control registers
4. **Type safety** with VHDL's strong typing
5. **Easy to understand** and maintain

## Adding New Shared Packages

When adding new shared packages:

1. **Follow naming convention**: `package_name_pkg.vhd`
2. **Include comprehensive header comments** explaining purpose and usage
3. **Provide utility functions** for common operations
4. **Update this README** with package description and examples
5. **Test with multiple modules** to ensure reusability

## Package Dependencies

Shared packages should have minimal dependencies:
- **Primary**: IEEE standard libraries (`std_logic_1164`, `numeric_std`)
- **Avoid**: Dependencies on other project-specific packages
- **Goal**: Self-contained, reusable components

## Future Considerations

As the project grows, consider:
- **Versioning**: Package version numbers for compatibility
- **Generic parameters**: More flexible type definitions
- **Validation**: Built-in bounds checking and error handling
- **Documentation**: More detailed usage examples and best practices
