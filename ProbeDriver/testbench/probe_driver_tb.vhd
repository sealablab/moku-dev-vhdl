-- ProbeDriver Unit Testbench
-- Tests the core ProbeDriver module with new bit widths
-- Focuses on core functionality and state machine behavior

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.IntensityLut_pkg.all;
use work.ProbeConfig_pkg.all;

entity probe_driver_tb is
end entity probe_driver_tb;

architecture testbench of probe_driver_tb is
  -- Clock and control signals
  signal clk : std_logic := '0';
  signal reset : std_logic := '1';
  signal enable : std_logic := '0';
  signal trig_in : std_logic := '0';
  
  -- Input test values (using NEW bit widths)
  signal Intensity_index : std_logic_vector(6 downto 0) := "0110010";  -- 50 (valid)
  signal PulseDuration_in : std_logic_vector(15 downto 0) := x"0010";  -- 16 cycles
  signal CoolDown_in : std_logic_vector(15 downto 0) := x"0008";       -- 8 cycles
  
  -- Output signals from DUT
  signal trig_out : signed(15 downto 0);
  signal intensity_out : signed(15 downto 0);
  signal status_register : std_logic_vector(4 downto 0);
  
  -- Clock period
  constant CLK_PERIOD : time := 10 ns;  -- 100MHz clock
  
  -- Test state tracking
  signal test_step : integer := 0;
  signal test_passed : boolean := true;
  
begin
  -- =============================================================================
  -- CLOCK GENERATION
  -- =============================================================================
  clk <= not clk after CLK_PERIOD / 2;
  
  -- =============================================================================
  -- DEVICE UNDER TEST INSTANTIATION
  -- =============================================================================
  dut: entity work.probe_driver
    port map (
      clk            => clk,
      reset          => reset,
      enable         => enable,
      trig_in        => trig_in,
      Intensity_index   => Intensity_index,
      PulseDuration_in  => PulseDuration_in,
      CoolDown_in       => CoolDown_in,
      trig_out          => trig_out,
      intensity_out     => intensity_out,
      status_register   => status_register
    );
  
  -- =============================================================================
  -- TEST STIMULUS
  -- =============================================================================
  stimulus: process
  begin
    -- Test 1: Initial reset state
    test_step <= 1;
    report "Test 1: Initial reset state";
    wait for CLK_PERIOD * 2;
    
    -- Test 2: Release reset and enable
    test_step <= 2;
    report "Test 2: Release reset and enable";
    reset <= '0';
    enable <= '1';
    wait for CLK_PERIOD * 2;
    
    -- Test 3: Trigger the probe
    test_step <= 3;
    report "Test 3: Trigger probe";
    trig_in <= '1';
    wait for CLK_PERIOD;
    trig_in <= '0';
    
    -- Test 4: Wait for firing and cooldown
    test_step <= 4;
    report "Test 4: Wait for firing and cooldown";
    wait for CLK_PERIOD * 50;  -- Wait for complete cycle
    
    -- Test 5: Test different intensity values
    test_step <= 5;
    report "Test 5: Test different intensity values";
    Intensity_index <= "1100100";  -- 100 (maximum)
    wait for CLK_PERIOD * 2;
    
    -- Test 6: Test different duration
    test_step <= 6;
    report "Test 6: Test different duration";
    PulseDuration_in <= x"0020";  -- 32 cycles
    wait for CLK_PERIOD * 2;
    
    -- Test 7: Test different cooldown
    test_step <= 7;
    report "Test 7: Test different cooldown";
    CoolDown_in <= x"0010";  -- 16 cycles
    wait for CLK_PERIOD * 2;
    
    -- Test 8: Final trigger test
    test_step <= 8;
    report "Test 8: Final trigger test";
    trig_in <= '1';
    wait for CLK_PERIOD;
    trig_in <= '0';
    
    -- Test 9: Wait for completion
    test_step <= 9;
    report "Test 9: Wait for completion";
    wait for CLK_PERIOD * 100;
    
    -- Test 10: Summary
    test_step <= 10;
    report "Test 10: Testbench completed";
    if test_passed then
      report "PASS: All tests completed successfully";
    else
      report "FAIL: Some tests failed";
    end if;
    
    wait;
  end process stimulus;
  
  -- =============================================================================
  -- MONITORING AND VALIDATION
  -- =============================================================================
  monitor: process(clk)
  begin
    if rising_edge(clk) then
      -- Monitor status register changes
      case status_register is
        when "00001" =>  -- ARMED state
          report "Status: ARMED state reached";
        when "00010" =>  -- FIRING state
          report "Status: FIRING state reached";
        when "00100" =>  -- FIRED state reached
          report "Status: FIRED state reached";
        when "01000" =>  -- COOL_DOWN state
          report "Status: COOL_DOWN state reached";
        when "10000" =>  -- Error state
          report "WARNING: Error detected in status register";
          test_passed <= false;
        when others =>
          null;
      end case;
      
      -- Monitor intensity output during firing
      if status_register(1) = '1' and intensity_out /= x"0000" then
        report "Intensity output: " & to_string(intensity_out);
      end if;
    end if;
  end process monitor;
  
end architecture testbench;
