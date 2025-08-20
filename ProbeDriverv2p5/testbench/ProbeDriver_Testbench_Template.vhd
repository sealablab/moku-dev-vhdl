-- ProbeDriver_Testbench_Template.vhd
-- Reusable testbench template for ProbeDriver components
-- Configurable for different testing layers: CORE, WRAPPER, TOP_LEVEL
-- Uses the MokuModules_pkg to avoid CustomWrapper duplication
--
-- Date: 2025-01-27
-- Tag: ProbeDriver-Testbench-Template-v1.0

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.probe_driver_pkg.all;
use work.MokuModules_pkg.all;
use work.ProbeDriver_Testbench_Config_pkg.all;

entity ProbeDriver_Testbench_Template is
    generic (
        -- Test configuration
        TEST_LAYER : test_layer_type := CORE;
        TEST_PURPOSE : test_purpose_type := BASIC;
        
        -- Override configuration if needed
        CLOCK_PERIOD_OVERRIDE : time := 0 ns;
        SIMULATION_TIME_OVERRIDE : time := 0 us;
        ENABLE_WAVEFORMS_OVERRIDE : boolean := true
    );
end entity ProbeDriver_Testbench_Template;

architecture template of ProbeDriver_Testbench_Template is

    -- =============================================================================
    -- CONFIGURATION
    -- =============================================================================
    
    -- Get configuration for this test
    constant CONFIG : testbench_config_type := get_testbench_config(TEST_LAYER, TEST_PURPOSE);
    
    -- Clock and timing (allow override)
    constant CLK_PERIOD : time := CONFIG.clock_period;
    constant SIM_TIME : time := CONFIG.simulation_time;
    
    -- =============================================================================
    -- SIGNAL DECLARATIONS
    -- =============================================================================
    
    -- Clock and reset
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    
    -- Test control
    signal test_phase : test_phase_type := INIT;
    signal cycle_count : integer := 0;
    signal test_done : boolean := false;
    
    -- =============================================================================
    -- CORE LAYER SIGNALS (ALWAYS AVAILABLE)
    -- =============================================================================
    
    -- Core layer signals
    signal core_enable : std_logic := '0';
    signal core_clk_en : std_logic := '1';
    signal core_status_clear : std_logic := '0';
    signal core_config_intensity_index : probe_intensity_index_type;
    signal core_config_pulse_duration : probe_duration_type;
    signal core_config_cooldown_period : probe_cooldown_type;
    signal core_probe_trigger_input : std_logic := '0';
    signal core_probe_auto_arm : std_logic := '0';
    signal core_probe_trigger_output : signed(15 downto 0);
    signal core_probe_intensity_output : signed(15 downto 0);
    signal core_probe_status_register : probe_status_type;
    
    -- =============================================================================
    -- TEST PARAMETERS
    -- =============================================================================
    
    -- Get test parameters for this layer
    signal test_pulse_duration : probe_duration_type;
    signal test_cooldown_period : probe_cooldown_type;
    signal test_intensity_index : probe_intensity_index_type;
    
begin

    -- =============================================================================
    -- CLOCK GENERATION
    -- =============================================================================
    clk <= not clk after CLK_PERIOD / 2 when not test_done else '0';
    
    -- =============================================================================
    -- TEST PARAMETER ASSIGNMENT
    -- =============================================================================
    
    -- Assign test parameters based on layer
    test_pulse_duration <= CORE_TEST_PULSE_DURATION when TEST_LAYER = CORE else
                           WRAPPER_TEST_PULSE_DURATION when TEST_LAYER = WRAPPER else
                           TOP_LEVEL_TEST_PULSE_DURATION;
    
    test_cooldown_period <= CORE_TEST_COOLDOWN when TEST_LAYER = CORE else
                            WRAPPER_TEST_COOLDOWN when TEST_LAYER = WRAPPER else
                            TOP_LEVEL_TEST_COOLDOWN;
    
    test_intensity_index <= CORE_TEST_INTENSITY when TEST_LAYER = CORE else
                            WRAPPER_TEST_INTENSITY when TEST_LAYER = WRAPPER else
                            TOP_LEVEL_TEST_INTENSITY;
    
    -- =============================================================================
    -- UNIT UNDER TEST INSTANTIATION
    -- =============================================================================
    
    -- Core layer instantiation (ALWAYS AVAILABLE)
    uut_core: entity work.probe_driver_core
        port map (
            clk                    => clk,
            reset                  => reset,
            enable                 => core_enable,
            clk_en                 => core_clk_en,
            status_clear           => core_status_clear,
            config_intensity_index => core_config_intensity_index,
            config_pulse_duration  => core_config_pulse_duration,
            config_cooldown_period => core_config_cooldown_period,
            probe_trigger_input    => core_probe_trigger_input,
            probe_auto_arm         => core_probe_auto_arm,
            probe_trigger_output   => core_probe_trigger_output,
            probe_intensity_output => core_probe_intensity_output,
            probe_status_register  => core_probe_status_register
        );
    
    -- =============================================================================
    -- TEST SEQUENCE
    -- =============================================================================
    
    -- Main test sequence (to be overridden by specific testbenches)
    main_test: process
    begin
        -- Initialize test
        test_phase <= INIT;
        report "=== ProbeDriver Testbench Template Started ===";
        report "Test Layer: " & test_layer_type'image(TEST_LAYER);
        report "Test Purpose: " & test_purpose_type'image(TEST_PURPOSE);
        report "Clock Period: " & time'image(CLK_PERIOD);
        report "Simulation Time: " & time'image(SIM_TIME);
        
        -- Wait for initial setup
        wait for CLK_PERIOD * 5;
        
        -- Reset phase
        test_phase <= RESET_PHASE;
        report "Phase: Reset Phase";
        reset <= '1';
        wait for CLK_PERIOD * 10;
        reset <= '0';
        wait for CLK_PERIOD * 10;
        
        -- Configuration phase
        test_phase <= CONFIGURE_PHASE;
        report "Phase: Configuration Phase";
        
        -- Configure core parameters
        core_config_intensity_index <= test_intensity_index;
        core_config_pulse_duration <= test_pulse_duration;
        core_config_cooldown_period <= test_cooldown_period;
        core_enable <= '1';
        
        wait for CLK_PERIOD * 10;
        
        -- Functionality phase
        test_phase <= FUNCTIONALITY_PHASE;
        report "Phase: Functionality Phase";
        
        -- Basic functionality test (to be customized)
        wait for CLK_PERIOD * 50;
        
        -- Verification phase
        test_phase <= VERIFICATION_PHASE;
        report "Phase: Verification Phase";
        wait for CLK_PERIOD * 20;
        
        -- Complete
        test_phase <= COMPLETE;
        report "=== Test Complete ===";
        test_done <= true;
        wait;
    end process main_test;
    
    -- =============================================================================
    -- CYCLE COUNTER
    -- =============================================================================
    cycle_counter: process(clk)
    begin
        if rising_edge(clk) then
            cycle_count <= cycle_count + 1;
        end if;
    end process cycle_counter;
    
    -- =============================================================================
    -- ASSERTION CHECKS
    -- =============================================================================
    assertion_checks: if CONFIG.enable_assertions generate
        process
        begin
            -- Wait for reset to complete
            wait until reset = '0';
            wait for CLK_PERIOD * 20;
            
            -- Basic assertions (to be customized)
            assert cycle_count > 0 report "Cycle counter should be incrementing" severity note;
            
            -- Wait for test completion
            wait until test_phase = COMPLETE;
            
            report "All assertion checks passed";
            wait;
        end process;
    end generate;

end architecture template;
