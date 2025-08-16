# Slot2/testbench/Makefile
# Simple Makefile for running ProbeDriver testbench

# GHDL compiler and flags
GHDL = ghdl
GHDL_FLAGS = --std=08 --ieee=synopsys

# Testbench file
TB_FILE = ProbeDriver_tb.vhd

# DUT files (need to be compiled first)
DUT_FILES = ../IntensityLut.vhd ../ProbeConfig.vhd ../ProbeDriver.vhd

# Target for running the testbench
all: compile run

# Compile all files
compile:
	@echo "Compiling DUT files..."
	$(GHDL) -a $(GHDL_FLAGS) $(DUT_FILES)
	@echo "Compiling testbench..."
	$(GHDL) -a $(GHDL_FLAGS) $(TB_FILE)
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) ProbeDriver_tb

# Run the testbench
run: compile
	@echo "Running testbench..."
	$(GHDL) -r $(GHDL_FLAGS) ProbeDriver_tb --stop-time=1000ns --vcd=ProbeDriver_tb.vcd

# Clean generated files
clean:
	rm -f *.o *.cf *.vcd
	rm -f work-obj08.cf

# Show help
help:
	@echo "Available targets:"
	@echo "  compile  - Compile all VHDL files"
	@echo "  run      - Compile and run testbench"
	@echo "  clean    - Remove generated files"
	@echo "  help     - Show this help message"

.PHONY: all compile run clean help
