-- ProbeDriver_Testbench_Config_pkg.vhd
-- Configuration package for ProbeDriver testbenches
-- Provides consistent parameters and constants across all testbench layers
--
-- Date: 2025-01-27
-- Tag: ProbeDriver-Testbench-Config-v1.0

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.probe_driver_pkg.all;
use work.MokuModules_pkg.all;

package ProbeDriver_Testbench_Config_pkg is

    -- =============================================================================
    -- TESTING LAYER CONFIGURATION
    -- =============================================================================
    
    -- Test layer enumeration
    type test_layer_type is (CORE, WRAPPER, TOP_LEVEL);
    
    -- Test purpose enumeration  
    type test_purpose_type is (BASIC, COMPREHENSIVE, STRESS, DEMO, INTEGRATION);
    
    -- Test configuration record
    type testbench_config_type is record
        layer : test_layer_type;
        purpose : test_purpose_type;
        clock_period : time;
        simulation_time : time;
        enable_assertions : boolean;
        enable_waveforms : boolean;
        waveform_filename : string(1 to 50);
    end record;
    
    -- =============================================================================
    -- DEFAULT CONFIGURATIONS
    -- =============================================================================
    
    -- Core layer configuration (fast simulation)
    constant CORE_CONFIG : testbench_config_type := (
        layer => CORE,
        purpose => BASIC,
        clock_period => 10 ns,
        simulation_time => 10 us,
        enable_assertions => true,
        enable_waveforms => true,
        waveform_filename => "probe_driver_core_basic_tb.vcd                    "
    );
    
    -- Wrapper layer configuration (medium simulation)
    constant WRAPPER_CONFIG : testbench_config_type := (
        layer => WRAPPER,
        purpose => INTEGRATION,
        clock_period => 10 ns,
        simulation_time => 20 us,
        enable_assertions => true,
        enable_waveforms => true,
        waveform_filename => "probe_driver_wrapper_integration_tb.vcd           "
    );
    
    -- Top-level configuration (real hardware timing)
    constant TOP_LEVEL_CONFIG : testbench_config_type := (
        layer => TOP_LEVEL,
        purpose => COMPREHENSIVE,
        clock_period => 32 ns,
        simulation_time => 100 us,
        enable_assertions => true,
        enable_waveforms => true,
        waveform_filename => "probe_driver_top_level_comprehensive_tb.vcd       "
    );
    
    -- =============================================================================
    -- TEST PARAMETERS
    -- =============================================================================
    
    -- Safe test values for different layers
    constant CORE_TEST_PULSE_DURATION : probe_duration_type := x"000A";      -- 10 cycles
    constant CORE_TEST_COOLDOWN : probe_cooldown_type := x"0005";            -- 5 cycles
    constant CORE_TEST_INTENSITY : probe_intensity_index_type := "0000001";  -- 1%
    
    constant WRAPPER_TEST_PULSE_DURATION : probe_duration_type := x"0014";   -- 20 cycles
    constant WRAPPER_TEST_COOLDOWN : probe_cooldown_type := x"000A";         -- 10 cycles
    constant WRAPPER_TEST_INTENSITY : probe_intensity_index_type := "0000010"; -- 10%
    
    constant TOP_LEVEL_TEST_PULSE_DURATION : probe_duration_type := std_logic_vector(PROBE_PULSE_MIN_DURATION);  -- Min duration
    constant TOP_LEVEL_TEST_COOLDOWN : probe_cooldown_type := std_logic_vector(PROBE_COOLDOWN_MIN);              -- Min cooldown
    constant TOP_LEVEL_TEST_INTENSITY : probe_intensity_index_type := "0000001";                                -- 1%
    
    -- =============================================================================
    -- TEST PHASE CONFIGURATION
    -- =============================================================================
    
    -- Test phase enumeration (common across all layers)
    type test_phase_type is (
        INIT,
        RESET_PHASE,
        CONFIGURE_PHASE,
        FUNCTIONALITY_PHASE,
        STRESS_PHASE,
        VERIFICATION_PHASE,
        COMPLETE
    );
    
    -- Phase timing configuration
    type phase_timing_config_type is record
        reset_duration : time;
        config_duration : time;
        functionality_duration : time;
        stress_duration : time;
        verification_duration : time;
    end record;
    
    -- Default phase timing
    constant DEFAULT_PHASE_TIMING : phase_timing_config_type := (
        reset_duration => 100 ns,
        config_duration => 200 ns,
        functionality_duration => 1 us,
        stress_duration => 2 us,
        verification_duration => 500 ns
    );
    
    -- =============================================================================
    -- UTILITY FUNCTIONS
    -- =============================================================================
    
    -- Get configuration for a specific layer and purpose
    function get_testbench_config(layer : test_layer_type; purpose : test_purpose_type) return testbench_config_type;
    
    -- Get test parameters for a specific layer
    function get_test_parameters(layer : test_layer_type) return testbench_config_type;
    
    -- Get waveform filename
    function get_waveform_filename(layer : test_layer_type; purpose : test_purpose_type) return string;
    
end package ProbeDriver_Testbench_Config_pkg;

package body ProbeDriver_Testbench_Config_pkg is

    function get_testbench_config(layer : test_layer_type; purpose : test_purpose_type) return testbench_config_type is
        variable config : testbench_config_type;
    begin
        case layer is
            when CORE =>
                config := CORE_CONFIG;
            when WRAPPER =>
                config := WRAPPER_CONFIG;
            when TOP_LEVEL =>
                config := TOP_LEVEL_CONFIG;
        end case;
        
        -- Override purpose
        config.purpose := purpose;
        
        return config;
    end function;
    
    function get_test_parameters(layer : test_layer_type) return testbench_config_type is
    begin
        case layer is
            when CORE =>
                return CORE_CONFIG;
            when WRAPPER =>
                return WRAPPER_CONFIG;
            when TOP_LEVEL =>
                return TOP_LEVEL_CONFIG;
        end case;
    end function;
    
    function get_waveform_filename(layer : test_layer_type; purpose : test_purpose_type) return string is
        variable config : testbench_config_type;
    begin
        config := get_testbench_config(layer, purpose);
        return config.waveform_filename;
    end function;
    
end package body;
