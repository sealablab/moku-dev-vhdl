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
  signal pulse_counter : unsigned(31 downto 0) := (others => '0');
  signal cooldown_counter : unsigned(31 downto 0) := (others => '0');
  
  -- Control signals
  signal Intensity : unsigned(6 downto 0);
  
  -- Status register
  signal status_reg : std_logic_vector(4 downto 0) := (others => '0');
  
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
      
      -- ZeroInit mode detection: Check if all ControlRegisters are 0x00 (default state)
      if (PulseDuration_in = x"0000") and (CoolDown_in = x"0000") and (Intensity_index = "0000000") then
        zeroinit_mode <= '1';  -- Enable zeroinit mode
        zeroinit_completed <= '0';  -- Reset completion flag
        zeroinit_trigger <= '1';  -- Trigger zeroinit sequence
      else
        zeroinit_mode <= '0';  -- Disable zeroinit mode
        zeroinit_completed <= '0';
        zeroinit_trigger <= '0';
      end if;
      
      -- Use actual input values (or safe defaults in zeroinit mode)
      if zeroinit_mode = '1' then
        -- In zeroinit mode, use safe default values directly
        Intensity <= (others => '0');  -- Safe zero intensity (IntensityLut(0) = 0x0000)
        -- PulseDuration and CoolDown will use constants directly in state machine
      else
        -- Normal mode: use input values
        Intensity <= unsigned(Intensity_index);
        PulseDuration <= unsigned(PulseDuration_in);
        CoolDown <= unsigned(CoolDown_in);
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
          -- Actively firing the probe with duration
          if zeroinit_mode = '1' then
            -- In zeroinit mode, use safe constant
            if pulse_counter >= PulseMinDuration then
              current_state <= FIRED;
              cooldown_counter <= (others => '0');
              status_reg(2) <= '1';  -- Set bit 2 when entering FIRED
            else
              pulse_counter <= pulse_counter + 1;
            end if;
          else
            -- In normal mode, use input duration
            if pulse_counter >= PulseDuration then
              current_state <= FIRED;
              cooldown_counter <= (others => '0');
              status_reg(2) <= '1';  -- Set bit 2 when entering FIRED
            else
              pulse_counter <= pulse_counter + 1;
            end if;
          end if;
          
        when FIRED =>
          -- Pulse completed, start cooldown
          current_state <= COOL_DOWN;
          status_reg(3) <= '1';  -- Set bit 3 when entering COOL_DOWN
          
        when COOL_DOWN =>
          -- Wait for cooldown period
          if zeroinit_mode = '1' then
            -- In zeroinit mode, use safe constant
            if cooldown_counter >= ProbeCoolDownMin then
              current_state <= IDLE;
              -- Mark zeroinit sequence as completed
              zeroinit_completed <= '1';
            else
              cooldown_counter <= cooldown_counter + 1;
            end if;
          else
            -- In normal mode, use input cooldown
            if cooldown_counter >= CoolDown then
              current_state <= IDLE;
            else
              cooldown_counter <= cooldown_counter + 1;
            end if;
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



