-- Slot2/Slot2-ProbeDriver.vhd: 
-- This is the 'reference' implementation of a very basic probe driver.
-- Note: As an added benefit, this probe driver happens to be compatible with the Riscure DS1120A
--
-- ZEROINIT MODE: When all ControlRegisters are 0x00 (default state), the module automatically
-- executes one complete state machine cycle using safe default values:
--   - Intensity: 0 (safe minimum, valid)
--   - Duration: PulseMinDuration (16 cycles, using actual minimum constant)  
--   - Cooldown: ProbeCoolDownMin (24 cycles, using actual minimum constant)
-- This provides observable behavior for debugging while ensuring safety and using unified constants. 

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.IntensityLut_pkg.all;
use work.ProbeConfig_pkg.all;

-- =============================================================================
-- ENTITY - Port definitions (inputs and outputs)
-- =============================================================================
entity probe_driver is
  port (
    clk        : in  std_logic;
    reset      : in  std_logic;
    enable     : in  std_logic;
    trig_in    : in  std_logic;
   
    -- Begin Probe Driver 'API'
    -- Note: These input registers are only read during Reset.
    Intensity_index      : in  std_logic_vector(6 downto 0);
    PulseDuration_in  : in  std_logic_vector(15 downto 0);
    CoolDown_in       : in  std_logic_vector(15 downto 0);
    -- Note: These output registers are only written during Reset.
    trig_out         : out signed(15 downto 0);
    intensity_out    : out signed(15 downto 0);
    status_register  : out std_logic_vector(4 downto 0)
    -- End Probe Driver 'API'
  );
end entity;
  
-- =============================================================================
-- ARCHITECTURE - Implementation details
-- =============================================================================
architecture rtl of probe_driver is
  -- Type definitions
  type intensity_lut_type is array (0 to 100) of signed(15 downto 0);
  
  -- Signal declarations
  signal PulseDuration : unsigned(15 downto 0);  -- 16 bits for up to 65,535 cycles (~2.1 ms at 100MHz)
  signal CoolDown : unsigned(15 downto 0) := (others => '0');       -- 16 bits for up to 65,535 cycles (~2.1 ms at 100MHz)
  signal cnt    : signed(15 downto 0) := (others => '0');
  
  -- State machine signals
  type state_type is (IDLE, ARMED, FIRING, FIRED, COOL_DOWN);
  signal current_state : state_type := IDLE;
  
  -- Timing counters
  signal pulse_counter : unsigned(15 downto 0) := (others => '0');
  signal cooldown_counter : unsigned(15 downto 0) := (others => '0');
  
  -- Control signals
  signal Intensity : unsigned(6 downto 0);
  
  -- Status register
  signal status_reg : std_logic_vector(4 downto 0) := (others => '0');
  
  -- Safe defaults logic: when inputs are 0x00, use safe minimum values
  
  -- Auto-fire on reset: fires once using safe defaults after first enable
  signal reset_fired : std_logic := '0';

-- =============================================================================
-- BEGIN - Main logic starts here
-- =============================================================================
begin

-- =============================================================================
-- CLOCKED PROCESS - State machine and timing logic
-- =============================================================================
process(clk) 
begin
  if rising_edge(clk) then
    if reset = '1' then
      -- Reset logic
      current_state <= IDLE;
      pulse_counter <= (others => '0');
      cooldown_counter <= (others => '0');
      cnt <= (others => '0');
      status_reg <= (others => '0');  -- Initialize status register to 0
      reset_fired <= '0';  -- Reset the auto-fire flag
      
      -- Safe defaults: use minimum values when inputs are 0x00, otherwise use input values
      if (Intensity_index = "0000000") then
        Intensity <= "0000001";  -- Safe minimum intensity (IntensityLut[1] = smallest observable output)
      else
        Intensity <= unsigned(Intensity_index);
      end if;
      
      if (PulseDuration_in = x"0000") then
        PulseDuration <= PulseMinDuration;  -- Safe minimum duration
      else
        PulseDuration <= unsigned(PulseDuration_in);
      end if;
      
      if (CoolDown_in = x"0000") then
        CoolDown <= ProbeCoolDownMin;  -- Safe minimum cooldown
      else
        CoolDown <= unsigned(CoolDown_in);
      end if;
    else
      -- State machine logic ------------------------------------------------------
      case current_state is
        when IDLE =>
          -- Wait for enable signal
          if enable = '1' then
            current_state <= ARMED;
            pulse_counter <= (others => '0');
            status_reg(0) <= '1';  -- Set bit 0 when entering ARMED
            
            -- Auto-fire once on first enable after reset
            if reset_fired = '0' then
              reset_fired <= '1';  -- Mark as fired
            end if;
          end if;
          
        when ARMED =>
          -- Wait for trigger input OR auto-advance on first fire after reset
          if trig_in = '1' or (reset_fired = '0') then
            current_state <= FIRING;
            -- Initialize pulse counter to duration value
            pulse_counter <= PulseDuration;
            status_reg(1) <= '1';  -- Set bit 1 when entering FIRING
          end if;
          
        when FIRING =>
          -- Actively firing the probe with duration
          if pulse_counter = 0 then
            -- Duration complete, move to FIRED state
            current_state <= FIRED;
            cooldown_counter <= (others => '0');
            status_reg(2) <= '1';  -- Set bit 2 when entering FIRED
          else
            -- Decrement counter
            pulse_counter <= pulse_counter - 1;
          end if;
          
        when FIRED =>
          -- Pulse completed, start cooldown
          current_state <= COOL_DOWN;
          status_reg(3) <= '1';  -- Set bit 3 when entering COOL_DOWN
          
        when COOL_DOWN =>
          -- Wait for cooldown period (CoolDown already set correctly based on mode)
          if cooldown_counter >= CoolDown then
            current_state <= IDLE;
          else
            cooldown_counter <= cooldown_counter + 1;
          end if;
          
        when others =>
          current_state <= IDLE;
      end case;
      
      -- Update general counter when enabled
      if enable = '1' then
        cnt <= cnt + 1;
      end if;
    end if;
  end if;
end process;
      
-- =============================================================================
-- OUTPUT LOGIC - Combinational output assignments
-- =============================================================================
  trig_out <= ProbeTrigger_Threshold when current_state = FIRING else (others => '0');
  
  intensity_out <= IntensityLut(to_integer(Intensity)) when current_state = FIRING else (others => '0');  
  -- Status register output
  status_register <= status_reg;

end architecture; 



