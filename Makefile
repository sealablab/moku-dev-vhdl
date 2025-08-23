MODULES := $$(shell find . -maxdepth 1 -type d -not -path "*/\.*" -not -path ".")

.PHONY: lint build sim standards
lint:
	for m in $$(MODULES); do [ -f $$m/Makefile ] && $$(MAKE) -C $$m lint || true; done

build:
	for m in $$(MODULES); do [ -f $$m/Makefile ] && $$(MAKE) -C $$m build || true; done

sim:
	for m in $$(MODULES); do [ -f $$m/Makefile ] && $$(MAKE) -C $$m sim || true; done

standards:
	@echo "=== VHDL Standards (New Hybrid Approach) ==="
	@echo "Module Rules: standards/module_rules.md"
	@echo "Style Guide: standards/vhdl_style.md"
	@echo "Parse Contract: standards/PARSE_CONTRACT.md"
	@echo ""
	@echo "=== Old Standards (Deprecated) ==="
	@echo "Moved to: .to_be_removed/standards/"
	@echo "See: .to_be_removed/README.md for details"
