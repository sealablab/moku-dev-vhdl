# EnhancedSlotBlinker Makefile
# Builds the EnhancedSlotBlinker bitstream using GHDL
# REFACTORED: Now uses architecture-only approach for MCC compatibility

# GHDL compiler and flags
GHDL = ghdl
GHDL_FLAGS = --std=08 --ieee=synopsys

# Source files in dependency order (CustomWrapper entity must come first)
# Note: CustomWrapper.vhd provides the entity declaration that EnhancedSlotBlinker.vhd implements
SOURCES = ../MokuModules/CustomWrapper.vhd SlotBlinker.vhd EnhancedSlotBlinker.vhd

# Target name
TARGET = EnhancedSlotBlinker

# Default target - compile all files
all: syntax_check
	@echo "========================================"
	@echo "EnhancedSlotBlinker build complete!"
	@echo "========================================"

# Check syntax of all files
syntax_check: $(SOURCES)
	@echo "========================================"
	@echo "Checking VHDL syntax for EnhancedSlotBlinker..."
	@echo "========================================"
	@for file in $(SOURCES); do \
		echo "Compiling $$file..."; \
		$(GHDL) -a $(GHDL_FLAGS) $$file; \
		if [ $$? -eq 0 ]; then \
			echo "✓ $$(basename $$file .vhd) compiled successfully"; \
		else \
			echo "✗ $$(basename $$file .vhd) compilation failed"; \
			exit 1; \
		fi; \
	done
	@echo "========================================"
	@echo "All EnhancedSlotBlinker files compiled successfully!"
	@echo "========================================"

# Check syntax of individual files
check_main:
	@echo "Checking main SlotBlinker entity..."
	$(GHDL) -a $(GHDL_FLAGS) SlotBlinker.vhd

check_top:
	@echo "Checking top-level wrapper..."
	$(GHDL) -a $(GHDL_FLAGS) ../MokuModules/CustomWrapper.vhd
	$(GHDL) -a $(GHDL_FLAGS) SlotBlinker.vhd
	$(GHDL) -a $(GHDL_FLAGS) EnhancedSlotBlinker.vhd

# Create executable (elaboration)
elaborate: syntax_check
	@echo "========================================"
	@echo "Elaborating EnhancedSlotBlinker design..."
	@echo "========================================"
	$(GHDL) -e $(GHDL_FLAGS) CustomWrapper
	@echo "✓ Elaboration complete - CustomWrapper executable created"

# Run simulation (if testbench is available)
simulate: elaborate
	@echo "========================================"
	@echo "Running EnhancedSlotBlinker simulation..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) CustomWrapper --stop-time=1000ns
	@echo "✓ Simulation complete"

# Clean build artifacts
clean:
	@echo "Cleaning EnhancedSlotBlinker build artifacts..."
	rm -f *.o *.cf work-obj93.cf work-obj08.cf CustomWrapper
	@echo "✓ Clean complete"

# Show help
help:
	@echo "========================================"
	@echo "EnhancedSlotBlinker Makefile Help"
	@echo "========================================"
	@echo "Available targets:"
	@echo "  all         - Compile all files (default)"
	@echo "  syntax_check- Check syntax of all files"
	@echo "  check_main  - Check only main SlotBlinker entity"
	@echo "  check_top   - Check only top-level wrapper"
	@echo "  elaborate   - Create executable from compiled files"
	@echo "  simulate    - Run simulation (requires elaboration)"
	@echo "  clean       - Remove generated files"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "REFACTORED: Architecture-only approach for MCC compatibility"
	@echo "  - CustomWrapper.vhd provides entity declaration"
	@echo "  - EnhancedSlotBlinker.vhd provides architecture implementation"
	@echo ""
	@echo "Usage examples:"
	@echo "  make                    # Compile all files"
	@echo "  make check_main         # Check only main entity"
	@echo "  make check_top          # Check only top-level wrapper"
	@echo "  make elaborate          # Create executable"
	@echo "  make simulate           # Run simulation"
	@echo "  make clean             # Clean up build artifacts"

# Phony targets (don't represent actual files)
.PHONY: all syntax_check check_main check_top elaborate simulate clean help
