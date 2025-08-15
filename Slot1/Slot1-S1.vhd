-- Slot1/Slot1-S1.vhd: Current idea is to hold the 'global' FI state in the left instrument (S1)
-- Freeing up S2 to host a specific Driver. 
-- JC ret2here:
-- features: control0[31] -> map to enable 
--          delay_in[31:0] -> 10-bit delay value (clock cycles)


-- mermaidjs
-- stateDiagram-v2
--    [*] --> IDLE
--    IDLE --> DELAY : enable = '1'
--    DELAY --> RUNNING : delay_counter >= delay_value
--    RUNNING --> IDLE : enable = '0'
--    RUNNING --> RUNNING : enable = '1' / cnt <= cnt + 1
--    DELAY --> DELAY : delay_counter < delay_value / delay_counter++
-- end mermaidjs


library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

constant TEN_SECOND_DELAY : unsigned(31 downto 0) := to_unsigned(312500000, 32);
-- Then assign: control1 <= std_logic_vector(TEN_SECOND_DELAY);

-- 1) entity port map (inputs and outputs)
entity Slot1_S1 is
  port (
    clk        : in  std_logic;
    reset      : in  std_logic;
    control0   : in  std_logic_vector(31 downto 0);
    delay_in   : in  std_logic_vector(31 downto 0);
    blink_out  : out signed(15 downto 0)
  );
end entity;
  
-- 2) architecture block (sort of like 'local' variables)
architecture rtl of Slot1_S1 is
  -- 2.1) 'local' variables aka 'signals' 
  signal enable : std_logic;
  signal cnt    : signed(31 downto 0) := (others => '0');
  signal delay_value : unsigned(31 downto 0) := (others => '0');
  signal delay_counter : unsigned(31 downto 0) := (others => '0');
  
  -- State machine type and signal
  type state_type is (IDLE, DELAY, RUNNING);
  signal current_state : state_type := IDLE;

-- 3) begin (synchronous logic)
begin
  enable <= not control0(31); -- active-low enable

-- 4) begin clocked synchronous logic
process(clk) 
begin
  if rising_edge(clk) then
    if reset = '1' then
      cnt <= (others => '0');           -- reset logic
      delay_value <= unsigned(delay_in(31 downto 0)); -- read delay value from delay_in
      delay_counter <= (others => '0'); -- reset delay counter
      current_state <= IDLE;            -- reset state machine
    else
      case current_state is
        when IDLE =>
          if enable = '1' then
            current_state <= DELAY;     -- transition to delay state
            delay_counter <= (others => '0'); -- reset delay counter
          end if;
          
        when DELAY =>
          if delay_counter >= delay_value then
            current_state <= RUNNING;   -- delay complete, enter running state
            delay_counter <= (others => '0'); -- reset delay counter
          else
            delay_counter <= delay_counter + 1; -- increment delay counter
          end if;
          
        when RUNNING =>
          if enable = '1' then
            cnt <= cnt + 1;            -- counter updates only when enabled
          else
            current_state <= IDLE;     -- return to idle if disabled
          end if;
          
        when others =>
          current_state <= IDLE;       -- safety default
      end case;
    end if;                           -- closes: if reset / else
  end if;                             -- closes: if rising_edge(clk)
end process;                          -- end process (clk)
      
-- 5) Synchronous logic:       
-- Note: This is generally where you want to take your (internal) signals (i.e. `cnt`)
--       and assign them to your pre-defined outputs (`blink_out`)
  blink_out <= signed(cnt);

end architecture;
-- Slot1/Slot1-S1.vhd: Slot1 S1 Driver with delay feature
