# BestSlotBlinker Pattern Summary

## Current 8 Patterns (control0(3 downto 0))

| Pattern | Code | Description | Output Range |
|---------|------|-------------|--------------|
| 0000 | 0 | **Square wave (50% duty cycle) - DEFAULT** | 0x0000 or 0x7FFF |
| 0001 | 1 | Sawtooth (linear ramp) | 0x0000 to 0xFFFF |
| 0010 | 2 | Triangle wave (folded sawtooth) | 0x0000 to 0x7FFF |
| 0011 | 3 | Sine approximation (16-step lookup) | 0x8000 to 0x7FFF |
| 0100 | 4 | **Improved LFSR random** | 0x0000 to 0xFFFF |
| 0101 | 5 | Staircase (4 steps) | 0x2000, 0x4000, 0x6000, 0x7FFF |
| 0110 | 6 | Pulse train (narrow pulses) | 0x0000 or 0x7FFF |
| 0111 | 7 | Alternating levels | 0x2000 or 0x6000 |

## LFSR Implementation Details

The random pattern (0100) now uses a proper 16-bit Linear Feedback Shift Register:
- **Taps**: Bits 15, 14, 13, 4
- **Length**: 65,535 states (maximal length for 16-bit)
- **Quality**: True pseudo-random sequence
- **Initialization**: Uses counter value for different starting points

## UART TX Pattern Implementation Analysis

### Code Complexity: ~25-35 lines of VHDL

#### Required Components:
1. **State Machine** (5-8 lines)
   - IDLE, START, DATA, STOP states
   
2. **Bit Timing** (3-5 lines)
   - Counter for baud rate timing
   - Bit position counter (0-7 for data bits)
   
3. **Message Buffer** (5-8 lines)
   - ROM or constant array for message
   - Example: "HELLO" = [0x48, 0x45, 0x4C, 0x4C, 0x4F]
   
4. **Output Logic** (5-8 lines)
   - Generate UART TX signal levels
   - START bit (low), DATA bits, STOP bit (high)
   
5. **State Transitions** (3-5 lines)
   - Next state logic based on timing and bit count

#### Implementation Options:
- **Replace existing pattern**: Convert one unused pattern (e.g., 1000-1111)
- **Add new pattern**: Extend to 16 patterns (4 bits → 5 bits)
- **Dedicated UART mode**: Special control bit enables UART for all outputs

#### Example UART Message:
```
START | D7 | D6 | D5 | D4 | D3 | D2 | D1 | D0 | STOP
  L   | H  | E  | L  | L  | O  | \n | \r |    |  H
```

### Benefits:
- **Debugging**: Easy identification on logic analyzer
- **Communication**: Can send status messages
- **Testing**: Verify timing and signal integrity
- **Integration**: Works with existing UART receivers

### Considerations:
- **Baud Rate**: Must match receiver expectations
- **Message Length**: Limited by pattern repetition rate
- **Timing**: Requires precise clock division
- **Compatibility**: May need level shifting for RS-232
