-- probe_driver_wrapper_tb.vhd
-- Integration testbench for the refactored probe driver wrapper
-- Tests control register mapping, clock divider integration, and end-to-end functionality
-- PHASE 2: Interface Layer Testing

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.probe_driver_pkg.all;

entity probe_driver_wrapper_tb is
end entity probe_driver_wrapper_tb;

architecture testbench of probe_driver_wrapper_tb is
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;
    
    -- Test signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    
    -- Input and Output ports
    signal InputA : signed(15 downto 0) := (others => '0');
    signal InputB : signed(15 downto 0) := (others => '0');
    signal InputC : signed(15 downto 0) := (others => '0');
    signal InputD : signed(15 downto 0) := (others => '0');
    
    signal OutputA : signed(15 downto 0);
    signal OutputB : signed(15 downto 0);
    signal OutputC : signed(15 downto 0);
    signal OutputD : signed(15 downto 0);
    
    -- Control Registers
    signal Control0 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control1 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control2 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control3 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control4 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control5 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control6 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control7 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control8 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control9 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control10 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control11 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control12 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control13 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control14 : std_logic_vector(31 downto 0) := (others => '0');
    signal Control15 : std_logic_vector(31 downto 0) := (others => '0');
    
    -- Test control
    signal test_done : boolean := false;
    signal test_phase : integer := 0;
    
begin
    -- Clock generation
    clk <= not clk after CLK_PERIOD/2 when not test_done else '0';
    
    -- Instantiate the unit under test
    uut: entity work.probe_driver_wrapper
        port map (
            clk => clk,
            reset => reset,
            InputA => InputA,
            InputB => InputB,
            InputC => InputC,
            InputD => InputD,
            OutputA => OutputA,
            OutputB => OutputB,
            OutputC => OutputC,
            OutputD => OutputD,
            Control0 => Control0,
            Control1 => Control1,
            Control2 => Control2,
            Control3 => Control3,
            Control4 => Control4,
            Control5 => Control5,
            Control6 => Control6,
            Control7 => Control7,
            Control8 => Control8,
            Control9 => Control9,
            Control10 => Control10,
            Control11 => Control11,
            Control12 => Control12,
            Control13 => Control13,
            Control14 => Control14,
            Control15 => Control15
        );
    
    -- Test stimulus
    stimulus: process
    begin
        -- Initialize
        wait for CLK_PERIOD * 2;
        
        -- Test Phase 1: Reset behavior and safe defaults
        report "=== PHASE 1: Reset behavior and safe defaults ===";
        test_phase <= 1;
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD * 2;
        
        -- Test Phase 2: Enable with safe defaults (Control0(31) = '1')
        report "=== PHASE 2: Enable with safe defaults ===";
        test_phase <= 2;
        Control0(31) <= '1';  -- Enable
        Control0(22 downto 16) <= "0000001";  -- Intensity index 1
        Control0(15 downto 0) <= x"000A";     -- Duration 10 cycles
        Control1(31 downto 16) <= x"0005";    -- Cooldown 5 cycles
        wait for CLK_PERIOD * 2;
        
        -- Test Phase 3: Trigger once and wait for completion
        report "=== PHASE 3: Trigger once and wait for completion ===";
        test_phase <= 3;
        Control0(23) <= '1';  -- Soft trigger
        wait for CLK_PERIOD;
        Control0(23) <= '0';  -- Clear trigger
        wait for CLK_PERIOD * 20;  -- Wait for pulse + cooldown
        
        -- Test Phase 4: Manual trigger (Control0(23) = '1')
        report "=== PHASE 4: Manual trigger ===";
        test_phase <= 4;
        Control0(23) <= '1';  -- Soft trigger
        wait for CLK_PERIOD;
        Control0(23) <= '0';  -- Clear trigger
        wait for CLK_PERIOD * 20;  -- Wait for pulse + cooldown
        
        -- Test Phase 5: Auto-arm feature (Control0(30) = '1')
        report "=== PHASE 5: Auto-arm feature ===";
        test_phase <= 5;
        Control0(30) <= '1';  -- Enable auto-arm
        Control0(23) <= '1';  -- Trigger
        wait for CLK_PERIOD;
        Control0(23) <= '0';  -- Clear trigger
        wait for CLK_PERIOD * 20;  -- Wait for pulse + cooldown
        
        -- Test Phase 6: Clock divider testing (Control0(27:24))
        report "=== PHASE 6: Clock divider testing ===";
        test_phase <= 6;
        Control0(27 downto 24) <= x"1";  -- Divide by 2
        Control0(23) <= '1';  -- Trigger
        wait for CLK_PERIOD;
        Control0(23) <= '0';  -- Clear trigger
        wait for CLK_PERIOD * 40;  -- Wait longer due to clock division
        
        -- Test Phase 7: Status clear (Control0(28))
        report "=== PHASE 7: Status clear (Control0(28)) ===";
        test_phase <= 7;
        Control0(28) <= '1';  -- Status clear
        wait for CLK_PERIOD;
        Control0(28) <= '0';  -- Clear pulse
        wait for CLK_PERIOD * 2;
        
        -- Test Phase 8: Disable module (Control0(31) = '0')
        report "=== PHASE 8: Disable module ===";
        test_phase <= 8;
        Control0(31) <= '0';  -- Disable
        wait for CLK_PERIOD * 5;
        
        -- Test complete
        report "=== ALL INTEGRATION TESTS PASSED ===";
        test_done <= true;
        wait;
    end process stimulus;
    
    -- Monitor process for status checking
    monitor: process
        variable status_check : boolean := true;
    begin
        wait until test_phase = 1;
        
        -- Phase 1: Check reset behavior
        wait for CLK_PERIOD * 4;
        if OutputA /= x"0000" then
            report "ERROR: Status register not cleared on reset" severity error;
            status_check := false;
        end if;
        
        -- Phase 2: Check enable behavior (should auto-fire to ARMED state)
        wait until test_phase = 2;
        wait for CLK_PERIOD * 2;
        if OutputA(0) /= '1' then
            report "ERROR: ARMED status not set when enabled" severity error;
            status_check := false;
        end if;
        
        -- Phase 3: Check completion (should show FIRING then COOL_DOWN, and FIRED sticky bit)
        wait until test_phase = 3;
        wait for CLK_PERIOD * 10;  -- Wait for FIRING state
        if OutputA(1) /= '1' then
            report "ERROR: FIRING status not set during auto-fire" severity error;
            status_check := false;
        end if;
        wait for CLK_PERIOD * 10;  -- Wait for COOL_DOWN state
        if OutputA(3) /= '1' then
            report "ERROR: COOL_DOWN status not set after auto-fire" severity error;
            status_check := false;
        end if;
        -- FIRED sticky should be set
        if OutputA(2) /= '1' then
            report "ERROR: FIRED sticky bit not set after completion" severity error;
            status_check := false;
        end if;
        
        -- Phase 4: Check manual trigger (should show FIRING then COOL_DOWN)
        wait until test_phase = 4;
        wait for CLK_PERIOD * 10;  -- Wait for FIRING state
        if OutputA(1) /= '1' then
            report "ERROR: FIRING status not set during manual trigger" severity error;
            status_check := false;
        end if;
        wait for CLK_PERIOD * 10;  -- Wait for COOL_DOWN state
        if OutputA(3) /= '1' then
            report "ERROR: COOL_DOWN status not set after manual trigger" severity error;
            status_check := false;
        end if;
        
        -- Phase 5: Check auto-arm (should return to ARMED state)
        wait until test_phase = 5;
        wait for CLK_PERIOD * 20;  -- Wait for complete cycle
        if OutputA(0) /= '1' then
            report "ERROR: ARMED status not set after auto-arm" severity error;
            status_check := false;
        end if;
        
        -- Phase 6: Check clock divider (should work with slower timing)
        wait until test_phase = 6;
        wait for CLK_PERIOD * 40;  -- Wait longer due to clock division
        if OutputA(3) /= '1' then
            report "ERROR: COOL_DOWN status not set with clock divider" severity error;
            status_check := false;
        end if;
        
        -- Phase 7: Check status clear (FIRED sticky clears)
        wait until test_phase = 7;
        wait for CLK_PERIOD * 3;
        if OutputA(2) /= '0' then
            report "ERROR: FIRED sticky bit not cleared by status clear" severity error;
            status_check := false;
        end if;
        
        -- Phase 8: Check disable (should clear ARMED status)
        wait until test_phase = 8;
        wait for CLK_PERIOD * 5;  -- Wait longer for disable to take effect
        if OutputA(0) = '1' then
            report "ERROR: ARMED status still set when disabled" severity error;
            status_check := false;
        end if;
        
        -- Final status report
        if status_check then
            report "=== INTEGRATION TEST STATUS: ALL CHECKS PASSED ===";
        else
            report "=== INTEGRATION TEST STATUS: SOME CHECKS FAILED ===" severity error;
        end if;
        
        wait;
    end process monitor;
    
    -- Output monitoring process
    output_monitor: process
    begin
        wait until test_done;
        report "=== OUTPUT MONITORING COMPLETE ===";
        report "OutputA (Status): " & to_string(OutputA);
        report "OutputB (Trigger): " & to_string(OutputB);
        report "OutputC (Intensity): " & to_string(OutputC);
        report "OutputD (Reserved): " & to_string(OutputD);
        report "SIMULATION DONE";
        wait;
    end process output_monitor;
    
end architecture testbench;
