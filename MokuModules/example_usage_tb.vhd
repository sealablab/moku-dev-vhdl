-- example_usage_tb.vhd
-- Example testbench demonstrating the new MokuModules approach
-- This shows how to eliminate duplication by using the standardized package

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

-- NEW APPROACH: Include the standardized package instead of duplicating component declarations
use work.MokuModules_pkg.all;

entity example_usage_tb is
end entity example_usage_tb;

architecture testbench of example_usage_tb is
    -- Use constants from the package instead of defining them locally
    constant CLK_PERIOD : time := MOKUGO_CLK_PERIOD;  -- 32ns from package
    constant RESET_ACTIVE_VAL : std_logic := RESET_ACTIVE; -- From package
    
    -- Signal declarations
    signal clk : std_logic := '0';
    signal reset : std_logic := RESET_ACTIVE_VAL;
    signal inputA, inputB, inputC, inputD : signed(15 downto 0) := (others => '0');
    signal outputA, outputB, outputC, outputD : signed(15 downto 0);
    signal control0, control1, control2, control3, control4 : std_logic_vector(31 downto 0) := (others => '0');
    signal control5, control6, control7, control8, control9 : std_logic_vector(31 downto 0) := (others => '0');
    signal control10, control11, control12, control13, control14, control15 : std_logic_vector(31 downto 0) := (others => '0');
    
begin
    -- =============================================================================
    -- CLOCK GENERATION
    -- =============================================================================
    clk <= not clk after CLK_PERIOD / 2;
    
    -- =============================================================================
    -- UNIT UNDER TEST INSTANTIATION
    -- =============================================================================
    -- NEW APPROACH: No component declaration needed - it's in the package!
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
    
    -- =============================================================================
    -- TEST STIMULUS
    -- =============================================================================
    test_stimulus: process
    begin
        -- Initialize
        wait for CLK_PERIOD * 2;
        
        -- Release reset
        reset <= RESET_INACTIVE;
        wait for CLK_PERIOD * 2;
        
        -- Test basic functionality
        control0 <= x"00000001";
        wait for CLK_PERIOD;
        
        -- Verify outputs
        assert outputA = x"0000" report "OutputA should be 0 after reset" severity note;
        
        -- End simulation
        wait for CLK_PERIOD * 10;
        report "Example testbench completed successfully" severity note;
        wait;
    end process test_stimulus;
    
end architecture testbench;
