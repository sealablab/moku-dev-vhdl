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
  -- Control signals
  signal enable : std_logic;
  
  -- Counters for different frequencies
  signal cnt_a : unsigned(15 downto 0) := (others => '0');
  signal cnt_b : unsigned(15 downto 0) := (others => '0');
  signal cnt_c : unsigned(15 downto 0) := (others => '0');
  signal cnt_d : unsigned(15 downto 0) := (others => '0');
  
  -- Frequency dividers for different speeds
  signal div_a : unsigned(7 downto 0) := (others => '0');
  signal div_b : unsigned(7 downto 0) := (others => '0');
  signal div_c : unsigned(7 downto 0) := (others => '0');
  signal div_d : unsigned(7 downto 0) := (others => '0');

begin
  -- Enable control (active-low, bit 31 of control0)
  enable <= not control0(31);

  -- Output A: Fast counter (every clock cycle when enabled)
  process(clk) 
  begin
    if rising_edge(clk) then
      if reset = '1' then
        cnt_a <= (others => '0');
      elsif enable = '1' then
        cnt_a <= cnt_a + 1;
      end if;
    end if;
  end process;
  
  -- Output B: Medium speed counter (every 4th clock cycle)
  process(clk) 
  begin
    if rising_edge(clk) then
      if reset = '1' then
        cnt_b <= (others => '0');
        div_b <= (others => '0');
      elsif enable = '1' then
        div_b <= div_b + 1;
        if div_b = "00000011" then  -- Every 4th cycle
          cnt_b <= cnt_b + 1;
          div_b <= (others => '0');
        end if;
      end if;
    end if;
  end process;
  
  -- Output C: Slow counter (every 16th clock cycle)
  process(clk) 
  begin
    if rising_edge(clk) then
      if reset = '1' then
        cnt_c <= (others => '0');
        div_c <= (others => '0');
      elsif enable = '1' then
        div_c <= div_c + 1;
        if div_c = "00001111" then  -- Every 16th cycle
          cnt_c <= cnt_c + 1;
          div_c <= (others => '0');
        end if;
      end if;
    end if;
  end process;
  
  -- Output D: Very slow counter (every 64th clock cycle)
  process(clk) 
  begin
    if rising_edge(clk) then
      if reset = '1' then
        cnt_d <= (others => '0');
        div_d <= (others => '0');
      elsif enable = '1' then
        div_d <= div_d + 1;
        if div_d = "00111111" then  -- Every 64th cycle
          cnt_d <= cnt_d + 1;
          div_d <= (others => '0');
        end if;
      end if;
    end if;
  end process;
      
  -- Assign outputs - convert unsigned counters to signed for output
  output_a <= signed(cnt_a);
  output_b <= signed(cnt_b);
  output_c <= signed(cnt_c);
  output_d <= signed(cnt_d);

end architecture rtl;
