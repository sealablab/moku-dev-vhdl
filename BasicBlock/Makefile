# <Module>/Makefile
# Minimal GHDL Makefile for a single module
# Usage:
#   make lint   # syntax check only
#   make build  # compile all sources
#   make sim    # compile & run testbench (if tb_*.vhd exists)
#   make clean  # remove generated files

GHDL ?= ghdl
STD  ?= 08

SRC = \
  ../common/*.vhd \
  common/*.vhd \
  core/*.vhd \
  wrapper/*.vhd \
  ../MokuModules/CustomWrapper.vhd \
  $(notdir $(CURDIR)).vhd

.PHONY: lint build sim clean

lint:
	$(GHDL) -s --std=$(STD) $(SRC)

build: lint
	$(GHDL) -a --std=$(STD) $(SRC)

sim: build
	@if ls tb_*.vhd >/dev/null 2>&1; then \
	  $(GHDL) -a --std=$(STD) tb_*.vhd && \
	  tb=$$(basename $$(ls tb_*.vhd | head -n1) .vhd); \
	  $(GHDL) -e --std=$(STD) $$tb && ./$$tb | tee sim.log; \
	else \
	  echo "No testbench found; skipping."; \
	fi

clean:
	rm -f *.o *.cf work-obj*.cf sim.log tb_* core/*.o common/*.o wrapper/*.o
