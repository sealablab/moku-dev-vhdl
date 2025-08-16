# ProbeDriver Testbench

This directory contains a simple testbench for testing the `ProbeDriver.vhd` module.

## Files

- `ProbeDriver_tb.vhd` - The main testbench file
- `Makefile` - Build and run scripts for GHDL
- `README.md` - This file

## What the Testbench Tests

The testbench performs the following tests:

1. **Reset and Basic Functionality** - Tests reset behavior
2. **Enable Probe Driver** - Tests enable signal functionality
3. **Trigger Probe** - Tests trigger input and state transitions
4. **Complete Cycle** - Waits for firing + cooldown cycle
5. **Status Register** - Checks that all status bits are set after cycle
6. **Error Conditions** - Tests error handling with invalid inputs
7. **Final Status** - Final verification

## Running the Testbench

### Prerequisites
- GHDL installed and available in PATH
- VHDL-2008 support

### Basic Usage

```bash
# Navigate to testbench directory
cd Slot2/testbench

# Run the testbench (compiles and runs)
make run

# Just compile without running
make compile

# Clean generated files
make clean

# Show help
make help
```

### Manual GHDL Commands

If you prefer to run GHDL manually:

```bash
# Compile DUT files first
ghdl -a --std=08 --ieee=synopsys ../IntensityLut.vhd
ghdl -a --std=08 --ieee=synopsys ../ProbeDriver.vhd

# Compile testbench
ghdl -a --std=08 --ieee=synopsys ProbeDriver_tb.vhd

# Elaborate
ghdl -e --std=08 --ieee=synopsys ProbeDriver_tb

# Run simulation
ghdl -r --std=08 --ieee=synopsys ProbeDriver_tb --stop-time=1000ns
```

## Output

The testbench generates:
- Console output showing test progress and status register values
- A VCD file (`ProbeDriver_tb.vcd`) for waveform viewing
- Status register monitoring showing state transitions

## Expected Results

- Status register should accumulate bits as states are visited
- Error bit (bit 4) should be set when invalid inputs are provided
- All operational bits (0-3) should be set after a complete cycle

## Customization

You can modify the testbench to:
- Change test values in the stimulus process
- Add more test scenarios
- Modify timing parameters
- Add assertions for automated verification
