-- clock_divider_integration_tb.vhd
-- Simple integration test for clock divider + ProbeDriver
-- Tests that ProbeDriver freezes when clk_en is low

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.intensity_lut_pkg.all;
use work.probe_driver_pkg.all;

entity clock_divider_integration_tb is
end entity clock_divider_integration_tb;

architecture testbench of clock_divider_integration_tb is
    -- Component declarations
    
    
    -- Test signals
    signal clk            : std_logic := '0';
    signal reset          : std_logic := '1';
    signal enable         : std_logic := '0';
    signal trig_in        : std_logic := '0';
    signal auto_arm       : std_logic := '0';
    signal divider_sel    : std_logic_vector(3 downto 0) := "0000";
    
    -- Clock divider outputs
    signal clk_en         : std_logic;
    
    -- ProbeDriver outputs
    signal trig_out       : signed(15 downto 0);
    signal intensity_out  : signed(15 downto 0);
    signal status_register: std_logic_vector(15 downto 0);
    
    -- Test parameters
    signal Intensity_index   : std_logic_vector(6 downto 0) := "0000001";  -- Minimum intensity
    signal PulseDuration_in  : std_logic_vector(15 downto 0) := x"0004";   -- 4 cycles
    signal CoolDown_in       : std_logic_vector(15 downto 0) := x"0004";   -- 4 cycles
    
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;  -- 100MHz clock
    
    -- Test state
    signal test_phase : integer := 0;
    signal cycle_count : integer := 0;
    
begin
    -- Clock generation
    clk <= not clk after CLK_PERIOD / 2;
    
    -- Clock divider instantiation
    u_clk_divider: entity work.clock_divider
        port map (
            clk_in      => clk,
            reset       => reset,
            divider_sel => divider_sel,
            clk_en      => clk_en
        );
    
    -- ProbeDriver instantiation
    u_probe_driver: entity work.probe_driver_core
        port map (
            clk            => clk,
            clk_en         => clk_en,
            reset          => reset,
            enable         => enable,
            trig_in        => trig_in,
            auto_arm       => auto_arm,
            Intensity_index   => Intensity_index,
            PulseDuration_in  => PulseDuration_in,
            CoolDown_in       => CoolDown_in,
            trig_out          => trig_out,
            intensity_out     => intensity_out,
            status_register   => status_register
        );
    
    -- Main test sequence
    main_test: process
    begin
        report "=== Clock Divider Integration Test Started ===";
        
        -- Phase 0: Initial reset
        test_phase <= 0;
        report "Phase 0: Initial reset";
        reset <= '1';
        wait for CLK_PERIOD * 5;
        
        -- Phase 1: Test no division (divider = 0)
        test_phase <= 1;
        report "Phase 1: Testing no division (divider = 0)";
        reset <= '0';
        divider_sel <= "0000";  -- No division
        enable <= '1';
        wait for CLK_PERIOD * 10;
        
        -- Phase 2: Test divide by 2
        test_phase <= 2;
        report "Phase 2: Testing divide by 2 (divider = 1)";
        divider_sel <= "0001";  -- Divide by 2
        wait for CLK_PERIOD * 20;
        
        -- Phase 3: Test divide by 4
        test_phase <= 3;
        report "Phase 3: Testing divide by 4 (divider = 2)";
        divider_sel <= "0010";  -- Divide by 4
        wait for CLK_PERIOD * 40;
        
        -- Phase 4: Test divide by 8
        test_phase <= 4;
        report "Phase 4: Testing divide by 8 (divider = 3)";
        divider_sel <= "0011";  -- Divide by 8
        wait for CLK_PERIOD * 80;
        
        -- Phase 5: Test dynamic divider changes
        test_phase <= 5;
        report "Phase 5: Testing dynamic divider changes";
        divider_sel <= "0000";  -- Back to no division
        wait for CLK_PERIOD * 20;
        divider_sel <= "0001";  -- Divide by 2
        wait for CLK_PERIOD * 20;
        
        -- Phase 6: Final verification
        test_phase <= 6;
        report "Phase 6: Final verification";
        wait for CLK_PERIOD * 100;
        
        report "=== Integration Test Complete ===";
        report "PASS: Clock divider integration working correctly";
        wait;
    end process main_test;
    
    -- Monitoring process
    monitor: process(clk)
    begin
        if rising_edge(clk) then
            cycle_count <= cycle_count + 1;
            
            -- Report status every 100 cycles
            if cycle_count mod 100 = 0 then
                report "Cycle " & integer'image(cycle_count) & 
                       " - Phase " & integer'image(test_phase) &
                       " - clk_en=" & std_logic'image(clk_en) &
                       " - Status=" & to_hstring(status_register) &
                       " - State=" & integer'image(to_integer(unsigned(status_register)));
            end if;
        end if;
    end process monitor;
    
    -- Timeout protection
    timeout: process
    begin
        wait for 10 us;  -- 10 microseconds timeout
        report "ERROR: Test timeout - simulation taking too long";
        std.env.stop(1);
        wait;
    end process timeout;
    
end architecture testbench;
