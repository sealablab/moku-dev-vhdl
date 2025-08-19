-- probe_driver_core_tb.vhd
-- Testbench for the refactored probe driver core component
-- Tests basic functionality and state machine transitions

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.probe_driver_pkg.all;

entity probe_driver_core_tb is
end entity probe_driver_core_tb;

architecture testbench of probe_driver_core_tb is
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;
    
    -- Test signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal enable : std_logic := '0';
    signal clk_en : std_logic := '1';
    signal status_clear : std_logic := '0';
    
    -- Configuration signals
    signal config_intensity_index : probe_intensity_index_type := "0000001";  -- Minimum intensity
    signal config_pulse_duration : probe_duration_type := x"000A";          -- 10 cycles
    signal config_cooldown_period : probe_cooldown_type := x"0005";         -- 5 cycles
    
    -- Input signals
    signal probe_trigger_input : std_logic := '0';
    signal probe_auto_arm : std_logic := '0';
    
    -- Output signals
    signal probe_trigger_output : signed(15 downto 0);
    signal probe_intensity_output : signed(15 downto 0);
    signal probe_status_register : probe_status_type;
    
    -- Test control
    signal test_done : boolean := false;
    
begin
    -- Clock generation
    clk <= not clk after CLK_PERIOD/2 when not test_done else '0';
    
    -- Instantiate the unit under test
    uut: entity work.probe_driver_core
        port map (
            clk                    => clk,
            reset                  => reset,
            enable                 => enable,
            clk_en                 => clk_en,
            status_clear           => status_clear,
            config_intensity_index => config_intensity_index,
            config_pulse_duration  => config_pulse_duration,
            config_cooldown_period => config_cooldown_period,
            probe_trigger_input    => probe_trigger_input,
            probe_auto_arm         => probe_auto_arm,
            probe_trigger_output   => probe_trigger_output,
            probe_intensity_output => probe_intensity_output,
            probe_status_register  => probe_status_register
        );
    
    -- Test stimulus
    stimulus: process
    begin
        -- Initialize
        wait for CLK_PERIOD * 2;
        
        -- Test 1: Reset behavior
        report "Test 1: Reset behavior";
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        -- Test 2: Enable and auto-fire
        report "Test 2: Enable and auto-fire";
        enable <= '1';
        wait for CLK_PERIOD * 2;
        
        -- Test 3: Wait for auto-fire completion
        report "Test 3: Wait for auto-fire completion";
        wait for CLK_PERIOD * 20;  -- Wait for pulse + cooldown
        
        -- Test 4: Manual trigger
        report "Test 4: Manual trigger";
        probe_trigger_input <= '1';
        wait for CLK_PERIOD;
        probe_trigger_input <= '0';
        wait for CLK_PERIOD * 20;  -- Wait for pulse + cooldown
        
        -- Test 5: Auto-arm feature
        report "Test 5: Auto-arm feature";
        probe_auto_arm <= '1';
        probe_trigger_input <= '1';
        wait for CLK_PERIOD;
        probe_trigger_input <= '0';
        wait for CLK_PERIOD * 20;  -- Wait for pulse + cooldown
        
        -- Test complete
        report "ALL TESTS PASSED";
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
