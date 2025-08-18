# ProbeDriver Testbench Makefile - Clean Implementation
# Build system for the new, focused testbench approach

# GHDL compiler and flags
GHDL = ghdl
GHDL_FLAGS = --std=08 --ieee=synopsys

# Testbench files
TB_UNIT = probe_driver_tb.vhd
TB_INTEGRATION = top_probe_driver_tb.vhd
TB_CUSTOMWRAPPER_TOP = CustomWrapper-top-tb.vhd

# DUT files for unit test (ProbeDriver only)
DUT_FILES_UNIT = ../IntensityLut.vhd ../ProbeConfig.vhd ../ProbeDriver.vhd

# DUT files for integration test (complete top-level)
DUT_FILES_INTEGRATION = ../IntensityLut.vhd ../ProbeConfig.vhd ../ProbeDriver.vhd ../CustomWrapper.vhd ../top_probe_driver.vhd

# Default target
all: test_all

# =============================================================================
# UNIT TEST TARGETS
# =============================================================================

# Compile and run unit test
test_unit: compile_unit run_unit

# Compile unit test files
compile_unit:
	@echo "========================================"
	@echo "Compiling ProbeDriver Unit Test..."
	@echo "========================================"
	@echo "Compiling DUT files..."
	$(GHDL) -a $(GHDL_FLAGS) $(DUT_FILES_UNIT)
	@echo "Compiling testbench..."
	$(GHDL) -a $(GHDL_FLAGS) $(TB_UNIT)
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) probe_driver_tb

# Run unit test
run_unit: compile_unit
	@echo "========================================"
	@echo "Running ProbeDriver Unit Test..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) probe_driver_tb --stop-time=2000ns --vcd=unit_test.vcd

# =============================================================================
# INTEGRATION TEST TARGETS
# =============================================================================

# Compile and run integration test
test_integration: compile_integration run_integration

# Compile integration test files
compile_integration:
	@echo "========================================"
	@echo "Compiling Top-Level Integration Test..."
	@echo "========================================"
	@echo "Compiling DUT files..."
	$(GHDL) -a $(GHDL_FLAGS) $(DUT_FILES_INTEGRATION)
	@echo "Compiling testbench..."
	$(GHDL) -a $(GHDL_FLAGS) $(TB_INTEGRATION)
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) top_probe_driver_tb

# Run integration test
run_integration: compile_integration
	@echo "========================================"
	@echo "Running Top-Level Integration Test..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) top_probe_driver_tb --stop-time=3000ns --vcd=integration_test.vcd

# =============================================================================
# CUSTOMWRAPPER TOP TESTBENCH TARGETS
# =============================================================================

# Compile and run CustomWrapper top testbench
test_customwrapper_top: compile_customwrapper_top run_customwrapper_top

# Compile CustomWrapper top testbench files
compile_customwrapper_top:
	@echo "========================================"
	@echo "Compiling CustomWrapper Top Testbench..."
	@echo "========================================"
	@echo "Compiling DUT files..."
	$(GHDL) -a $(GHDL_FLAGS) $(DUT_FILES_INTEGRATION)
	@echo "Compiling testbench..."
	$(GHDL) -a $(GHDL_FLAGS) $(TB_CUSTOMWRAPPER_TOP)
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) CustomWrapper_top_tb

# Run CustomWrapper top testbench
run_customwrapper_top: compile_customwrapper_top
	@echo "========================================"
	@echo "Running CustomWrapper Top Testbench..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) CustomWrapper_top_tb --stop-time=15000ns --vcd=customwrapper_top.vcd

# =============================================================================
# COMBINED TARGETS
# =============================================================================

# Run all tests
test_all: test_unit test_integration test_customwrapper_top
	@echo "========================================"
	@echo "All tests completed!"
	@echo "========================================"

# =============================================================================
# UTILITY TARGETS
# =============================================================================

# Clean up generated files
clean:
	@echo "Cleaning up..."
	rm -f *.o *.cf work-obj93.cf work-obj08.cf *.vcd
	@echo "Clean complete"

# Show help
help:
	@echo "Available targets:"
	@echo "  all                    - Run all tests (default)"
	@echo "  test_unit              - Run unit tests only"
	@echo "  test_integration       - Run integration tests only"
	@echo "  test_customwrapper_top - Run CustomWrapper top testbench only"
	@echo "  test_all               - Run all tests"
	@echo "  clean                  - Remove generated files"
	@echo "  help                   - Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make                        # Run all tests"
	@echo "  make test_unit              # Run unit tests only"
	@echo "  make test_integration       # Run integration tests only"
	@echo "  make test_customwrapper_top # Run CustomWrapper top testbench only"
	@echo "  make clean                 # Clean up"

# Phony targets
.PHONY: all test_unit test_integration test_customwrapper_top test_all clean help compile_unit run_unit compile_integration run_integration compile_customwrapper_top run_customwrapper_top
