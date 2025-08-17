# BestSlotBlinker

An enhanced version of the SlotBlinker with improved pattern generation and optimized design.

## Key Improvements

### 1. **Improved Random Pattern (LFSR)**
- Replaced simple XOR-based "random" with proper 16-bit Linear Feedback Shift Register
- **Taps**: Bits 15, 14, 13, 4 (maximal length sequence)
- **Period**: 65,535 states for true pseudo-random generation
- **Quality**: Much better randomness distribution

### 2. **Streamlined Pattern Set**
- Reduced from 16+ patterns to 8 optimized patterns
- Kept the most useful and distinctive waveforms
- Maintained pattern selection in `control0(3 downto 0)` as requested

### 3. **8 Implemented Patterns**
| Code | Pattern | Description |
|------|---------|-------------|
| 0000 | Sawtooth | Linear ramp (0x0000 to 0xFFFF) |
| 0001 | Square Wave | 50% duty cycle (0x0000 or 0x7FFF) |
| 0010 | Triangle | Folded sawtooth (0x0000 to 0x7FFF) |
| 0011 | Sine | 16-step approximation (-0x8000 to 0x7FFF) |
| 0100 | **LFSR Random** | **Improved pseudo-random sequence** |
| 0101 | Staircase | 4 discrete levels |
| 0110 | Pulse Train | Narrow pulses with long low periods |
| 0111 | Alternating | Two alternating levels |

## Control Register Layout

- **control0(3 downto 0)**: Pattern selection (8 patterns)
- **control0(28 downto 24)**: Global clock divider (1-32)
- **control0(29)**: Sign control (0=unsigned, 1=signed)
- **control0(30)**: Software reset
- **control0(31)**: nEnable (active-low)

## UART TX Pattern Analysis

The `PATTERN_SUMMARY.md` file contains a detailed analysis of implementing UART TX output:

- **Code Complexity**: ~25-35 lines of VHDL
- **Implementation**: State machine + timing + message buffer
- **Benefits**: Easy debugging, status messages, timing verification
- **Options**: Replace unused pattern or extend to 16 patterns

## Usage

1. Set `control0(3 downto 0)` to select desired pattern (0-7)
2. Configure individual output parameters via control1-4
3. Use global divider in `control0(28 downto 24)` for timing control
4. Enable/disable with `control0(31)` (nEnable)

## Files

- `BestSlotBlinker.vhd` - Main VHDL implementation
- `PATTERN_SUMMARY.md` - Detailed pattern documentation and UART analysis
- `README.md` - This overview file
