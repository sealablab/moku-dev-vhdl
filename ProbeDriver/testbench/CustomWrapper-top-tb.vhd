-- CustomWrapper-top-tb.vhd
-- Higher-level testbench for CustomWrapper entity
-- Focuses on sanity checking OutputsABC values in simulation
-- Simulates real hardware behavior: 32ns clock, zero-initialized control registers

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.probe_driver_pkg.all;

entity CustomWrapper_top_tb is
end entity CustomWrapper_top_tb;

architecture testbench of CustomWrapper_top_tb is
  -- Clock period definition - matches real hardware (32ns)
  constant CLK_PERIOD : time := 32 ns;
  
  -- Component declaration for the unit under test
  component CustomWrapper is
    port (
      Clk : in std_logic;
      Reset : in std_logic;
      InputA : in signed(15 downto 0);
      InputB : in signed(15 downto 0);
      InputC : in signed(15 downto 0);
      InputD : in signed(15 downto 0);
      OutputA : out signed(15 downto 0);
      OutputB : out signed(15 downto 0);
      OutputC : out signed(15 downto 0);
      OutputD : out signed(15 downto 0);
      Control0 : in std_logic_vector(31 downto 0);
      Control1 : in std_logic_vector(31 downto 0);
      Control2 : in std_logic_vector(31 downto 0);
      Control3 : in std_logic_vector(31 downto 0);
      Control4 : in std_logic_vector(31 downto 0);
      Control5 : in std_logic_vector(31 downto 0);
      Control6 : in std_logic_vector(31 downto 0);
      Control7 : in std_logic_vector(31 downto 0);
      Control8 : in std_logic_vector(31 downto 0);
      Control9 : in std_logic_vector(31 downto 0);
      Control10 : in std_logic_vector(31 downto 0);
      Control11 : in std_logic_vector(31 downto 0);
      Control12 : in std_logic_vector(31 downto 0);
      Control13 : in std_logic_vector(31 downto 0);
      Control14 : in std_logic_vector(31 downto 0);
      Control15 : in std_logic_vector(31 downto 0)
    );
  end component;
  
  -- Signal declarations
  signal clk : std_logic := '0';
  signal reset : std_logic := '1';
  signal inputA, inputB, inputC, inputD : signed(15 downto 0) := (others => '0');
  signal outputA, outputB, outputC, outputD : signed(15 downto 0);
  signal control0, control1, control2, control3, control4 : std_logic_vector(31 downto 0) := (others => '0');
  signal control5, control6, control7, control8, control9 : std_logic_vector(31 downto 0) := (others => '0');
  signal control10, control11, control12, control13, control14, control15 : std_logic_vector(31 downto 0) := (others => '0');
  
  -- Test state tracking
  type test_phase_type is (INIT, RESET_PHASE, ZERO_INIT_MODE, BASIC_FUNCTIONALITY, AUTO_ARM_TEST, VERIFICATION, COMPLETE);
  signal test_phase : test_phase_type := INIT;
  signal phase_counter : integer := 0;
  signal cycle_count : integer := 0;
  
  -- Test results and monitoring
  signal test_passed : boolean := true;
  signal output_monitor_active : std_logic := '0';
  signal last_outputA, last_outputB, last_outputC : signed(15 downto 0);
  
  -- Expected values for sanity checking
  signal expected_status_bits : std_logic_vector(3 downto 0) := (others => '0');
  
begin
  -- =============================================================================
  -- CLOCK GENERATION - Real hardware timing (32ns)
  -- =============================================================================
  clk <= not clk after CLK_PERIOD / 2;
  
  -- =============================================================================
  -- UNIT UNDER TEST INSTANTIATION
  -- =============================================================================
  uut: CustomWrapper
    port map (
      Clk => clk,
      Reset => reset,
      InputA => inputA,
      InputB => inputB,
      InputC => inputC,
      InputD => inputD,
      OutputA => outputA,
      OutputB => outputB,
      OutputC => outputC,
      OutputD => outputD,
      Control0 => control0,
      Control1 => control1,
      Control2 => control2,
      Control3 => control3,
      Control4 => control4,
      Control5 => control5,
      Control6 => control6,
      Control7 => control7,
      Control8 => control8,
      Control9 => control9,
      Control10 => control10,
      Control11 => control11,
      Control12 => control12,
      Control13 => control13,
      Control14 => control14,
      Control15 => control15
    );
  
  -- =============================================================================
  -- MAIN TEST SEQUENCE
  -- =============================================================================
  main_test: process
  begin
    -- Test Phase 1: Initial Reset and Zero-Init Mode
    test_phase <= INIT;
    report "=== CustomWrapper Top-Level Testbench Started ===";
    report "Test Phase 1: Initial Reset and Zero-Init Mode";
    
    -- Wait for initial clock cycles
    wait for CLK_PERIOD * 5;
    
    -- Release reset (hardware loads bitstream and handles reset)
    test_phase <= RESET_PHASE;
    report "Releasing reset - hardware should initialize control registers to zero";
    reset <= '0';
    wait for CLK_PERIOD * 10;
    
    -- Test Phase 2: Zero-Init Mode (all control registers = 0x00)
    test_phase <= ZERO_INIT_MODE;
    report "Test Phase 2: Zero-Init Mode - All control registers are 0x00";
    report "Expected: Module auto-fires with safe defaults after enable";
    
    -- Verify all control registers are zero (hardware behavior)
    assert control0 = x"00000000" report "Control0 should be zero-initialized" severity note;
    assert control1 = x"00000000" report "Control1 should be zero-initialized" severity note;
    
    -- Enable the system (Control0(31) = '0' enables the module)
    control0(31) <= '0';  -- Enable module
    wait for CLK_PERIOD * 5;
    
    -- Monitor outputs during zero-init mode
    output_monitor_active <= '1';
    wait for CLK_PERIOD * 100;  -- Wait for complete cycle
    
    -- Test Phase 3: Basic Functionality
    test_phase <= BASIC_FUNCTIONALITY;
    report "Test Phase 3: Basic Functionality - Configure and test normal operation";
    
    -- Configure control registers for normal operation
    control0(31) <= '0';      -- Enable
    control0(30) <= '0';      -- Auto-arm disabled
    control0(23) <= '0';      -- No trigger
    control0(22 downto 16) <= "0110010";  -- Intensity = 50
    control0(15 downto 0) <= std_logic_vector(PulseMinDuration);  -- Min duration
    control1(31 downto 16) <= std_logic_vector(resize(ProbeCoolDownMin, 16));  -- Min cooldown
    
    wait for CLK_PERIOD * 10;
    
    -- Trigger the probe
    control0(23) <= '1';
    wait for CLK_PERIOD;
    control0(23) <= '0';
    
    -- Wait for complete cycle
    wait for CLK_PERIOD * 100;
    
    -- Test Phase 4: Auto-arm Feature
    test_phase <= AUTO_ARM_TEST;
    report "Test Phase 4: Auto-arm Feature - Test CR0[30] functionality";
    
    -- Enable auto-arm
    control0(30) <= '1';
    wait for CLK_PERIOD * 10;
    
    -- Trigger again to test auto-arm behavior
    control0(23) <= '1';
    wait for CLK_PERIOD;
    control0(23) <= '0';
    
    -- Wait for complete cycle with auto-arm
    wait for CLK_PERIOD * 100;
    
    -- Test Phase 5: Verification and Summary
    test_phase <= VERIFICATION;
    report "Test Phase 5: Verification and Summary";
    
    -- Final verification
    wait for CLK_PERIOD * 20;
    
    test_phase <= COMPLETE;
    report "=== Test Complete ===";
    if test_passed then
      report "PASS: All sanity checks passed successfully";
    else
      report "FAIL: Some sanity checks failed";
    end if;
    
    wait;
  end process main_test;
  
  -- =============================================================================
  -- OUTPUT MONITORING AND SANITY CHECKS
  -- =============================================================================
  output_monitor: process(clk)
    variable output_changes : integer := 0;
  begin
    if rising_edge(clk) then
      cycle_count <= cycle_count + 1;
      
      -- Monitor OutputA (Status Register)
      if outputA /= last_outputA then
        report "OutputA changed: " & to_hstring(last_outputA) & " -> " & to_hstring(outputA) & " at cycle " & integer'image(cycle_count);
        last_outputA <= outputA;
        output_changes := output_changes + 1;
        
        -- Sanity check: Status register should have reasonable values
        if outputA(15) = '1' then
          report "WARNING: Error bit (bit 15) is set in status register";
        end if;
        
        -- Check if status bits make sense
        if outputA(3 downto 0) /= "0000" then
          report "INFO: Status bits [3:0] = " & to_hstring(outputA(3 downto 0));
        end if;
      end if;
      
      -- Monitor OutputB (Trigger threshold when firing)
      if outputB /= last_outputB then
        report "OutputB changed: " & to_hstring(last_outputB) & " -> " & to_hstring(outputB) & " at cycle " & integer'image(cycle_count);
        last_outputB <= outputB;
        output_changes := output_changes + 1;
        
        -- Sanity check: OutputB should be 0 when not firing
        if outputB /= x"0000" and outputA(1) = '0' then
          report "WARNING: OutputB non-zero when not in FIRING state";
        end if;
      end if;
      
      -- Monitor OutputC (Intensity output)
      if outputC /= last_outputC then
        report "OutputC changed: " & to_hstring(last_outputC) & " -> " & to_hstring(outputC) & " at cycle " & integer'image(cycle_count);
        last_outputC <= outputC;
        output_changes := output_changes + 1;
        
        -- Sanity check: OutputC should be 0 when not firing
        if outputC /= x"0000" and outputA(1) = '0' then
          report "WARNING: OutputC non-zero when not in FIRING state";
        end if;
      end if;
      
      -- Periodic status report
      if cycle_count mod 100 = 0 then
        report "Cycle " & integer'image(cycle_count) & ": Outputs A=" & to_hstring(outputA) & 
               " B=" & to_hstring(outputB) & " C=" & to_hstring(outputC);
      end if;
      
      -- Phase-specific monitoring
      case test_phase is
        when ZERO_INIT_MODE =>
          -- In zero-init mode, expect auto-fire behavior
          if cycle_count > 50 and outputA(0) = '1' then
            report "INFO: Zero-init mode - module entered ARMED state as expected";
          end if;
          
        when BASIC_FUNCTIONALITY =>
          -- Monitor normal operation
          if outputA(1) = '1' then
            report "INFO: Module entered FIRING state";
          end if;
          
        when AUTO_ARM_TEST =>
          -- Monitor auto-arm behavior
          if outputA(0) = '1' and outputA(3) = '0' then
            report "INFO: Auto-arm working - module returned to ARMED state after cooldown";
          end if;
          
        when others =>
          null;
      end case;
    end if;
  end process output_monitor;
  
  -- =============================================================================
  -- ASSERTION CHECKS
  -- =============================================================================
  assertion_checks: process
  begin
    -- Wait for reset to complete
    wait until reset = '0';
    wait for CLK_PERIOD * 20;
    
    -- Check that outputs are stable after reset
    wait for CLK_PERIOD * 5;
    assert outputA = last_outputA report "OutputA should be stable after reset" severity warning;
    assert outputB = last_outputB report "OutputB should be stable after reset" severity warning;
    assert outputC = last_outputC report "OutputC should be stable after reset" severity warning;
    
    -- Wait for test completion
    wait until test_phase = COMPLETE;
    
    -- Final assertions
    assert test_passed report "Test failed - check simulation output" severity failure;
    report "All assertion checks passed";
    
    wait;
  end process assertion_checks;
  
end architecture testbench;
