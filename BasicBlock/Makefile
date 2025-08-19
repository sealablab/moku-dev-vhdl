# =============================================================================
# Makefile for BasicBlock Module
# =============================================================================
# 
# PURPOSE: This Makefile automates the build process for the BasicBlock module.
#          It handles compilation, elaboration, simulation, and cleaning tasks.
#          Think of it as a "build script" that knows how to compile VHDL.
# 
# TARGET PLATFORM: Moku-Go (Liquid Instruments)
#                  - FPGA-based signal generation and analysis platform
#                  - Compatible with MCC (Moku Cloud Compiler)
#                  - Uses GHDL for VHDL compilation and simulation
# 
# REFACTORED: Now uses BasicBlock.vhd (architecture-only) for MCC compatibility
# 
# LEARNING OBJECTIVES:
#   1. Understanding Makefile syntax and automation
#   2. Learning about VHDL compilation order and dependencies
#   3. Understanding how to manage build processes
#   4. Learning about GHDL compilation flags and options
#   5. Understanding how to create reusable build systems
# 
# =============================================================================

# =============================================================================
# VARIABLES - These define the build configuration
# =============================================================================

# VHDL source files - these are the files we need to compile
# The order is important: packages must be compiled before modules that use them
# Note: CustomWrapper.vhd provides the entity declaration that BasicBlock.vhd implements
VHDL_FILES = \
	common/led_pattern_pkg.vhd \
	common/basicblock_pkg.vhd \
	../common/clock_divider.vhd \
	core/basicblock_core.vhd \
	wrapper/basicblock_wrapper.vhd \
	../MokuModules/CustomWrapper.vhd \
	BasicBlock.vhd

# Top-level entity name - this is the main module that gets synthesized
# In BasicBlock, this is "CustomWrapper" (the platform interface)
TOP_LEVEL = CustomWrapper

# Work library name - this is where GHDL stores compiled modules
WORK_LIB = work

# VHDL standard - this specifies which VHDL language version to use
# VHDL-2008 provides modern features like improved types and functions
VHDL_STD = 08

# GHDL compiler - this is the tool we use to compile VHDL
GHDL = ghdl

# GHDL compilation flags - these control how GHDL compiles our code
# --std=08: Use VHDL-2008 standard
# --work=work: Store compiled modules in the "work" library
GHDL_FLAGS = --std=$(VHDL_STD) --work=$(WORK_LIB)

# =============================================================================
# TARGETS - These are the commands you can run with "make"
# =============================================================================

# Default target - this runs when you just type "make"
# It compiles all the VHDL files
.PHONY: all
all: analyze

# Analyze target - this compiles all VHDL files into the work library
# This is the first step in the build process
.PHONY: analyze
analyze: $(VHDL_FILES)
	@echo "============================================================================="
	@echo "Analyzing BasicBlock module..."
	@echo "============================================================================="
	@echo "Compiling VHDL files with GHDL..."
	@echo "VHDL Standard: $(VHDL_STD)"
	@echo "Work Library: $(WORK_LIB)"
	@echo "============================================================================="
	$(GHDL) -a $(GHDL_FLAGS) $^
	@echo "============================================================================="
	@echo "Analysis complete! All VHDL files compiled successfully."
	@echo "============================================================================="

# Elaborate target - this creates the top-level design from compiled modules
# This is the second step in the build process
.PHONY: elaborate
elaborate: analyze
	@echo "============================================================================="
	@echo "Elaborating BasicBlock module..."
	@echo "============================================================================="
	@echo "Creating top-level design: $(TOP_LEVEL)"
	@echo "============================================================================="
	$(GHDL) -e $(GHDL_FLAGS) $(TOP_LEVEL)
	@echo "============================================================================="
	@echo "Elaboration complete! Top-level design created successfully."
	@echo "============================================================================="

# Run target - this simulates the design (if you have a testbench)
# Note: BasicBlock doesn't include a testbench, so this is a placeholder
.PHONY: run
run: elaborate
	@echo "============================================================================="
	@echo "Running BasicBlock simulation..."
	@echo "============================================================================="
	@echo "Note: BasicBlock doesn't include a testbench."
	@echo "To add simulation, create a testbench file and update this Makefile."
	@echo "============================================================================="
	@echo "Simulation complete! (No testbench to run)"

# Sim target - alias for run (common convention)
.PHONY: sim
sim: run

# Clean target - this removes all compiled files and generated outputs
# Useful when you want to start fresh or free up disk space
.PHONY: clean
clean:
	@echo "============================================================================="
	@echo "Cleaning BasicBlock build files..."
	@echo "============================================================================="
	rm -f *.o *.cf *.vcd *.ghw
	rm -rf $(WORK_LIB)
	@echo "============================================================================="
	@echo "Clean complete! All build files removed."
	@echo "============================================================================="

# Help target - this shows all available commands
# Very useful for new users or when you forget the syntax
.PHONY: help
help:
	@echo "============================================================================="
	@echo "BasicBlock Module Makefile Help"
	@echo "============================================================================="
	@echo "Available targets:"
	@echo "  all       - Compile all VHDL files (default)"
	@echo "  analyze   - Compile VHDL files into work library"
	@echo "  elaborate - Create top-level design from compiled modules"
	@echo "  run       - Run simulation (if testbench exists)"
	@echo "  sim       - Alias for run"
	@echo "  clean     - Remove all compiled files and outputs"
	@echo "  help      - Show this help message"
	@echo "  syntax    - Check VHDL syntax without full compilation"
	@echo "  info      - Show module information and dependencies"
	@echo "  deps      - Generate dependency graph (requires graphviz)"
	@echo ""
	@echo "Usage examples:"
	@echo "  make              - Compile all files"
	@echo "  make analyze      - Compile files only"
	@echo "  make elaborate    - Compile and elaborate"
	@echo "  make clean        - Remove all build files"
	@echo "  make help         - Show this help"
	@echo "============================================================================="

# =============================================================================
# UTILITY TARGETS - These provide additional useful functionality
# =============================================================================

# Syntax check target - this checks VHDL syntax without full compilation
# Useful for quick syntax validation during development
.PHONY: syntax
syntax: $(VHDL_FILES)
	@echo "============================================================================="
	@echo "Checking VHDL syntax..."
	@echo "============================================================================="
	$(GHDL) -s $(GHDL_FLAGS) $^
	@echo "============================================================================="
	@echo "Syntax check complete! All files have valid VHDL syntax."
	@echo "============================================================================="

# Info target - this shows information about the compiled modules
# Useful for understanding the design structure and dependencies
.PHONY: info
info: analyze
	@echo "============================================================================="
	@echo "BasicBlock Module Information"
	@echo "============================================================================="
	@echo "Top-level entity: $(TOP_LEVEL)"
	@echo "VHDL standard: $(VHDL_STD)"
	@echo "Work library: $(WORK_LIB)"
	@echo "Source files:"
	@for file in $(VHDL_FILES); do \
		echo "  - $$file"; \
	done
	@echo ""
	@echo "Module dependencies:"
	$(GHDL) -d $(GHDL_FLAGS) $(TOP_LEVEL)
	@echo "============================================================================="

# Dependencies target - this generates a visual dependency graph
# Requires graphviz to be installed (dot command)
.PHONY: deps
deps: analyze
	@echo "============================================================================="
	@echo "Generating dependency graph..."
	@echo "============================================================================="
	@if command -v dot >/dev/null 2>&1; then \
		echo "digraph BasicBlock_Dependencies {" > basicblock_deps.dot; \
		echo "  rankdir=TB;" >> basicblock_deps.dot; \
		echo "  node [shape=box, style=filled, fillcolor=lightblue];" >> basicblock_deps.dot; \
		echo "  edge [color=blue];" >> basicblock_deps.dot; \
		echo "" >> basicblock_deps.dot; \
		echo "  // Source files" >> basicblock_deps.dot; \
		echo "  \"led_pattern_pkg\" [label=\"led_pattern_pkg.vhd\"];" >> basicblock_deps.dot; \
		echo "  \"basicblock_pkg\" [label=\"basicblock_pkg.vhd\"];" >> basicblock_deps.dot; \
		echo "  \"basicblock_core\" [label=\"basicblock_core.vhd\"];" >> basicblock_deps.dot; \
		echo "  \"basicblock_wrapper\" [label=\"basicblock_wrapper.vhd\"];" >> basicblock_deps.dot; \
		echo "  \"CustomWrapper\" [label=\"CustomWrapper.vhd\"];" >> basicblock_deps.dot; \
		echo "  \"BasicBlock\" [label=\"BasicBlock.vhd\"];" >> basicblock_deps.dot; \
		echo "" >> basicblock_deps.dot; \
		echo "  // Dependencies" >> basicblock_deps.dot; \
		echo "  \"basicblock_pkg\" -> \"led_pattern_pkg\";" >> basicblock_deps.dot; \
		echo "  \"basicblock_core\" -> \"led_pattern_pkg\";" >> basicblock_deps.dot; \
		echo "  \"basicblock_core\" -> \"basicblock_pkg\";" >> basicblock_deps.dot; \
		echo "  \"basicblock_wrapper\" -> \"basicblock_pkg\";" >> basicblock_deps.dot; \
		echo "  \"basicblock_wrapper\" -> \"basicblock_core\";" >> basicblock_deps.dot; \
		echo "  \"CustomWrapper\" -> \"basicblock_wrapper\";" >> basicblock_deps.dot; \
		echo "  \"BasicBlock\" -> \"CustomWrapper\";" >> basicblock_deps.dot; \
		echo "}" >> basicblock_deps.dot; \
		dot -Tpng basicblock_deps.dot -o basicblock_deps.png; \
		echo "Dependency graph saved to basicblock_deps.png"; \
		echo "Dependency graph saved to basicblock_deps.dot"; \
	else \
		echo "Warning: graphviz not found. Install it to generate dependency graphs."; \
		echo "On macOS: brew install graphviz"; \
		echo "On Ubuntu: sudo apt-get install graphviz"; \
		echo "On Windows: Download from https://graphviz.org/download/"; \
	fi
	@echo "============================================================================="

# =============================================================================
# DEPENDENCIES - These ensure files are compiled in the correct order
# =============================================================================
# VHDL compilation order is critical:
# 1. Packages must be compiled before modules that use them
# 2. Lower-level modules must be compiled before higher-level modules
# 3. The top-level module must be compiled last

# basicblock_pkg.vhd depends on led_pattern_pkg.vhd
common/basicblock_pkg.vhd: common/led_pattern_pkg.vhd

# basicblock_core.vhd depends on both packages
core/basicblock_core.vhd: common/led_pattern_pkg.vhd common/basicblock_pkg.vhd

# basicblock_wrapper.vhd depends on the core and packages
wrapper/basicblock_wrapper.vhd: common/basicblock_pkg.vhd core/basicblock_core.vhd

# CustomWrapper.vhd depends on the wrapper
../MokuModules/CustomWrapper.vhd: wrapper/basicblock_wrapper.vhd

# BasicBlock.vhd depends on the CustomWrapper
BasicBlock.vhd: ../MokuModules/CustomWrapper.vhd

# =============================================================================
# BUILD NOTES - Additional information for developers
# =============================================================================
# 
# Compilation Process:
# 1. analyze: Compiles all VHDL files into the work library
# 2. elaborate: Creates the top-level design from compiled modules
# 3. run: Simulates the design (if testbench exists)
# 
# File Organization:
# - common/: Contains packages with shared types and functions
# - core/: Contains the main LED pattern generation logic
# - wrapper/: Contains the interface and control register parsing
# - BasicBlock_Top.vhd: Top-level module with platform interface
# 
# Integration with clk-divider:
# - BasicBlock uses the existing clk-divider module for timing control
# - The clk-divider module must be available in the work library
# - To use BasicBlock, first compile the clk-divider module
# 
# Platform Compatibility:
# - BasicBlock implements the CustomWrapper interface for Moku-Go
# - Compatible with MCC (Moku Cloud Compiler)
# - Can be deployed directly to Moku-Go devices
# 
# Future Enhancements:
# - Add testbench for simulation and testing
# - Add synthesis constraints for FPGA implementation
# - Add automated testing and validation scripts
# - Add documentation generation tools
# 
# =============================================================================
