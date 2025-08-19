-- minimal_wrapper_test.vhd
-- Minimal test bypassing clock divider to isolate core state machine issues
-- PHASE 2: Debug Core Integration

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.probe_driver_pkg.all;

entity minimal_wrapper_test is
end entity minimal_wrapper_test;

architecture testbench of minimal_wrapper_test is
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;
    
    -- Test signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    
    -- Output signals
    signal OutputA : signed(15 downto 0);
    signal OutputB : signed(15 downto 0);
    signal OutputC : signed(15 downto 0);
    signal OutputD : signed(15 downto 0);
    
    -- Control Registers
    signal Control0 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control1 : std_logic_vector(31 downto 0) := (others => '0');
    
    -- Test control
    signal test_done : boolean := false;
    
begin
    -- Clock generation
    clk <= not clk after CLK_PERIOD/2 when not test_done else '0';
    
    -- Instantiate the unit under test
    uut: entity work.probe_driver_wrapper
        port map (
            clk => clk,
            reset => reset,
            InputA => (others => '0'),
            InputB => (others => '0'),
            InputC => (others => '0'),
            InputD => (others => '0'),
            OutputA => OutputA,
            OutputB => OutputB,
            OutputC => OutputC,
            OutputD => OutputD,
            Control0 => Control0,
            Control1 => Control1,
            Control2 => (others => '0'),
            Control3 => (others => '0'),
            Control4 => (others => '0'),
            Control5 => (others => '0'),
            Control6 => (others => '0'),
            Control7 => (others => '0'),
            Control8 => (others => '0'),
            Control9 => (others => '0'),
            Control10 => (others => '0'),
            Control11 => (others => '0'),
            Control12 => (others => '0'),
            Control13 => (others => '0'),
            Control14 => (others => '0'),
            Control15 => (others => '0')
        );
    
    -- Test stimulus
    stimulus: process
    begin
        -- Initialize
        wait for CLK_PERIOD * 2;
        
        -- Test 1: Reset and check initial state
        report "=== TEST 1: Reset and initial state ===";
        reset <= '1';
        wait for CLK_PERIOD * 3;
        report "OutputA after reset: " & to_string(OutputA);
        
        reset <= '0';
        wait for CLK_PERIOD * 3;
        report "OutputA after reset cleared: " & to_string(OutputA);
        
        -- Test 2: Enable with minimal configuration
        report "=== TEST 2: Enable with minimal config ===";
        Control0(31) <= '0';  -- Enable
        Control0(22 downto 16) <= "0000001";  -- Intensity 1
        Control0(15 downto 0) <= x"0005";     -- Duration 5 cycles
        Control1(31 downto 16) <= x"0003";    -- Cooldown 3 cycles
        wait for CLK_PERIOD * 3;
        report "OutputA after enable: " & to_string(OutputA);
        
        -- Test 3: Wait for state transitions
        report "=== TEST 3: Wait for state transitions ===";
        wait for CLK_PERIOD * 10;
        report "OutputA after 10 cycles: " & to_string(OutputA);
        wait for CLK_PERIOD * 10;
        report "OutputA after 20 cycles: " & to_string(OutputA);
        
        -- Test complete
        report "=== MINIMAL TEST COMPLETE ===";
        test_done <= true;
        wait;
    end process stimulus;
    
    -- Monitor process
    monitor: process
    begin
        wait until test_done;
        report "SIMULATION DONE";
        wait;
    end process monitor;
    
end architecture testbench;
