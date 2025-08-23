MODULES := $(shell find . -maxdepth 1 -type d -not -path '*/\.*' -not -path '.')

.PHONY: lint build sim standards
lint:
	for m in $(MODULES); do [ -f $$m/Makefile ] && $(MAKE) -C $$m lint || true; done

build:
	for m in $(MODULES); do [ -f $$m/Makefile ] && $(MAKE) -C $$m build || true; done

sim:
	for m in $(MODULES); do [ -f $$m/Makefile ] && $(MAKE) -C $$m sim || true; done

standards:
	@echo "=== VHDL Standards ==="
	@echo "Module Rules: standards/module_rules.md (or .yaml/.json)"
	@echo "Style Guide: standards/vhdl_style.md (or .yaml/.json)"
	@echo "Format Comparison: standards/format_comparison.md"
