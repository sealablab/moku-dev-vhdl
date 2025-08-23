# moku-dev-vhdl/Makefile
# Simple aggregator — no style/lint rules, just delegate to modules.

MODULES := $(shell find . -maxdepth 1 -type d -not -path '*/.*' -not -path '.')

.PHONY: all lint build sim clean

all: build

lint:
	@for m in $(MODULES); do \
	  [ -f $$m/Makefile ] && $(MAKE) -C $$m lint || true; \
	done

build:
	@for m in $(MODULES); do \
	  [ -f $$m/Makefile ] && $(MAKE) -C $$m build || true; \
	done

sim:
	@for m in $(MODULES); do \
	  [ -f $$m/Makefile ] && $(MAKE) -C $$m sim || true; \
	done

clean:
	@for m in $(MODULES); do \
	  [ -f $$m/Makefile ] && $(MAKE) -C $$m clean || true; \
	done
