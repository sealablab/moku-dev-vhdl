# Makefile for ProbeDriver Human Interface Testbenches
# Restored from testbench.old/ during cleanup recovery
# 
# This Makefile provides easy access to the human-interface testbench code
# that was accidentally removed during recent cleanup operations.

# GHDL command (adjust path if needed)
GHDL := ghdl

# Target testbenches (restored from testbench.old/)
CORE_TB := probe_driver_core_tb
WRAPPER_TB := probe_driver_wrapper_tb
HUMAN_TB := jc_CustomWrapper_top_tb
HIGH_LEVEL_TB := CustomWrapper_top_tb

# Source files (in dependency order for modular architecture)
SOURCES := \
	../../clk-divider/clk_divider.vhd \
	../common/intensity_lut_pkg.vhd \
	../common/probe_driver_pkg.vhd \
	../core/probe_driver_core.vhd \
	../wrapper/probe_driver_wrapper.vhd

# Default target - show available options
all: help

# =============================================================================
# HUMAN INTERFACE TESTBENCH (RESTORED FROM CLEANUP)
# =============================================================================

# Test the human-interface focused testbench by "jc"
human_test: analyze_human elaborate_human run_human

analyze_human: ../common/intensity_lut_pkg.vhd ../common/probe_driver_pkg.vhd ../core/probe_driver_core.vhd ../wrapper/probe_driver_wrapper.vhd ../../clk-divider/clk_divider.vhd
	@echo "=== Analyzing files for human interface testbench ==="
	$(GHDL) -a --std=08 --work=work ../../clk-divider/clk_divider.vhd
	$(GHDL) -a --std=08 --work=work ../common/intensity_lut_pkg.vhd
	$(GHDL) -a --std=08 --work=work ../common/probe_driver_pkg.vhd
	$(GHDL) -a --std=08 --work=work ../core/probe_driver_core.vhd
	$(GHDL) -a --std=08 --work=work ../wrapper/probe_driver_wrapper.vhd
	$(GHDL) -a --std=08 --work=work HumanInterface_pkg.vhd
	$(GHDL) -a --std=08 --work=work $(HUMAN_TB).vhd
	@echo "=== Human interface analysis complete ==="

elaborate_human: analyze_human
	@echo "=== Elaborating human interface testbench ==="
	$(GHDL) -e --std=08 --work=work $(HUMAN_TB)
	@echo "=== Human interface elaboration complete ==="

run_human: elaborate_human
	@echo "=== Running human interface testbench ==="
	$(GHDL) -r --std=08 --work=work $(HUMAN_TB) --stop-time=100us --vcd=human_test.vcd
	@echo "=== Human interface test complete ==="

# =============================================================================
# HIGH-LEVEL TESTBENCH (RESTORED FROM CLEANUP)
# =============================================================================

# Test the high-level CustomWrapper testbench
high_level_test: analyze_high_level elaborate_high_level run_high_level

analyze_high_level: ../common/intensity_lut_pkg.vhd ../common/probe_driver_pkg.vhd ../core/probe_driver_core.vhd ../wrapper/probe_driver_wrapper.vhd ../../clk-divider/clk_divider.vhd
	@echo "=== Analyzing files for high-level testbench ==="
	$(GHDL) -a --std=08 --work=work ../../clk-divider/clk_divider.vhd
	$(GHDL) -a --std=08 --work=work ../common/intensity_lut_pkg.vhd
	$(GHDL) -a --std=08 --work=work ../common/probe_driver_pkg.vhd
	$(GHDL) -a --std=08 --work=work ../core/probe_driver_core.vhd
	$(GHDL) -a --std=08 --work=work ../wrapper/probe_driver_wrapper.vhd
	$(GHDL) -a --std=08 --work=work $(HIGH_LEVEL_TB).vhd
	@echo "=== High-level analysis complete ==="

elaborate_high_level: analyze_high_level
	@echo "=== Elaborating high-level testbench ==="
	$(GHDL) -e --std=08 --work=work $(HIGH_LEVEL_TB)
	@echo "=== High-level elaboration complete ==="

run_high_level: elaborate_high_level
	@echo "=== Running high-level testbench ==="
	$(GHDL) -r --std=08 --work=work $(HIGH_LEVEL_TB) --stop-time=100us --vcd=high_level_test.vcd
	@echo "=== High-level test complete ==="

# =============================================================================
# CORE COMPONENT TESTS (RESTORED FROM CLEANUP)
# =============================================================================

# Test core component only
core_test: analyze_core elaborate_core run_core

analyze_core: ../common/intensity_lut_pkg.vhd ../common/probe_driver_pkg.vhd ../core/probe_driver_core.vhd
	@echo "=== Analyzing core component files ==="
	$(GHDL) -a --std=08 --work=work ../common/intensity_lut_pkg.vhd
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

analyze_wrapper: ../common/intensity_lut_pkg.vhd ../common/probe_driver_pkg.vhd ../core/probe_driver_core.vhd ../wrapper/probe_driver_wrapper.vhd ../../clk-divider/clk_divider.vhd
	@echo "=== Analyzing wrapper component files ==="
	$(GHDL) -a --std=08 --work=work ../common/intensity_lut_pkg.vhd
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
# COMPREHENSIVE TESTING
# =============================================================================

# Run all restored testbenches
test_all: human_test high_level_test core_test wrapper_test
	@echo "=== All restored testbenches completed successfully ==="

# =============================================================================
# WAVEFORM VIEWING
# =============================================================================

# View waveforms for human interface test
wave_human: run_human
	@echo "=== Opening waveform viewer for human interface test ==="
	@echo "Note: Install GTKWave to view waveforms:"
	@echo "  macOS: brew install gtkwave"
	@echo "  Ubuntu: sudo apt-get install gtkwave"
	@echo "  Windows: Download from http://gtkwave.sourceforge.net/"
	@echo ""
	@echo "To view waveforms manually: gtkwave human_test.vcd"

# View waveforms for high-level test
wave_high_level: run_high_level
	@echo "=== Opening waveform viewer for high-level test ==="
	@echo "To view waveforms manually: gtkwave high_level_test.vcd"

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
	@echo "ProbeDriver Human Interface Testbenches - RESTORED FROM CLEANUP"
	@echo "=================================================================="
	@echo ""
	@echo "AVAILABLE TARGETS:"
	@echo ""
	@echo "HUMAN INTERFACE TESTS (RESTORED):"
	@echo "  human_test      - Test human-interface focused testbench by 'jc'"
	@echo "  wave_human      - Run human test and show waveform info"
	@echo ""
	@echo "HIGH-LEVEL TESTS (RESTORED):"
	@echo "  high_level_test - Test high-level CustomWrapper testbench"
	@echo "  wave_high_level - Run high-level test and show waveform info"
	@echo ""
	@echo "COMPONENT TESTS (RESTORED):"
	@echo "  core_test       - Test core component only"
	@echo "  wrapper_test    - Test wrapper component only"
	@echo ""
	@echo "COMPREHENSIVE:"
	@echo "  test_all        - Run all restored testbenches"
	@echo ""
	@echo "UTILITY:"
	@echo "  clean           - Remove generated files"
	@echo "  help            - Show this help message"
	@echo ""
	@echo "RECOMMENDED WORKFLOW:"
	@echo "  make human_test    # Start with human-interface testbench"
	@echo "  make wave_human    # View waveforms if needed"
	@echo "  make test_all      # Run all tests for comprehensive validation"
	@echo ""
	@echo "Note: These testbenches were restored from testbench.old/ after"
	@echo "being accidentally removed during recent cleanup operations."

# Phony targets
.PHONY: all help human_test high_level_test core_test wrapper_test test_all
.PHONY: analyze_human elaborate_human run_human
.PHONY: analyze_high_level elaborate_high_level run_high_level
.PHONY: analyze_core elaborate_core run_core
.PHONY: analyze_wrapper elaborate_wrapper run_wrapper
.PHONY: wave_human wave_high_level clean
