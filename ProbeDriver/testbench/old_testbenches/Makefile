# Slot2/testbench/Makefile
# Makefile for running both ProbeDriver and Top module testbenches

# GHDL compiler and flags
GHDL = ghdl
GHDL_FLAGS = --std=08 --ieee=synopsys

# Testbench files
TB_PROBE = ProbeDriver_tb.vhd
TB_TOP = top_probe_driver_tb.vhd
TB_SIMPLE = simple_top_tb.vhd
TB_MINIMAL = minimal_test.vhd
TB_DEBUG = debug_test.vhd
TB_TOP_STATUS = top_status_tb.vhd
TB_VALIDATION = ProbeDriverValidation_simple.vhd
TB_ZEROINIT = zeroinit_test.vhd

# DUT files for ProbeDriver testbench
DUT_FILES_PROBE = ../IntensityLut.vhd ../ProbeConfig.vhd ../ProbeDriver.vhd

# DUT files for Top module testbench (includes CustomWrapper and top_probe_driver)
DUT_FILES_TOP = ../IntensityLut.vhd ../ProbeConfig.vhd ../ProbeDriver.vhd ../CustomWrapper.vhd ../top_probe_driver.vhd

# Default target
all: test_probe test_top test_simple test_minimal test_debug test_top_status test_validation test_zeroinit

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
# TOP STATUS TESTBENCH TARGETS
# =============================================================================

# Compile and run Top Status testbench
test_top_status: compile_top_status run_top_status

# Compile Top Status testbench files
compile_top_status:
	@echo "========================================"
	@echo "Compiling Top Status testbench..."
	@echo "========================================"
	@echo "Compiling DUT files..."
	$(GHDL) -a $(GHDL_FLAGS) $(DUT_FILES_TOP)
	@echo "Compiling testbench..."
	$(GHDL) -a $(GHDL_FLAGS) $(TB_TOP_STATUS)
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) top_status_tb

# Run Top Status testbench
run_top_status: compile_top_status
	@echo "========================================"
	@echo "Running Top Status testbench..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) top_status_tb --stop-time=3000ns --vcd=top_status_tb.vcd

# =============================================================================
# VALIDATION TESTBENCH TARGETS
# =============================================================================

# Compile and run Validation testbench
test_validation: compile_validation run_validation

# Compile Validation testbench files
compile_validation:
	@echo "========================================"
	@echo "Compiling Validation testbench..."
	@echo "========================================"
	@echo "Compiling DUT files..."
	$(GHDL) -a $(GHDL_FLAGS) $(DUT_FILES_PROBE)
	@echo "Compiling testbench..."
	$(GHDL) -a $(GHDL_FLAGS) $(TB_VALIDATION)
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) ProbeDriverValidation_simple

# Run Validation testbench
run_validation: compile_validation
	@echo "========================================"
	@echo "Running Validation testbench..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) ProbeDriverValidation_simple --vcd=ProbeDriverValidation_simple.vcd

# =============================================================================
# ZEROINIT TESTBENCH TARGETS
# =============================================================================

# Compile and run ZeroInit testbench
test_zeroinit: compile_zeroinit run_zeroinit

# Compile ZeroInit testbench files
compile_zeroinit:
	@echo "========================================"
	@echo "Compiling ZeroInit testbench..."
	@echo "========================================"
	@echo "Compiling DUT files..."
	$(GHDL) -a $(GHDL_FLAGS) $(DUT_FILES_PROBE)
	@echo "Compiling testbench..."
	$(GHDL) -a $(GHDL_FLAGS) $(TB_ZEROINIT)
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) zeroinit_test

# Run ZeroInit testbench
run_zeroinit: compile_zeroinit
	@echo "========================================"
	@echo "Running ZeroInit testbench..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) zeroinit_test --vcd=zeroinit_test.vcd

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
	@echo "Top Status Testbench:"
	@echo "  test_top_status    - Compile and run Top Status testbench"
	@echo "  compile_top_status - Compile Top Status testbench files"
	@echo "  run_top_status     - Run Top Status testbench"
	@echo ""
	@echo "Validation Testbench:"
	@echo "  test_validation    - Compile and run Validation testbench"
	@echo "  compile_validation - Compile Validation testbench files"
	@echo "  run_validation     - Run Validation testbench"
	@echo ""
	@echo "ZeroInit Testbench:"
	@echo "  test_zeroinit      - Compile and run ZeroInit testbench"
	@echo "  compile_zeroinit   - Compile ZeroInit testbench files"
	@echo "  run_zeroinit       - Run ZeroInit testbench"
	@echo ""
	@echo "Utility:"
	@echo "  all            - Run all testbenches"
	@echo "  clean          - Remove generated files"
	@echo "  help           - Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make test_probe       # Test ProbeDriver module"
	@echo "  make test_top         # Test Top module integration"
	@echo "  make test_simple      # Test Top module (simple version)"
	@echo "  make test_top_status  # Test TopLevel status register"
	@echo "  make test_validation  # Test parameter validation and edge conditions"
	@echo "  make test_zeroinit    # Test automatic state machine execution on reset"
	@echo "  make all              # Run all testbenches"

.PHONY: all test_probe compile_probe run_probe test_top compile_top run_top test_simple compile_simple run_simple test_top_status compile_top_status run_top_status test_validation compile_validation run_validation test_zeroinit compile_zeroinit run_zeroinit clean help
