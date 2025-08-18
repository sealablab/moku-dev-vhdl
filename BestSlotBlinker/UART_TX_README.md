# UART TX Driver for BestSlotBlinker

A standalone UART TX driver module that can be used independently or integrated with the BestSlotBlinker pattern generator.

## Features

### 🚀 **Core Functionality**
- **Standard UART Protocol**: START bit + 8 data bits + STOP bit
- **Configurable Baud Rate**: Generic parameter for easy customization
- **16 Pre-defined Messages**: Built-in message ROM with common characters
- **State Machine Design**: Clean, reliable transmission control
- **Status Signals**: Busy and done indicators for external control

### ⚙️ **Configurable Parameters**
- **Clock Frequency**: Generic `CLK_FREQ_HZ` (default: 100 MHz)
- **Baud Rate**: Generic `BAUD_RATE` (default: 115,200 bps)
- **Message Selection**: 4-bit selector for 16 different messages

### 📡 **Message ROM Contents**
| Index | Hex | ASCII | Description |
|-------|-----|-------|-------------|
| 0 | 0x48 | "H" | Capital H |
| 1 | 0x45 | "E" | Capital E |
| 2 | 0x4C | "L" | Capital L |
| 3 | 0x4F | "O" | Capital O |
| 4 | 0x21 | "!" | Exclamation mark |
| 5 | 0x3F | "?" | Question mark |
| 6 | 0x2E | "." | Period |
| 7 | 0x2C | "," | Comma |
| 8 | 0x20 | " " | Space |
| 9 | 0x0A | LF | Line feed (newline) |
| 10 | 0x0D | CR | Carriage return |
| 11 | 0x00 | NUL | Null character |
| 12 | 0x41 | "A" | Capital A |
| 13 | 0x42 | "B" | Capital B |
| 14 | 0x43 | "C" | Capital C |
| 15 | 0x44 | "D" | Capital D |

## Port Interface

### **Input Ports**
- `clk`: System clock input
- `reset`: Active-high reset signal
- `enable`: Transmission trigger (rising edge sensitive)
- `message_sel`: 4-bit message selector (0-15)

### **Output Ports**
- `uart_tx`: UART TX signal (idle high, active low)
- `busy`: Transmission in progress indicator
- `done`: Transmission complete pulse (one clock cycle)

## Usage Examples

### **1. Standalone Usage**
```vhdl
-- Instantiate with custom clock frequency and baud rate
uart_driver : UART_TX_Driver
  generic map (
    CLK_FREQ_HZ => 50_000_000,  -- 50 MHz clock
    BAUD_RATE   => 9600          -- 9600 baud
  )
  port map (
    clk         => clk,
    reset       => reset,
    enable      => uart_enable,
    message_sel => "0000",       -- Send "H"
    uart_tx     => uart_tx_pin,
    busy        => uart_busy,
    done        => uart_done
  );
```

### **2. Simple Control Logic**
```vhdl
-- Send message when button pressed
process(clk, reset)
begin
  if reset = '1' then
    uart_enable <= '0';
  elsif rising_edge(clk) then
    if button_pressed = '1' and uart_busy = '0' then
      uart_enable <= '1';
    else
      uart_enable <= '0';
    end if;
  end if;
end process;
```

### **3. Message Cycling**
```vhdl
-- Cycle through messages automatically
process(clk, reset)
begin
  if reset = '1' then
    message_sel <= (others => '0');
  elsif rising_edge(clk) then
    if uart_done = '1' then
      message_sel <= message_sel + 1; -- Next message
    end if;
  end if;
end process;
```

## Integration with BestSlotBlinker

### **Option 1: Separate Output Pin**
- Keep pattern generator outputs unchanged
- Add UART TX as additional output
- Use `BestSlotBlinker_with_UART.vhd` example

### **Option 2: Replace Pattern Output**
- Modify one output to generate UART signal
- Requires pattern selection logic changes
- More complex but saves pins

### **Option 3: Dedicated UART Mode**
- Add control bit to enable UART mode
- All outputs become UART TX signals
- Maximum UART functionality

## Timing Characteristics

### **Transmission Time**
- **1 Byte**: 10 bits × (1/baud_rate)
- **115,200 bps**: ~87 μs per byte
- **9600 bps**: ~1.04 ms per byte

### **Clock Requirements**
- **Minimum**: 8 × baud_rate for reliable operation
- **Recommended**: 16 × baud_rate or higher
- **Example**: 115,200 bps needs ≥921.6 kHz clock

## Customization Options

### **1. Add Custom Messages**
```vhdl
-- Modify MESSAGE_ROM constant
constant MESSAGE_ROM : message_array_t := (
  x"48", -- "H"
  x"45", -- "E"  
  x"4C", -- "L"
  x"4C", -- "L"
  x"4F", -- "O"
  x"0A", -- LF
  x"0D", -- CR
  -- ... add more messages
);
```

### **2. Variable Message Length**
- Extend to support different message lengths
- Add length field to message ROM
- Modify state machine for variable transmission

### **3. External Message Input**
- Replace ROM with external message input
- Add message valid signal
- Support for dynamic message content

## Debugging and Testing

### **Logic Analyzer Setup**
- **Trigger**: Rising edge on `enable`
- **Signals**: `uart_tx`, `busy`, `done`
- **Expected**: START(0) + DATA(8) + STOP(1)

### **Oscilloscope Setup**
- **Timebase**: 1-10 μs/div for 115,200 bps
- **Trigger**: Falling edge on `uart_tx`
- **Expected**: Clean square wave with proper timing

### **Common Issues**
- **Wrong baud rate**: Check CLK_FREQ_HZ and BAUD_RATE generics
- **No transmission**: Verify `enable` signal timing
- **Corrupted data**: Check clock stability and timing constraints

## Files

- `UART_TX_Driver.vhd` - Main UART TX driver module
- `BestSlotBlinker_with_UART.vhd` - Integration example
- `UART_TX_README.md` - This documentation file
