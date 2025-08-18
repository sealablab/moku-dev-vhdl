-- Top-Level Integration Testbench
-- Tests the complete top-level interface using top_probe_driver_improved.vhd
-- Validates the new CR0/CR1 control register layout

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.ProbeConfig_pkg.all;

entity top_probe_driver_improved_tb is
end entity top_probe_driver_improved_tb;

architecture testbench of top_probe_driver_improved_tb is
  -- Clock period definition
  constant CLK_PERIOD : time := 10 ns;  -- 100MHz clock
  
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
  
  -- Test parameters using NEW control register layout
  signal test_intensity : std_logic_vector(6 downto 0) := "0110010";  -- 50
  signal test_pulse_duration : std_logic_vector(15 downto 0) := std_logic_vector(PulseMinDuration);  -- within bounds
  signal test_cooldown : std_logic_vector(15 downto 0) := std_logic_vector(resize(ProbeCoolDownMin, 16));       -- >= min cooldown
  
  -- Test state machine
  type test_state_type is (INIT, RESET_PHASE, IDLE, ENABLE, TRIGGER, FIRE, COOLDOWN, VERIFY, DONE);
  signal test_state : test_state_type := INIT;
  signal test_counter : integer := 0;
  
  -- Test results
  signal test_passed : boolean := true;
  signal test_errors : integer := 0;
  signal allow_error_checks : std_logic := '0';
  
begin
  -- =============================================================================
  -- CLOCK GENERATION
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
  -- TEST STIMULUS
  -- =============================================================================
  stimulus: process
  begin
    -- Test 1: Initial reset
    test_state <= INIT;
    report "Test 1: Initial reset";
    wait for CLK_PERIOD * 2;
    
    -- Pre-initialize control registers at time 0 so validation passes during reset
    -- CR0: [31]=enable, [23]=trig, [22:16]=intensity, [15:0]=duration
    -- CR1: [31:16]=cooldown
    
    -- Concurrent assignments ensure values are present before first clock rising edge
    control0(31) <= '1';
    control0(23) <= '0';
    control0(22 downto 16) <= test_intensity;
    control0(15 downto 0) <= test_pulse_duration;
    control1(31 downto 16) <= test_cooldown;
    
    -- Test 2: Release reset
    test_state <= RESET_PHASE;
    report "Test 2: Release reset";
    reset <= '0';
    -- Allow some cycles for configuration to settle before enabling error checks
    wait for CLK_PERIOD * 2;
    allow_error_checks <= '1';
    
    -- Test 3: Control registers are already configured before reset release
    test_state <= IDLE;
    report "Test 3: Configured control registers (pre-init)";
    
    -- Test 4: Enable the system
    test_state <= ENABLE;
    report "Test 4: Enable system";
    wait for CLK_PERIOD * 4;
    
    -- Test 5: Trigger the probe
    test_state <= TRIGGER;
    report "Test 5: Trigger probe";
    control0(23) <= '1';  -- Set soft trigger
    wait for CLK_PERIOD;
    control0(23) <= '0';  -- Clear soft trigger
    wait for CLK_PERIOD * 2;
    
    -- Test 6: Wait for firing
    test_state <= FIRE;
    report "Test 6: Wait for firing";
    wait for CLK_PERIOD * 20;
    
    -- Test 7: Wait for cooldown
    test_state <= COOLDOWN;
    report "Test 7: Wait for cooldown";
    wait for CLK_PERIOD * 20;
    
    -- Test 8: Verify outputs
    test_state <= VERIFY;
    report "Test 8: Verify outputs";
    wait for CLK_PERIOD * 4;
    
    -- Test 9: Test different parameters
    test_state <= DONE;
    report "Test 9: Test different parameters";
    
    -- Test maximum intensity
    control0(22 downto 16) <= "1100100";  -- 100 (maximum)
    control0(15 downto 0) <= x"0020";     -- 32 cycles duration
    control1(31 downto 16) <= x"0010";    -- 16 cycles cooldown
    wait for CLK_PERIOD * 2;
    
    -- Final trigger
    control0(23) <= '1';
    wait for CLK_PERIOD;
    control0(23) <= '0';
    
    -- Wait for completion
    wait for CLK_PERIOD * 100;
    
    -- Test summary
    report "Testbench completed";
    if test_passed then
      report "PASS: All tests completed successfully";
    else
      report "FAIL: " & integer'image(test_errors) & " test(s) failed";
    end if;
    
    wait;
  end process stimulus;
  
  -- =============================================================================
  -- OUTPUT MONITORING
  -- =============================================================================
  monitor: process(clk)
    variable prev_outputA : signed(15 downto 0) := (others => '0');
  begin
    if rising_edge(clk) then
      -- Report on state transitions (OutputA[3:0])
      if outputA(3 downto 0) /= prev_outputA(3 downto 0) then
        report "Top status changed to: " & to_hstring(std_logic_vector(outputA));
      end if;
      -- Error bit edge (after grace period)
      if allow_error_checks = '1' and prev_outputA(15) = '0' and outputA(15) = '1' then
        report "Top-level ERROR bit asserted";
        test_passed <= false;
        test_errors <= test_errors + 1;
      end if;
      prev_outputA := outputA;
      -- Report intensity when FIRING enters
      if prev_outputA(1) = '0' and outputA(1) = '1' then
        report "Top FIRING: OutputC=" & to_hstring(std_logic_vector(outputC));
      end if;
    end if;
  end process monitor;
  
end architecture testbench;
