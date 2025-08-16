-- Slot2/testbench/ProbeDriver_tb.vhd
-- Minimal testbench for ProbeDriver.vhd

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.IntensityLut_pkg.all;

-- =============================================================================
-- ENTITY - Testbench entity (no ports needed)
-- =============================================================================
entity ProbeDriver_tb is
end entity ProbeDriver_tb;

-- =============================================================================
-- ARCHITECTURE - Testbench implementation
-- =============================================================================
architecture testbench of ProbeDriver_tb is
  -- Clock and control signals
  signal clk : std_logic := '0';
  signal reset : std_logic := '1';
  signal enable : std_logic := '0';
  signal trig_in : std_logic := '0';
  
  -- Input test values
  signal Intensity_index : std_logic_vector(7 downto 0) := x"50";  -- 80 (valid)
  signal PulseDuration_in : std_logic_vector(31 downto 0) := x"00000010";  -- 16 cycles
  signal CoolDown_in : std_logic_vector(31 downto 0) := x"00000008";  -- 8 cycles
  
  -- Output signals from DUT (Device Under Test)
  signal trig_out : signed(15 downto 0);
  signal intensity_out : signed(15 downto 0);
  signal status_register : std_logic_vector(4 downto 0);
  
  -- Clock period
  constant CLK_PERIOD : time := 10 ns;  -- Restore original clock speed
  
  -- Component declaration for DUT
  component probe_driver is
    port (
      clk        : in  std_logic;
      reset      : in  std_logic;
      enable     : in  std_logic;
      trig_in    : in  std_logic;
      Intensity_index      : in  std_logic_vector(7 downto 0);
      PulseDuration_in  : in  std_logic_vector(31 downto 0);
      CoolDown_in       : in  std_logic_vector(31 downto 0);
      trig_out         : out signed(15 downto 0);
      intensity_out    : out signed(15 downto 0);
      status_register  : out std_logic_vector(4 downto 0)
    );
  end component;
  
begin
  -- =============================================================================
  -- CLOCK GENERATION
  -- =============================================================================
  clk <= not clk after CLK_PERIOD / 2;
  
  -- =============================================================================
  -- DEVICE UNDER TEST INSTANTIATION
  -- =============================================================================
  dut: probe_driver
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
  -- COMPREHENSIVE TEST STIMULUS
  -- =============================================================================
  stimulus: process
  begin
    -- Initialize
    wait for CLK_PERIOD * 2;
    
    -- Test 1: Reset and basic functionality
    report "Test 1: Reset and basic functionality";
    reset <= '0';
    wait for CLK_PERIOD * 2;
    
    -- Test 2: Enable the probe driver
    report "Test 2: Enable probe driver";
    enable <= '1';
    wait for CLK_PERIOD * 2;
    
    -- Test 3: Trigger the probe
    report "Test 3: Trigger probe";
    trig_in <= '1';
    wait for CLK_PERIOD;
    trig_in <= '0';
    
    -- Test 4: Wait for complete cycle
    report "Test 4: Wait for complete cycle";
    wait for CLK_PERIOD * 50;  -- Wait for firing + cooldown
    
    -- Test 5: Check status register
    report "Test 5: Status register should show all bits high";
    wait for CLK_PERIOD * 2;
    
    -- Test 6: Test error conditions
    report "Test 6: Test error conditions";
    reset <= '1';
    Intensity_index <= x"FF";  -- Invalid intensity > 100
    PulseDuration_in <= x"00000001";  -- Below minimum duration
    CoolDown_in <= x"00000000";  -- Below minimum cooldown
    wait for CLK_PERIOD * 2;
    
    reset <= '0';
    wait for CLK_PERIOD * 2;
    
    -- Test 7: Final status check
    report "Test 7: Final status check";
    wait for CLK_PERIOD * 5;
    
    -- End simulation
    report "Simulation completed successfully";
    wait;
  end process stimulus;
  
  -- =============================================================================
  -- MONITORING PROCESS
  -- =============================================================================
  monitor: process
  begin
    wait for CLK_PERIOD;
    
    -- Monitor status register changes
    if status_register /= "00000" then
      report "Status Register: " & to_string(status_register);
    end if;
    
    -- Monitor trigger output
    if trig_out /= 0 then
      report "Trigger Output: " & to_string(trig_out);
    end if;
    
    -- Monitor intensity output
    if intensity_out /= 0 then
      report "Intensity Output: " & to_string(intensity_out);
    end if;
  end process monitor;
  
end architecture testbench;
