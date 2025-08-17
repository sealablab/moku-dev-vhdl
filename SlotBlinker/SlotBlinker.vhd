-- SlotBlinker/SlotBlinker.vhd
-- A minimal blinker that generates distinct patterns on all four outputs
-- Designed for easy identification on oscilloscope and logic analyzer

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity SlotBlinker is
  port (
    clk        : in  std_logic;
    reset      : in  std_logic;
    control0   : in  std_logic_vector(31 downto 0);
    -- Four distinct outputs with different patterns
    output_a   : out signed(15 downto 0);
    output_b   : out signed(15 downto 0);
    output_c   : out signed(15 downto 0);
    output_d   : out signed(15 downto 0)
  );
end entity;
  
architecture rtl of SlotBlinker is
  -- Control signal
  signal enable : std_logic;
  
  -- Single counter for all outputs
  signal counter : unsigned(15 downto 0) := (others => '0');

begin
  -- Enable control (active-low, bit 31 of control0)
  enable <= not control0(31);

  -- Single process generates all four outputs with different frequencies
  process(clk) 
  begin
    if rising_edge(clk) then
      if reset = '1' then
        counter <= (others => '0');
      elsif enable = '1' then
        -- Increment main counter every clock cycle
        counter <= counter + 1;
      end if;
    end if;
  end process;
      
  -- Assign outputs using arithmetic division for different frequencies
  -- Output A: Every clock cycle (fastest) - full counter
  output_a <= signed(counter);
  
  -- Output B: Every 4th cycle - counter / 4
  output_b <= signed(counter / 4);
  
  -- Output C: Every 16th cycle - counter / 16
  output_c <= signed(counter / 16);
  
  -- Output D: Every 64th cycle - counter / 64
  output_d <= signed(counter / 64);

end architecture rtl;
