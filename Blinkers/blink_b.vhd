-- Binkers/blink_b.vhd: The most basic of blinkers
-- features: control0[31] -> map to enable 

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

-- 1) entity port map (inputs and outputs)
entity blink_b is
  port (
    clk        : in  std_logic;
    reset      : in  std_logic;
    control0   : in  std_logic_vector(31 downto 0);
    blink_out  : out signed(15 downto 0)
  );
end entity;
  
-- 2) architecture block (sort of like 'local' variables)
architecture rtl of blink_b is
  -- 2.1) 'local' variables aka 'signals' 
  signal enable : std_logic;
  signal cnt    : signed(15 downto 0) := (others => '0');

-- 3) begin (syncronous logic)
begin
  enable <= not control0(31); -- active-low enable


-- 4) begin clocked syncronous loghic
process(clk) 
begin
    -- note: this is the 'normal' way you will see reset handled
  if rising_edge(clk) then
    if reset = '1' then
      cnt <= (others => '0');  -- reset logic
    elsif enable = '1' then
      cnt <= cnt + 1;          -- counter updates only when enabled
    end if;                    -- closes: if reset / elsif enable
  end if;                      -- closes: if rising_edge(clk)
end process;                 -- end process (clk)
      
-- 5 Synronous logic:       
-- Note: This is generally where you want to take your (internal) signals (i.e. `cnt`)
--       and assign them to your pre-defined outputs (`blink_out`)
  blink_out <= signed(cnt);

end architecture;
-- Blinkers/blink_b.vhd: The most basic of blinkers 


