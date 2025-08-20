-- jc_CustomWrapper_top_tb.vhd
-- Higher-level testbench for CustomWrapper entity (lovingly hand crafted by jc)
-- Designed to illustrate the process of iterating over a testbench
-- MIRRORS internal signal names from top_probe_driver.vhd for clarity
-- Uses HumanInterface_pkg for human-friendly display functions
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.probe_driver_pkg.all;
use work.HumanInterface_pkg.all;

-- NEW APPROACH: Include the standardized package instead of duplicating component declarations
use work.MokuModules_pkg.all;

entity jc_CustomWrapper_top_tb is
end entity jc_CustomWrapper_top_tb;

architecture testbench of jc_CustomWrapper_top_tb is
  -- Clock period definition - using standardized constant from package
  constant CLK_PERIOD : time := MOKUGO_CLK_PERIOD;  -- 32ns from package
  
  -- NEW APPROACH: No component declaration needed - it's in the MokuModules package!
  
  -- =============================================================================
  -- INTERNAL SIGNALS - MIRRORING top_probe_driver.vhd NAMES
  -- =============================================================================
  -- Clock and reset
  signal clk : std_logic := '0';
  signal reset : std_logic := '1';
  
  -- Input/Output ports (from CustomWrapper interface)
  signal inputA, inputB, inputC, inputD : signed(15 downto 0) := (others => '0');
  signal outputA, outputB, outputC, outputD : signed(15 downto 0);
  
  -- Control registers (matching top_probe_driver.vhd layout)
  signal control0, control1, control2, control3, control4 : std_logic_vector(31 downto 0) := (others => '0');
  signal control5, control6, control7, control8, control9 : std_logic_vector(31 downto 0) := (others => '0');
  signal control10, control11, control12, control13, control14, control15 : std_logic_vector(31 downto 0) := (others => '0');
  
  -- =============================================================================
  -- DERIVED SIGNALS - MIRRORING INTERNAL LOGIC
  -- =============================================================================
  -- Mirror the internal signals from top_probe_driver.vhd
  signal probe_driver_status_register : std_logic_vector(15 downto 0); -- 16-bit status from ProbeDriver
  signal toplevel_status_register : std_logic_vector(15 downto 0);     -- 16-bit top-level status (same as probe_driver_status_register)
  signal probe_trig_out : signed(15 downto 0);                        -- Probe trigger output
  signal probe_intensity_out : signed(15 downto 0);                   -- Probe intensity output
  signal probe_clk_en : std_logic;                                    -- Clock enable from divider
  
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
  -- SIGNAL MAPPING - MIRROR INTERNAL LOGIC FROM top_probe_driver.vhd
  -- =============================================================================
  -- Map the CustomWrapper outputs to our internal signal names
  toplevel_status_register <= std_logic_vector(outputA);
  probe_driver_status_register <= toplevel_status_register;  -- Direct mapping - both are now 16-bit
  probe_trig_out <= outputB;
  probe_intensity_out <= outputC;
  
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
    report "Step " & integer'image(test_step) & "/3: Reset active, all controls at 0x00";
    reset <= '1';
    control0 <= (others => '0');  -- All zeros = safe defaults mode
    control1 <= (others => '0');
    wait for CLK_PERIOD * 3;
    
    -- Display current status using HumanInterface functions
    report display_system_status(control0, control1, toplevel_status_register);


    -- Step 2: Release reset, observe initial state
    test_step := 2;
    report "Step " & integer'image(test_step) & "/3: Release reset, observe IDLE state";
    reset <= '0';
    wait for CLK_PERIOD * 5;
    
    -- Display status after reset release
    report "Status after reset release:";
    report display_system_status(control0, control1, toplevel_status_register);
    
    -- Step 3: Enable the module
    test_step := 3;
    report "Step " & integer'image(test_step) & "/3: Enable module (Control0(31) = '0')";
    control0(31) <= '0';  -- Enable = '0' (inverted logic)
    wait for CLK_PERIOD * 5;
    
    -- Display final status
    report "Final Status:";
    report display_system_status(control0, control1, toplevel_status_register);
    
    -- End simulation
    report "Simulation complete";
    wait;
  end process test_sequence;
  
end architecture testbench;
  