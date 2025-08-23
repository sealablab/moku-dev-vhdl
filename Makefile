MODULES := $(shell find . -maxdepth 1 -type d -not -path '*/\.*' -not -path '.')

.PHONY: lint build sim
lint:
	for m in $(MODULES); do [ -f $$m/Makefile ] && $(MAKE) -C $$m lint || true; done

build:
	for m in $(MODULES); do [ -f $$m/Makefile ] && $(MAKE) -C $$m build || true; done

sim:
	for m in $(MODULES); do [ -f $$m/Makefile ] && $(MAKE) -C $$m sim || true; done
