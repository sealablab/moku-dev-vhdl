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

### **Global Control (CR0)**
- **control0(31)**: nEnable (active-low enable)
- **control0(30)**: Sign control (0=unsigned, 1=signed)
- **control0(29)**: Reserved for future use
- **control0(28 downto 24)**: Global clock divider (1-32)
- **control0(23 downto 16)**: Reserved for future use
- **control0(15 downto 0)**: **16-bit bit-mask field** for advanced experimentation

### **Individual Output Control (CR1-CR4)**
Each output has its own control register with **local pattern selection**:
- **controlX(31 downto 24)**: Frequency divider (1-256)
- **controlX(23 downto 16)**: Amplitude scale (0-255)
- **controlX(15 downto 8)**: Extended pattern type (0=use local pattern)
- **controlX(7 downto 4)**: Phase offset (0-15)
- **controlX(3 downto 0)**: **Local pattern selection (0-7)** ⭐

**Key Improvement**: Each output's pattern is now configured in its own register for easier human configuration!

### 🎭 **Advanced Bit-Mask Feature**
The 16-bit bit-mask field in CR0[15:0] allows advanced users to selectively mask out specific bits from all pattern outputs. This enables pattern experimentation, custom waveform creation, and bit-level debugging while maintaining full backward compatibility.

## UART TX Pattern Analysis

The `PATTERN_SUMMARY.md` file contains a detailed analysis of implementing UART TX output:

- **Code Complexity**: ~25-35 lines of VHDL
- **Implementation**: State machine + timing + message buffer
- **Benefits**: Easy debugging, status messages, timing verification
- **Options**: Replace unused pattern or extend to 16 patterns

## Usage

### **Quick Configuration (Recommended)**
1. Set each output's pattern in the lower 4 bits of its control register:
   - `control1(3 downto 0)` = Output A pattern (0-7)
   - `control2(3 downto 0)` = Output B pattern (0-7)
   - `control3(3 downto 0)` = Output C pattern (0-7)
   - `control4(3 downto 0)` = Output D pattern (0-7)

2. Configure frequency and amplitude per output:
   - `controlX(31 downto 24)` = Frequency divider
   - `controlX(23 downto 16)` = Amplitude scale

3. Use global divider in `control0(28 downto 24)` for timing control
4. Enable/disable with `control0(31)` (nEnable)

### **Example Configuration**
```vhdl
-- Output A: Square wave, full amplitude, no frequency division
control1 <= x"01000001";  -- pattern=1 (square), amp=255, freq_div=1

-- Output B: Triangle wave, half amplitude, 4x slower
control2 <= x"04000002";  -- pattern=2 (triangle), amp=128, freq_div=4

-- Output C: LFSR random, full amplitude, 16x slower  
control3 <= x"10000004";  -- pattern=4 (random), amp=255, freq_div=16
```

## Files

- `BestSlotBlinker.vhd` - Main VHDL implementation
- `PATTERN_SUMMARY.md` - Detailed pattern documentation and UART analysis
- `README.md` - This overview file
