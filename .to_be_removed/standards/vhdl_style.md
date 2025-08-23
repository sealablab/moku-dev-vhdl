# VHDL Style Guide v1

## Standards
- **VHDL Standard**: 2008
- **File Extension**: .vhd
- **Line Length**: 120 characters
- **Indentation**: 2 spaces

## Naming Conventions

### Entities
- **Pattern**: `^[A-Z][A-Za-z0-9_]*$`
- **Examples**: `ProbeDriver`, `SigGen`, `ArithmeticUnit`
- **Invalid**: `probe_driver`, `siggen`

### Architectures
- **Valid**: `rtl`, `behave`, `tb`
- **Examples**: `rtl`, `tb`

### Signals
- **Pattern**: `^[a-z0-9_]+$`
- **Examples**: `clk`, `rst_n`, `data_in`, `ready_out`

### Constants
- **Pattern**: `^[A-Z0-9_]+$`
- **Examples**: `CLK_PERIOD`, `RESET_DELAY`, `MAX_COUNT`

## Clocking Standards

### Clock
- **Name**: `clk`
- **Type**: System clock

### Reset
- **Name**: `rst_n`
- **Active**: Low (active when '0')
- **Type**: Synchronous

### Clock Enable
- **Name**: `clk_en`
- **Required**: Yes
- **Purpose**: Clock gating control

## Required Packages
```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
```

## Forbidden Packages
- `std_logic_arith` - Use `numeric_std` instead
- `std_logic_unsigned` - Use `numeric_std` instead

## Testbench Magic Strings
- **Pass**: `"ALL TESTS PASSED"`
- **Done**: `"SIMULATION DONE"`
