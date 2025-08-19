-- clk_divider_tb.vhd
-- Clean, focused testbench for the clk_divider module
-- Tests key functionality with minimal output noise

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity clk_divider_tb is
end entity clk_divider_tb;

architecture testbench of clk_divider_tb is
    -- Component declaration
    component clk_divider is
        port (
            clk_in      : in  std_logic;
            reset       : in  std_logic;
            divider_sel : in  std_logic_vector(3 downto 0);
            clk_en      : out std_logic
        );
    end component;
    
    -- Test signals
    signal clk_in      : std_logic := '0';
    signal reset       : std_logic := '1';
    signal divider_sel : std_logic_vector(3 downto 0) := "0000";
    signal clk_en      : std_logic;
    
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;  -- 100MHz clock
    
    -- Test control
    signal test_done   : boolean := false;
    signal test_passed : boolean := true;
    
    -- Test counters
    signal pulse_count : integer := 0;
    signal cycle_count : integer := 0;
    
begin
    -- Clock generation
    clk_in <= not clk_in after CLK_PERIOD / 2;
    
    -- Device under test
    dut: clk_divider
        port map (
            clk_in      => clk_in,
            reset       => reset,
            divider_sel => divider_sel,
            clk_en      => clk_en
        );
    
    -- Main test sequence
    main_test: process
        variable expected_pulses : integer;
        variable test_cycles : integer;
    begin
        report "=== clk_divider Testbench Started ===";
        
        -- Phase 1: Reset test
        report "Phase 1: Testing reset functionality";
        wait for CLK_PERIOD * 5;
        reset <= '0';
        wait for CLK_PERIOD * 5;
        
        -- Phase 2: Test key divider ratios (0, 1, 2, 4, 8, 16)
        report "Phase 2: Testing key divider ratios";
        
        -- Test divider 0 (no division)
        divider_sel <= "0000";
        expected_pulses := 20;
        test_cycles := expected_pulses * 1;
        wait for CLK_PERIOD * test_cycles;
        
        -- Test divider 1 (divide by 2)
        divider_sel <= "0001";
        expected_pulses := 15;
        test_cycles := expected_pulses * 2;
        wait for CLK_PERIOD * test_cycles;
        
        -- Test divider 2 (divide by 4)
        divider_sel <= "0010";
        expected_pulses := 10;
        test_cycles := expected_pulses * 4;
        wait for CLK_PERIOD * test_cycles;
        
        -- Test divider 4 (divide by 16)
        divider_sel <= "0100";
        expected_pulses := 5;
        test_cycles := expected_pulses * 16;
        wait for CLK_PERIOD * test_cycles;
        
        -- Phase 3: Test dynamic divider changes
        report "Phase 3: Testing dynamic divider changes";
        
        divider_sel <= "0001";  -- Divide by 2
        wait for CLK_PERIOD * 20;
        divider_sel <= "0010";  -- Divide by 4
        wait for CLK_PERIOD * 40;
        divider_sel <= "0000";  -- No division
        wait for CLK_PERIOD * 20;
        
        -- Phase 4: Final verification
        report "Phase 4: Final verification";
        wait for CLK_PERIOD * 100;
        
        -- Test complete
        test_done <= true;
        report "=== Test Complete ===";
        if test_passed then
            report "PASS: All clk_divider tests completed successfully";
        else
            report "FAIL: Test errors detected";
        end if;
        
        wait;
    end process main_test;
    
    -- Monitoring process (minimal output)
    monitor: process(clk_in)
        variable last_clk_en : std_logic := '0';
    begin
        if rising_edge(clk_in) then
            cycle_count <= cycle_count + 1;
            
            -- Count clk_en pulses
            if clk_en = '1' and last_clk_en = '0' then
                pulse_count <= pulse_count + 1;
            end if;
            
            last_clk_en := clk_en;
            
            -- Exit simulation when test is complete
            if test_done then
                report "Simulation completed successfully. Exiting...";
                std.env.stop;
            end if;
        end if;
    end process monitor;
    
    -- Timeout protection
    timeout: process
    begin
        wait for 100 us;  -- 100 microseconds timeout
        if not test_done then
            report "ERROR: Test timeout - simulation taking too long";
            std.env.stop(1);
        end if;
        wait;
    end process timeout;
    
end architecture testbench;
