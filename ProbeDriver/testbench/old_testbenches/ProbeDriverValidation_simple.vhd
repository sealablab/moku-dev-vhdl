-- ProbeDriver/testbench/ProbeDriverValidation_simple.vhd
-- Simplified validation testbench for ProbeDriver edge conditions
-- Tests all parameter limits and validation rules defined in ProbeConfig_pkg

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.Std_Logic_TextIO.all;
use STD.TextIO.all;
use STD.Env.all;
use work.ProbeConfig_pkg.all;

entity ProbeDriverValidation_simple is
end entity ProbeDriverValidation_simple;

architecture testbench of ProbeDriverValidation_simple is
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;  -- 100MHz clock
    
    -- Component declaration for the unit under test
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
    
    -- Signal declarations
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal enable : std_logic := '0';
    signal trig_in : std_logic := '0';
    signal intensity_index : std_logic_vector(7 downto 0) := (others => '0');
    signal pulse_duration : std_logic_vector(31 downto 0) := (others => '0');
    signal cooldown : std_logic_vector(31 downto 0) := (others => '0');
    signal trig_out : signed(15 downto 0);
    signal intensity_out : signed(15 downto 0);
    signal status_register : std_logic_vector(4 downto 0);
    
    -- Test tracking
    signal test_passed : boolean := true;
    signal test_errors : integer := 0;
    signal test_count : integer := 0;
    
begin
    -- Instantiate the unit under test
    uut: probe_driver
        port map (
            clk => clk,
            reset => reset,
            enable => enable,
            trig_in => trig_in,
            Intensity_index => intensity_index,
            PulseDuration_in => pulse_duration,
            CoolDown_in => cooldown,
            trig_out => trig_out,
            intensity_out => intensity_out,
            status_register => status_register
        );
    
    -- Clock generation
    clk <= not clk after CLK_PERIOD/2;
    
    -- Test stimulus process
    test_stimulus: process
        variable line_var : line;
        variable expected_error : boolean;
        variable actual_error : boolean;
    begin
        -- Initialize test
        wait for CLK_PERIOD * 2;
        enable <= '1';  -- Enable the probe driver for all tests
        trig_in <= '1';  -- Provide trigger to move state machine forward
        
        write(line_var, string'("=== ProbeDriver Validation Testbench ==="));
        writeline(output, line_var);
        write(line_var, string'("Testing all edge conditions and parameter validation"));
        writeline(output, line_var);
        writeline(output, line_var);
        
        -- =============================================================================
        -- TEST 1: Intensity Range Validation
        -- =============================================================================
        write(line_var, string'("=== TEST 1: Intensity Range Validation ==="));
        writeline(output, line_var);
        
        -- Test 1.1: Minimum intensity (should pass - INCLUSIVE bounds)
        test_count <= test_count + 1;
        intensity_index <= std_logic_vector(to_unsigned(0, 8));
        pulse_duration <= std_logic_vector(to_unsigned(16, 32));
        cooldown <= std_logic_vector(to_unsigned(24, 32));
        
        reset <= '1';
        wait for CLK_PERIOD * 3;
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        expected_error := false;  -- Min intensity (0) should NOT cause error (INCLUSIVE)
        actual_error := status_register(4) = '1';
        
        if expected_error = actual_error then
            write(line_var, string'("PASS: Min Intensity (0) - No error as expected (INCLUSIVE)"));
        else
            write(line_var, string'("FAIL: Min Intensity (0) - Error: ") & 
                  to_string(status_register(4)) & string'(" (expected ") & 
                  to_string(expected_error) & string'(")"));
            test_passed <= false;
            test_errors <= test_errors + 1;
        end if;
        writeline(output, line_var);
        
        -- Test 1.2: Maximum intensity (should pass - INCLUSIVE bounds)
        test_count <= test_count + 1;
        intensity_index <= std_logic_vector(to_unsigned(100, 8));
        
        reset <= '1';
        wait for CLK_PERIOD * 3;
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        expected_error := false;  -- Max intensity (100) should NOT cause error (INCLUSIVE)
        actual_error := status_register(4) = '1';
        
        if expected_error = actual_error then
            write(line_var, string'("PASS: Max Intensity (100) - No error as expected (INCLUSIVE)"));
        else
            write(line_var, string'("FAIL: Max Intensity (100) - Error: ") & 
                  to_string(status_register(4)) & string'(" (expected ") & 
                  to_string(expected_error) & string'(")"));
            test_passed <= false;
            test_errors <= test_errors + 1;
        end if;
        writeline(output, line_var);
        
        -- Test 1.3: Above maximum intensity (should fail)
        test_count <= test_count + 1;
        intensity_index <= std_logic_vector(to_unsigned(101, 8));
        
        reset <= '1';
        wait for CLK_PERIOD * 3;
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        expected_error := true;
        actual_error := status_register(4) = '1';
        
        if expected_error = actual_error then
            write(line_var, string'("PASS: Above Max Intensity (101) - Error correctly detected"));
        else
            write(line_var, string'("FAIL: Above Max Intensity (101) - Error: ") & 
                  to_string(status_register(4)) & string'(" (expected ") & 
                  to_string(expected_error) & string'(")"));
            test_passed <= false;
            test_errors <= test_errors + 1;
        end if;
        writeline(output, line_var);
        
        -- =============================================================================
        -- TEST 2: Pulse Duration Validation
        -- =============================================================================
        write(line_var, string'("=== TEST 2: Pulse Duration Validation ==="));
        writeline(output, line_var);
        
        -- Test 2.1: Minimum duration (should pass - INCLUSIVE bounds)
        test_count <= test_count + 1;
        intensity_index <= std_logic_vector(to_unsigned(50, 8));
        pulse_duration <= std_logic_vector(to_unsigned(16, 32));
        cooldown <= std_logic_vector(to_unsigned(24, 32));
        
        reset <= '1';
        wait for CLK_PERIOD * 3;
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        expected_error := false;  -- Min duration (16 cycles) should NOT cause error (INCLUSIVE)
        actual_error := status_register(4) = '1';
        
        if expected_error = actual_error then
            write(line_var, string'("PASS: Min Duration (16 cycles) - No error as expected (INCLUSIVE)"));
        else
            write(line_var, string'("FAIL: Min Duration (16 cycles) - Error: ") & 
                  to_string(status_register(4)) & string'(" (expected ") & 
                  to_string(expected_error) & string'(")"));
            test_passed <= false;
            test_errors <= test_errors + 1;
        end if;
        writeline(output, line_var);
        
        -- Test 2.2: Below minimum duration (should fail)
        test_count <= test_count + 1;
        pulse_duration <= std_logic_vector(to_unsigned(15, 32));
        
        reset <= '1';
        wait for CLK_PERIOD * 3;
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        expected_error := true;
        actual_error := status_register(4) = '1';
        
        if expected_error = actual_error then
            write(line_var, string'("PASS: Below Min Duration (15 cycles) - Error correctly detected"));
        else
            write(line_var, string'("FAIL: Below Min Duration (15 cycles) - Error: ") & 
                  to_string(status_register(4)) & string'(" (expected ") & 
                  to_string(expected_error) & string'(")"));
            test_passed <= false;
            test_errors <= test_errors + 1;
        end if;
        writeline(output, line_var);
        
        -- Test 2.3: Maximum duration (should pass)
        test_count <= test_count + 1;
        pulse_duration <= std_logic_vector(to_unsigned(1024, 32));
        
        reset <= '1';
        wait for CLK_PERIOD * 3;
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        expected_error := false;  -- Max duration (1024 cycles) should not cause error
        actual_error := status_register(4) = '1';
        
        if expected_error = actual_error then
            write(line_var, string'("PASS: Max Duration (1024 cycles) - No error as expected"));
        else
            write(line_var, string'("FAIL: Max Duration (1024 cycles) - Error: ") & 
                  to_string(status_register(4)) & string'(" (expected ") & 
                  to_string(expected_error) & string'(")"));
            test_passed <= false;
            test_errors <= test_errors + 1;
        end if;
        writeline(output, line_var);
        
        -- Test 2.4: Above maximum duration (should fail - upper limit enforced)
        test_count <= test_count + 1;
        pulse_duration <= std_logic_vector(to_unsigned(1025, 32));
        
        reset <= '1';
        wait for CLK_PERIOD * 3;
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        expected_error := true;  -- Above max duration (1025 cycles) should cause error (upper limit enforced)
        actual_error := status_register(4) = '1';
        
        if expected_error = actual_error then
            write(line_var, string'("PASS: Above Max Duration (1025 cycles) - Error correctly detected (upper limit enforced)"));
        else
            write(line_var, string'("FAIL: Above Max Duration (1025 cycles) - Error: ") & 
                  to_string(status_register(4)) & string'(" (expected ") & 
                  to_string(expected_error) & string'(")"));
            test_passed <= false;
            test_errors <= test_errors + 1;
        end if;
        writeline(output, line_var);
        
        -- =============================================================================
        -- TEST 3: Cooldown Validation
        -- =============================================================================
        write(line_var, string'("=== TEST 3: Cooldown Validation ==="));
        writeline(output, line_var);
        
        -- Test 3.1: Minimum cooldown (should pass - INCLUSIVE bounds)
        test_count <= test_count + 1;
        intensity_index <= std_logic_vector(to_unsigned(50, 8));
        pulse_duration <= std_logic_vector(to_unsigned(16, 32));
        cooldown <= std_logic_vector(to_unsigned(24, 32));
        
        reset <= '1';
        wait for CLK_PERIOD * 3;
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        expected_error := false;  -- Min cooldown (24 cycles) should NOT cause error (INCLUSIVE)
        actual_error := status_register(4) = '1';
        
        if expected_error = actual_error then
            write(line_var, string'("PASS: Min Cooldown (24 cycles) - No error as expected (INCLUSIVE)"));
        else
            write(line_var, string'("FAIL: Min Cooldown (24 cycles) - Error: ") & 
                  to_string(status_register(4)) & string'(" (expected ") & 
                  to_string(expected_error) & string'(")"));
            test_passed <= false;
            test_errors <= test_errors + 1;
        end if;
        writeline(output, line_var);
        
        -- Test 3.2: Below minimum cooldown (should fail)
        test_count <= test_count + 1;
        cooldown <= std_logic_vector(to_unsigned(23, 32));
        
        reset <= '1';
        wait for CLK_PERIOD * 3;
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        expected_error := true;
        actual_error := status_register(4) = '1';
        
        if expected_error = actual_error then
            write(line_var, string'("PASS: Below Min Cooldown (23 cycles) - Error correctly detected"));
        else
            write(line_var, string'("FAIL: Below Min Cooldown (23 cycles) - Error: ") & 
                  to_string(status_register(4)) & string'(" (expected ") & 
                  to_string(expected_error) & string'(")"));
            test_passed <= false;
            test_errors <= test_errors + 1;
        end if;
        writeline(output, line_var);
        
        -- =============================================================================
        -- TEST 4: Multiple Error Conditions
        -- =============================================================================
        write(line_var, string'("=== TEST 4: Multiple Error Conditions ==="));
        writeline(output, line_var);
        
        -- Test 4.1: Multiple violations (should fail)
        test_count <= test_count + 1;
        intensity_index <= std_logic_vector(to_unsigned(101, 8));
        pulse_duration <= std_logic_vector(to_unsigned(15, 32));
        cooldown <= std_logic_vector(to_unsigned(23, 32));
        
        reset <= '1';
        wait for CLK_PERIOD * 3;
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        expected_error := true;
        actual_error := status_register(4) = '1';
        
        if expected_error = actual_error then
            write(line_var, string'("PASS: Multiple Violations - Error correctly detected"));
        else
            write(line_var, string'("FAIL: Multiple Violations - Error: ") & 
                  to_string(status_register(4)) & string'(" (expected ") & 
                  to_string(expected_error) & string'(")"));
            test_passed <= false;
            test_errors <= test_errors + 1;
        end if;
        writeline(output, line_var);
        
        -- =============================================================================
        -- TEST 5: Edge Case Values
        -- =============================================================================
        write(line_var, string'("=== TEST 5: Edge Case Values ==="));
        writeline(output, line_var);
        
        -- Test 5.1: Zero intensity (should pass - INCLUSIVE bounds)
        test_count <= test_count + 1;
        intensity_index <= x"00";
        pulse_duration <= std_logic_vector(to_unsigned(16, 32));
        cooldown <= std_logic_vector(to_unsigned(24, 32));
        
        reset <= '1';
        wait for CLK_PERIOD * 3;
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        expected_error := false;  -- Zero intensity should NOT cause error (INCLUSIVE, 0 is valid)
        actual_error := status_register(4) = '1';
        
        if expected_error = actual_error then
            write(line_var, string'("PASS: Zero Intensity - No error as expected (INCLUSIVE)"));
        else
            write(line_var, string'("FAIL: Zero Intensity - Error: ") & 
                  to_string(status_register(4)) & string'(" (expected ") & 
                  to_string(expected_error) & string'(")"));
            test_passed <= false;
            test_errors <= test_errors + 1;
        end if;
        writeline(output, line_var);
        
        -- Test 5.2: Very large duration (should fail - upper limit enforced)
        test_count <= test_count + 1;
        pulse_duration <= x"0000FFFF";
        
        reset <= '1';
        wait for CLK_PERIOD * 3;
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        expected_error := true;  -- Very large duration (65535 cycles) should cause error (upper limit enforced)
        actual_error := status_register(4) = '1';
        
        if expected_error = actual_error then
            write(line_var, string'("PASS: Very Large Duration (65535 cycles) - Error correctly detected (upper limit enforced)"));
        else
            write(line_var, string'("FAIL: Very Large Duration (65535 cycles) - Error: ") & 
                  to_string(status_register(4)) & string'(" (expected ") & 
                  to_string(expected_error) & string'(")"));
            test_passed <= false;
            test_errors <= test_errors + 1;
        end if;
        writeline(output, line_var);
        
        -- =============================================================================
        -- TEST SUMMARY
        -- =============================================================================
        write(line_var, string'("=== TEST SUMMARY ==="));
        writeline(output, line_var);
        write(line_var, string'("Total tests run: ") & to_string(test_count));
        writeline(output, line_var);
        write(line_var, string'("Errors found: ") & to_string(test_errors));
        writeline(output, line_var);
        
        if test_passed then
            write(line_var, string'("=== ALL VALIDATION TESTS PASSED ==="));
        else
            write(line_var, string'("=== VALIDATION TESTS FAILED ==="));
        end if;
        writeline(output, line_var);
        
        -- Clean ending
        write(line_var, string'(""));
        writeline(output, line_var);
        write(line_var, string'("Simulation completed successfully."));
        writeline(output, line_var);
        
        -- End simulation properly
        finish(0);
    end process test_stimulus;
    
    -- Monitor process for real-time status monitoring (only during active tests)
    monitor: process(clk)
        variable line_var : line;
        variable last_error_state : std_logic := '0';
    begin
        if rising_edge(clk) then
            -- Only print when error state changes (rising edge detection)
            if status_register(4) = '1' and last_error_state = '0' then
                write(line_var, string'("ERROR DETECTED - Status: 0x") & 
                      to_hstring(status_register));
                writeline(output, line_var);
            end if;
            last_error_state := status_register(4);
        end if;
    end process monitor;
    
end architecture testbench;
