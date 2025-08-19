# ProbeDriver - Complete Fault Injection Probe System


## Interface Specification


### Control Registers
| Port | Type | Width | Description |
|------|------|-------|-------------|
| `Control0` | in | 32 | Primary control register |
| `Control1` | in | 32 | Secondary control register |
| `Control2-Control15` | in | 32 | Reserved for future expansion |

## Control Register Mapping

### Control0 - Primary Control Register
```
Bit 31: Global Enable (EN)
Bit 30: Auto-arm Mode (AA)
Bit 29: Reserved
Bit 28: Status Clear (SC)
Bit 27-24: Clock Divider Selection (CD3:CD0)
Bit 23: Soft Trigger (ST)
Bit 22-16: Intensity Index (I6:I0) - 7-bit
Bit 15-0:  Pulse Duration (D15:D0) - 16-bit
```

**Detailed Bit Functions:**
- **Bit 31 (EN)**: Master enable for entire probe driver system
- **Bit 30 (AA)**: Auto-re-arm after cooldown completion
- **Bit 28 (SC)**: Clear sticky status flags and LED indicators
- **Bits 27-24 (CD3:CD0)**: 4-bit clock divider (÷1 to ÷32768)
- **Bit 23 (ST)**: Software-controlled trigger signal
- **Bits 22-16 (I6:I0)**: 7-bit intensity index (0-100 range)
- **Bits 15-0 (D15:D0)**: 16-bit pulse width in clock cycles

## Control1 - Secondary Control Register
```
Bit 31-16: Cooldown Period (C15:C0) - 16-bit
Bit 15-0:  Reserved for future use
```

**Detailed Bit Functions:**
- **Bits 31-16 (C15:C0)**: 16-bit cooldown duration in clock cycles
- **Bits 15-0**: Available for future configuration parameters

## Output Signal Mapping

### OutputA - Status Register
```
[15:5]: Reserved for future expansion (set to 0)
[4]:    Error indicator (future use)
[3]:    COOL_DOWN state active
[2]:    FIRED event occurred (sticky)
[1]:    FIRING state active
[0]:    ARMED state active
```

**Status Decoding Examples:**
- **0x0001**: ARMED - Ready to fire
- **0x0002**: FIRING - Actively driving probe
- **0x0004**: FIRED - Pulse completed (sticky flag)
- **0x0008**: COOL_DOWN - Cooling period active
- **0x000F**: All states active (error condition)

### OutputB - Trigger Output
- **During FIRING**: PROBE_TRIGGER_LEVEL
- **Other States**: Shows `0x0000`
- **Purpose**: Drive the (input) trigger of the attached Probe

### OutputC - Intensity Output
- **During FIRING**: Shows current probe intensity voltage
- **Other States**: Shows `0x0000`
- **Purpose**: Drive the 'intensity' input of attached Probe

### OutputD - Reserved
- **Current Value**: Always `0x0000`
- **Future Use**: Available for additional status or control signals

## Internal Architecture

### Key Internal Signals
| Signal | Type | Width | Purpose |
|--------|------|-------|---------|
| `probe_trigger_output` | signed | 16 | Core trigger output |
| `probe_intensity_output` | signed | 16 | Core intensity output |
| `probe_status_register` | std_logic_vector | 16 | Core status register |
| `probe_clk_en` | std_logic | 1 | Clock enable from divider |
| `status_leds` | std_logic_vector | 5 | LED status indicators |

### Soft Trigger Management
```vhdl
-- Automatically de-assert soft trigger after one clock cycle
soft_trigger_process: process(Clk)
begin
    if rising_edge(Clk) then
        if Reset = '1' then
            soft_trigger <= '0';
        else
            -- Set trigger high when control register goes high
            if soft_trigger_raw = '1' then
                soft_trigger <= '1';
            else
                -- De-assert after one cycle
                soft_trigger <= '0';
            end if;
        end if;
    end if;
end process;
```

**Purpose**: Prevents multiple probe firings from a single control register write by auto-de-asserting the trigger signal.

## Status LED Management

### LED Mapping
| LED | Status Bit | Description |
|-----|------------|-------------|
| LED0 | Bit 0 | ARMED state indicator |
| LED1 | Bit 1 | FIRING state indicator |
| LED2 | Bit 2 | FIRED event indicator (sticky) |
| LED3 | Bit 3 | COOL_DOWN state indicator |
| LED4 | Bit 4 | Error indicator (future use) |

### LED Behavior
- **Latch Logic**: LEDs remain on once set until explicitly cleared
- **Clear Mechanism**: LEDs reset via `status_clear` signal (Control0[28])
- **Reset Behavior**: All LEDs clear on system reset
- **Visual Feedback**: Provides immediate visual status indication

## Clock Management

### Clock Divider Integration
```vhdl
u_clk_divider: entity work.clock_divider
    generic map (
        DIVIDER_WIDTH => 4,               -- 4-bit divider for ProbeDriver
        MAX_DIVIDER => 15
    )
    port map (
        clk_in      => Clk,
        reset       => Reset,
        divider     => "0000" & clock_divider_sel,  -- Extend 4-bit to 16-bit
        enable      => '1',                         -- Always enabled
        clk_out     => open,                        -- Not used in ProbeDriver
        clk_out_en  => probe_clk_en                 -- Clock enable for ProbeDriver
    );
```

**Purpose**: Enables convenient debugging features by reducing clock frequency to the probe driver core
**Configuration**: 4-bit divider selection (0-15) provides 16 different frequency options

## Supporting Packages

### intensity_lut_pkg.vhd

The intensity lookup table package provides voltage-to-intensity mapping for safe probe operation.


**Key Features:**
- **Safety-First Design**: LUT serves as both intensity mapping and safety bounds
- **Configurable Range**: IntensityLut[0] = 0V (safe off), IntensityLut[100] = maximum safe output
- **Voltage Calibration**: ADC configured for 0x7FFF = 4.999999V, 3.3V ≈ 0x52AA
- **Safe Defaults**: Users can modify endpoints to adjust safe operating range

**Core Functions:**
```vhdl
function get_intensity_value(index : natural range 0 to 100) return signed;
function get_intensity_value_safe(index : std_logic_vector(6 downto 0)) return signed;
```

**Usage Example:**
```vhdl
-- Get intensity for 50% setting (1.65V)
intensity_50 := get_intensity_value(50);  -- Returns 0x0190
```

### probe_driver_pkg.vhd

The probe driver package provides shared types, constants, and utility functions for the entire system.

**Key Components:**
- **Type Definitions**: State machine states, status register types, configuration types
- **Safety Constants**: Minimum duration (100 cycles), minimum cooldown (1000 cycles)
- **Utility Functions**: Status bit manipulation, safe default value generation
- **State Management**: State-to-string conversion, status checking functions

**Core Types:**
```vhdl
type probe_state_type is (IDLE, ARMED, FIRING, COOL_DOWN);
subtype probe_status_type is std_logic_vector(15 downto 0);
subtype probe_intensity_index_type is std_logic_vector(6 downto 0);
```

**Safety Functions:**
```vhdl
function get_safe_intensity_index(intensity_in : probe_intensity_index_type) return probe_intensity_index_type;
function get_safe_duration(duration_in : probe_duration_type) return probe_duration_type;
function get_safe_cooldown(cooldown_in : probe_cooldown_type) return probe_cooldown_type;
```


#### Clock Divider Selection
- **High Performance**: Use divider 0-3 for maximum responsiveness
- **Power Saving**: Use divider 8-15 for reduced power consumption
- **Balanced**: Use divider 4-7 for typical operation

#### Intensity Configuration
- **Safe Operation**: Start with intensity index 10-20
- **Normal Operation**: Use intensity index 30-70
- **High Power**: Use intensity index 80-100 (monitor thermal conditions)

#### Timing Parameters
- **Minimum Duration**: 100 clock cycles recommended
- **Minimum Cooldown**: 1000 clock cycles for thermal safety
- **Typical Values**: Duration 1000-10000, Cooldown 5000-50000

## Usage Patterns

### Basic Operation Sequence
1. **Initialize**: Set Control0[31] = '1' to enable system
2. **Configure**: Set intensity, duration, and cooldown parameters
3. **Arm**: System automatically arms after enable
4. **Trigger**: Use Control0[23] or external trigger to fire probe
5. **Monitor**: Observe status via OutputA and LED indicators
6. **Clear**: Use Control0[28] to clear sticky status flags

### Advanced Operation
- **Auto Arm mode**: Set Control0[30] = '1' for auto-re-arming
- **Status Monitoring**: Use OutputA for real-time state monitoring
- **Event Detection**: Monitor OutputA[2] for pulse completion events

## Common Register Settings

### 1. Basic Probe Operation
```vhdl
-- Enable probe driver with auto-arm
Control0 <= x"80000064";  -- EN=1, AA=1, Duration=100
Control1 <= x"03E80000";  -- Cooldown=1000
```

### 2. Manual Trigger Mode
```vhdl
-- Enable without auto-arm, manual trigger
Control0 <= x"40000064";  -- EN=1, AA=0, Duration=100
Control1 <= x"03E80000";  -- Cooldown=1000
-- Then set bit 23 to trigger: Control0(23) <= '1';
```

### 3. Slow Clock Operation
```vhdl
-- Enable with 1/8 clock speed
Control0 <= x"83000064";  -- EN=1, AA=1, CD=3 (÷8), Duration=100
Control1 <= x"03E80000";  -- Cooldown=1000
```

### 4. Status Clear Operation
```vhdl
-- Clear all status flags and LEDs
Control0 <= x"10000000";  -- Status Clear=1 (bit 28)
-- Then clear it: Control0 <= x"00000000";
```

