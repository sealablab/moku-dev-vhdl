# ProbeDriver v2.5 Makefile
# Build system for ProbeDriver v2.5 VHDL files - MCC compatible
# REFACTORED: Now uses shared percent_lut_pkg and latest state machine requirements

# GHDL compiler and flags
GHDL = ghdl
GHDL_FLAGS = --std=08 --ieee=synopsys

# Source files in dependency order (REFACTORED: Now includes shared packages)
# Note: CustomWrapper.vhd provides the entity declaration that ProbeDriver.vhd implements
SOURCES = ../shared/percent_lut_pkg.vhd ../common/clock_divider.vhd common/intensity_lut_pkg.vhd common/probe_driver_pkg.vhd core/probe_driver_core.vhd ../MokuModules/CustomWrapper.vhd ProbeDriver.vhd

# Default target
all: build

# Build all sources in dependency order
build: $(SOURCES)
	@echo "========================================"
	@echo "Building ProbeDriver v2.5 for MCC synthesis..."
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
	@echo "ProbeDriver v2.5 build complete!"
	@echo "========================================"

# Legacy target for backward compatibility
syntax_check: build

# Check syntax of individual files
check_package:
	@echo "Checking package syntax..."
	$(GHDL) -a $(GHDL_FLAGS) ../shared/percent_lut_pkg.vhd
	$(GHDL) -a $(GHDL_FLAGS) common/intensity_lut_pkg.vhd
	$(GHDL) -a $(GHDL_FLAGS) common/probe_driver_pkg.vhd

check_main:
	@echo "Checking main file syntax..."
	$(GHDL) -a $(GHDL_FLAGS) ../shared/percent_lut_pkg.vhd
	$(GHDL) -a $(GHDL_FLAGS) common/intensity_lut_pkg.vhd
	$(GHDL) -a $(GHDL_FLAGS) common/probe_driver_pkg.vhd
	$(GHDL) -a $(GHDL_FLAGS) core/probe_driver_core.vhd

check_top:
	@echo "Checking top-level file syntax..."
	$(GHDL) -a $(GHDL_FLAGS) ../shared/percent_lut_pkg.vhd
	$(GHDL) -a $(GHDL_FLAGS) common/intensity_lut_pkg.vhd
	$(GHDL) -a $(GHDL_FLAGS) common/probe_driver_pkg.vhd
	$(GHDL) -a $(GHDL_FLAGS) core/probe_driver_core.vhd
	$(GHDL) -a $(GHDL_FLAGS) ../MokuModules/CustomWrapper.vhd
	$(GHDL) -a $(GHDL_FLAGS) ProbeDriver.vhd

# Clean up generated files
clean:
	@echo "Cleaning up..."
	rm -f *.o *.cf work-obj93.cf work-obj08.cf
	@echo "Clean complete"

# Show help
help:
	@echo "Available targets:"
	@echo "  all           - Build ProbeDriver v2.5 for MCC synthesis (default)"
	@echo "  build         - Build ProbeDriver v2.5 for MCC synthesis"
	@echo "  syntax_check  - Legacy target (same as build)"
	@echo "  check_package - Check only the package files"
	@echo "  check_main    - Check only the main file"
	@echo "  check_top     - Check only the top-level file"
	@echo "  clean         - Remove generated files"
	@echo "  help          - Show this help message"
	@echo ""
	@echo "REFACTORED: Now uses latest requirements and shared packages!"
	@echo "  - Shared percent_lut_pkg for consistent type definitions"
	@echo "  - Record-based Status Register records"
	@echo "  - Hybrid approach: VHDL enumerated types + Status Register records"
	@echo "  - Clock divider module"
	@echo "  - Intensity lookup table package (using shared types)"
	@echo "  - Probe driver package (latest requirements)"
	@echo "  - Core state machine (latest requirements)"
	@echo "  - CustomWrapper.vhd (entity declaration from MokuModules)"
	@echo "  - ProbeDriver.vhd (complete integrated implementation v2.5)"
	@echo ""
	@echo "Build Mode:"
	@echo "  MCC: Use ProbeDriver.vhd for MCC synthesis (make build)"
	@echo ""
	@echo "Usage examples:"
	@echo "  make                    # Build ProbeDriver v2.5 for MCC"
	@echo "  make build             # Build ProbeDriver v2.5 for MCC"
	@echo "  make check_package     # Check only packages"
	@echo "  make check_main        # Check only main file"
	@echo "  make check_top         # Check only top-level file"
	@echo "  make clean             # Clean up"

# Phony targets (don't represent actual files)
.PHONY: all build syntax_check check_package check_main check_top clean help
