-- Slot2/testbench/minimal_test.vhd
-- Minimal testbench to debug probe driver enable/trigger sequence

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.Std_Logic_TextIO.all;
use STD.TextIO.all;

-- NEW APPROACH: Include the standardized package instead of duplicating component declarations
use work.MokuModules_pkg.all;

entity minimal_test is
end entity minimal_test;

architecture testbench of minimal_test is
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
    
    -- Minimal test stimulus
    test_stimulus: process
        variable line_var : line;
    begin
        -- Initialize
        wait for CLK_PERIOD * 5;
        reset <= '0';
        wait for CLK_PERIOD * 10;
        
        -- Set basic parameters BEFORE reset so probe driver can read them
        control2(15 downto 8) <= x"55";  -- Intensity = 85
        control3 <= x"00000010";          -- Short pulse duration = 16
        control4 <= x"00000010";          -- Short cooldown = 16
        
        wait for CLK_PERIOD * 5;
        
        -- Now reset the probe driver to load the new parameters
        control1(15) <= '1';  -- Assert reset
        wait for CLK_PERIOD * 5;
        control1(15) <= '0';  -- Deassert reset
        wait for CLK_PERIOD * 10;
        
        -- Step 1: Enable
        write(line_var, string'("Step 1: Enabling probe driver"));
        writeline(output, line_var);
        control1(14) <= '1';  -- Enable
        wait for CLK_PERIOD * 10;
        
        write(line_var, string'("After enable - OutputA: ") & to_string(outputA));
        writeline(output, line_var);
        write(line_var, string'("OutputD (status): ") & to_string(outputD));
        writeline(output, line_var);
        
        -- Step 2: Trigger
        write(line_var, string'("Step 2: Triggering probe driver"));
        writeline(output, line_var);
        control1(13) <= '1';  -- Trigger
        wait for CLK_PERIOD * 5;
        control1(13) <= '0';  -- Deassert trigger
        wait for CLK_PERIOD * 30;  -- Wait for complete cycle
        
        write(line_var, string'("After trigger cycle - OutputA: ") & to_string(outputA));
        writeline(output, line_var);
        write(line_var, string'("OutputB: ") & to_string(outputB));
        writeline(output, line_var);
        write(line_var, string'("OutputD (status): ") & to_string(outputD));
        writeline(output, line_var);
        
        -- Test completion
        write(line_var, string'("=== Minimal Test Complete ==="));
        writeline(output, line_var);
        
        wait;
    end process test_stimulus;
    
end architecture testbench;
