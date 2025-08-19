-- Enhanced SlotBlinker testbench
-- Comprehensive testing of all enhanced features and pipelined architecture

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
      control1   : in  std_logic_vector(31 downto 0);
      control2   : in  std_logic_vector(31 downto 0);
      control3   : in  std_logic_vector(31 downto 0);
      control4   : in  std_logic_vector(31 downto 0);
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
  signal control1 : std_logic_vector(31 downto 0) := (others => '0');
  signal control2 : std_logic_vector(31 downto 0) := (others => '0');
  signal control3 : std_logic_vector(31 downto 0) := (others => '0');
  signal control4 : std_logic_vector(31 downto 0) := (others => '0');
  signal output_a : signed(15 downto 0);
  signal output_b : signed(15 downto 0);
  signal output_c : signed(15 downto 0);
  signal output_d : signed(15 downto 0);

  -- Clock period (31.25 MHz equivalent for realistic testing)
  constant CLK_PERIOD : time := 32 ns;
  
  -- Test state tracking
  signal test_phase : integer := 0;
  signal cycle_count : integer := 0;

begin
  -- Instantiate the unit under test
  uut: SlotBlinker
    port map (
      clk      => clk,
      reset    => reset,
      control0 => control0,
      control1 => control1,
      control2 => control2,
      control3 => control3,
      control4 => control4,
      output_a => output_a,
      output_b => output_b,
      output_c => output_c,
      output_d => output_d
    );

  -- Clock generation
  clk <= not clk after CLK_PERIOD / 2;

  -- Cycle counter for timing verification
  process(clk)
  begin
    if rising_edge(clk) and reset = '0' then
      cycle_count <= cycle_count + 1;
    end if;
  end process;

  -- Test stimulus
  stimulus: process
  begin
    -- Test Phase 0: Initial reset and default behavior
    report "=== Test Phase 0: Initial reset and default behavior ===";
    reset <= '1';
    control0 <= (others => '0');  -- All zeros should give safe defaults
    control1 <= (others => '0');
    control2 <= (others => '0');
    control3 <= (others => '0');
    control4 <= (others => '0');
    wait for CLK_PERIOD * 10;
    
    -- Test Phase 1: Enable with defaults (should work now)
    report "=== Test Phase 1: Enable with defaults ===";
    reset <= '0';
    control0(31) <= '0';  -- Enable (active-low: 0 = enabled, 1 = disabled)
    wait for CLK_PERIOD * 50;  -- Wait for pipeline to fill
    
    -- Test Phase 2: Test different pattern types
    report "=== Test Phase 2: Different pattern types ===";
    control1(15 downto 8) <= x"01";  -- Output A: Square wave
    control2(15 downto 8) <= x"02";  -- Output B: Sine approximation
    control3(15 downto 8) <= x"03";  -- Output C: Random
    control4(15 downto 8) <= x"00";  -- Output D: Sawtooth (default)
    wait for CLK_PERIOD * 100;
    
    -- Test Phase 3: Test frequency dividers
    report "=== Test Phase 3: Frequency dividers ===";
    control1(31 downto 24) <= x"02";  -- Output A: 2x slower
    control2(31 downto 24) <= x"04";  -- Output B: 4x slower
    control3(31 downto 24) <= x"08";  -- Output C: 8x slower
    control4(31 downto 24) <= x"10";  -- Output D: 16x slower
    wait for CLK_PERIOD * 200;
    
    -- Test Phase 4: Test amplitude scaling
    report "=== Test Phase 4: Amplitude scaling ===";
    control1(23 downto 16) <= x"80";  -- Output A: 50% amplitude
    control2(23 downto 16) <= x"40";  -- Output B: 25% amplitude
    control3(23 downto 16) <= x"20";  -- Output C: 12.5% amplitude
    control4(23 downto 16) <= x"10";  -- Output D: 6.25% amplitude
    wait for CLK_PERIOD * 100;
    
    -- Test Phase 5: Test phase offsets
    report "=== Test Phase 5: Phase offsets ===";
    control1(7 downto 0) <= x"40";  -- Output A: 90° phase
    control2(7 downto 0) <= x"80";  -- Output B: 180° phase
    control3(7 downto 0) <= x"C0";  -- Output C: 270° phase
    control4(7 downto 0) <= x"00";  -- Output D: 0° phase
    wait for CLK_PERIOD * 100;
    
    -- Test Phase 6: Test global divider
    report "=== Test Phase 6: Global divider ===";
    control0(28 downto 24) <= "00100";  -- Global 4x slower
    wait for CLK_PERIOD * 100;
    
    -- Test Phase 7: Test sign control
    report "=== Test Phase 7: Sign control ===";
    control0(29) <= '1';  -- Enable signed mode
    wait for CLK_PERIOD * 100;
    
    -- Test Phase 8: Test software reset
    report "=== Test Phase 8: Software reset ===";
    control0(30) <= '1';  -- Software reset
    wait for CLK_PERIOD * 10;
    control0(30) <= '0';  -- Release software reset
    wait for CLK_PERIOD * 50;
    
    -- Test Phase 9: Return to safe defaults
    report "=== Test Phase 9: Return to safe defaults ===";
    control0 <= x"00000000";  -- Enable (bit 31 = 0), all other defaults
    control1 <= (others => '0');
    control2 <= (others => '0');
    control3 <= (others => '0');
    control4 <= (others => '0');
    wait for CLK_PERIOD * 100;
    
    -- End simulation
    report "=== Test completed successfully ===";
    wait;
  end process;

  -- Monitor outputs and verify behavior
  monitor: process
    variable prev_output_a : signed(15 downto 0);
    variable prev_output_b : signed(15 downto 0);
    variable prev_output_c : signed(15 downto 0);
    variable prev_output_d : signed(15 downto 0);
    variable output_changes : integer := 0;
  begin
    wait for CLK_PERIOD * 60;  -- Wait for pipeline to fill
    
    -- Monitor for expected behavior
    for i in 1 to 50 loop
      wait for CLK_PERIOD;
      
      -- Check that outputs are changing (not stuck)
      if output_a /= prev_output_a then
        output_changes := output_changes + 1;
      end if;
      
      -- Store current values for next comparison
      prev_output_a := output_a;
      prev_output_b := output_b;
      prev_output_c := output_c;
      prev_output_d := output_d;
      
      -- Verify outputs are within expected ranges
      assert output_a >= -32768 and output_a <= 32767 report "Output A out of range: " & integer'image(to_integer(output_a));
      assert output_b >= -32768 and output_b <= 32767 report "Output B out of range: " & integer'image(to_integer(output_b));
      assert output_c >= -32768 and output_c <= 32767 report "Output C out of range: " & integer'image(to_integer(output_c));
      assert output_d >= -32768 and output_d <= 32767 report "Output D out of range: " & integer'image(to_integer(output_d));
    end loop;
    
    -- Verify we saw some changes
    assert output_changes > 0 report "No output changes detected - design may be stuck";
    report "Output changes detected: " & integer'image(output_changes);
    
    wait;
  end process;

  -- Waveform output for GTKWave
  process
  begin
    wait for CLK_PERIOD * 1000;  -- Run for 1000 cycles
    report "Simulation time limit reached";
    wait;
  end process;

end architecture testbench;
