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
    Intensity_index      : in  std_logic_vector(7 downto 0);
    PulseDuration_in  : in  std_logic_vector(31 downto 0);
    CoolDown_in       : in  std_logic_vector(31 downto 0);
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
  signal PulseDuration : unsigned(15 downto 0);  -- 16 bits for up to 65,535 cycles (~2.1 ms)
  signal CoolDown : unsigned(31 downto 0) := (others => '0');       -- 32 bits for up to 4,294,967,295 cycles (~137 seconds)
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
  signal clamped_intensity : integer range 0 to 100 := 0;  -- Initialize to 0
  
  -- Status register
  signal status_reg : std_logic_vector(4 downto 0) := (others => '0');
  
  -- Error tracking signals
  signal intensity_error : std_logic := '0';
  signal duration_error : std_logic := '0';
  signal cooldown_error : std_logic := '0';
  
  -- ZeroInit mode signals for automatic demonstration on reset
  signal zeroinit_mode : std_logic := '0';  -- Flag to indicate zeroinit mode
  signal zeroinit_completed : std_logic := '0';  -- Flag to prevent multiple zeroinit cycles
  signal zeroinit_trigger : std_logic := '0';  -- Internal trigger for zeroinit sequence

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
      intensity_error <= '0';         -- Initialize error signals to 0
      duration_error <= '0';
      cooldown_error <= '0';
      
      -- ZeroInit mode detection: Check if all ControlRegisters are 0x00 (default state)
      if (PulseDuration_in = x"00000000") and (CoolDown_in = x"00000000") and (Intensity_index = x"00") then
        zeroinit_mode <= '1';  -- Enable zeroinit mode
        zeroinit_completed <= '0';  -- Reset completion flag
        zeroinit_trigger <= '1';  -- Trigger zeroinit sequence
      else
        zeroinit_mode <= '0';  -- Disable zeroinit mode
        zeroinit_completed <= '0';
        zeroinit_trigger <= '0';
      end if;
      
      -- Use actual input values
      PulseDuration <= unsigned(PulseDuration_in(15 downto 0));
      CoolDown <= unsigned(CoolDown_in);
      Intensity <= unsigned(Intensity_index);
    
      -- In zeroinit mode, use safe defaults and skip validation
      if zeroinit_mode = '1' then
        -- Use safe default values directly
        clamped_intensity <= 0;  -- Safe zero intensity
        effective_duration <= PulseMinDuration;  -- Safe minimum duration
        -- CoolDown already set above
        
        -- No validation errors in zeroinit mode
        intensity_error <= '0';
        duration_error <= '0';
        cooldown_error <= '0';
      else
        -- Normal mode: do bounds checking
        -- Validate intensity to valid range (0-100) for lookup table - INCLUSIVE bounds
        -- Note: IntensityLut[0] = off, IntensityLut[1] = MinIntensity, IntensityLut[100] = MaxIntensity
        if to_integer(unsigned(Intensity_index)) >= ProbeIntensityMin and to_integer(unsigned(Intensity_index)) <= ProbeIntensityMax then
          clamped_intensity <= to_integer(unsigned(Intensity_index));
          intensity_error <= '0';  -- No error
        else
          clamped_intensity <= ProbeIntensityMin;  -- Default to safe value
          intensity_error <= '1';  -- Error: outside valid intensity range
        end if;
        
        -- Validate duration to valid range (PulseMinDuration to PulseMaxDuration) - INCLUSIVE bounds
        if unsigned(PulseDuration_in(15 downto 0)) >= PulseMinDuration and unsigned(PulseDuration_in(15 downto 0)) <= PulseMaxDuration then
          effective_duration <= unsigned(PulseDuration_in(15 downto 0));
          duration_error <= '0';  -- No error
        else
          effective_duration <= PulseMinDuration;  -- Default to safe value
          duration_error <= '1';  -- Error: outside valid duration range
        end if;
        
        -- Validate cooldown to minimum requirement - INCLUSIVE lower bound, no upper limit
        if unsigned(CoolDown_in) >= ProbeCoolDownMin then
          cooldown_error <= '0';  -- No error
        else
          cooldown_error <= '1';  -- Error: below minimum cooldown
        end if;
      end if;
      
      -- Set error bit (bit 4) if any error is detected
      if (intensity_error = '1') or (duration_error = '1') or (cooldown_error = '1') then
        status_reg(4) <= '1';  -- Set bit 4 high when any error is detected
      else
        status_reg(4) <= '0';  -- Clear bit 4 when no errors
      end if;
    else
      -- State machine logic ------------------------------------------------------
      case current_state is
        when IDLE =>
          -- Wait for enable signal OR auto-advance in zeroinit mode
          if enable = '1' or (zeroinit_mode = '1' and zeroinit_trigger = '1') then
            current_state <= ARMED;
            pulse_counter <= (others => '0');
            status_reg(0) <= '1';  -- Set bit 0 when entering ARMED
            if zeroinit_mode = '1' then
              zeroinit_trigger <= '0';  -- Clear trigger after use
            end if;
          end if;
          
        when ARMED =>
          -- Wait for trigger input OR auto-advance in zeroinit mode
          if trig_in = '1' or (zeroinit_mode = '1' and zeroinit_completed = '0') then
            current_state <= FIRING;
            pulse_counter <= (others => '0'); -- Start counting up from 0
            status_reg(1) <= '1';  -- Set bit 1 when entering FIRING
          end if;
          
        when FIRING =>
          -- Actively firing the probe with effective duration
          if pulse_counter >= effective_duration then
            current_state <= FIRED;
            cooldown_counter <= (others => '0');
            status_reg(2) <= '1';  -- Set bit 2 when entering FIRED
          else
            pulse_counter <= pulse_counter + 1;
          end if;
          
        when FIRED =>
          -- Pulse completed, start cooldown
          current_state <= COOL_DOWN;
          status_reg(3) <= '1';  -- Set bit 3 when entering COOL_DOWN
          
        when COOL_DOWN =>
          -- Wait for cooldown period
          if cooldown_counter >= CoolDown then
            current_state <= IDLE;
            -- Mark zeroinit sequence as completed
            if zeroinit_mode = '1' then
              zeroinit_completed <= '1';
            end if;
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
  
  intensity_out <= IntensityLut(clamped_intensity) when current_state = FIRING else (others => '0');  
  -- Status register output
  status_register <= status_reg;

end architecture; 



