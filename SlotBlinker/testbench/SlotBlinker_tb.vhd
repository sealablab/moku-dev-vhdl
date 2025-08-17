-- SlotBlinker testbench
-- Tests the SlotBlinker entity to verify correct operation

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity SlotBlinker_tb is
end entity;

architecture testbench of SlotBlinker_tb is
  -- Component declaration
  component SlotBlinker is
    port (
      clk        : in  std_logic;
      reset      : in  std_logic;
      control0   : in  std_logic_vector(31 downto 0);
      output_a   : out signed(15 downto 0);
      output_b   : out signed(15 downto 0);
      output_c   : out signed(15 downto 0);
      output_d   : out signed(15 downto 0)
    );
  end component;

  -- Test signals
  signal clk      : std_logic := '0';
  signal reset    : std_logic := '1';
  signal control0 : std_logic_vector(31 downto 0) := (others => '0');
  signal output_a : signed(15 downto 0);
  signal output_b : signed(15 downto 0);
  signal output_c : signed(15 downto 0);
  signal output_d : signed(15 downto 0);

  -- Clock period
  constant CLK_PERIOD : time := 10 ns;

begin
  -- Instantiate the unit under test
  uut: SlotBlinker
    port map (
      clk      => clk,
      reset    => reset,
      control0 => control0,
      output_a => output_a,
      output_b => output_b,
      output_c => output_c,
      output_d => output_d
    );

  -- Clock generation
  clk <= not clk after CLK_PERIOD / 2;

  -- Test stimulus
  stimulus: process
  begin
    -- Initial reset
    reset <= '1';
    control0 <= (others => '0');
    wait for CLK_PERIOD * 5;
    
    -- Release reset and enable
    reset <= '0';
    control0(31) <= '0';  -- Enable (active low)
    wait for CLK_PERIOD * 100;
    
    -- Disable
    control0(31) <= '1';  -- Disable (active high)
    wait for CLK_PERIOD * 20;
    
    -- Re-enable
    control0(31) <= '0';  -- Enable again
    wait for CLK_PERIOD * 50;
    
    -- End simulation
    wait;
  end process;

  -- Monitor outputs
  monitor: process
  begin
    wait for CLK_PERIOD * 10;  -- Wait for initial setup
    
    -- Monitor for a few cycles
    for i in 1 to 20 loop
      wait for CLK_PERIOD;
      -- Outputs should be incrementing at different rates
    end loop;
    
    wait;
  end process;

end architecture testbench;
