# SlotBlinker Makefile
# Builds the SlotBlinker bitstream

# VHDL source files
VHDL_SOURCES = SlotBlinker.vhd top_slot_blinker.vhd

# Target name
TARGET = SlotBlinker

# Default target
all: $(TARGET)

# Build the SlotBlinker
$(TARGET): $(VHDL_SOURCES)
	@echo "Building $(TARGET)..."
	# Add build commands here when ready to compile
	@echo "Build complete for $(TARGET)"

# Clean build artifacts
clean:
	@echo "Cleaning $(TARGET)..."
	rm -f *.o *.cf $(TARGET)

# Help target
help:
	@echo "Available targets:"
	@echo "  all     - Build the SlotBlinker (default)"
	@echo "  clean   - Remove build artifacts"
	@echo "  help    - Show this help message"

.PHONY: all clean help
