-- ZeroInit Debug Testbench for ProbeDriver
-- Shows detailed information about zeroinit mode operation

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.Std_Logic_TextIO.all;
use STD.TextIO.all;
use STD.Env.all;
use work.ProbeConfig_pkg.all;

entity zeroinit_debug is
end entity zeroinit_debug;

architecture testbench of zeroinit_debug is
    -- Clock and control signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal enable : std_logic := '0';
    signal trig_in : std_logic := '0';
    
    -- Input signals (all set to 0x00 for zeroinit mode)
    signal Intensity_index : std_logic_vector(7 downto 0) := x"00";
    signal PulseDuration_in : std_logic_vector(31 downto 0) := x"00000000";
    signal CoolDown_in : std_logic_vector(31 downto 0) := x"00000000";
    
    -- Output signals
    signal trig_out : signed(15 downto 0);
    signal intensity_out : signed(15 downto 0);
    signal status_register : std_logic_vector(4 downto 0);
    
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;
    
begin
    -- Instantiate the DUT
    dut: entity work.probe_driver
        port map (
            clk => clk,
            reset => reset,
            enable => enable,
            trig_in => trig_in,
            Intensity_index => Intensity_index,
            PulseDuration_in => PulseDuration_in,
            CoolDown_in => CoolDown_in,
            trig_out => trig_out,
            intensity_out => intensity_out,
            status_register => status_register
        );
    
    -- Clock generation
    clk <= not clk after CLK_PERIOD / 2;
    
    -- Test stimulus
    test_stimulus: process
        variable line_var : line;
    begin
        -- Wait for initial setup
        wait for CLK_PERIOD * 2;
        
        write(line_var, string'("=== ZeroInit Debug Testbench ==="));
        writeline(output, line_var);
        write(line_var, string'("Testing zeroinit mode with detailed debugging"));
        writeline(output, line_var);
        writeline(output, line_var);
        
        -- Show expected values
        write(line_var, string'("Expected ZeroInit Values:"));
        writeline(output, line_var);
        write(line_var, string'("  Intensity: 0 (ProbeIntensityMin)"));
        writeline(output, line_var);
        write(line_var, string'("  Duration: ") & to_string(ProbeIntensityMin) & string'(" (PulseMinDuration)"));
        writeline(output, line_var);
        write(line_var, string'("  Cooldown: ") & to_string(ProbeCoolDownMin) & string'(" (ProbeCoolDownMin)"));
        writeline(output, line_var);
        writeline(output, line_var);
        
        -- Show input values
        write(line_var, string'("Input Values (0x00 ControlRegisters):"));
        writeline(output, line_var);
        write(line_var, string'("  Intensity_index: 0x") & to_hstring(Intensity_index));
        writeline(output, line_var);
        write(line_var, string'("  PulseDuration_in: 0x") & to_hstring(PulseDuration_in));
        writeline(output, line_var);
        write(line_var, string'("  CoolDown_in: 0x") & to_hstring(CoolDown_in));
        writeline(output, line_var);
        writeline(output, line_var);
        
        -- Release reset to start zeroinit mode
        write(line_var, string'("Releasing reset..."));
        writeline(output, line_var);
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        -- Monitor status for a few cycles
        write(line_var, string'("Monitoring status register changes..."));
        writeline(output, line_var);
        writeline(output, line_var);
        
        -- Wait and show status changes
        for i in 1 to 10 loop
            wait for CLK_PERIOD;
            write(line_var, string'("Cycle ") & to_string(i) & string'(": Status=0x") & to_hstring(status_register));
            writeline(output, line_var);
        end loop;
        
        -- Wait for more cycles to see state progression
        wait for CLK_PERIOD * 20;
        
        -- Show final state
        write(line_var, string'(""));
        writeline(output, line_var);
        write(line_var, string'("=== Final Results ==="));
        writeline(output, line_var);
        write(line_var, string'("Final Status Register: 0x") & to_hstring(status_register));
        writeline(output, line_var);
        
        -- Decode status register
        write(line_var, string'("Status Register Decode:"));
        writeline(output, line_var);
        write(line_var, string'("  Bit 0 (ARMED): ") & to_string(status_register(0)));
        writeline(output, line_var);
        write(line_var, string'("  Bit 1 (FIRING): ") & to_string(status_register(1)));
        writeline(output, line_var);
        write(line_var, string'("  Bit 2 (FIRED): ") & to_string(status_register(2)));
        writeline(output, line_var);
        write(line_var, string'("  Bit 3 (COOL_DOWN): ") & to_string(status_register(3)));
        writeline(output, line_var);
        write(line_var, string'("  Bit 4 (ERROR): ") & to_string(status_register(4)));
        writeline(output, line_var);
        
        write(line_var, string'(""));
        writeline(output, line_var);
        write(line_var, string'("ZeroInit debug test completed."));
        writeline(output, line_var);
        
        -- End simulation
        finish(0);
    end process test_stimulus;
    
end architecture testbench;
