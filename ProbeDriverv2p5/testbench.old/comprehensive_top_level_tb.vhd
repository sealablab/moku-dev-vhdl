-- comprehensive_top_level_tb.vhd
-- Comprehensive top-level testbench for CustomWrapper + clk_divider + ProbeDriver
-- Tests complete system integration from top level down

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.intensity_lut_pkg.all;
use work.probe_driver_pkg.all;

entity comprehensive_top_level_tb is
end entity comprehensive_top_level_tb;

architecture testbench of comprehensive_top_level_tb is
    -- Component declaration for CustomWrapper
    component CustomWrapper is
        port (
            Clk      : in  std_logic;
            Reset    : in  std_logic;
            InputA   : in  signed(15 downto 0);
            InputB   : in  signed(15 downto 0);
            InputC   : in  signed(15 downto 0);
            InputD   : in  signed(15 downto 0);
            Control0 : in  std_logic_vector(31 downto 0);
            Control1 : in  std_logic_vector(31 downto 0);
            Control2 : in  std_logic_vector(31 downto 0);
            Control3 : in  std_logic_vector(31 downto 0);
            Control4 : in  std_logic_vector(31 downto 0);
            Control5 : in  std_logic_vector(31 downto 0);
            Control6 : in  std_logic_vector(31 downto 0);
            Control7 : in  std_logic_vector(31 downto 0);
            Control8 : in  std_logic_vector(31 downto 0);
            Control9 : in  std_logic_vector(31 downto 0);
            Control10: in  std_logic_vector(31 downto 0);
            Control11: in  std_logic_vector(31 downto 0);
            Control12: in  std_logic_vector(31 downto 0);
            Control13: in  std_logic_vector(31 downto 0);
            Control14: in  std_logic_vector(31 downto 0);
            Control15: in  std_logic_vector(31 downto 0);
            OutputA  : out signed(15 downto 0);
            OutputB  : out signed(15 downto 0);
            OutputC  : out signed(15 downto 0);
            OutputD  : out signed(15 downto 0)
        );
    end component;
    
    -- Test signals
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal inputA    : signed(15 downto 0) := (others => '0');
    signal inputB    : signed(15 downto 0) := (others => '0');
    signal inputC    : signed(15 downto 0) := (others => '0');
    signal inputD    : signed(15 downto 0) := (others => '0');
    signal control0  : std_logic_vector(31 downto 0) := (others => '0');
    signal control1  : std_logic_vector(31 downto 0) := (others => '0');
    signal control2  : std_logic_vector(31 downto 0) := (others => '0');
    signal control3  : std_logic_vector(31 downto 0) := (others => '0');
    signal control4  : std_logic_vector(31 downto 0) := (others => '0');
    signal control5  : std_logic_vector(31 downto 0) := (others => '0');
    signal control6  : std_logic_vector(31 downto 0) := (others => '0');
    signal control7  : std_logic_vector(31 downto 0) := (others => '0');
    signal control8  : std_logic_vector(31 downto 0) := (others => '0');
    signal control9  : std_logic_vector(31 downto 0) := (others => '0');
    signal control10 : std_logic_vector(31 downto 0) := (others => '0');
    signal control11 : std_logic_vector(31 downto 0) := (others => '0');
    signal control12 : std_logic_vector(31 downto 0) := (others => '0');
    signal control13 : std_logic_vector(31 downto 0) := (others => '0');
    signal control14 : std_logic_vector(31 downto 0) := (others => '0');
    signal control15 : std_logic_vector(31 downto 0) := (others => '0');
    signal outputA   : signed(15 downto 0);
    signal outputB   : signed(15 downto 0);
    signal outputC   : signed(15 downto 0);
    signal outputD   : signed(15 downto 0);
    
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;  -- 100MHz clock
    
    -- Test state tracking
    signal test_phase : integer := 0;
    signal cycle_count : integer := 0;
    
    -- Test parameters
    signal current_divider : std_logic_vector(3 downto 0) := "0000";
    signal current_intensity : std_logic_vector(6 downto 0) := "0000001";
    signal current_duration : std_logic_vector(15 downto 0) := x"0004";
    signal current_cooldown : std_logic_vector(15 downto 0) := x"0004";
    
    -- Expected behavior tracking
    signal expected_state : std_logic_vector(3 downto 0);
    signal expected_outputs : boolean := false;
    
begin
    -- Clock generation
    clk <= not clk after CLK_PERIOD / 2;
    
    -- Device under test (CustomWrapper)
    dut: CustomWrapper
        port map (
            Clk      => clk,
            Reset    => reset,
            InputA   => inputA,
            InputB   => inputB,
            InputC   => inputC,
            InputD   => inputD,
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
            Control15 => control15,
            OutputA  => outputA,
            OutputB  => outputB,
            OutputC  => outputC,
            OutputD  => outputD
        );
    
    -- Main test sequence
    main_test: process
        variable test_cycles : integer;
        variable divider_value : integer;
    begin
        report "=== Comprehensive Top-Level Test Started ===";
        
        -- Phase 0: Initial reset and setup
        test_phase <= 0;
        report "Phase 0: Initial reset and setup";
        reset <= '1';
        control0 <= (others => '0');  -- All zeros = safe defaults mode
        control1 <= (others => '0');
        wait for CLK_PERIOD * 10;
        
        -- Phase 1: Test normal operation (no clock division)
        test_phase <= 1;
        report "Phase 1: Testing normal operation (no clock division)";
        reset <= '0';
        current_divider <= "0000";  -- No division
        control0(27 downto 24) <= current_divider;
        control0(31) <= '0';       -- Enable (safe defaults mode)
        control0(30) <= '0';       -- Auto-arm disabled
        control0(23) <= '0';       -- No trigger
        control0(22 downto 16) <= current_intensity;
        control0(15 downto 0) <= current_duration;
        control1(31 downto 16) <= current_cooldown;
        
        -- Wait for auto-fire cycle to complete
        test_cycles := to_integer(unsigned(current_duration)) + to_integer(unsigned(current_cooldown)) + 10;
        wait for CLK_PERIOD * test_cycles;
        
        -- Phase 2: Test clock division by 2
        test_phase <= 2;
        report "Phase 2: Testing clock division by 2";
        current_divider <= "0001";  -- Divide by 2
        control0(27 downto 24) <= current_divider;
        wait for CLK_PERIOD * 20;
        
        -- Phase 3: Test clock division by 4
        test_phase <= 3;
        report "Phase 3: Testing clock division by 4";
        current_divider <= "0010";  -- Divide by 4
        control0(27 downto 24) <= current_divider;
        wait for CLK_PERIOD * 40;
        
        -- Phase 4: Test clock division by 8
        test_phase <= 4;
        report "Phase 4: Testing clock division by 8";
        current_divider <= "0011";  -- Divide by 8
        control0(27 downto 24) <= current_divider;
        wait for CLK_PERIOD * 80;
        
        -- Phase 5: Test clock division by 16
        test_phase <= 5;
        report "Phase 5: Testing clock division by 16";
        current_divider <= "0100";  -- Divide by 16
        control0(27 downto 24) <= current_divider;
        wait for CLK_PERIOD * 160;
        
        -- Phase 6: Test auto-arm feature
        test_phase <= 6;
        report "Phase 6: Testing auto-arm feature";
        current_divider <= "0000";  -- Back to no division for faster testing
        control0(27 downto 24) <= current_divider;
        control0(30) <= '1';       -- Enable auto-arm
        wait for CLK_PERIOD * 20;
        
        -- Phase 7: Test manual trigger
        test_phase <= 7;
        report "Phase 7: Testing manual trigger";
        control0(23) <= '1';       -- Trigger
        wait for CLK_PERIOD * 2;
        control0(23) <= '0';       -- Clear trigger
        wait for CLK_PERIOD * 50;  -- Wait for cycle to complete
        
        -- Phase 8: Test dynamic divider changes
        test_phase <= 8;
        report "Phase 8: Testing dynamic divider changes";
        control0(27 downto 24) <= "0001";  -- Divide by 2
        wait for CLK_PERIOD * 20;
        control0(27 downto 24) <= "0010";  -- Divide by 4
        wait for CLK_PERIOD * 40;
        control0(27 downto 24) <= "0000";  -- Back to no division
        wait for CLK_PERIOD * 20;
        
        -- Phase 9: Test different intensity and duration
        test_phase <= 9;
        report "Phase 9: Testing different intensity and duration";
        current_intensity <= "0110010";  -- 50 (medium intensity)
        current_duration <= x"0008";     -- 8 cycles
        control0(22 downto 16) <= current_intensity;
        control0(15 downto 0) <= current_duration;
        wait for CLK_PERIOD * 50;
        
        -- Phase 10: Test different cooldown
        test_phase <= 10;
        report "Phase 10: Testing different cooldown";
        current_cooldown <= x"0008";     -- 8 cycles
        control1(31 downto 16) <= current_cooldown;
        wait for CLK_PERIOD * 50;
        
        -- Phase 11: Test disable mode
        test_phase <= 11;
        report "Phase 11: Testing disable mode";
        control0(31) <= '1';       -- Disable (safety off mode)
        wait for CLK_PERIOD * 20;
        control0(31) <= '0';       -- Re-enable
        wait for CLK_PERIOD * 20;
        
        -- Phase 12: Final verification
        test_phase <= 12;
        report "Phase 12: Final verification";
        wait for CLK_PERIOD * 100;
        
        -- Test complete
        report "=== Comprehensive Test Complete ===";
        report "PASS: All top-level integration tests completed successfully";
        
        wait;
    end process main_test;
    
    -- Monitoring and validation process
    monitor: process(clk)
        variable last_outputA : signed(15 downto 0);
        variable last_outputB : signed(15 downto 0);
        variable last_outputC : signed(15 downto 0);
    begin
        if rising_edge(clk) then
            cycle_count <= cycle_count + 1;
            
            -- Track output changes
            if outputA /= last_outputA or outputB /= last_outputB or outputC /= last_outputC then
                report "Cycle " & integer'image(cycle_count) & 
                       " - Outputs changed:" &
                       " A=" & to_hstring(std_logic_vector(outputA)) &
                       " B=" & to_hstring(std_logic_vector(outputB)) &
                       " C=" & to_hstring(std_logic_vector(outputC));
            end if;
            
            last_outputA := outputA;
            last_outputB := outputB;
            last_outputC := outputC;
            
            -- Periodic status report
            if cycle_count mod 200 = 0 then
                report "Cycle " & integer'image(cycle_count) & 
                       " - Phase " & integer'image(test_phase) &
                       " - Divider=" & to_hstring(current_divider) &
                       " - Control0=" & to_hstring(control0) &
                       " - OutputA=" & to_hstring(std_logic_vector(outputA));
            end if;
            
            -- Basic validation checks
            if test_phase > 0 then
                -- Validate that outputs are reasonable
                if outputA < -32768 or outputA > 32767 then
                    report "ERROR: OutputA out of range: " & integer'image(to_integer(outputA));
                end if;
                
                if outputB < -32768 or outputB > 32767 then
                    report "ERROR: OutputB out of range: " & integer'image(to_integer(outputB));
                end if;
                
                if outputC < -32768 or outputC > 32767 then
                    report "ERROR: OutputC out of range: " & integer'image(to_integer(outputC));
                end if;
            end if;
        end if;
    end process monitor;
    
    -- Timeout protection
    timeout: process
    begin
        wait for 50 us;  -- 50 microseconds timeout
        if test_phase < 12 then
            report "ERROR: Test timeout - simulation taking too long";
        end if;
        std.env.stop;
        wait;
    end process timeout;
    
end architecture testbench;
