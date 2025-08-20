-- core_direct_test.vhd
-- Direct test of the core component to isolate auto-fire issues
-- PHASE 2: Debug Core Auto-fire Logic

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.probe_driver_pkg.all;

entity core_direct_test is
end entity core_direct_test;

architecture testbench of core_direct_test is
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;
    
    -- Test signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal enable : std_logic := '0';
    signal clk_en : std_logic := '1';
    signal status_clear : std_logic := '0';
    
    -- Configuration signals
    signal config_intensity_index : probe_intensity_index_type := "0000001";
    signal config_pulse_duration : probe_duration_type := x"0005";
    signal config_cooldown_period : probe_cooldown_type := x"0003";
    
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
        
        -- Test 1: Reset and check initial state
        report "=== TEST 1: Reset and initial state ===";
        reset <= '1';
        wait for CLK_PERIOD * 3;
        report "Status after reset: " & to_string(probe_status_register);
        
        reset <= '0';
        wait for CLK_PERIOD * 3;
        report "Status after reset cleared: " & to_string(probe_status_register);
        
        -- Test 2: Enable and check auto-fire
        report "=== TEST 2: Enable and auto-fire ===";
        enable <= '1';
        wait for CLK_PERIOD * 3;
        report "Status after enable: " & to_string(probe_status_register);
        
        -- Test 3: Wait for state transitions
        report "=== TEST 3: Wait for state transitions ===";
        wait for CLK_PERIOD * 5;
        report "Status after 5 cycles: " & to_string(probe_status_register);
        wait for CLK_PERIOD * 5;
        report "Status after 10 cycles: " & to_string(probe_status_register);
        wait for CLK_PERIOD * 5;
        report "Status after 15 cycles: " & to_string(probe_status_register);
        
        -- Test complete
        report "=== CORE DIRECT TEST COMPLETE ===";
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
