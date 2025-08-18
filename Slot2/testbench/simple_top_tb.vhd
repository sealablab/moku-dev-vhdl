-- Slot2/testbench/simple_top_tb.vhd
-- Simple testbench for the top_probe_driver module
-- Focuses on basic register assignments and output verification

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.Std_Logic_TextIO.all;
use STD.TextIO.all;

-- NEW APPROACH: Include the standardized package instead of duplicating component declarations
use work.MokuModules_pkg.all;

entity simple_top_tb is
end entity simple_top_tb;

architecture testbench of simple_top_tb is
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
    
    -- Simple test stimulus
    test_stimulus: process
        variable line_var : line;
    begin
        -- Initialize
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD * 5;  -- Give more time for reset to complete
        
        -- Test 1: Basic register assignment verification
        write(line_var, string'("=== Test 1: Register Assignment Verification ==="));
        writeline(output, line_var);
        
        -- Set up control registers
        control0 <= x"12345678";  -- Reserved for TOP module
        control1 <= x"00000000";  -- All control signals off
        control2 <= x"00005500";  -- Intensity = 85 in bits [15:8]
        control3 <= x"00000064";  -- Pulse duration = 100
        control4 <= x"00000100";  -- Cooldown = 256
        
        wait for CLK_PERIOD * 5;
        
        -- Display current outputs
        write(line_var, string'("OutputA: ") & to_string(outputA));
        writeline(output, line_var);
        write(line_var, string'("OutputB: ") & to_string(outputB));
        writeline(output, line_var);
        write(line_var, string'("OutputC: ") & to_string(outputC));
        writeline(output, line_var);
        write(line_var, string'("OutputD: ") & to_string(outputD));
        writeline(output, line_var);
        
        -- Test 2: Enable the probe driver
        write(line_var, string'("=== Test 2: Enable Probe Driver ==="));
        writeline(output, line_var);
        
        control1(14) <= '1';  -- Enable
        wait for CLK_PERIOD * 10;  -- Give more time for enable to take effect
        
        write(line_var, string'("After Enable - OutputA: ") & to_string(outputA));
        writeline(output, line_var);
        
        -- Test 2.5: Trigger the probe driver to fire
        write(line_var, string'("=== Test 2.5: Trigger Probe Driver ==="));
        writeline(output, line_var);
        
        control1(13) <= '1';  -- Trigger
        wait for CLK_PERIOD * 5;  -- Hold trigger longer
        control1(13) <= '0';  -- Deassert trigger
        wait for CLK_PERIOD * 20;  -- Wait longer for firing cycle to complete
        
        write(line_var, string'("After Trigger - OutputA: ") & to_string(outputA));
        writeline(output, line_var);
        write(line_var, string'("After Trigger - OutputB: ") & to_string(outputB));
        writeline(output, line_var);
        
        -- Test 3: Change intensity
        write(line_var, string'("=== Test 3: Change Intensity ==="));
        writeline(output, line_var);
        
        control2(15 downto 8) <= x"FF";  -- Maximum intensity
        wait for CLK_PERIOD * 5;
        
        -- Reset to reload new parameters
        control1(15) <= '1';  -- Assert reset
        wait for CLK_PERIOD * 3;
        control1(15) <= '0';  -- Deassert reset
        wait for CLK_PERIOD * 5;
        
        -- Re-enable after reset
        control1(14) <= '1';  -- Enable
        wait for CLK_PERIOD * 5;
        
        write(line_var, string'("After Intensity Change and Reset - OutputA: ") & to_string(outputA));
        writeline(output, line_var);
        
        -- Test completion
        write(line_var, string'("=== Test Complete ==="));
        writeline(output, line_var);
        
        wait;
    end process test_stimulus;
    
end architecture testbench;
