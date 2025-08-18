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
    
    -- End simulation
    report "Simulation complete";
    wait;
  end process test_sequence;
  
end architecture testbench;
  