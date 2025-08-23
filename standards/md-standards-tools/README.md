# Markdown RULE Tools

This folder contains tiny helpers to parse hidden RULE tags inside Markdown and surface them to your build:
- `tools/parse_rules.py` — extracts `<!-- RULE:path=value -->` comments and prints JSON
- `tools/emit_make_vars.py` — converts those rules into a `standards.mk` include (Make variables)
- `tools/lint_headers.sh` — checks VHDL files for required `use` lines and forbidden packages based on `standards.mk`
- `tools/md_rules_to_yaml.py` — optional: convert Markdown RULEs into a YAML file

## RULE Tag Format

Inside your `standards/*.md` files, place comments like:

```
<!-- RULE:testbench.magic.pass=ALL TESTS PASSED -->
<!-- RULE:testbench.magic.done=SIMULATION DONE -->
<!-- RULE:packages.required=ieee.std_logic_1164.all,ieee.numeric_std.all -->
<!-- RULE:forbidden=std_logic_arith,std_logic_unsigned -->
<!-- RULE:clock.reset.name=rst_n -->
<!-- RULE:clock.reset.active_low=true -->
```

- Paths are dot-separated and produce nested keys.
- Values are auto-typed: `true/false` → booleans, integers/floats parsed, comma lists → arrays, otherwise strings.

## Wiring into Make

1) Copy `tools/` to your repo (e.g., at the meta root).
2) Add a generator rule like this (see `examples/Makefile.fragment`):

```
standards.mk: moku-dev-vhdl/standards/vhdl_style.md moku-dev-vhdl/standards/module_rules.md tools/emit_make_vars.py tools/parse_rules.py
	$(TOOLS_DIR)/emit_make_vars.py $^ > $@
```

3) Include `standards.mk` where needed, e.g., top-level Makefile or module Makefiles:

```
-include standards.mk
```

4) Run style checks:

```
make standards.mk
tools/lint_headers.sh standards.mk "moku-dev-vhdl/**/*.vhd"
```

This keeps humans writing Markdown, while letting machines enforce and consume rules.
