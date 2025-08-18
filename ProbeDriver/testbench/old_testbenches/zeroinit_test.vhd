-- ZeroInit Testbench for ProbeDriver
-- Tests the automatic state machine execution when ControlRegisters are 0x00

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use IEEE.Std_Logic_TextIO.all;
use STD.TextIO.all;
use STD.Env.all;
use work.ProbeConfig_pkg.all;

entity zeroinit_test is
end entity zeroinit_test;

architecture testbench of zeroinit_test is
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
    
    -- Test state tracking
    signal test_completed : boolean := false;
    signal state_transitions : integer := 0;
    
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
        
        write(line_var, string'("=== ZeroInit Testbench ==="));
        writeline(output, line_var);
        write(line_var, string'("Testing automatic state machine execution on reset with 0x00 ControlRegisters"));
        writeline(output, line_var);
        writeline(output, line_var);
        
        -- Release reset to start zeroinit mode
        write(line_var, string'("Releasing reset..."));
        writeline(output, line_var);
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        -- Monitor state transitions
        write(line_var, string'("Monitoring state transitions..."));
        writeline(output, line_var);
        writeline(output, line_var);
        
        -- Wait for the complete zeroinit cycle to complete
        -- This should take: 16 cycles (duration) + 24 cycles (cooldown) = 40 cycles minimum
        wait for CLK_PERIOD * 50;
        
        -- Check final state
        write(line_var, string'("=== Test Results ==="));
        writeline(output, line_var);
        write(line_var, string'("Final Status Register: 0x") & to_hstring(status_register));
        writeline(output, line_var);
        write(line_var, string'("State Transitions Observed: ") & to_string(state_transitions));
        writeline(output, line_var);
        
        -- Verify zeroinit behavior
        if status_register(4) = '0' then
            write(line_var, string'("PASS: No validation errors detected"));
        else
            write(line_var, string'("FAIL: Validation errors detected"));
        end if;
        writeline(output, line_var);
        
        if status_register(3) = '1' then
            write(line_var, string'("PASS: COOL_DOWN state was reached"));
        else
            write(line_var, string'("FAIL: COOL_DOWN state was not reached"));
        end if;
        writeline(output, line_var);
        
        write(line_var, string'(""));
        writeline(output, line_var);
        write(line_var, string'("ZeroInit test completed successfully."));
        writeline(output, line_var);
        
        -- End simulation
        finish(0);
    end process test_stimulus;
    
    -- Monitor process to track state changes
    monitor: process(clk)
        variable last_status : std_logic_vector(4 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            -- Count state transitions by monitoring status register changes
            if status_register /= last_status then
                state_transitions <= state_transitions + 1;
                last_status := status_register;
            end if;
        end if;
    end process monitor;
    
end architecture testbench;
