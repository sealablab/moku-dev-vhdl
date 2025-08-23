# Module Rules v1

<!-- RULE:version=1 -->

## Directory Layout

### Source Files
Every module must contain these files:
- `{Name}.vhd` — Main wrapper/interface
- `{Name}_Regs.vhd` — Register definitions package
- `{Name}_Core.vhd` — Core logic implementation
<!-- RULE:dir_layout.src_files={Name}.vhd,{Name}_Regs.vhd,{Name}_Core.vhd -->

### Testbench Files
- `tb_{Name}.vhd` — Module testbench
<!-- RULE:dir_layout.tb_files=tb_{Name}.vhd -->

## Required Entities
- `{Name}_Core` — Core entity must be implemented
<!-- RULE:required_entities={Name}_Core -->

## Reset Policy
Reference: `standards/vhdl_style.md#clocking--reset`
<!-- RULE:reset_policy.reference=standards/vhdl_style.md#clocking--reset -->

## Naming Conventions
- **Module Name Case**: PascalCase
- **Examples**: `ProbeDriver`, `SigGen`, `ArithmeticUnit`
<!-- RULE:naming.module_name_case=PascalCase -->

## Cross-References
- Style Guide: `standards/vhdl_style.md`
<!-- RULE:cross_refs.style=vhdl_style.md -->
