GHDL ?= ghdl
STD  ?= 08

SRC = \  ../common/clock_divider.vhd \  common/*.vhd \  core/*.vhd \  wrapper/*.vhd \  ../MokuModules/CustomWrapper.vhd \  ProbeDriver.vhd

.PHONY: lint build sim clean

lint:
	$(GHDL) -s --std=$(STD) $(SRC)

build: lint
	$(GHDL) -a --std=$(STD) $(SRC)

sim: build
	@if ls tb_*.vhd >/dev/null 2>&1; then \
		$(GHDL) -a --std=$(STD) tb_*.vhd && \
		name=$$(basename $$(ls tb_*.vhd | head -n1) .vhd); \
		$(GHDL) -e --std=$(STD) $$name && ./$$name | tee sim.log && \
		grep -q "ALL TESTS PASSED" sim.log; \
	else \
		echo "No testbench found; skipping."; \
	fi

clean:
	rm -f *.o *.cf work-obj*.cf sim.log tb_* core/*.o common/*.o wrapper/*.o
