# Makefile for ProbeDriver Integration Testing
# Supports both individual component tests and comprehensive integration tests
# 
# This Makefile demonstrates the GHDL workflow for our modular architecture:
# 1. Analyze (compile) the design files in dependency order
# 2. Elaborate (link) the testbench
# 3. Run the simulation
# 4. View waveforms (optional)

# GHDL command (adjust path if needed)
GHDL := ghdl

# Target testbenches
CORE_TB := probe_driver_core_tb
WRAPPER_TB := probe_driver_wrapper_tb
INTEGRATION_TB := comprehensive_top_level_tb

# Source files (in dependency order for modular architecture)
SOURCES := \
	../common/probe_driver_pkg.vhd \
	../core/probe_driver_core.vhd \
	../wrapper/probe_driver_wrapper.vhd \
	../ProbeConfig.vhd \
	../IntensityLut.vhd \
	../../clk-divider/clk_divider.vhd \
	../ProbeDriver.vhd \
	../CustomWrapper.vhd \
	../top_probe_driver.vhd

# Default target
all: integration_test

# =============================================================================
# INDIVIDUAL COMPONENT TESTS
# =============================================================================

# Test core component only
core_test: analyze_core elaborate_core run_core

analyze_core: ../common/probe_driver_pkg.vhd ../core/probe_driver_core.vhd
	@echo "=== Analyzing core component files ==="
	$(GHDL) -a --std=08 --work=work ../common/probe_driver_pkg.vhd
	$(GHDL) -a --std=08 --work=work ../core/probe_driver_core.vhd
	$(GHDL) -a --std=08 --work=work $(CORE_TB).vhd
	@echo "=== Core analysis complete ==="

elaborate_core: analyze_core
	@echo "=== Elaborating core testbench ==="
	$(GHDL) -e --std=08 --work=work $(CORE_TB)
	@echo "=== Core elaboration complete ==="

run_core: elaborate_core
	@echo "=== Running core component test ==="
	$(GHDL) -r --std=08 --work=work $(CORE_TB) --stop-time=10us --vcd=core_test.vcd
	@echo "=== Core test complete ==="

# Test wrapper component only
wrapper_test: analyze_wrapper elaborate_wrapper run_wrapper

analyze_wrapper: ../common/probe_driver_pkg.vhd ../core/probe_driver_core.vhd ../wrapper/probe_driver_wrapper.vhd ../../clk-divider/clk_divider.vhd
	@echo "=== Analyzing wrapper component files ==="
	$(GHDL) -a --std=08 --work=work ../common/probe_driver_pkg.vhd
	$(GHDL) -a --std=08 --work=work ../core/probe_driver_core.vhd
	$(GHDL) -a --std=08 --work=work ../../clk-divider/clk_divider.vhd
	$(GHDL) -a --std=08 --work=work ../wrapper/probe_driver_wrapper.vhd
	$(GHDL) -a --std=08 --work=work $(WRAPPER_TB).vhd
	@echo "=== Wrapper analysis complete ==="

elaborate_wrapper: analyze_wrapper
	@echo "=== Elaborating wrapper testbench ==="
	$(GHDL) -e --std=08 --work=work $(WRAPPER_TB)
	@echo "=== Wrapper elaboration complete ==="

run_wrapper: elaborate_wrapper
	@echo "=== Running wrapper component test ==="
	$(GHDL) -r --std=08 --work=work $(WRAPPER_TB) --stop-time=10us --vcd=wrapper_test.vcd
	@echo "=== Wrapper test complete ==="

# =============================================================================
# COMPREHENSIVE INTEGRATION TEST
# =============================================================================

# Full system integration test
integration_test: analyze_integration elaborate_integration run_integration

analyze_integration: $(SOURCES)
	@echo "=== Analyzing all integration test files ==="
	$(GHDL) -a --std=08 --work=work ../common/probe_driver_pkg.vhd
	$(GHDL) -a --std=08 --work=work ../core/probe_driver_core.vhd
	$(GHDL) -a --std=08 --work=work ../wrapper/probe_driver_wrapper.vhd
	$(GHDL) -a --std=08 --work=work ../ProbeConfig.vhd
	$(GHDL) -a --std=08 --work=work ../IntensityLut.vhd
	$(GHDL) -a --std=08 --work=work ../../clk-divider/clk_divider.vhd
	$(GHDL) -a --std=08 --work=work ../ProbeDriver.vhd
	$(GHDL) -a --std=08 --work=work ../CustomWrapper.vhd
	$(GHDL) -a --std=08 --work=work ../top_probe_driver.vhd
	$(GHDL) -a --std=08 --work=work $(INTEGRATION_TB).vhd
	@echo "=== Integration analysis complete ==="

elaborate_integration: analyze_integration
	@echo "=== Elaborating integration testbench ==="
	$(GHDL) -e --std=08 --work=work $(INTEGRATION_TB)
	@echo "=== Integration elaboration complete ==="

run_integration: elaborate_integration
	@echo "=== Running comprehensive integration test ==="
	$(GHDL) -r --std=08 --work=work $(INTEGRATION_TB) --stop-time=100us --vcd=integration_test.vcd
	@echo "=== Integration test complete ==="

# =============================================================================
# WAVEFORM VIEWING
# =============================================================================

# View waveforms for integration test
wave: run_integration
	@echo "=== Opening waveform viewer for integration test ==="
	@echo "Note: Install GTKWave to view waveforms:"
	@echo "  macOS: brew install gtkwave"
	@echo "  Ubuntu: sudo apt-get install gtkwave"
	@echo "  Windows: Download from http://gtkwave.sourceforge.net/"
	@echo ""
	@echo "To view waveforms manually: gtkwave integration_test.vcd"

# =============================================================================
# UTILITY TARGETS
# =============================================================================

# Clean generated files
clean:
	@echo "=== Cleaning generated files ==="
	rm -f *.o *.cf *_test *_test.vcd
	@echo "Clean complete"

# Help target
help:
	@echo "Available targets:"
	@echo ""
	@echo "INDIVIDUAL COMPONENT TESTS:"
	@echo "  core_test     - Test core component only"
	@echo "  wrapper_test  - Test wrapper component only"
	@echo ""
	@echo "INTEGRATION TESTS:"
	@echo "  integration_test - Full system integration test"
	@echo "  wave            - Run integration test and show waveform info"
	@echo ""
	@echo "UTILITY:"
	@echo "  clean          - Remove generated files"
	@echo "  help           - Show this help message"
	@echo ""
	@echo "Typical workflow for Iteration 2: make integration_test"
	@echo "For waveforms: make wave"

# Phony targets
.PHONY: all core_test wrapper_test integration_test wave clean help
.PHONY: analyze_core elaborate_core run_core
.PHONY: analyze_wrapper elaborate_wrapper run_wrapper
.PHONY: analyze_integration elaborate_integration run_integration
