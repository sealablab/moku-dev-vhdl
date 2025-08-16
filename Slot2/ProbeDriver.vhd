-- Slot2/Slot2-ProbeDriver.vhd: 
-- This is the 'reference' implementation of a very basic probe driver.
-- Note: As an added benefit, this probe driver happens to be compatible with the Riscure DS1120A 

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.IntensityLut_pkg.all;

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
    Intensity_index      : in  std_logic_vector(7 downto 0);
    PulseDuration_in  : in  std_logic_vector(31 downto 0);
    CoolDown_in       : in  std_logic_vector(31 downto 0);
    -- Note: These output registers are only written during Reset.
    trig_out         : out std_logic;
    intensity_out    : out signed(15 downto 0)
    -- End Probe Driver 'API'
  );
end entity;
  
-- =============================================================================
-- ARCHITECTURE - Implementation details
-- =============================================================================
architecture rtl of probe_driver is
  -- Constants - Configuration values for the probe driver
  constant ProbeMinDuration : unsigned(15 downto 0) := to_unsigned(2, 16);      -- Minimum pulse duration (clock cycles)
  constant ProbeMaxDuration : unsigned(15 downto 0) := to_unsigned(32, 16);     -- Maximum pulse duration (clock cycles)  
  constant ProbeCoolDownMin : unsigned(15 downto 0) := to_unsigned(1, 16);      -- Probe cool down period (clock cycles) 
  -- Type definitions
  type intensity_lut_type is array (0 to 100) of signed(15 downto 0);
  
  -- Signal declarations
  signal PulseDuration : unsigned(15 downto 0);  -- 16 bits for up to 65,535 cycles (~2.1 ms)
  signal CoolDown : unsigned(31 downto 0);       -- 32 bits for up to 4,294,967,295 cycles (~137 seconds)
  signal cnt    : signed(15 downto 0) := (others => '0');
  
  -- State machine signals
  type state_type is (IDLE, ARMED, FIRING, FIRED, COOL_DOWN);
  signal current_state : state_type := IDLE;
  
  -- Timing counters
  signal pulse_counter : unsigned(31 downto 0) := (others => '0');
  signal cooldown_counter : unsigned(31 downto 0) := (others => '0');
  
  -- Control signals
  signal effective_duration : unsigned(15 downto 0);
  signal Intensity : unsigned(7 downto 0);
  signal clamped_intensity : integer range 0 to 100;

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
      
      -- Load input values during reset
      PulseDuration <= unsigned(PulseDuration_in(15 downto 0));
      CoolDown <= unsigned(CoolDown_in);
      Intensity <= unsigned(Intensity_index);
      
      -- Clamp intensity to valid range (0-100) for lookup table
      if to_integer(unsigned(Intensity_index)) <= 100 then
        clamped_intensity <= to_integer(unsigned(Intensity_index  ));
      else
        clamped_intensity <= 100;
        -- TODO: We should track / count the number of times we've exceeded the maximum intensity
      end if;
      
      -- Calculate effective duration (max of PulseDuration and ProbeMinDuration)
      if unsigned(PulseDuration_in(15 downto 0)) > ProbeMinDuration then
        effective_duration <= unsigned(PulseDuration_in(15 downto 0));
      else
        effective_duration <= ProbeMinDuration;
        -- TODO: We should track / count the number of times we've exceeded the minimum duration
      end if;
      
      -- Calculate effective cooldown (max of CoolDown_in and ProbeCoolDownMin)
      if unsigned(CoolDown_in(15 downto 0)) > ProbeCoolDownMin then
        CoolDown <= unsigned(CoolDown_in(15 downto 0));
      else
        CoolDown <= unsigned(ProbeCoolDownMin);
        -- TODO: We should track / count the number of times we've exceeded the minimum cooldown
      end if;
    else
      -- State machine logic ------------------------------------------------------
      case current_state is
        when IDLE =>
          -- Wait for enable signal
          if enable = '1' then
            current_state <= ARMED;
            pulse_counter <= (others => '0');
          end if;
          
        when ARMED =>
          -- Wait for trigger input
          if trig_in = '1' then
            current_state <= FIRING;
            pulse_counter <= (others => '0'); -- Start counting up from 0
          end if;
          
        when FIRING =>
          -- Actively firing the probe with effective duration
          if pulse_counter >= effective_duration then
            current_state <= FIRED;
            cooldown_counter <= (others => '0');
          else
            pulse_counter <= pulse_counter + 1;
          end if;
          
        when FIRED =>
          -- Pulse completed, start cooldown
          current_state <= COOL_DOWN;
          
        when COOL_DOWN =>
          -- Wait for cooldown period
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
  trig_out <= '1' when current_state = FIRING else '0';
  
  -- Intensity output based on state and user input
  intensity_out <= IntensityLut(clamped_intensity) when current_state = FIRING else  -- User-specified intensity when firing
                   IntensityLut(0);                                                 -- Zero intensity otherwise

end architecture; 



