# SlotBlinker testbench Makefile
# Builds and runs the testbench

# VHDL source files
VHDL_SOURCES = ../SlotBlinker.vhd SlotBlinker_tb.vhd

# Testbench entity
TB_ENTITY = SlotBlinker_tb

# Default target
all: run_test

# Run the testbench
run_test: $(TB_ENTITY)
	@echo "Running testbench..."
	# Add simulation commands here when ready
	@echo "Testbench complete"

# Build the testbench
$(TB_ENTITY): $(VHDL_SOURCES)
	@echo "Building testbench..."
	# Add build commands here when ready
	@echo "Testbench build complete"

# Clean build artifacts
clean:
	@echo "Cleaning testbench..."
	rm -f *.o *.cf $(TB_ENTITY)

# Help target
help:
	@echo "Available targets:"
	@echo "  all       - Build and run testbench (default)"
	@echo "  run_test  - Run the testbench"
	@echo "  clean     - Remove build artifacts"
	@echo "  help      - Show this help message"

.PHONY: all run_test clean help
