# Makefile for jc-CustomWrapper-top-tb.vhd
# Simple GHDL workflow for users unfamiliar with GHDL
# 
# This Makefile demonstrates the basic GHDL workflow:
# 1. Analyze (compile) the design files
# 2. Elaborate (link) the testbench
# 3. Run the simulation
# 4. View waveforms (optional)

# GHDL command (adjust path if needed)
GHDL := ghdl

# Target testbench
TB := jc_CustomWrapper_top_tb

# Source files (in dependency order)
SOURCES := \
	../ProbeConfig.vhd \
	../IntensityLut.vhd \
	../../clk-divider/clk_divider.vhd \
	../ProbeDriver.vhd \
	../CustomWrapper.vhd \
	../top_probe_driver.vhd \
	$(TB).vhd

# Default target
all: run

# Analyze all source files
analyze: $(SOURCES)
	@echo "=== Analyzing source files ==="
	$(GHDL) -a --std=08 --work=work ../ProbeConfig.vhd
	$(GHDL) -a --std=08 --work=work ../IntensityLut.vhd
	$(GHDL) -a --std=08 --work=work ../../clk-divider/clk_divider.vhd
	$(GHDL) -a --std=08 --work=work ../ProbeDriver.vhd
	$(GHDL) -a --std=08 --work=work ../CustomWrapper.vhd
	$(GHDL) -a --std=08 --work=work ../top_probe_driver.vhd
	$(GHDL) -a --std=08 --work=work $(TB).vhd
	@echo "=== Analysis complete ==="

# Elaborate the testbench
elaborate: analyze
	@echo "=== Elaborating testbench ==="
	$(GHDL) -e --std=08 --work=work $(TB)
	@echo "=== Elaboration complete ==="

# Run the simulation
run: elaborate
	@echo "=== Running simulation ==="
	$(GHDL) -r --std=08 --work=work $(TB) --stop-time=100us --vcd=jc_CustomWrapper_top_tb.vcd
	@echo "=== Simulation complete ==="

# Run with waveform output (for GTKWave)
wave: run
	@echo "=== Opening waveform viewer ==="
	@echo "Note: Install GTKWave to view waveforms:"
	@echo "  macOS: brew install gtkwave"
	@echo "  Ubuntu: sudo apt-get install gtkwave"
	@echo "  Windows: Download from http://gtkwave.sourceforge.net/"
	@echo ""
	@echo "To view waveforms manually: gtkwave $(TB).vcd"

# Clean generated files
clean:
	@echo "=== Cleaning generated files ==="
	rm -f *.o *.cf $(TB) $(TB).vcd
	@echo "=== Clean complete ==="

# Help target
help:
	@echo "Available targets:"
	@echo "  analyze  - Compile all source files"
	@echo "  elaborate- Link the testbench"
	@echo "  run      - Run simulation (creates VCD file)"
	@echo "  wave     - Run simulation and open waveform viewer"
	@echo "  clean    - Remove generated files"
	@echo "  help     - Show this help message"
	@echo ""
	@echo "Typical workflow: make run"
	@echo "For waveforms: make wave"

# Phony targets
.PHONY: all analyze elaborate run wave clean help
