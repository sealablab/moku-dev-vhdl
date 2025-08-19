-- Slot2/testbench/top_probe_driver_tb.vhd
-- Testbench for the top_probe_driver module
-- Tests register assignments, control signals, and output responses

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.Std_Logic_TextIO.all;
use STD.TextIO.all;

-- NEW APPROACH: Include the standardized package instead of duplicating component declarations
use work.MokuModules_pkg.all;

entity top_probe_driver_tb is
end entity top_probe_driver_tb;

architecture testbench of top_probe_driver_tb is
    -- Clock period definition - using standardized constant from package
    constant CLK_PERIOD : time := MOKULAB_CLK_PERIOD;  -- 10ns from package
    
    -- NEW APPROACH: No component declaration needed - it's in the MokuModules package!
    
    -- Signal declarations
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal inputA, inputB, inputC, inputD : signed(15 downto 0) := (others => '0');
    signal outputA, outputB, outputC, outputD : signed(15 downto 0);
    signal control0, control1, control2, control3, control4 : std_logic_vector(31 downto 0) := (others => '0');
    signal control5, control6, control7, control8, control9 : std_logic_vector(31 downto 0) := (others => '0');
    signal control10, control11, control12, control13, control14, control15 : std_logic_vector(31 downto 0) := (others => '0');
    
    -- Test stimulus signals
    signal test_intensity : std_logic_vector(7 downto 0) := "01010101";  -- 85
    signal test_pulse_duration : std_logic_vector(31 downto 0) := x"00000064";  -- 100
    signal test_cooldown : std_logic_vector(31 downto 0) := x"00000100";  -- 256
    
    -- Test state machine
    type test_state_type is (INIT, RESET_PHASE, IDLE, ENABLE, TRIGGER, FIRE, COOLDOWN, VERIFY, DONE);
    signal test_state : test_state_type := INIT;
    signal test_counter : integer := 0;
    
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
    begin
        -- Initialize test
        wait for CLK_PERIOD * 2;
        
        -- Test 1: Basic Register Assignment Test
        write(line_var, string'("=== Test 1: Basic Register Assignment Test ==="));
        writeline(output, line_var);
        
        -- Set up control registers
        control0 <= x"12345678";  -- Reserved for TOP module
        control1(15) <= '0';      -- Reset = 0
        control1(14) <= '1';      -- Enable = 1
        control1(13) <= '0';      -- Trigger = 0
        control1(12 downto 8) <= "00000";  -- Mode = 0
        control1(7 downto 0) <= "00000000"; -- Status readback
        
        control2(31 downto 16) <= x"0000";  -- Reserved
        control2(15 downto 8) <= test_intensity;  -- Intensity = 85
        control2(7 downto 0) <= x"00";     -- Reserved
        
        control3 <= test_pulse_duration;    -- Pulse duration = 100
        control4 <= test_cooldown;          -- Cooldown = 256
        
        wait for CLK_PERIOD * 5;
        
        -- Test 2: Control Signal Test
        write(line_var, string'("=== Test 2: Control Signal Test ==="));
        writeline(output, line_var);
        
        -- Test reset functionality
        control1(15) <= '1';  -- Assert reset
        wait for CLK_PERIOD * 3;
        control1(15) <= '0';  -- Deassert reset
        wait for CLK_PERIOD * 2;
        
        -- Test enable functionality
        control1(14) <= '1';  -- Enable
        wait for CLK_PERIOD * 2;
        
        -- Test trigger functionality
        control1(13) <= '1';  -- Assert trigger
        wait for CLK_PERIOD * 2;
        control1(13) <= '0';  -- Deassert trigger
        wait for CLK_PERIOD * 10;
        
        -- Test 3: Output Verification Test
        write(line_var, string'("=== Test 3: Output Verification Test ==="));
        writeline(output, line_var);
        
        -- Check OutputA (should show voltage value from IntensityLut when not firing)
        -- Note: IntensityLut(85) = x"02A8" = 680 decimal
        if outputA /= x"02A8" then
            write(line_var, string'("ERROR: OutputA mismatch. Expected: x02A8 (680), Got: ") & 
                  to_string(outputA));
            writeline(output, line_var);
            test_passed <= false;
            test_errors <= test_errors + 1;
        else
            write(line_var, string'("PASS: OutputA correct (shows voltage value from IntensityLut)"));
            writeline(output, line_var);
        end if;
        
        -- Check OutputD (status and control info)
        write(line_var, string'("OutputD (Status & Control): ") & to_string(outputD));
        writeline(output, line_var);
        
        wait for CLK_PERIOD * 5;
        
        -- Test 4: Parameter Change Test
        write(line_var, string'("=== Test 4: Parameter Change Test ==="));
        writeline(output, line_var);
        
        -- Change intensity
        control2(15 downto 8) <= "11111111";  -- Maximum intensity
        wait for CLK_PERIOD * 3;
        
        -- Change pulse duration
        control3 <= x"000000FF";  -- 255 cycles
        wait for CLK_PERIOD * 3;
        
        -- Change cooldown
        control4 <= x"00000200";  -- 512 cycles
        wait for CLK_PERIOD * 3;
        
        -- Test 5: Final Verification
        write(line_var, string'("=== Test 5: Final Verification ==="));
        writeline(output, line_var);
        
        -- Trigger again to see new parameters
        control1(13) <= '1';
        wait for CLK_PERIOD * 2;
        control1(13) <= '0';
        wait for CLK_PERIOD * 15;
        
        -- Final status check
        write(line_var, string'("Final OutputA: ") & to_string(outputA));
        writeline(output, line_var);
        write(line_var, string'("Final OutputB: ") & to_string(outputB));
        writeline(output, line_var);
        write(line_var, string'("Final OutputC: ") & to_string(outputC));
        writeline(output, line_var);
        write(line_var, string'("Final OutputD: ") & to_string(outputD));
        writeline(output, line_var);
        
        -- Test completion
        wait for CLK_PERIOD * 5;
        
        if test_passed then
            write(line_var, string'("=== ALL TESTS PASSED ==="));
        else
            write(line_var, string'("=== TESTS FAILED: ") & to_string(test_errors) & string'(" errors ==="));
        end if;
        writeline(output, line_var);
        
        -- End simulation
        wait;
    end process test_stimulus;
    
    -- Monitor process for real-time output
    monitor: process(clk)
        variable line_var : line;
    begin
        if rising_edge(clk) then
            -- Monitor control register changes
            if control1(15) = '1' then
                write(line_var, string'("RESET asserted"));
                writeline(output, line_var);
            end if;
            
            if control1(14) = '1' and control1(14)'event then
                write(line_var, string'("ENABLE asserted"));
                writeline(output, line_var);
            end if;
            
            if control1(13) = '1' and control1(13)'event then
                write(line_var, string'("TRIGGER asserted"));
                writeline(output, line_var);
            end if;
        end if;
    end process monitor;
    
end architecture testbench;
