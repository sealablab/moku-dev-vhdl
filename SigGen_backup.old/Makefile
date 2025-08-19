# Makefile for SigGen Module
# REFACTORED: Modular design with 3-tier architecture
# Follows the same pattern as ProbeDriver Makefile

# =============================================================================
# VARIABLES
# =============================================================================
VHDL_FILES = \
	common/pattern_generator_pkg.vhd \
	common/siggen_pkg.vhd \
	core/siggen_core.vhd \
	wrapper/siggen_wrapper.vhd \
	SigGen_Top.vhd

TOP_LEVEL = CustomWrapper
WORK_LIB = work
VHDL_STD = 08

# Compiler and simulator settings
GHDL = ghdl
GHDL_FLAGS = --std=$(VHDL_STD) --work=$(WORK_LIB)

# =============================================================================
# TARGETS
# =============================================================================
.PHONY: all clean analyze elaborate run sim

# Default target
all: analyze

# Analyze all VHDL files
analyze: $(VHDL_FILES)
	@echo "Analyzing SigGen module..."
	$(GHDL) -a $(GHDL_FLAGS) $^

# Elaborate the top-level entity
elaborate: analyze
	@echo "Elaborating SigGen module..."
	$(GHDL) -e $(GHDL_FLAGS) $(TOP_LEVEL)

# Run simulation (requires testbench)
run: elaborate
	@echo "Running SigGen simulation..."
	$(GHDL) -r $(GHDL_FLAGS) $(TOP_LEVEL) --stop-time=1000ns

# Clean generated files
clean:
	@echo "Cleaning SigGen module..."
	rm -f *.o *.cf *.vcd *.ghw
	rm -rf $(WORK_LIB)

# Show help
help:
	@echo "SigGen Module Makefile"
	@echo "======================"
	@echo "Targets:"
	@echo "  all       - Analyze all VHDL files (default)"
	@echo "  analyze   - Analyze VHDL files"
	@echo "  elaborate - Elaborate top-level entity"
	@echo "  run       - Run simulation (requires testbench)"
	@echo "  clean     - Remove generated files"
	@echo "  help      - Show this help message"
	@echo ""
	@echo "Usage:"
	@echo "  make [target]"
	@echo ""
	@echo "Example:"
	@echo "  make analyze    # Analyze all files"
	@echo "  make elaborate  # Elaborate design"
	@echo "  make clean      # Clean up"

# =============================================================================
# DEPENDENCIES
# =============================================================================
# Pattern generator package must be analyzed first
common/siggen_pkg.vhd: common/pattern_generator_pkg.vhd

# Core module depends on packages
core/siggen_core.vhd: common/pattern_generator_pkg.vhd common/siggen_pkg.vhd

# Wrapper depends on packages and core
wrapper/siggen_wrapper.vhd: common/siggen_pkg.vhd core/siggen_core.vhd

# Top level depends on wrapper
SigGen_Top.vhd: wrapper/siggen_wrapper.vhd

# =============================================================================
# UTILITY TARGETS
# =============================================================================
# Check syntax only
syntax: analyze

# Show entity information
info: elaborate
	$(GHDL) -e $(GHDL_FLAGS) $(TOP_LEVEL) --disp-tree

# Generate dependency graph (requires dot)
deps:
	@echo "Generating dependency graph..."
	@echo "digraph SigGen {" > siggen_deps.dot
	@echo "  rankdir=TB;" >> siggen_deps.dot
	@echo "  \"pattern_generator_pkg\" -> \"siggen_pkg\";" >> siggen_deps.dot
	@echo "  \"siggen_pkg\" -> \"siggen_core\";" >> siggen_deps.dot
	@echo "  \"pattern_generator_pkg\" -> \"siggen_core\";" >> siggen_deps.dot
	@echo "  \"siggen_pkg\" -> \"siggen_wrapper\";" >> siggen_deps.dot
	@echo "  \"siggen_core\" -> \"siggen_wrapper\";" >> siggen_deps.dot
	@echo "  \"siggen_wrapper\" -> \"SigGen_Top\";" >> siggen_deps.dot
	@echo "}" >> siggen_deps.dot
	@echo "Dependency graph saved to siggen_deps.dot"
