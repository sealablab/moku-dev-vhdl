-- ProbeDriver/testbench/top_status_tb.vhd
-- Testbench for testing the TopLevel status register and state machine execution
-- Verifies that the 16-bit status register correctly reflects probe driver states

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.Std_Logic_TextIO.all;
use STD.TextIO.all;
use work.ProbeConfig_pkg.all;

entity top_status_tb is
end entity top_status_tb;

architecture testbench of top_status_tb is
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;  -- 100MHz clock
    
    -- Component declaration for the unit under test
    component CustomWrapper is
        port (
            Clk : in std_logic;
            Reset : in std_logic;
            InputA : in signed(15 downto 0);
            InputB : in signed(15 downto 0);
            InputC : in signed(15 downto 0);
            InputD : in signed(15 downto 0);
            OutputA : out signed(15 downto 0);
            OutputB : out signed(15 downto 0);
            OutputC : out signed(15 downto 0);
            OutputD : out signed(15 downto 0);
            Control0 : in std_logic_vector(31 downto 0);
            Control1 : in std_logic_vector(31 downto 0);
            Control2 : in std_logic_vector(31 downto 0);
            Control3 : in std_logic_vector(31 downto 0);
            Control4 : in std_logic_vector(31 downto 0);
            Control5 : in std_logic_vector(31 downto 0);
            Control6 : in std_logic_vector(31 downto 0);
            Control7 : in std_logic_vector(31 downto 0);
            Control8 : in std_logic_vector(31 downto 0);
            Control9 : in std_logic_vector(31 downto 0);
            Control10 : in std_logic_vector(31 downto 0);
            Control11 : in std_logic_vector(31 downto 0);
            Control12 : in std_logic_vector(31 downto 0);
            Control13 : in std_logic_vector(31 downto 0);
            Control14 : in std_logic_vector(31 downto 0);
            Control15 : in std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Signal declarations
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal inputA, inputB, inputC, inputD : signed(15 downto 0) := (others => '0');
    signal outputA, outputB, outputC, outputD : signed(15 downto 0);
    signal control0, control1, control2, control3, control4 : std_logic_vector(31 downto 0) := (others => '0');
    signal control5, control6, control7, control8, control9 : std_logic_vector(31 downto 0) := (others => '0');
    signal control10, control11, control12, control13, control14, control15 : std_logic_vector(31 downto 0) := (others => '0');
    
    -- Test parameters
    signal test_intensity : std_logic_vector(7 downto 0) := "01010101";  -- 85
    signal test_pulse_duration : std_logic_vector(31 downto 0) := x"00000020";  -- 32 cycles
    signal test_cooldown : std_logic_vector(31 downto 0) := x"00000040";  -- 64 cycles
    
    -- Test state tracking
    type test_state_type is (INIT, RESET_PHASE, IDLE_WAIT, ENABLE, ARMED_WAIT, TRIGGER, FIRING_WAIT, FIRED_WAIT, COOLDOWN_WAIT, IDLE_RETURN, VERIFY, DONE);
    signal test_state : test_state_type := INIT;
    signal test_counter : integer := 0;
    signal cycle_count : integer := 0;
    
    -- Status register monitoring
    signal expected_status : std_logic_vector(15 downto 0);
    signal status_history : std_logic_vector(15 downto 0);
    signal state_transitions : integer := 0;
    
    -- Test results
    signal test_passed : boolean := true;
    signal test_errors : integer := 0;
    
begin
    -- Instantiate the unit under test
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
    
    -- Clock generation
    clk <= not clk after CLK_PERIOD/2;
    
    -- Test stimulus process
    test_stimulus: process
        variable line_var : line;
        variable status_str : string(1 to 16);
        variable expected_armed : std_logic_vector(15 downto 0);
        variable expected_firing : std_logic_vector(15 downto 0);
    begin
        -- Initialize test
        wait for CLK_PERIOD * 2;
        
        write(line_var, string'("=== TopLevel Status Register Test ==="));
        writeline(output, line_var);
        write(line_var, string'("Testing state machine execution and status register updates"));
        writeline(output, line_var);
        
        -- Test 1: Reset and Initial Status
        write(line_var, string'("=== Test 1: Reset and Initial Status ==="));
        writeline(output, line_var);
        
        -- Set up control registers
        control0 <= x"12345678";  -- Reserved for TOP module
        control1(15) <= '1';      -- Reset = 1
        control1(14) <= '0';      -- Enable = 0
        control1(13) <= '0';      -- Trigger = 0
        control1(12 downto 8) <= "00000";  -- Mode = 0
        control1(7 downto 0) <= "00000000"; -- Status readback
        
        control2(31 downto 16) <= x"0000";  -- Reserved
        control2(15 downto 8) <= test_intensity;  -- Intensity = 85
        control2(7 downto 0) <= x"00";     -- Reserved
        
        control3 <= test_pulse_duration;    -- Pulse duration = 32
        control4 <= test_cooldown;          -- Cooldown = 64
        
        wait for CLK_PERIOD * 3;
        
        -- Test 2: Release Reset and Enable
        write(line_var, string'("=== Test 2: Release Reset and Enable ==="));
        writeline(output, line_var);
        
        control1(15) <= '0';  -- Release reset
        wait for CLK_PERIOD * 2;
        control1(14) <= '1';  -- Enable
        wait for CLK_PERIOD * 5;  -- Wait longer for signal to settle
        
        -- Check status register (should show ARMED state: 0x0001)
        -- Use a variable for immediate comparison
        expected_armed := x"0001";
        
        -- Convert both to std_logic_vector for comparison
        if std_logic_vector(outputA) /= expected_armed then
            write(line_var, string'("ERROR: Expected ARMED status 0x0001, got 0x") & 
                  to_hstring(std_logic_vector(outputA)));
            writeline(output, line_var);
            test_passed <= false;
            test_errors <= test_errors + 1;
        else
            write(line_var, string'("PASS: ARMED status correct (0x0001)"));
            writeline(output, line_var);
        end if;
        
        -- Test 3: Trigger and Monitor FIRING State
        write(line_var, string'("=== Test 3: Trigger and Monitor FIRING State ==="));
        writeline(output, line_var);
        
        control1(13) <= '1';  -- Assert trigger
        wait for CLK_PERIOD * 2;
        control1(13) <= '0';  -- Deassert trigger
        
        -- Wait for FIRING state (should show 0x0003)
        wait for CLK_PERIOD * 8;  -- Wait longer for state transition
        
        -- Use a variable for immediate comparison
        expected_firing := x"0003";
        
        -- Convert both to std_logic_vector for comparison
        if std_logic_vector(outputA) /= expected_firing then
            write(line_var, string'("ERROR: Expected FIRING status 0x0003, got 0x") & 
                  to_hstring(std_logic_vector(outputA)));
            writeline(output, line_var);
            test_passed <= false;
            test_errors <= test_errors + 1;
        else
            write(line_var, string'("PASS: FIRING status correct (0x0003)"));
            writeline(output, line_var);
        end if;
        
        -- Test 4: Monitor State Transitions (Dynamic Timing)
        write(line_var, string'("=== Test 4: Monitor State Transitions (Dynamic Timing) ==="));
        writeline(output, line_var);
        
        -- Monitor state transitions dynamically instead of fixed timing
        -- The monitor process will track all state changes automatically
        
        -- Wait for completion of the full cycle
        wait for CLK_PERIOD * 200;  -- Wait for complete cycle completion
        
        write(line_var, string'("State machine cycle completed. Final status: 0x") & 
              to_hstring(std_logic_vector(outputA)));
        writeline(output, line_var);
        
        -- Verify we're back to IDLE or ARMED state
        if (outputA(3 downto 0) = "0000") or (outputA(3 downto 0) = "0001") then
            write(line_var, string'("PASS: State machine returned to stable state"));
            writeline(output, line_var);
        else
            write(line_var, string'("WARNING: State machine in unexpected state: 0x") & 
                  to_hstring(std_logic_vector(outputA)));
            writeline(output, line_var);
        end if;
        
        -- Test 5: Error Condition Test
        write(line_var, string'("=== Test 5: Error Condition Test ==="));
        writeline(output, line_var);
        
        -- Set invalid parameters to trigger error
        control2(15 downto 8) <= "11111111";  -- Maximum intensity (should be OK)
        control3 <= x"0000000A";  -- Below minimum duration (should trigger error)
        control4 <= x"00000010";  -- Below minimum cooldown (should trigger error)
        
        -- Reset to load new parameters
        control1(15) <= '1';
        wait for CLK_PERIOD * 3;
        control1(15) <= '0';
        wait for CLK_PERIOD * 2;
        
        -- Check if error bit is set (bit 15 should be 1)
        if outputA(15) /= '1' then
            write(line_var, string'("ERROR: Error bit not set when invalid parameters provided"));
            writeline(output, line_var);
            test_passed <= false;
            test_errors <= test_errors + 1;
        else
            write(line_var, string'("PASS: Error bit correctly set (0x") & 
                  to_hstring(std_logic_vector(outputA)) & string'(")"));
            writeline(output, line_var);
        end if;
        
        -- Test 6: Final Status Summary
        write(line_var, string'("=== Test 6: Final Status Summary ==="));
        writeline(output, line_var);
        
        write(line_var, string'("Final OutputA (TopLevel Status): 0x") & 
              to_hstring(std_logic_vector(outputA)));
        writeline(output, line_var);
        write(line_var, string'("Final OutputB (Intensity): 0x") & 
              to_hstring(std_logic_vector(outputB)));
        writeline(output, line_var);
        write(line_var, string'("Final OutputC (Intensity): 0x") & 
              to_hstring(std_logic_vector(outputC)));
        writeline(output, line_var);
        
        -- Test completion
        wait for CLK_PERIOD * 5;
        
        -- Final test result summary
        write(line_var, string'("=== Test Summary ==="));
        writeline(output, line_var);
        write(line_var, string'("State transitions observed: ") & to_string(state_transitions));
        writeline(output, line_var);
        
        if test_passed then
            write(line_var, string'("=== ALL TESTS PASSED ==="));
        else
            write(line_var, string'("=== TESTS FAILED: ") & to_string(test_errors) & string'(" errors ==="));
        end if;
        writeline(output, line_var);
        
        -- End simulation
        wait;
    end process test_stimulus;
    
    -- Monitor process for real-time status monitoring
    monitor: process(clk)
        variable line_var : line;
        variable prev_status : std_logic_vector(15 downto 0);
    begin
        if rising_edge(clk) then
            -- Track status changes
            if outputA /= signed(prev_status) then
                write(line_var, string'("Status Change: 0x") & 
                      to_hstring(prev_status) & string'(" -> 0x") & 
                      to_hstring(std_logic_vector(outputA)));
                writeline(output, line_var);
                
                -- Decode the new status
                case outputA(3 downto 0) is
                    when "0000" => write(line_var, string'("  State: IDLE"));
                    when "0001" => write(line_var, string'("  State: ARMED"));
                    when "0011" => write(line_var, string'("  State: FIRING"));
                    when "0111" => write(line_var, string'("  State: FIRED"));
                    when "1111" => write(line_var, string'("  State: COOL_DOWN"));
                    when others => write(line_var, string'("  State: UNKNOWN"));
                end case;
                writeline(output, line_var);
                
                if outputA(15) = '1' then
                    write(line_var, string'("  ERROR: Parameter validation failed"));
                    writeline(output, line_var);
                end if;
                
                state_transitions <= state_transitions + 1;
                prev_status := std_logic_vector(outputA);
            end if;
        end if;
    end process monitor;
    
end architecture testbench;
