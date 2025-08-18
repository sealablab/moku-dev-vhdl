# Clock Divider Module

## Overview
The `clk_divider` is a standalone VHDL module that provides configurable clock division for the ProbeDriver system. It generates a clock enable signal that can be used to slow down the entire ProbeDriver operation.

## Features
- **Configurable Division**: 16 different divider ratios (0-15)
- **Synchronous Design**: Uses synchronous reset and counter-based division
- **Dynamic Switching**: Divider ratio can be changed during operation
- **Clock Enable Output**: Generates a single-cycle high pulse for each divided period
- **Standalone Module**: Can be tested independently before integration

## Divider Ratios

| CR0[27:24] | Decimal | Division Ratio | Output Frequency |
|-------------|---------|----------------|------------------|
| 0000        | 0       | No division    | Input clock      |
| 0001        | 1       | ÷2             | Input clock ÷ 2  |
| 0010        | 2       | ÷4             | Input clock ÷ 4  |
| 0011        | 3       | ÷8             | Input clock ÷ 8  |
| 0100        | 4       | ÷16            | Input clock ÷ 16 |
| 0101        | 5       | ÷32            | Input clock ÷ 32 |
| 0110        | 6       | ÷64            | Input clock ÷ 64 |
| 0111        | 7       | ÷128           | Input clock ÷ 128|
| 1000        | 8       | ÷256           | Input clock ÷ 256|
| 1001        | 9       | ÷512           | Input clock ÷ 512|
| 1010        | 10      | ÷1024          | Input clock ÷ 1024|
| 1011        | 11      | ÷2048          | Input clock ÷ 2048|
| 1100        | 12      | ÷4096          | Input clock ÷ 4096|
| 1101        | 13      | ÷8192          | Input clock ÷ 8192|
| 1110        | 14      | ÷16384         | Input clock ÷ 16384|
| 1111        | 15      | ÷32768         | Input clock ÷ 32768|

## Interface

### Ports
- **`clk_in`** (in): Input clock signal
- **`reset`** (in): Synchronous reset signal (active high)
- **`divider_sel`** (in): 4-bit divider selection (CR0[27:24])
- **`clk_en`** (out): Clock enable output (high for one input clock cycle)

## Quick Start

### **Run Tests**
```bash
make test          # Run all tests
```

### **Available Commands**
```bash
make              # Run all tests (default)
make test         # Run tests
make compile      # Compile only
make clean        # Clean generated files
make help         # Show available commands
```

## File Structure
```
clk-divider/
├── clk_divider.vhd          # Main module implementation
├── testbench/               # Testbench directory
│   ├── clk_divider_tb.vhd   # Clean, focused testbench
│   ├── Makefile             # Testbench build system
│   └── README.md            # Testbench documentation
├── Makefile                 # Main build system
└── README.md                # This overview
```

## Testing

The testbench is designed to be **clean, focused, and efficient**:
- **Minimal Output**: Only essential test progress reports
- **Focused Testing**: Tests key divider ratios and functionality
- **Automatic Exit**: Simulation exits automatically when tests complete
- **Timeout Protection**: 100μs timeout prevents infinite simulation

For detailed testbench information, see: **[testbench/README.md](testbench/README.md)**

## Integration

### **Basic Instantiation**
```vhdl
u_clk_divider: entity work.clk_divider
    port map (
        clk_in      => input_clock,
        reset       => system_reset,
        divider_sel => control_register(27 downto 24),
        clk_en      => clock_enable
    );
```

### **ProbeDriver Integration**
The `clk_en` output can be used to gate the ProbeDriver logic:
```vhdl
-- In ProbeDriver process
if rising_edge(clk_in) and clk_en = '1' then
    -- ProbeDriver logic here
    -- This will only execute when clock enable is high
end if;
```

## Benefits

1. **Flexible Timing**: Allows ProbeDriver to run at different speeds
2. **Debugging Support**: Slower operation makes debugging easier
3. **Power Management**: Can reduce power consumption when full speed isn't needed
4. **Compatibility**: Similar to BestSlotBlinker approach
5. **Standalone Design**: Can be tested independently before integration

## Status

✅ **Phase 1 Complete**: Standalone module with clean testbench
🔄 **Phase 2 Pending**: ProbeDriver integration
🔄 **Phase 3 Pending**: System validation

The module is **fully functional and ready for integration** with the ProbeDriver system.
