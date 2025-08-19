# ProbeDriver Register Description

## **Overview**
The ProbeDriver uses a 16-register control interface (Control0-Control15) with the first two registers (Control0, Control1) actively used for configuration and control. The remaining registers (Control2-Control15) are reserved for future expansion.

## **Active Control Registers**

### **Control0 (32 bits) - Main Configuration Register**
```
┌─────────────────────────────────────────────────────────────────┐
│ 31 │ 30 │ 29 │ 28 │ 27 │ 26 │ 25 │ 24 │ 23 │ 22 │ 21 │ 20 │ 19 │ 18 │ 17 │ 16 │ 15 │ 14 │ 13 │ 12 │ 11 │ 10 │ 09 │ 08 │ 07 │ 06 │ 05 │ 04 │ 03 │ 02 │ 01 │ 00 │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│ EN │ AA │  R  │  R  │ CD3 │ CD2 │ CD1 │ CD0 │ ST  │ I6 │ I5 │ I4 │ I3 │ I2 │ I1 │ I0 │ D15│ D14│ D13│ D12│ D11│ D10│ D09│ D08│ D07│ D06│ D05│ D04│ D03│ D02│ D01│ D00│
└─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘
```

**Bit Definitions:**
- **Bit 31 (EN)**: Global Enable
  - `0` = Disabled (IDLE state)
  - `1` = Enabled (normal operation)
- **Bit 30 (AA)**: Auto-Arm
  - `0` = Manual arm required
  - `1` = Auto-arm on reset (transitions to ARMED state)
- **Bits 29-28**: Reserved (future use)
- **Bits 27-24 (CD3:CD0)**: Clock Divider Selection
  - `0000` = ÷1 (full speed)
  - `0001` = ÷2 (half speed)
  - `0010` = ÷4 (quarter speed)
  - `0011` = ÷8 (eighth speed)
  - `0100` = ÷16 (sixteenth speed)
  - `0101` = ÷32 (thirty-second speed)
  - `0110` = ÷64 (sixty-fourth speed)
  - `0111` = ÷128 (one-twenty-eighth speed)
  - `1000` = ÷256 (one-two-fifty-sixth speed)
  - `1001` = ÷512 (one-five-twelfth speed)
  - `1010` = ÷1024 (one-thousand-twenty-fourth speed)
  - `1011` = ÷2048 (one-two-thousand-forty-eighth speed)
  - `1100` = ÷4096 (one-four-thousand-ninety-sixth speed)
  - `1101` = ÷8192 (one-eight-thousand-one-ninety-second speed)
  - `1110` = ÷16384 (one-sixteen-thousand-three-hundred-eighty-fourth speed)
  - `1111` = ÷32768 (one-thirty-two-thousand-seven-hundred-sixty-eighth speed)
- **Bit 23 (ST)**: Soft Trigger
  - `0` = No trigger
  - `1` = Trigger probe (when armed)
- **Bits 22-16 (I6:I0)**: Intensity Index (7 bits)
  - Range: `0000000` to `1100100` (0-100 decimal)
  - Maps to intensity lookup table
  - `0000000` = minimum intensity
  - `1100100` = maximum intensity
- **Bits 15-0 (D15:D0)**: Pulse Duration (16 bits)
  - Range: `0x0000` to `0xFFFF` (0-65535 clock cycles)
  - Minimum safe value: `0x0064` (100 clock cycles)

### **Control1 (32 bits) - Timing and Status Control**
```
┌─────────────────────────────────────────────────────────────────┐
│ 31 │ 30 │ 29 │ 28 │ 27 │ 26 │ 25 │ 24 │ 23 │ 22 │ 21 │ 20 │ 19 │ 18 │ 17 │ 16 │ 15 │ 14 │ 13 │ 12 │ 11 │ 10 │ 09 │ 08 │ 07 │ 06 │ 05 │ 04 │ 03 │ 02 │ 01 │ 00 │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│ C15│ C14│ C13│ C12│ C11│ C10│ C09│ C08│ C07│ C06│ C05│ C04│ C03│ C02│ C01│ C00│ SC │  R  │  R  │  R  │  R  │  R  │  R  │  R  │  R  │  R  │  R  │  R  │  R  │  R  │  R  │  R  │
└─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘
```

**Bit Definitions:**
- **Bits 31-16 (C15:C0)**: Cooldown Period (16 bits)
  - Range: `0x0000` to `0xFFFF` (0-65535 clock cycles)
  - Minimum safe value: `0x03E8` (1000 clock cycles)
  - Time between probe pulses
- **Bit 15 (SC)**: Status Clear
  - `0` = No action
  - `1` = Clear all sticky status flags and LED indicators
- **Bits 14-0**: Reserved (future use)

## **Status Register (OutputA)**
The status register provides real-time state information and is mapped to OutputA:

```
┌─────────────────────────────────────────────────────────────────┐
│ 15 │ 14 │ 13 │ 12 │ 11 │ 10 │ 09 │ 08 │ 07 │ 06 │ 05 │ 04 │ 03 │ 02 │ 01 │ 00 │
├─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┼─────┤
│  R  │  R  │  R  │  R  │  R  │  R  │  R  │  R  │  R  │  R  │  R  │ ERR│ COOL│ FIRED│FIRING│ARMED│
└─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘
```

**Status Bits:**
- **Bit 0 (ARMED)**: Probe is armed and ready to fire
- **Bit 1 (FIRING)**: Probe is currently firing
- **Bit 2 (FIRED)**: Sticky flag - probe has completed firing (cleared by status clear)
- **Bit 3 (COOL_DOWN)**: Probe is in cooldown period
- **Bit 4 (ERROR)**: Reserved for future error conditions
- **Bits 5-15**: Reserved for future expansion

## **Common Register Settings for Debugging**

### **1. Basic Probe Operation**
```vhdl
-- Enable probe driver with auto-arm
Control0 <= x"80000064";  -- EN=1, AA=1, Duration=100
Control1 <= x"03E80000";  -- Cooldown=1000, Status Clear=0
```

### **2. Manual Trigger Mode**
```vhdl
-- Enable without auto-arm, manual trigger
Control0 <= x"40000064";  -- EN=1, AA=0, Duration=100
Control1 <= x"03E80000";  -- Cooldown=1000
-- Then set bit 23 to trigger: Control0(23) <= '1';
```

### **3. Slow Clock Operation**
```vhdl
-- Enable with 1/8 clock speed
Control0 <= x"83000064";  -- EN=1, AA=1, CD=3 (÷8), Duration=100
Control1 <= x"03E80000";  -- Cooldown=1000
```

### **4. High Intensity, Long Duration**
```vhdl
-- Maximum intensity (100), long pulse
Control0 <= x"806400FF";  -- EN=1, AA=1, Intensity=100, Duration=255
Control1 <= x"0FFF0000";  -- Cooldown=4095
```

### **5. Status Monitoring**
```vhdl
-- Monitor status via OutputA
-- Bit 0: Armed status
-- Bit 1: Firing status  
-- Bit 2: Fired (sticky)
-- Bit 3: Cooldown status
-- Bit 4: Error status
```

### **6. Status Clear Operation**
```vhdl
-- Clear all status flags and LEDs
Control1 <= x"00008000";  -- Status Clear=1
-- Then clear it: Control1 <= x"00000000";
```

## **Output Port Mapping**

| Port | Description | Content |
|------|-------------|---------|
| **OutputA** | Status Register | 16-bit status with state information |
| **OutputB** | Trigger Threshold | Shows `0x4000` when firing, `0x0000` otherwise |
| **OutputC** | Intensity Output | Current intensity value during firing, `0x0000` otherwise |
| **OutputD** | Reserved | Always `0x0000` (future use) |

## **State Machine Flow**

```
    RESET
       │
       ▼
     IDLE ──[EN=1]──► ARMED ──[Trigger]──► FIRING ──[Duration]──► COOL_DOWN
       ▲                                    │                        │
       │                                    ▼                        │
       └─────────────────────────────── FIRED ◄──────────────────────┘
```

## **Debugging Tips**

1. **Check Global Enable**: Ensure Control0(31) = '1' for operation
2. **Monitor Status**: Use OutputA to track state machine progression
3. **Verify Timing**: Check duration and cooldown values are above minimums
4. **Clock Division**: Use Control0(27:24) to slow operation for debugging
5. **Status Clear**: Use Control1(15) to reset sticky flags and LEDs
6. **Auto-Arm**: Set Control0(30) = '1' for automatic arming after reset

## **Reserved Registers**
- **Control2-Control15**: Reserved for future expansion
- **Current Value**: All bits set to 0
- **Future Use**: Advanced triggering, configuration storage, performance monitoring
