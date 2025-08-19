-- Slot2/testbench/debug_test.vhd
-- Debug testbench to trace intensity value issues

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.Std_Logic_TextIO.all;
use STD.TextIO.all;

-- NEW APPROACH: Include the standardized package instead of duplicating component declarations
use work.MokuModules_pkg.all;

entity debug_test is
end entity debug_test;

architecture testbench of debug_test is
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
    
    -- Debug test stimulus
    test_stimulus: process
        variable line_var : line;
    begin
        -- Initialize
        wait for CLK_PERIOD * 5;
        reset <= '0';
        wait for CLK_PERIOD * 10;
        
        -- Test 1: Set intensity to 0 (should show IntensityLut(0) = 0x0000)
        write(line_var, string'("=== Test 1: Intensity = 0 ==="));
        writeline(output, line_var);
        
        control2(15 downto 8) <= x"00";  -- Intensity = 0
        control3 <= x"00000010";          -- Short pulse duration = 16
        control4 <= x"00000010";          -- Short cooldown = 16
        
        wait for CLK_PERIOD * 5;
        
        -- Reset to load parameters
        control1(15) <= '1';  -- Assert reset
        wait for CLK_PERIOD * 5;
        control1(15) <= '0';  -- Deassert reset
        wait for CLK_PERIOD * 10;
        
        -- Enable and trigger
        control1(14) <= '1';  -- Enable
        wait for CLK_PERIOD * 5;
        control1(13) <= '1';  -- Trigger
        wait for CLK_PERIOD * 5;
        control1(13) <= '0';  -- Deassert trigger
        
        -- Check output DURING firing (not after)
        wait for CLK_PERIOD * 8;  -- Wait until middle of firing cycle
        write(line_var, string'("DURING firing - OutputA: ") & to_string(outputA));
        writeline(output, line_var);
        write(line_var, string'("Status: ") & to_string(outputD));
        writeline(output, line_var);
        
        -- Wait for complete cycle
        wait for CLK_PERIOD * 12;
        
        write(line_var, string'("AFTER firing - OutputA: ") & to_string(outputA));
        writeline(output, line_var);
        write(line_var, string'("Status: ") & to_string(outputD));
        writeline(output, line_var);
        
        wait for CLK_PERIOD * 10;
        
        -- Test 2: Set intensity to 50 (should show IntensityLut(50) = 0x0190)
        write(line_var, string'("=== Test 2: Intensity = 50 ==="));
        writeline(output, line_var);
        
        control2(15 downto 8) <= x"32";  -- Intensity = 50
        wait for CLK_PERIOD * 5;
        
        -- Reset to load new parameters
        control1(15) <= '1';  -- Assert reset
        wait for CLK_PERIOD * 5;
        control1(15) <= '0';  -- Deassert reset
        wait for CLK_PERIOD * 10;
        
        -- Enable and trigger
        control1(14) <= '1';  -- Enable
        wait for CLK_PERIOD * 5;
        control1(13) <= '1';  -- Trigger
        wait for CLK_PERIOD * 5;
        control1(13) <= '0';  -- Deassert trigger
        
        -- Check output DURING firing (not after)
        wait for CLK_PERIOD * 8;  -- Wait until middle of firing cycle
        write(line_var, string'("DURING firing - OutputA: ") & to_string(outputA));
        writeline(output, line_var);
        write(line_var, string'("Status: ") & to_string(outputD));
        writeline(output, line_var);
        
        -- Wait for complete cycle
        wait for CLK_PERIOD * 12;
        
        write(line_var, string'("AFTER firing - OutputA: ") & to_string(outputA));
        writeline(output, line_var);
        write(line_var, string'("Status: ") & to_string(outputD));
        writeline(output, line_var);
        
        wait for CLK_PERIOD * 10;
        
        -- Test 3: Set intensity to 100 (should show IntensityLut(100) = 0x0320)
        write(line_var, string'("=== Test 3: Intensity = 100 ==="));
        writeline(output, line_var);
        
        control2(15 downto 8) <= x"64";  -- Intensity = 100
        wait for CLK_PERIOD * 5;
        
        -- Reset to load new parameters
        control1(15) <= '1';  -- Assert reset
        wait for CLK_PERIOD * 5;
        control1(15) <= '0';  -- Deassert reset
        wait for CLK_PERIOD * 10;
        
        -- Enable and trigger
        control1(14) <= '1';  -- Enable
        wait for CLK_PERIOD * 5;
        control1(13) <= '1';  -- Trigger
        wait for CLK_PERIOD * 5;
        control1(13) <= '0';  -- Deassert trigger
        
        -- Check output DURING firing (not after)
        wait for CLK_PERIOD * 8;  -- Wait until middle of firing cycle
        write(line_var, string'("DURING firing - OutputA: ") & to_string(outputA));
        writeline(output, line_var);
        write(line_var, string'("Status: ") & to_string(outputD));
        writeline(output, line_var);
        
        -- Wait for complete cycle
        wait for CLK_PERIOD * 12;
        
        write(line_var, string'("AFTER firing - OutputA: ") & to_string(outputA));
        writeline(output, line_var);
        write(line_var, string'("Status: ") & to_string(outputD));
        writeline(output, line_var);
        
        -- Test completion
        write(line_var, string'("=== Debug Test Complete ==="));
        writeline(output, line_var);
        
        wait;
    end process test_stimulus;
    
end architecture testbench;
