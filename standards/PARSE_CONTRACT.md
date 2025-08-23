# Markdown Rules Parsing Contract (v1)

This document defines how our tools extract **machine-readable** rules from human-friendly Markdown,
without committing to YAML or JSON.

## Extraction Principles

1. **HTML RULE comments are authoritative.**
   - Any HTML comment of the form:
     `<!-- RULE:<path>=<value> -->`
     is parsed into a key path and value.
   - Example:
     `<!-- RULE:naming.entities.pattern=^[A-Z][A-Za-z0-9_]*$ -->`
     becomes:
     ```json
     { "naming": { "entities": { "pattern": "^[A-Z][A-Za-z0-9_]*$" } } }
     ```

2. **Comma lists are split** into arrays unless the value is quoted.
   - `<!-- RULE:packages.required=a,b,c -->` → `["a","b","c"]`
   - `<!-- RULE:note="a,b,c" -->` → `"a,b,c"`

3. **Booleans and integers** are coerced when obvious:
   - `true/false` → booleans
   - `120` → integer

4. **Everything else is a string** (no need for quoting).

5. **Markdown content remains for humans.**
   - Lists, code fences, and prose are not required to be parsed, but SHOULD reflect the RULE values.

## Required RULE Keys

### In `vhdl_style.md`
- `version`
- `vhdl_standard`
- `file_extension`
- `line_length`
- `indent`
- `naming.entities.pattern`
- `naming.architecture.allowed`
- `naming.signal.pattern`
- `naming.constant.pattern`
- `clock.name`
- `reset.name`
- `reset.active_low`
- `reset.synchronous`
- `clk_enable.name`
- `clk_enable.required`
- `packages.required`
- `packages.forbidden`
- `testbench.magic.pass`
- `testbench.magic.done`

### In `module_rules.md`
- `version`
- `dir_layout.src_files`
- `dir_layout.tb_files`
- `required_entities`
- `reset_policy.reference`
- `naming.module_name_case`
- `cross_refs.style`

## Example

```markdown
<!-- RULE:line_length=120 -->
<!-- RULE:packages.forbidden=std_logic_arith,std_logic_unsigned -->
```

## Parsing Notes

- Keys are **case-sensitive** and use `.` to indicate nesting.
- Duplicate keys: the **last occurrence wins**.
- Unknown keys are ignored (forward-compatible).
