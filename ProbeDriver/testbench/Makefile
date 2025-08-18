# ProbeDriver Testbench Makefile - Clean Implementation
# Build system for the new, focused testbench approach

# GHDL compiler and flags
GHDL = ghdl
GHDL_FLAGS = --std=08 --ieee=synopsys

# Testbench files
TB_UNIT = probe_driver_tb.vhd
TB_INTEGRATION = top_probe_driver_tb.vhd
TB_CUSTOM_DEBUG = custom_top_debug_tb.vhd

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
# CUSTOM DEBUG TEST TARGETS
# =============================================================================

# Compile and run custom debug test
test_custom_debug: compile_custom_debug run_custom_debug

# Compile custom debug test files
compile_custom_debug:
	@echo "========================================"
	@echo "Compiling CustomWrapper Debug Test..."
	@echo "========================================"
	@echo "Compiling DUT files..."
	$(GHDL) -a $(GHDL_FLAGS) $(DUT_FILES_INTEGRATION)
	@echo "Compiling testbench..."
	$(GHDL) -a $(GHDL_FLAGS) $(TB_CUSTOM_DEBUG)
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) custom_top_debug_tb

# Run custom debug test
run_custom_debug: compile_custom_debug
	@echo "========================================"
	@echo "Running CustomWrapper Debug Test..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) custom_top_debug_tb --stop-time=10000ns --vcd=custom_debug.vcd

# =============================================================================
# COMBINED TARGETS
# =============================================================================

# Run all tests
test_all: test_unit test_integration test_custom_debug
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
	@echo "  all              - Run all tests (default)"
	@echo "  test_unit        - Run unit tests only"
	@echo "  test_integration - Run integration tests only"
	@echo "  test_custom_debug - Run custom debug test only"
	@echo "  test_all         - Run all tests"
	@echo "  clean            - Remove generated files"
	@echo "  help             - Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make                    # Run all tests"
	@echo "  make test_unit          # Run unit tests only"
	@echo "  make test_integration   # Run integration tests only"
	@echo "  make test_custom_debug  # Run custom debug test only"
	@echo "  make clean             # Clean up"

# Phony targets
.PHONY: all test_unit test_integration test_custom_debug test_all clean help compile_unit run_unit compile_integration run_integration compile_custom_debug run_custom_debug
