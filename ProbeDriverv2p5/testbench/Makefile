# Makefile for ProbeDriver Testbench Template System
# Clean, focused build system for the new reusable testbench architecture
#
# Date: 2025-01-27
# Tag: Makefile-Template-System-v1.0

# =============================================================================
# CONFIGURATION
# =============================================================================

# GHDL command
GHDL := ghdl

# Testbench naming convention: {module}_{layer}_{purpose}_tb
MODULE := probe_driver
LAYERS := core wrapper top_level
PURPOSES := basic comprehensive stress demo integration

# Target testbenches (auto-generated from naming convention)
CORE_TB := $(MODULE)_core_basic_tb
WRAPPER_TB := $(MODULE)_wrapper_integration_tb
TOP_LEVEL_TB := $(MODULE)_top_level_comprehensive_tb

# Source files (in dependency order)
SOURCES := \
	../../common/clock_divider.vhd \
	../common/intensity_lut_pkg.vhd \
	../common/probe_driver_pkg.vhd \
	../core/probe_driver_core.vhd \
	../wrapper/probe_driver_wrapper.vhd \
	../../MokuModules/MokuModules_pkg.vhd \
	ProbeDriver_Testbench_Config_pkg.vhd \
	ProbeDriver_Testbench_Template.vhd

# =============================================================================
# DEFAULT TARGET
# =============================================================================

.PHONY: all
all: help

# =============================================================================
# CORE LAYER TESTING
# =============================================================================

.PHONY: core_test
core_test: analyze_core elaborate_core run_core

analyze_core: $(SOURCES)
	@echo "=== Analyzing files for core layer testbench ==="
	$(GHDL) -a --std=08 --work=work ../../common/clock_divider.vhd
	$(GHDL) -a --std=08 --work=work ../common/intensity_lut_pkg.vhd
	$(GHDL) -a --std=08 --work=work ../common/probe_driver_pkg.vhd
	$(GHDL) -a --std=08 --work=work ../core/probe_driver_core.vhd
	$(GHDL) -a --std=08 --work=work ../../MokuModules/MokuModules_pkg.vhd
	$(GHDL) -a --std=08 --work=work ProbeDriver_Testbench_Config_pkg.vhd
	$(GHDL) -a --std=08 --work=work ProbeDriver_Testbench_Template.vhd
	$(GHDL) -a --std=08 --work=work $(CORE_TB).vhd
	@echo "=== Core layer analysis complete ==="

elaborate_core: analyze_core
	@echo "=== Elaborating core layer testbench ==="
	$(GHDL) -e --std=08 --work=work $(CORE_TB)
	@echo "=== Core layer elaboration complete ==="

run_core: elaborate_core
	@echo "=== Running core layer testbench ==="
	$(GHDL) -r --std=08 --work=work $(CORE_TB) --stop-time=10us --vcd=core_test.vcd
	@echo "=== Core layer test complete ==="

# =============================================================================
# WRAPPER LAYER TESTING
# =============================================================================

.PHONY: wrapper_test
wrapper_test: analyze_wrapper elaborate_wrapper run_wrapper

analyze_wrapper: analyze_core
	@echo "=== Analyzing files for wrapper layer testbench ==="
	$(GHDL) -a --std=08 --work=work ../wrapper/probe_driver_wrapper.vhd
	$(GHDL) -a --std=08 --work=work $(WRAPPER_TB).vhd
	@echo "=== Wrapper layer analysis complete ==="

elaborate_wrapper: analyze_wrapper
	@echo "=== Elaborating wrapper layer testbench ==="
	$(GHDL) -e --std=08 --work=work $(WRAPPER_TB)
	@echo "=== Wrapper layer elaboration complete ==="

run_wrapper: elaborate_wrapper
	@echo "=== Running wrapper layer testbench ==="
	$(GHDL) -r --std=08 --work=work $(WRAPPER_TB) --stop-time=20us --vcd=wrapper_test.vcd
	@echo "=== Wrapper layer test complete ==="

# =============================================================================
# TOP-LEVEL TESTING
# =============================================================================

.PHONY: top_level_test
top_level_test: analyze_top_level elaborate_top_level run_top_level

analyze_top_level: analyze_core
	@echo "=== Analyzing files for top-level testbench ==="
	$(GHDL) -a --std=08 --work=work $(TOP_LEVEL_TB).vhd
	@echo "=== Top-level analysis complete ==="

elaborate_top_level: analyze_top_level
	@echo "=== Elaborating top-level testbench ==="
	$(GHDL) -e --std=08 --work=work $(TOP_LEVEL_TB)
	@echo "=== Top-level elaboration complete ==="

run_top_level: elaborate_top_level
	@echo "=== Running top-level testbench ==="
	$(GHDL) -r --std=08 --work=work $(TOP_LEVEL_TB) --stop-time=100us --vcd=top_level_test.vcd
	@echo "=== Top-level test complete ==="

# =============================================================================
# COMPREHENSIVE TESTING
# =============================================================================

.PHONY: test_all
test_all: core_test wrapper_test top_level_test
	@echo "=== All testbench layers completed successfully ==="
	@echo "Test progression: CORE → WRAPPER → TOP_LEVEL"

# =============================================================================
# WAVEFORM VIEWING
# =============================================================================

.PHONY: wave_core wave_wrapper wave_top_level
wave_core: run_core
	@echo "=== Core layer waveform: core_test.vcd ==="
	@echo "View with: gtkwave core_test.vcd"

wave_wrapper: run_wrapper
	@echo "=== Wrapper layer waveform: wrapper_test.vcd ==="
	@echo "View with: gtkwave wrapper_test.vcd"

wave_top_level: run_top_level
	@echo "=== Top-level waveform: top_level_test.vcd ==="
	@echo "View with: gtkwave top_level_test.vcd"

# =============================================================================
# DEVELOPMENT AND DEBUGGING
# =============================================================================

.PHONY: analyze_all
analyze_all: $(SOURCES)
	@echo "=== Analyzing all source files ==="
	$(GHDL) -a --std=08 --work=work ../../common/clock_divider.vhd
	$(GHDL) -a --std=08 --work=work ../common/intensity_lut_pkg.vhd
	$(GHDL) -a --std=08 --work=work ../common/probe_driver_pkg.vhd
	$(GHDL) -a --std=08 --work=work ../core/probe_driver_core.vhd
	$(GHDL) -a --std=08 --work=work ../wrapper/probe_driver_wrapper.vhd
	$(GHDL) -a --std=08 --work=work ../../MokuModules/MokuModules_pkg.vhd
	$(GHDL) -a --std=08 --work=work ProbeDriver_Testbench_Config_pkg.vhd
	$(GHDL) -a --std=08 --work=work ProbeDriver_Testbench_Template.vhd
	@echo "=== All source files analyzed ==="

.PHONY: clean
clean:
	@echo "=== Cleaning generated files ==="
	rm -f *.o *.cf *_test *_test.vcd
	@echo "Clean complete"

# =============================================================================
# HELP AND DOCUMENTATION
# =============================================================================

.PHONY: help
help:
	@echo "ProbeDriver Testbench Template System"
	@echo "===================================="
	@echo ""
	@echo "This Makefile provides a clean, focused build system for the new"
	@echo "reusable testbench architecture that eliminates CustomWrapper duplication."
	@echo ""
	@echo "TESTING LAYERS (Bottom-up approach):"
	@echo "  core_test       - Test core component logic (fast simulation)"
	@echo "  wrapper_test    - Test wrapper + core integration (medium simulation)"
	@echo "  top_level_test  - Test complete system (real hardware timing)"
	@echo ""
	@echo "COMPREHENSIVE TESTING:"
	@echo "  test_all        - Run all layers: CORE → WRAPPER → TOP_LEVEL"
	@echo ""
	@echo "WAVEFORM VIEWING:"
	@echo "  wave_core       - Run core test and show waveform info"
	@echo "  wave_wrapper    - Run wrapper test and show waveform info"
	@echo "  wave_top_level  - Run top-level test and show waveform info"
	@echo ""
	@echo "DEVELOPMENT:"
	@echo "  analyze_all     - Analyze all source files"
	@echo "  clean           - Remove generated files"
	@echo ""
	@echo "RECOMMENDED WORKFLOW:"
	@echo "  1. make test_all           # Test all layers"
	@echo "  2. make wave_top_level     # View top-level waveforms"
	@echo "  3. make clean              # Clean up when done"
	@echo ""
	@echo "NAMING CONVENTION:"
	@echo "  {module}_{layer}_{purpose}_tb.vhd"
	@echo "  Example: probe_driver_core_basic_tb.vhd"
	@echo ""
	@echo "For more information, see README-Testbench-Template-System.md"

# =============================================================================
# UTILITY TARGETS
# =============================================================================

.PHONY: list_tests
list_tests:
	@echo "Available testbenches:"
	@echo "  $(CORE_TB)"
	@echo "  $(WRAPPER_TB)"
	@echo "  $(TOP_LEVEL_TB)"

.PHONY: check_deps
check_deps:
	@echo "Checking dependencies..."
	@echo "GHDL: $(shell which $(GHDL) 2>/dev/null || echo 'NOT FOUND')"
	@echo "Sources:"
	@for src in $(SOURCES); do \
		if [ -f "$$src" ]; then \
			echo "  ✓ $$src"; \
		else \
			echo "  ✗ $$src (MISSING)"; \
		fi; \
	done
