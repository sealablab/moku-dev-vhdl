# BestSlotBlinker Control Register Layout

## Overview

The BestSlotBlinker uses 5 control registers (CR0-CR4) for comprehensive configuration. Each output now has its own pattern selection in the lower 4 bits of its control register, making it much easier for humans to configure individual outputs.

## Control Register 0 (CR0) - Global Control & Timing

| Bits | Name | Description | Default |
|------|------|-------------|---------|
| 31 | nEnable | **nEnable** (active-low enable) | 1 (disabled) |
| 30 | ~~soft_reset~~ | **REMOVED** (redundant with main reset) | - |
| 29 | sign_control | Sign control (0=unsigned, 1=signed) | 0 (unsigned) |
| 28-24 | global_divider | Global clock divider (1-32) | 1 |
| 23-4 | reserved | Reserved for future use | - |
| 3-0 | reserved | **Reserved for future use** | - |

## Control Register 1 (CR1) - Output A Configuration

| Bits | Name | Description | Default |
|------|------|-------------|---------|
| 31-24 | freq_div_a | Frequency divider (1-256) | 1 |
| 23-16 | amp_scale_a | Amplitude scale (0-255) | 255 (100%) |
| 15-8 | pattern_type_a | Pattern type (0-255) or use local pattern | 0 |
| 7-4 | phase_offset_a | **Phase offset (0-15)** | 0 |
| **3-0** | **pattern_a** | **Local pattern selection (0-7)** | 0 |

## Control Register 2 (CR2) - Output B Configuration

| Bits | Name | Description | Default |
|------|------|-------------|---------|
| 31-24 | freq_div_b | Frequency divider (1-256) | 4 |
| 23-16 | amp_scale_b | Amplitude scale (0-255) | 255 (100%) |
| 15-8 | pattern_type_b | Pattern type (0-255) or use local pattern | 0 |
| 7-4 | phase_offset_b | **Phase offset (0-15)** | 0 |
| **3-0** | **pattern_b** | **Local pattern selection (0-7)** | 0 |

## Control Register 3 (CR3) - Output C Configuration

| Bits | Name | Description | Default |
|------|------|-------------|---------|
| 31-24 | freq_div_c | Frequency divider (1-256) | 16 |
| 23-16 | amp_scale_c | Amplitude scale (0-255) | 255 (100%) |
| 15-8 | pattern_type_c | Pattern type (0-255) or use local pattern | 0 |
| 7-4 | phase_offset_c | **Phase offset (0-15)** | 0 |
| **3-0** | **pattern_c** | **Local pattern selection (0-7)** | 0 |

## Control Register 4 (CR4) - Output D Configuration

| Bits | Name | Description | Default |
|------|------|-------------|---------|
| 31-24 | freq_div_d | Frequency divider (1-256) | 64 |
| 23-16 | amp_scale_d | Amplitude scale (0-255) | 255 (100%) |
| 15-8 | pattern_type_d | Pattern type (0-255) or use local pattern | 0 |
| 7-4 | phase_offset_d | **Phase offset (0-15)** | 0 |
| **3-0** | **pattern_d** | **Local pattern selection (0-7)** | 0 |

## Key Changes from Previous Version

### ✅ **Improvements Made:**

1. **Individual Pattern Selection**: Each output now has its own pattern selector in bits 3-0 of its control register
2. **Eliminated Redundancy**: Removed CR0 bit 30 (software reset) as it duplicated the main reset signal
3. **Streamlined Phase Offset**: Reduced phase offset from 8 bits (0-255) to 4 bits (0-15) for more practical use
4. **Human-Friendly Design**: Much easier to configure individual outputs without cross-referencing registers

### 🔄 **Pattern Selection Logic:**

- **Local Pattern**: If `pattern_type_X(15 downto 8)` = 0, use `pattern_X(3 downto 0)` from same register
- **Extended Pattern**: If `pattern_type_X(15 downto 8)` > 0, use that value as pattern type
- **No Global Fallback**: Each output is completely independent with its own pattern selection

### 📝 **Usage Examples:**

#### **Configure Output A for Square Wave:**
```vhdl
control1 <= x"01000001";  -- freq_div=1, amp_scale=255, pattern_type=0, phase=0, pattern=1 (square)
```

#### **Configure Output B for Triangle Wave:**
```vhdl
control2 <= x"04000002";  -- freq_div=4, amp_scale=255, pattern_type=0, phase=0, pattern=2 (triangle)
```

#### **Configure Output C for LFSR Random:**
```vhdl
control3 <= x"10000004";  -- freq_div=16, amp_scale=255, pattern_type=0, phase=0, pattern=4 (random)
```

#### **Configure Output D for Pulse Train:**
```vhdl
control4 <= x"40000006";  -- freq_div=64, amp_scale=255, pattern_type=0, phase=0, pattern=6 (pulse)
```

## Benefits of New Layout

1. **Intuitive Configuration**: Each output's pattern is in its own register
2. **Reduced Confusion**: No need to remember which register controls which output's pattern
3. **Easier Debugging**: Can quickly identify and modify individual output settings
4. **Better Maintainability**: Clear separation of concerns between outputs
5. **Practical Phase Offsets**: 4-bit phase offset (0-15) is more than sufficient for most applications
