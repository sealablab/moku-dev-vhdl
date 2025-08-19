# SlotBlinker testbench Makefile
# Builds and runs the testbench using GHDL

# GHDL compiler and flags
GHDL = ghdl
GHDL_FLAGS = --std=08 --ieee=synopsys

# VHDL source files
VHDL_SOURCES = ../SlotBlinker.vhd SlotBlinker_tb.vhd

# Testbench entity
TB_ENTITY = SlotBlinker_tb

# Default target
all: run_test

# Build the testbench
$(TB_ENTITY): $(VHDL_SOURCES)
	@echo "========================================"
	@echo "Building SlotBlinker testbench..."
	@echo "========================================"
	@for file in $(VHDL_SOURCES); do \
		echo "Compiling $$file..."; \
		$(GHDL) -a $(GHDL_FLAGS) $$file; \
		if [ $$? -eq 0 ]; then \
			echo "✓ $$(basename $$file .vhd) compiled successfully"; \
		else \
			echo "✗ $$(basename $$file .vhd) compilation failed"; \
			exit 1; \
		fi; \
	done
	@echo "Elaborating testbench..."
	$(GHDL) -e $(GHDL_FLAGS) $(TB_ENTITY)
	@echo "✓ Testbench build complete"

# Run the testbench
run_test: $(TB_ENTITY)
	@echo "========================================"
	@echo "Running SlotBlinker testbench..."
	@echo "========================================"
	$(GHDL) -r $(GHDL_FLAGS) $(TB_ENTITY) --stop-time=2000ns --wave=SlotBlinker_tb.ghw
	@echo "✓ Testbench simulation complete"
	@echo "✓ Waveform file 'SlotBlinker_tb.ghw' created"

# Check syntax only
syntax_check: $(VHDL_SOURCES)
	@echo "========================================"
	@echo "Checking VHDL syntax for testbench..."
	@echo "========================================"
	@for file in $(VHDL_SOURCES); do \
		echo "Checking $$file..."; \
		$(GHDL) -s $(GHDL_FLAGS) $$file; \
		if [ $$? -eq 0 ]; then \
			echo "✓ $$(basename $$file .vhd) syntax OK"; \
		else \
			echo "✗ $$(basename $$file .vhd) syntax errors"; \
			exit 1; \
		fi; \
	done
	@echo "✓ All files have valid syntax"

# View waveform (if GTKWave is available)
view_wave: run_test
	@echo "========================================"
	@echo "Opening waveform viewer..."
	@echo "========================================"
	@if command -v gtkwave >/dev/null 2>&1; then \
		gtkwave SlotBlinker_tb.ghw; \
	else \
		echo "GTKWave not found. Install it to view waveforms."; \
		echo "Waveform file 'SlotBlinker_tb.ghw' was created."; \
	fi

# Clean build artifacts
clean:
	@echo "Cleaning testbench build artifacts..."
	rm -f *.o *.cf work-obj93.cf work-obj08.cf $(TB_ENTITY) *.ghw
	@echo "✓ Clean complete"

# Help target
help:
	@echo "========================================"
	@echo "SlotBlinker Testbench Makefile Help"
	@echo "========================================"
	@echo "Available targets:"
	@echo "  all           - Build and run testbench (default)"
	@echo "  run_test      - Run the testbench simulation"
	@echo "  syntax_check  - Check VHDL syntax only"
	@echo "  view_wave     - View waveform in GTKWave"
	@echo "  clean         - Remove build artifacts"
	@echo "  help          - Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make                    # Build and run testbench"
	@echo "  make syntax_check       # Check syntax only"
	@echo "  make run_test           # Run simulation"
	@echo "  make view_wave          # View waveform"
	@echo "  make clean             # Clean up build artifacts"

.PHONY: all run_test syntax_check view_wave clean help
