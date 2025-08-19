-- debug_core_test.vhd
-- Detailed debug test to trace auto-fire logic and state transitions
-- PHASE 2: Debug Auto-fire Logic

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.probe_driver_pkg.all;

entity debug_core_test is
end entity debug_core_test;

architecture testbench of debug_core_test is
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
    signal config_pulse_duration : probe_duration_type := x"0003";  -- Short duration for testing
    signal config_cooldown_period : probe_cooldown_type := x"0002"; -- Short cooldown for testing
    
    -- Input signals
    signal probe_trigger_input : std_logic := '0';
    signal probe_auto_arm : std_logic := '0';
    
    -- Output signals
    signal probe_trigger_output : signed(15 downto 0);
    signal probe_intensity_output : signed(15 downto 0);
    signal probe_status_register : probe_status_type;
    
    -- Test control
    signal test_done : boolean := false;
    signal cycle_count : integer := 0;
    
begin
    -- Clock generation
    clk <= not clk after CLK_PERIOD/2 when not test_done else '0';
    
    -- Cycle counter
    cycle_counter: process(clk)
    begin
        if rising_edge(clk) then
            cycle_count <= cycle_count + 1;
        end if;
    end process cycle_counter;
    
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
        report "Cycle " & integer'image(cycle_count) & ": Status after reset: " & to_string(probe_status_register);
        
        reset <= '0';
        wait for CLK_PERIOD * 3;
        report "Cycle " & integer'image(cycle_count) & ": Status after reset cleared: " & to_string(probe_status_register);
        
        -- Test 2: Enable and check auto-fire
        report "=== TEST 2: Enable and auto-fire ===";
        enable <= '1';
        wait for CLK_PERIOD * 3;
        report "Cycle " & integer'image(cycle_count) & ": Status after enable: " & to_string(probe_status_register);
        
        -- Test 3: Wait for state transitions with detailed monitoring
        report "=== TEST 3: Wait for state transitions ===";
        for i in 1 to 20 loop
            wait for CLK_PERIOD;
            report "Cycle " & integer'image(cycle_count) & ": Status = " & to_string(probe_status_register) & 
                   " (Bit0=" & std_logic'image(probe_status_register(0)) & 
                   ", Bit1=" & std_logic'image(probe_status_register(1)) & 
                   ", Bit2=" & std_logic'image(probe_status_register(2)) & 
                   ", Bit3=" & std_logic'image(probe_status_register(3)) & ")";
        end loop;
        
        -- Test complete
        report "=== DEBUG TEST COMPLETE ===";
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
