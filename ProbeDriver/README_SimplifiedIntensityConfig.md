# Simplified Intensity Configuration

## Overview

The ProbeDriver now uses a simplified, self-documenting approach to intensity configuration where the `IntensityLut` serves as both the intensity mapping AND the safety bounds.

## How It Works

### Before (Separate Configuration)
- `MinIntensity` and `MaxIntensity` were defined as separate constants
- Users had to maintain both the LUT and separate bounds constants
- Risk of configuration mismatches between LUT values and safety bounds

### After (Self-Documenting LUT)
- **IntensityLut[0] = 0x00** (off - safe zero intensity)
- **IntensityLut[1] = smallest observable output** (MinIntensity - safe minimum)
- **IntensityLut[100] = largest safe output** (MaxIntensity - safe maximum)

## Benefits

1. **Single Source of Truth**: The LUT defines both the intensity curve and safety bounds
2. **Self-Documenting**: Users can immediately see the safe operating range
3. **Easier Configuration**: No need to maintain separate MinIntensity/MaxIntensity constants
4. **Dynamic Safety**: Users can adjust safety limits by modifying the LUT endpoints
5. **Reduced Errors**: Eliminates the possibility of mismatched bounds and LUT values

## Configuration

To modify the safe operating range, simply update the LUT endpoints:

```vhdl
constant IntensityLut : intensity_lut_type := (
  x"0000",  -- [0] = off (always safe)
  x"0010",  -- [1] = new MinIntensity (smallest safe output)
  -- ... intermediate values ...
  x"0400"   -- [100] = new MaxIntensity (largest safe output)
);
```

## Validation

The system automatically validates that:
- Intensity index is within 0-100 range
- LUT[0] always provides safe zero intensity
- LUT[1] provides the minimum safe output
- LUT[100] provides the maximum safe output

## Migration

This change is backward compatible. Existing LUTs will continue to work, but now provide clearer safety boundaries and easier configuration management.
