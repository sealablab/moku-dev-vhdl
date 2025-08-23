# Module Rules v1

## Directory Layout

### Source Files
Every module must contain these files:
- `{Name}.vhd` - Main wrapper/interface
- `{Name}_Regs.vhd` - Register definitions package
- `{Name}_Core.vhd` - Core logic implementation

### Testbench Files
- `tb_{Name}.vhd` - Module testbench

## Required Entities
- `{Name}_Core` - Core entity must be implemented

## Reset Policy
Reference: `standards/vhdl_style.md#reset`

## Naming Conventions
- **Module Name Case**: PascalCase
- **Examples**: `ProbeDriver`, `SigGen`, `ArithmeticUnit`

## Cross-References
- Style Guide: `standards/vhdl_style.md`
