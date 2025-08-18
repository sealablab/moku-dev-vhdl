-- jc-CustomWrapper-top-tb.vhd
-- Higher-level testbench for CustomWrapper entity (lovingly hand crafted by jc)
-- Designed to illustrate the process of iterating over a testbench
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.ProbeConfig_pkg.all;

entity jc_CustomWrapper_top_tb is
end entity jc_CustomWrapper_top_tb;

architecture testbench of jc_CustomWrapper_top_tb is
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
  
  -- Main test process
  test_sequence: process
    variable test_step : integer := 0;
  begin
    -- Wait for initial setup
    wait for CLK_PERIOD * 5;
    
    -- =============================================================================
    -- TEST-01: Reset and State Machine Function
    -- =============================================================================
    report "=== TEST-01: Reset and State Machine Function ===";
    report "Goal: Observe ProbeDriver transition through state machine after reset";
    
    -- Step 1: Start with reset active
    test_step := 1;
    report "Step " & integer'image(test_step) & ": Reset active, all controls at 0x00";
    reset <= '1';
    control0 <= (others => '0');  -- All zeros = safe defaults mode
    control1 <= (others => '0');
    wait for CLK_PERIOD * 3;
    
    -- Step 2: Release reset, observe initial state
    test_step := 2;
    report "Step " & integer'image(test_step) & ": Release reset, observe IDLE state";
    reset <= '0';
    wait for CLK_PERIOD * 5;
    
    -- Check that we're in IDLE state (status bits [3:0] should be 0x0)
    if unsigned(outputA(3 downto 0)) /= 0 then
      report "ERROR: Expected IDLE state (0x0), got 0x" & 
             to_hstring(unsigned(outputA(3 downto 0))) severity error;
      test_passed <= false;
    else
      report "PASS: Correctly in IDLE state after reset";
    end if;
    
    -- Step 3: Enable the module (Control0(31) = '0' for enable)
    test_step := 3;
    report "Step " & integer'image(test_step) & ": Enable module (Control0(31) = '0')";
    control0(31) <= '0';  -- Enable = '0' (inverted logic)
    wait for CLK_PERIOD * 3;
    
    -- Check that we transitioned to ARMED state (status bit 0 should be '1')
    if outputA(0) /= '1' then
      report "ERROR: Expected ARMED state (bit 0 = '1'), got 0x" & 
             to_hstring(unsigned(outputA(3 downto 0))) severity error;
      test_passed <= false;
    else
      report "PASS: Correctly transitioned to ARMED state";
    end if;
    
    -- Step 4: Wait for auto-fire (should happen automatically after enable)
    test_step := 4;
    report "Step " & integer'image(test_step) & ": Wait for auto-fire sequence";
    
    -- Wait for FIRING state (status bit 1 should become '1')
    wait until outputA(1) = '1' for CLK_PERIOD * 100;
    if outputA(1) = '1' then
      report "PASS: Auto-fire initiated, entered FIRING state";
    else
      report "ERROR: Auto-fire did not occur within expected time" severity error;
      test_passed <= false;
    end if;
    
    -- Step 5: Wait for FIRING to complete and transition to COOL_DOWN
    test_step := 5;
    report "Step " & integer'image(test_step) & ": Wait for FIRING completion and COOL_DOWN";
    
    -- Wait for FIRING to complete (status bit 2 should become '1') and COOL_DOWN (bit 3)
    wait until outputA(2) = '1' and outputA(3) = '1' for CLK_PERIOD * 200;
    if outputA(2) = '1' and outputA(3) = '1' then
      report "PASS: FIRING completed, entered COOL_DOWN state";
    else
      report "ERROR: FIRING completion or COOL_DOWN transition failed" severity error;
      test_passed <= false;
    end if;
    
    -- Step 6: Wait for COOL_DOWN to complete and return to IDLE
    test_step := 6;
    report "Step " & integer'image(test_step) & ": Wait for COOL_DOWN completion and return to IDLE";
    
    -- Wait for COOL_DOWN to complete (status bit 3 should become '0') and return to IDLE
    wait until outputA(3) = '0' for CLK_PERIOD * 100;
    if outputA(3) = '0' then
      report "PASS: COOL_DOWN completed";
      
      -- Check final state - should be back to IDLE (all status bits [3:0] = 0)
      if unsigned(outputA(3 downto 0)) = 0 then
        report "PASS: Successfully returned to IDLE state";
      else
        report "ERROR: Did not return to IDLE state, status = 0x" & 
               to_hstring(unsigned(outputA(3 downto 0))) severity error;
        test_passed <= false;
      end if;
    else
      report "ERROR: COOL_DOWN did not complete within expected time" severity error;
      test_passed <= false;
    end if;
    
    -- =============================================================================
    -- TEST SUMMARY
    -- =============================================================================
    wait for CLK_PERIOD * 10;
    
    if test_passed then
      report "=== TEST-01 PASSED: State machine transitions working correctly ===";
    else
      report "=== TEST-01 FAILED: State machine transitions have issues ===" severity error;
    end if;
    
    -- End simulation
    report "Simulation complete";
    wait;
    
  end process test_sequence;
  
  -- =============================================================================
  -- OUTPUT MONITORING (Optional - for debugging)
  -- =============================================================================
  output_monitor: process(clk)
  begin
    if rising_edge(clk) then
      -- Monitor status register changes
      if outputA /= last_outputA then
        report "Status Register changed: 0x" & to_hstring(unsigned(outputA)) & 
               " (bits [3:0] = 0x" & to_hstring(unsigned(outputA(3 downto 0))) & ")";
        last_outputA <= outputA;
      end if;
      
      -- Monitor other outputs if needed
      if outputB /= last_outputB then
        last_outputB <= outputB;
      end if;
      
      if outputC /= last_outputC then
        last_outputC <= outputC;
      end if;
    end if;
  end process output_monitor;
  
  -- =============================================================================
  -- TIMEOUT PROTECTION
  -- =============================================================================
  timeout_protection: process
  begin
    wait for 100 us;  -- 100 microseconds timeout
    report "TIMEOUT: Simulation exceeded maximum allowed time" severity error;
    wait;
  end process timeout_protection;
  
end architecture testbench;
  