# Slot2/Makefile
# Build system for Slot2 VHDL files

# GHDL compiler and flags
GHDL = ghdl
GHDL_FLAGS = --std=08 --ieee=synopsys

# Source files in dependency order
SOURCES = IntensityLut.vhd ProbeConfig.vhd ProbeDriver.vhd CustomWrapper.vhd top_probe_driver.vhd

# Target for syntax checking
syntax_check: $(SOURCES)
	@echo "========================================"
	@echo "Checking VHDL syntax..."
	@echo "========================================"
	@for file in $(SOURCES); do \
		echo "ghdl -a --std=08 --ieee=synopsys $$file"; \
		$(GHDL) -a $(GHDL_FLAGS) $$file; \
		if [ $$? -eq 0 ]; then \
			echo "✓ $$(basename $$file .vhd) compiled successfully"; \
		else \
			echo "✗ $$(basename $$file .vhd) compilation failed"; \
			exit 1; \
		fi; \
	done
	@echo "========================================"
	@echo "All files compiled successfully!"
	@echo "========================================"

# Check syntax of individual files
check_package:
	@echo "Checking package syntax..."
	$(GHDL) -a $(GHDL_FLAGS) $(PACKAGE)

check_main:
	@echo "Checking main file syntax..."
	$(GHDL) -a $(GHDL_FLAGS) $(PACKAGE)
	$(GHDL) -a $(GHDL_FLAGS) $(MAIN)

check_top:
	@echo "Checking top-level file syntax..."
	$(GHDL) -a $(GHDL_FLAGS) $(WRAPPER)
	$(GHDL) -a $(GHDL_FLAGS) $(PACKAGE)
	$(GHDL) -a $(GHDL_FLAGS) $(MAIN)
	$(GHDL) -a $(GHDL_FLAGS) $(TOP)

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
	@echo "  check_top     - Check only the top-level file"
	@echo "  clean         - Remove generated files"
	@echo "  help          - Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make                    # Check all files"
	@echo "  make check_package      # Check only package"
	@echo "  make check_main         # Check only main file"
	@echo "  make check_top          # Check only top-level file"
	@echo "  make clean             # Clean up"

# Phony targets (don't represent actual files)
.PHONY: all syntax_check check_package check_main check_top clean help
