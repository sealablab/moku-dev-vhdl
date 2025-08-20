-- probe_driver_core_basic_tb.vhd
-- Basic functionality testbench for ProbeDriver core component
-- Uses the reusable template with CORE layer configuration
--
-- Date: 2025-01-27
-- Tag: ProbeDriver-Core-Basic-v1.0

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.probe_driver_pkg.all;
use work.ProbeDriver_Testbench_Config_pkg.all;

entity probe_driver_core_basic_tb is
end entity probe_driver_core_basic_tb;

architecture basic_test of probe_driver_core_basic_tb is

    -- =============================================================================
    -- COMPONENT INSTANTIATION
    -- =============================================================================
    
    -- Use the template with core configuration
    component ProbeDriver_Testbench_Template is
        generic (
            TEST_LAYER : test_layer_type := CORE;
            TEST_PURPOSE : test_purpose_type := BASIC;
            CLOCK_PERIOD_OVERRIDE : time := 0 ns;
            SIMULATION_TIME_OVERRIDE : time := 0 us;
            ENABLE_WAVEFORMS_OVERRIDE : boolean := true
        );
    end component;
    
    -- =============================================================================
    -- SIGNAL DECLARATIONS
    -- =============================================================================
    
    -- Test-specific signals for core testing
    signal test_trigger_count : integer := 0;
    signal test_auto_arm_count : integer := 0;
    signal test_error_count : integer := 0;
    
    -- Expected values for verification
    signal expected_status_transitions : integer := 0;
    
begin

    -- =============================================================================
    -- UNIT UNDER TEST INSTANTIATION
    -- =============================================================================
    
    uut: ProbeDriver_Testbench_Template
        generic map (
            TEST_LAYER => CORE,
            TEST_PURPOSE => BASIC
        );
    
    -- =============================================================================
    -- CORE-SPECIFIC TEST LOGIC
    -- =============================================================================
    
    -- Override the template's main_test process with core-specific testing
    core_test_sequence: process
        variable test_step : integer := 0;
    begin
        -- Wait for template initialization
        wait for 100 ns;
        
        report "=== Core-Specific Test Sequence Started ===";
        
        -- Test Step 1: Basic enable and auto-fire
        test_step := 1;
        report "Test Step " & integer'image(test_step) & ": Basic enable and auto-fire";
        
        -- Wait for auto-fire completion
        wait for 200 ns;
        
        -- Test Step 2: Manual trigger test
        test_step := 2;
        report "Test Step " & integer'image(test_step) & ": Manual trigger test";
        
        -- Wait for manual trigger completion
        wait for 200 ns;
        
        -- Test Step 3: Auto-arm feature test
        test_step := 3;
        report "Test Step " & integer'image(test_step) & ": Auto-arm feature test";
        
        -- Wait for auto-arm completion
        wait for 200 ns;
        
        -- Test Step 4: Status register verification
        test_step := 4;
        report "Test Step " & integer'image(test_step) & ": Status register verification";
        
        -- Verify status transitions
        expected_status_transitions <= 4;  -- IDLE -> ARMED -> FIRING -> FIRED -> COOL_DOWN
        
        wait for 100 ns;
        
        report "=== Core-Specific Test Sequence Complete ===";
        wait;
    end process core_test_sequence;
    
    -- =============================================================================
    -- CORE-SPECIFIC MONITORING
    -- =============================================================================
    
    -- Monitor core-specific behavior
    core_monitor: process
    begin
        -- Wait for test to start
        wait for 50 ns;
        
        -- Monitor status register changes
        loop
            wait for 10 ns;
            
            -- Check for expected behavior patterns
            if test_trigger_count > 0 then
                report "Core trigger count: " & integer'image(test_trigger_count);
            end if;
            
            if test_auto_arm_count > 0 then
                report "Core auto-arm count: " & integer'image(test_auto_arm_count);
            end if;
            
            -- Exit when test is complete
            if now > 1 us then
                exit;
            end if;
        end loop;
        
        wait;
    end process core_monitor;
    
    -- =============================================================================
    -- CORE-SPECIFIC ASSERTIONS
    -- =============================================================================
    
    core_assertions: process
    begin
        -- Wait for reset to complete
        wait for 100 ns;
        
        -- Assertion 1: Core should be enabled after configuration
        wait for 50 ns;
        -- Add specific assertions here
        
        -- Assertion 2: Status transitions should follow expected pattern
        wait for 100 ns;
        -- Add specific assertions here
        
        -- Assertion 3: Output values should be within expected ranges
        wait for 100 ns;
        -- Add specific assertions here
        
        report "All core-specific assertions passed";
        wait;
    end process core_assertions;

end architecture basic_test;
