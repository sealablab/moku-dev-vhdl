# Makefile for Slot2 Probe Driver VHDL Project
# Uses GHDL for VHDL compilation and syntax checking

# Compiler and flags
GHDL = ghdl
GHDL_FLAGS = --std=08 --ieee=synopsys

# Source files (in compilation order)
PACKAGE = IntensityLut.vhd
MAIN = Slot2-ProbeDriver.vhd
SOURCES = $(PACKAGE) $(MAIN)

# Default target
all: syntax_check

# Check syntax of all VHDL files
syntax_check: $(SOURCES)
	@echo "=========================================="
	@echo "Checking VHDL syntax..."
	@echo "=========================================="
	$(GHDL) -a $(GHDL_FLAGS) $(PACKAGE)
	@echo "✓ Package compiled successfully"
	$(GHDL) -a $(GHDL_FLAGS) $(MAIN)
	@echo "✓ Main file compiled successfully"
	@echo "=========================================="
	@echo "All files compiled successfully!"
	@echo "=========================================="

# Check syntax of individual files
check_package:
	@echo "Checking package syntax..."
	$(GHDL) -a $(GHDL_FLAGS) $(PACKAGE)

check_main:
	@echo "Checking main file syntax..."
	$(GHDL) -a $(GHDL_FLAGS) $(PACKAGE)
	$(GHDL) -a $(GHDL_FLAGS) $(MAIN)

# Clean up generated files
clean:
	@echo "Cleaning up..."
	rm -f *.o *.cf work-obj93.cf work-obj08.cf
	@echo "Clean complete"

# Show help
help:
	@echo "Available targets:"
	@echo "  all           - Check syntax of all files (default)"
	@echo "  syntax_check  - Check syntax of all files"
	@echo "  check_package - Check only the package file"
	@echo "  check_main    - Check only the main file"
	@echo "  clean         - Remove generated files"
	@echo "  help          - Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make                    # Check all files"
	@echo "  make check_package      # Check only package"
	@echo "  make clean             # Clean up"

# Phony targets (don't represent actual files)
.PHONY: all syntax_check check_package check_main clean help
