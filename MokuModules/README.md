# MokuModules - Standardized Module Definitions

This directory contains standardized module definitions and component declarations to eliminate duplication across your VHDL codebase.

## What This Solves

**Before**: Every testbench duplicated the entire `CustomWrapper` component declaration (39+ lines)
**After**: Testbenches simply include the package and use pre-defined components

## Files

- `CustomWrapper.vhd` - Complete CustomWrapper entity definition
- `MokuGo.vhd` - MokuGo-specific hardware interface
- `MokuModules_pkg.vhd` - Package containing standardized component declarations
- `README.md` - This file

## How to Use

### 1. In Testbenches (Replace Component Declarations)

**OLD WAY** (39+ lines of duplication):
```vhdl
-- Component declaration for the unit under test
component CustomWrapper is
  port (
    Clk : in std_logic;
    Reset : in std_logic;
    InputA : in signed(15 downto 0);
    -- ... 35+ more lines of port definitions
  );
end component;
```

**NEW WAY** (1 line):
```vhdl
-- Include the standardized package
use work.MokuModules_pkg.all;

-- No component declaration needed - it's in the package!
```

### 2. Complete Testbench Example

```vhdl
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.MokuModules_pkg.all;  -- Include standardized components

entity my_testbench is
end entity my_testbench;

architecture testbench of my_testbench is
  -- Use constants from package
  constant CLK_PERIOD : time := MOKUGO_CLK_PERIOD;
  
  -- Signal declarations
  signal clk : std_logic := '0';
  signal reset : std_logic := RESET_ACTIVE;
  -- ... other signals
  
begin
  -- Clock generation
  clk <= not clk after CLK_PERIOD / 2;
  
  -- Instantiate using component from package
  uut: CustomWrapper
    port map (
      Clk => clk,
      Reset => reset,
      -- ... port mappings
    );
    
  -- Test stimulus
  test_sequence: process
  begin
    -- Your test code here
  end process;
  
end architecture testbench;
```

## Benefits

1. **Eliminates Duplication**: No more copying 39+ lines of port definitions
2. **Centralized Updates**: Change CustomWrapper once, updates everywhere
3. **Consistency**: All testbenches use identical component definitions
4. **Maintainability**: Easier to keep interfaces in sync
5. **Standardization**: Common constants and types across all modules

## Migration Path

1. **Phase 1**: Update new testbenches to use the package
2. **Phase 2**: Gradually migrate existing testbenches
3. **Phase 3**: Remove old component declarations

## Adding New Modules

To add a new Moku hardware module:

1. Create the entity file (e.g., `MokuLab.vhd`)
2. Add component declaration to `MokuModules_pkg.vhd`
3. Add any platform-specific constants
4. Update this README

## Questions?

This approach follows VHDL best practices for component reuse and eliminates the duplication problem you identified. The package acts as a single source of truth for all Moku hardware interfaces.
