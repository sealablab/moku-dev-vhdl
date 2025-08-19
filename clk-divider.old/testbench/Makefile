# clk_divider testbench Makefile
# Focused build system for testing the clk_divider module

# GHDL compiler and flags
GHDL = ghdl
GHDL_FLAGS = --std=08 --ieee=synopsys

# Source files (relative to parent directory)
DUT_FILE = ../clk_divider.vhd
TB_FILE = clk_divider_tb.vhd

# Default target
all: test

# =============================================================================
# COMPILATION TARGETS
# =============================================================================

# Compile all files
compile:
	@echo "========================================"
	@echo "Compiling clk_divider testbench..."
	@echo "========================================"
	@echo "Compiling DUT..."
	$(GHDL) -a $(GHDL_FLAGS) $(DUT_FILE)
	@echo "Compiling testbench..."
	$(GHDL) -a $(GHDL_FLAGS) $(TB_FILE)
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) clk_divider_tb

# =============================================================================
# TESTING TARGETS
# =============================================================================

# Run tests (default)
test: compile run_test

# Run the testbench
run_test: compile
	@echo "========================================"
	@echo "Running clk_divider tests..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) clk_divider_tb

# =============================================================================
# UTILITY TARGETS
# =============================================================================

# Clean up generated files
clean:
	@echo "Cleaning testbench files..."
	rm -f *.o *.cf work-obj93.cf work-obj08.cf *.vcd
	@echo "Clean complete"

# Show help
help:
	@echo "Available targets:"
	@echo "  all        - Run all tests (default)"
	@echo "  compile    - Compile all files"
	@echo "  test       - Compile and run tests"
	@echo "  run_test   - Run tests (requires compilation)"
	@echo "  clean      - Remove generated files"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make              # Run all tests"
	@echo "  make compile      # Compile only"
	@echo "  make test         # Compile and test"
	@echo "  make clean        # Clean up"

# Phony targets
.PHONY: all compile test run_test clean help
