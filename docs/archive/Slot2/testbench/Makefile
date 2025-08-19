# Slot2/testbench/Makefile
# Makefile for running both ProbeDriver and Top module testbenches
# 
# UPDATED: Now uses MokuModules package to eliminate CustomWrapper duplication
# The MokuModules_pkg.vhd is included first to provide standardized component declarations

# GHDL compiler and flags
GHDL = ghdl
GHDL_FLAGS = --std=08 --ieee=synopsys

# Testbench files
TB_PROBE = ProbeDriver_tb.vhd
TB_TOP = top_probe_driver_tb.vhd
TB_SIMPLE = simple_top_tb.vhd
TB_MINIMAL = minimal_test.vhd
TB_DEBUG = debug_test.vhd

# DUT files for ProbeDriver testbench
DUT_FILES_PROBE = ../IntensityLut.vhd ../ProbeConfig.vhd ../ProbeDriver.vhd

# DUT files for Top module testbench (includes MokuModules package and other dependencies)
DUT_FILES_TOP = ../../MokuModules/MokuModules_pkg.vhd ../IntensityLut.vhd ../ProbeConfig.vhd ../ProbeDriver.vhd ../CustomWrapper.vhd ../top_probe_driver.vhd

# Default target
all: test_probe test_top test_simple test_minimal test_debug

# =============================================================================
# PROBE DRIVER TESTBENCH TARGETS
# =============================================================================

# Compile and run ProbeDriver testbench
test_probe: compile_probe run_probe

# Compile ProbeDriver testbench files
compile_probe:
	@echo "========================================"
	@echo "Compiling ProbeDriver testbench..."
	@echo "========================================"
	@echo "Compiling DUT files..."
	$(GHDL) -a $(GHDL_FLAGS) $(DUT_FILES_PROBE)
	@echo "Compiling testbench..."
	$(GHDL) -a $(GHDL_FLAGS) $(TB_PROBE)
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) ProbeDriver_tb

# Run ProbeDriver testbench
run_probe: compile_probe
	@echo "========================================"
	@echo "Running ProbeDriver testbench..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) ProbeDriver_tb --stop-time=1000ns --vcd=ProbeDriver_tb.vcd

# =============================================================================
# TOP MODULE TESTBENCH TARGETS
# =============================================================================

# Compile and run Top module testbench
test_top: compile_top run_top

# Compile Top module testbench files
compile_top:
	@echo "========================================"
	@echo "Compiling Top module testbench..."
	@echo "========================================"
	@echo "Compiling DUT files..."
	$(GHDL) -a $(GHDL_FLAGS) $(DUT_FILES_TOP)
	@echo "Compiling testbench..."
	$(GHDL) -a $(GHDL_FLAGS) $(TB_TOP)
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) top_probe_driver_tb

# Run Top module testbench
run_top: compile_top
	@echo "========================================"
	@echo "Running Top module testbench..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) top_probe_driver_tb --stop-time=2000ns --vcd=top_probe_driver_tb.vcd

# =============================================================================
# SIMPLE TOP MODULE TESTBENCH TARGETS
# =============================================================================

# Compile and run simple Top module testbench
test_simple: compile_simple run_simple

# Compile simple Top module testbench files
compile_simple:
	@echo "========================================"
	@echo "Compiling Simple Top module testbench..."
	@echo "========================================"
	@echo "Compiling DUT files..."
	$(GHDL) -a $(GHDL_FLAGS) $(DUT_FILES_TOP)
	@echo "Compiling testbench..."
	$(GHDL) -a $(GHDL_FLAGS) $(TB_SIMPLE)
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) simple_top_tb

# Run simple Top module testbench
run_simple: compile_simple
	@echo "========================================"
	@echo "Running Simple Top module testbench..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) simple_top_tb --stop-time=1000ns --vcd=simple_top_tb.vcd

# =============================================================================
# MINIMAL TESTBENCH TARGETS
# =============================================================================

# Compile and run minimal testbench
test_minimal: compile_minimal run_minimal

# Compile minimal testbench files
compile_minimal:
	@echo "========================================"
	@echo "Compiling Minimal testbench..."
	@echo "========================================"
	@echo "Compiling DUT files..."
	$(GHDL) -a $(GHDL_FLAGS) $(DUT_FILES_TOP)
	@echo "Compiling testbench..."
	$(GHDL) -a $(GHDL_FLAGS) $(TB_MINIMAL)
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) minimal_test

# Run minimal testbench
run_minimal: compile_minimal
	@echo "========================================"
	@echo "Running Minimal testbench..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) minimal_test --stop-time=1000ns --vcd=minimal_test.vcd

# =============================================================================
# DEBUG TESTBENCH TARGETS
# =============================================================================

# Compile and run debug testbench
test_debug: compile_debug run_debug

# Compile debug testbench files
compile_debug:
	@echo "========================================"
	@echo "Compiling Debug testbench..."
	@echo "========================================"
	@echo "Compiling DUT files..."
	$(GHDL) -a $(GHDL_FLAGS) $(DUT_FILES_TOP)
	@echo "Compiling testbench..."
	$(GHDL) -a $(GHDL_FLAGS) $(TB_DEBUG)
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) debug_test

# Run debug testbench
run_debug: compile_debug
	@echo "========================================"
	@echo "Running Debug testbench..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) debug_test --stop-time=1500ns --vcd=debug_test.vcd

# =============================================================================
# UTILITY TARGETS
# =============================================================================

# Clean generated files
clean:
	@echo "Cleaning up..."
	rm -f *.o *.cf *.vcd
	rm -f work-obj08.cf
	@echo "Clean complete"

# Show help
help:
	@echo "Available targets:"
	@echo ""
	@echo "ProbeDriver Testbench:"
	@echo "  test_probe     - Compile and run ProbeDriver testbench"
	@echo "  compile_probe  - Compile ProbeDriver testbench files"
	@echo "  run_probe      - Run ProbeDriver testbench"
	@echo ""
		@echo "Top Module Testbench:"
	@echo "  test_top       - Compile and run Top module testbench"
	@echo "  compile_top    - Compile Top module testbench files"
	@echo "  run_top        - Run Top module testbench"
	@echo ""
	@echo "Simple Top Module Testbench:"
	@echo "  test_simple    - Compile and run Simple Top module testbench"
	@echo "  compile_simple - Compile Simple Top module testbench files"
	@echo "  run_simple     - Run Simple Top module testbench"
	@echo ""
	@echo "Utility:"
	@echo "  all            - Run all testbenches"
	@echo "  clean          - Remove generated files"
	@echo "  help           - Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make test_probe    # Test ProbeDriver module"
	@echo "  make test_top      # Test Top module integration"
	@echo "  make test_simple   # Test Top module (simple version)"
	@echo "  make all           # Run all testbenches"

.PHONY: all test_probe compile_probe run_probe test_top compile_top run_top test_simple compile_simple run_simple clean help
