# clk-divider main Makefile
# Main build system for the clk_divider module

# Default target
all: test

# =============================================================================
# MAIN TARGETS
# =============================================================================

# Run all tests (delegates to testbench)
test:
	@echo "========================================"
	@echo "Running clk_divider tests..."
	@echo "========================================"
	@cd testbench && make test

# Compile only (delegates to testbench)
compile:
	@echo "========================================"
	@echo "Compiling clk_divider module..."
	@echo "========================================"
	@cd testbench && make compile

# =============================================================================
# UTILITY TARGETS
# =============================================================================

# Clean all generated files
clean:
	@echo "========================================"
	@echo "Cleaning clk_divider directory..."
	@echo "========================================"
	@cd testbench && make clean
	@echo "Clean complete"

# Show help
help:
	@echo "========================================"
	@echo "clk_divider Module Build System"
	@echo "========================================"
	@echo ""
	@echo "Available targets:"
	@echo "  all        - Run all tests (default)"
	@echo "  test       - Run all tests"
	@echo "  compile    - Compile all files"
	@echo "  clean      - Remove all generated files"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make              # Run all tests"
	@echo "  make test         # Run tests"
	@echo "  make compile      # Compile only"
	@echo "  make clean        # Clean up"
	@echo ""
	@echo "Note: All operations are delegated to the testbench subdirectory"
	@echo "For detailed testbench options, see: testbench/README.md"

# Phony targets
.PHONY: all test compile clean help
