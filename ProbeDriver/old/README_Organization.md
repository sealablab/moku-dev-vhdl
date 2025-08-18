# Slot2 Probe Driver - File Organization

## Overview
The probe driver has been reorganized for better readability and maintainability, following VHDL best practices.

## File Structure

### 1. `Slot2-ProbeDriver.vhd` - Main Driver File
- **Constants Section**: All configuration values at the top
- **Entity**: Port definitions (inputs/outputs)
- **Architecture**: Implementation with clear sections
- **State Machine**: Well-organized timing and control logic

### 2. `IntensityLut.vhd` - Lookup Table Package
- **Package**: Contains the intensity lookup table
- **Reusable**: Can be imported by other VHDL files
- **Maintainable**: Easy to modify voltage-to-intensity mappings

### 3. `Makefile` - Build Automation
- **Syntax Checking**: Easy compilation with `make`
- **Multiple Targets**: Check individual files or all files
- **Clean Up**: Remove generated files with `make clean`
- **Help**: Show available commands with `make help`

## Benefits of This Organization

### ✅ **Pros:**
1. **Readability**: Constants at the top, easy to find and modify
2. **Maintainability**: Clear sections with descriptive headers
3. **Modularity**: Lookup table can be reused in other projects
4. **Professional**: Follows industry VHDL coding standards
5. **Debugging**: Easier to locate and fix issues

### ⚠️ **Potential Downsides:**
1. **File Count**: Now have 2 files instead of 1
2. **Dependencies**: Main file depends on the package file
3. **Compilation Order**: Must compile package before main file

## How to Use

### Compilation Order:
```bash
# Option 1: Use the Makefile (recommended)
make                    # Check syntax of all files
make syntax_check       # Same as above
make check_package      # Check only package file
make check_main         # Check only main file

# Option 2: Manual compilation
ghdl -a ./IntensityLut.vhd
ghdl -a ./Slot2-ProbeDriver.vhd
```

### Using the Package in Other Files:
```vhdl
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.IntensityLut_pkg.all;  -- Import the package

-- Now you can use IntensityLut in your code
signal my_intensity : signed(15 downto 0);
my_intensity <= IntensityLut(50);  -- 50% intensity
```

## Constants Section
All configuration values are now clearly defined at the top of the architecture:
- `ProbeMinDuration`: Minimum safe pulse duration
- `ProbeMaxDuration`: Maximum allowed pulse duration  
- `ProbeCoolDown`: Default cooldown period

## Recommendations
1. **Keep constants at the top** for easy modification
2. **Use clear section headers** for better navigation
3. **Separate concerns** (timing logic vs. lookup tables)
4. **Follow consistent naming** conventions

This organization makes the code much more professional and easier to work with!
