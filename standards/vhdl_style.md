# VHDL Style Guide v1

<!-- RULE:version=1 -->
<!-- RULE:vhdl_standard=2008 -->
<!-- RULE:file_extension=.vhd -->
<!-- RULE:line_length=120 -->
<!-- RULE:indent=2 -->

## Standards

- **VHDL Standard**: 2008
- **File Extension**: `.vhd`
- **Line Length**: 120 characters
- **Indentation**: 2 spaces

## Naming Conventions

### Entities
- **Pattern**: `^[A-Z][A-Za-z0-9_]*$`
- **Examples**: `ProbeDriver`, `SigGen`, `ArithmeticUnit`
- **Invalid**: `probe_driver`, `siggen`
<!-- RULE:naming.entities.pattern=^[A-Z][A-Za-z0-9_]*$ -->

### Architectures
- **Allowed**: `rtl`, `behave`, `tb`
<!-- RULE:naming.architecture.allowed=rtl,behave,tb -->

### Signals
- **Pattern**: `^[a-z0-9_]+$`
<!-- RULE:naming.signal.pattern=^[a-z0-9_]+$ -->

### Constants
- **Pattern**: `^[A-Z0-9_]+$`
<!-- RULE:naming.constant.pattern=^[A-Z0-9_]+$ -->

## Clocking & Reset

- **Clock**: `clk`
- **Reset**: `rst_n` (active-low, synchronous)
- **Clock Enable**: `clk_en` (required)
<!-- RULE:clock.name=clk -->
<!-- RULE:reset.name=rst_n -->
<!-- RULE:reset.active_low=true -->
<!-- RULE:reset.synchronous=true -->
<!-- RULE:clk_enable.name=clk_en -->
<!-- RULE:clk_enable.required=true -->

## Required Packages

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
```
<!-- RULE:packages.required=ieee.std_logic_1164.all,ieee.numeric_std.all -->

## Forbidden Packages

- `std_logic_arith` — use `numeric_std` instead
- `std_logic_unsigned` — use `numeric_std` instead
<!-- RULE:packages.forbidden=std_logic_arith,std_logic_unsigned -->

## Testbench Magic Strings

- **Pass**: `ALL TESTS PASSED`
- **Done**: `SIMULATION DONE`
<!-- RULE:testbench.magic.pass=ALL TESTS PASSED -->
<!-- RULE:testbench.magic.done=SIMULATION DONE -->
