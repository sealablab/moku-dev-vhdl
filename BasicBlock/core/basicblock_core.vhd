-- =============================================================================
-- basicblock_core.vhd
-- =============================================================================
-- 
-- Core LED Pattern Generation Logic for BasicBlock Module
-- 
-- PURPOSE: This module contains the main logic for generating LED patterns and
--          managing the timing of those patterns. It's like the "brain" of the
--          LED system that decides what to display and when.
-- 
-- TARGET PLATFORM: Moku-Go (Liquid Instruments)
--                  - FPGA-based signal generation and analysis platform
--                  - 4 analog outputs (OutputA, OutputB, OutputC, OutputD)
--                  - 16-bit signed resolution (-32768 to +32767)
--                  - Configurable via control registers
-- 
-- INTEGRATION: This module integrates with the existing clk-divider module
--              to provide flexible timing control for LED patterns.
-- 
-- LEARNING OBJECTIVES:
--   1. Understanding VHDL entity and architecture design
--   2. Learning about clock divider integration and timing control
--   3. Understanding how to create synchronized LED patterns
--   4. Learning about state machines and pattern generation
--   5. Understanding how to interface with external modules
-- 
-- =============================================================================

library IEEE;
use IEEE.Std_Logic_1164.all;  -- Standard logic types (std_logic, std_logic_vector)
use IEEE.Numeric_Std.all;      -- Numeric types (unsigned, signed, integer)
use work.basicblock_pkg.all;   -- Our BasicBlock package with types and utilities
use work.led_pattern_pkg.all;  -- Our LED pattern generation package

entity basicblock_core is
    port (
        -- =============================================================================
        -- CLOCK AND CONTROL SIGNALS
        -- =============================================================================
        -- These are the basic signals that every digital system needs
        clk                    : in  std_logic;  -- Main system clock (125 MHz in Moku-Go)
        reset                  : in  std_logic;  -- Reset signal (1=reset, 0=normal)
        enable                 : in  std_logic;  -- Enable signal (1=enabled, 0=disabled)
        
        -- =============================================================================
        -- CLOCK DIVIDER INTEGRATION
        -- =============================================================================
        -- These signals connect to the clock divider module in the wrapper
        -- The wrapper instantiates the clock divider and passes control signals
        clk_divider_enable    : out std_logic;  -- Enable signal for clock divider
        clk_divider_ratio     : out std_logic_vector(15 downto 0); -- Division ratio
        clk_divider_output    : in  std_logic;  -- Divided clock input from wrapper
        
        -- =============================================================================
        -- CONFIGURATION INPUTS
        -- =============================================================================
        -- These contain all the settings for how the LED patterns should behave
        global_config          : in  global_config_type;   -- Global system settings
        output_a_config        : in  output_config_type;   -- Settings for Output A
        output_b_config        : in  output_config_type;   -- Settings for Output B
        output_c_config        : in  output_config_type;   -- Settings for Output C
        output_d_config        : in  output_config_type;   -- Settings for Output D
        
        -- =============================================================================
        -- OUTPUT SIGNALS
        -- =============================================================================
        -- These are the actual LED pattern outputs that go to the Moku-Go outputs
        -- Each output is 16-bit signed (-32768 to +32767) for fine control
        output_a               : out signed(15 downto 0);  -- LED pattern for Output A
        output_b               : out signed(15 downto 0);  -- LED pattern for Output B
        output_c               : out signed(15 downto 0);  -- LED pattern for Output C
        output_d               : out signed(15 downto 0)   -- LED pattern for Output D
    );
end entity basicblock_core;

architecture rtl of basicblock_core is
    -- =============================================================================
    -- INTERNAL SIGNALS - These are like "internal variables" in the module
    -- =============================================================================
    
    -- Clock divider control signals
    -- These control how the clk-divider module behaves
    signal clk_div_en         : std_logic;                    -- Clock divider enable
    signal clk_div_ratio      : std_logic_vector(15 downto 0); -- Clock division ratio
    
    -- Pattern timing signals
    -- These control when patterns change and how fast they run
    signal pattern_counter     : unsigned(15 downto 0) := (others => '0'); -- Main pattern counter
    signal output_counters_0  : unsigned(15 downto 0) := (others => '0'); -- Counter for Output A
    signal output_counters_1  : unsigned(15 downto 0) := (others => '0'); -- Counter for Output B
    signal output_counters_2  : unsigned(15 downto 0) := (others => '0'); -- Counter for Output C
    signal output_counters_3  : unsigned(15 downto 0) := (others => '0'); -- Counter for Output D
    
    -- Pattern generation signals
    -- These hold the current LED pattern values before brightness scaling
    signal raw_pattern_a       : unsigned(15 downto 0); -- Raw pattern for Output A
    signal raw_pattern_b       : unsigned(15 downto 0); -- Raw pattern for Output B
    signal raw_pattern_c       : unsigned(15 downto 0); -- Raw pattern for Output C
    signal raw_pattern_d       : unsigned(15 downto 0); -- Raw pattern for Output D
    
    -- Brightness-scaled patterns
    -- These hold the final pattern values after brightness adjustment
    signal scaled_pattern_a    : unsigned(15 downto 0); -- Scaled pattern for Output A
    signal scaled_pattern_b    : unsigned(15 downto 0); -- Scaled pattern for Output B
    signal scaled_pattern_c    : unsigned(15 downto 0); -- Scaled pattern for Output C
    signal scaled_pattern_d    : unsigned(15 downto 0); -- Scaled pattern for Output D
    
    -- Output enable signals
    -- These control whether each output is active or disabled
    signal output_a_enabled    : std_logic; -- Output A enable status
    signal output_b_enabled    : std_logic; -- Output B enable status
    signal output_c_enabled    : std_logic; -- Output C enable status
    signal output_d_enabled    : std_logic; -- Output D enable status
    
    -- Synchronization signals
    -- These ensure all outputs change patterns at the same time when sync mode is enabled
    signal sync_counter        : unsigned(15 downto 0) := (others => '0'); -- Synchronization counter
    signal sync_trigger        : std_logic; -- Trigger for synchronized pattern changes
    
    -- =============================================================================
    -- COMPONENT DECLARATIONS - These tell VHDL about external modules we'll use
    -- =============================================================================
    
    -- Note: ClockDivider is instantiated in the wrapper, not in the core
    -- The core receives clk_divider_output as an input signal
    
begin
    -- =============================================================================
    -- CLOCK DIVIDER INTEGRATION
    -- =============================================================================
    -- This section connects our module to the existing clk-divider module
    -- The clk-divider provides flexible timing control for our LED patterns
    
    -- Connect our clock divider control signals to the output ports
    -- This allows the wrapper to control the clock divider
    clk_divider_enable <= clk_div_en;
    clk_divider_ratio <= clk_div_ratio;
    
    -- Note: ClockDivider is instantiated in the wrapper, not in the core
    -- The core receives clk_divider_output as an input signal from the wrapper
    
    -- =============================================================================
    -- CLOCK DIVIDER CONTROL LOGIC
    -- =============================================================================
    -- This section controls how the clock divider behaves based on our configuration
    
    -- Set the clock divider ratio from global configuration
    -- This controls how fast our LED patterns change
    clk_div_ratio <= std_logic_vector(global_config.clock_divider);
    
    -- Enable the clock divider when the system is enabled
    -- This prevents unnecessary power consumption when disabled
    clk_div_en <= enable and global_config.master_enable;
    
    -- =============================================================================
    -- MAIN PATTERN TIMING LOGIC
    -- =============================================================================
    -- This section controls when patterns change and how fast they run
    
    -- Main pattern counter process
    -- This counter runs on the divided clock and controls pattern timing
    pattern_timing: process(clk_divider_output, reset)
    begin
        if reset = '1' then
            -- Reset all counters when reset is active
            pattern_counter <= (others => '0');
            sync_counter <= (others => '0');
            
        elsif rising_edge(clk_divider_output) then
            -- Only run when the system is enabled
            if enable = '1' and global_config.master_enable = '1' then
                -- Increment the main pattern counter
                -- This controls the overall timing of all patterns
                pattern_counter <= pattern_counter + 1;
                
                -- Handle synchronization mode
                if global_config.sync_mode = '1' then
                    -- In sync mode, all outputs change patterns at the same time
                    -- We use a separate counter for synchronization
                    sync_counter <= sync_counter + 1;
                    
                    -- Generate sync trigger every 256 cycles
                    -- This ensures all outputs stay synchronized
                    if sync_counter(7 downto 0) = x"FF" then
                        sync_trigger <= '1';
                    else
                        sync_trigger <= '0';
                    end if;
                else
                    -- In independent mode, each output has its own timing
                    sync_trigger <= '0';
                end if;
                
                -- Handle pattern reset
                if global_config.reset_pattern = '1' then
                    -- Reset all counters when reset pattern is requested
                    pattern_counter <= (others => '0');
                    sync_counter <= (others => '0');
                end if;
            end if;
        end if;
    end process;
    
    -- =============================================================================
    -- INDIVIDUAL OUTPUT TIMING LOGIC
    -- =============================================================================
    -- This section controls the timing for each individual output
    
    -- Output A timing counter
    -- Each output can have its own speed setting
    output_a_timing: process(clk_divider_output, reset)
    begin
        if reset = '1' then
            output_counters_0 <= (others => '0');
        elsif rising_edge(clk_divider_output) then
            if enable = '1' and global_config.master_enable = '1' then
                -- Check if this output should update its pattern
                if (pattern_counter mod to_integer(output_a_config.pattern_speed)) = 0 then
                    -- Update the output counter for this output
                    output_counters_0 <= output_counters_0 + 1;
                end if;
                
                -- Handle synchronization
                if global_config.sync_mode = '1' and sync_trigger = '1' then
                    -- Force update in sync mode
                    output_counters_0 <= output_counters_0 + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Output B timing counter
    output_b_timing: process(clk_divider_output, reset)
    begin
        if reset = '1' then
            output_counters_1 <= (others => '0');
        elsif rising_edge(clk_divider_output) then
            if enable = '1' and global_config.master_enable = '1' then
                if (pattern_counter mod to_integer(output_b_config.pattern_speed)) = 0 then
                    output_counters_1 <= output_counters_1 + 1;
                end if;
                
                if global_config.sync_mode = '1' and sync_trigger = '1' then
                    output_counters_1 <= output_counters_1 + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Output C timing counter
    output_c_timing: process(clk_divider_output, reset)
    begin
        if reset = '1' then
            output_counters_2 <= (others => '0');
        elsif rising_edge(clk_divider_output) then
            if enable = '1' and global_config.master_enable = '1' then
                if (pattern_counter mod to_integer(output_c_config.pattern_speed)) = 0 then
                    output_counters_2 <= output_counters_2 + 1;
                end if;
                
                if global_config.sync_mode = '1' and sync_trigger = '1' then
                    output_counters_2 <= output_counters_2 + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Output D timing counter
    output_d_timing: process(clk_divider_output, reset)
    begin
        if reset = '1' then
            output_counters_3 <= (others => '0');
        elsif rising_edge(clk_divider_output) then
            if enable = '1' and global_config.master_enable = '1' then
                if (pattern_counter mod to_integer(output_d_config.pattern_speed)) = 0 then
                    output_counters_3 <= output_counters_3 + 1;
                end if;
                
                if global_config.sync_mode = '1' and sync_trigger = '1' then
                    output_counters_3 <= output_counters_3 + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- =============================================================================
    -- PATTERN GENERATION LOGIC
    -- =============================================================================
    -- This section generates the actual LED patterns using our pattern functions
    
    -- Generate raw patterns for each output
    -- These are the basic patterns before brightness scaling
    raw_pattern_a <= generate_led_pattern(
        output_a_config.pattern_type,
        output_counters_0,
        "00"  -- Output A identifier
    );
    
    raw_pattern_b <= generate_led_pattern(
        output_b_config.pattern_type,
        output_counters_1,
        "01"  -- Output B identifier
    );
    
    raw_pattern_c <= generate_led_pattern(
        output_c_config.pattern_type,
        output_counters_2,
        "10"  -- Output C identifier
    );
    
    raw_pattern_d <= generate_led_pattern(
        output_d_config.pattern_type,
        output_counters_3,
        "11"  -- Output D identifier
    );
    
    -- =============================================================================
    -- BRIGHTNESS SCALING LOGIC
    -- =============================================================================
    -- This section applies brightness scaling to the raw patterns
    
    -- Apply brightness scaling to each output
    -- This allows users to dim or brighten patterns without changing the pattern itself
    scaled_pattern_a <= apply_brightness_scaling(raw_pattern_a, output_a_config.brightness);
    scaled_pattern_b <= apply_brightness_scaling(raw_pattern_b, output_b_config.brightness);
    scaled_pattern_c <= apply_brightness_scaling(raw_pattern_c, output_c_config.brightness);
    scaled_pattern_d <= apply_brightness_scaling(raw_pattern_d, output_d_config.brightness);
    
    -- =============================================================================
    -- OUTPUT ENABLE LOGIC
    -- =============================================================================
    -- This section controls whether each output is active or disabled
    
    -- Set output enable status based on configuration
    -- This allows users to turn individual outputs on or off
    output_a_enabled <= output_a_config.enable;
    output_b_enabled <= output_b_config.enable;
    output_c_enabled <= output_c_config.enable;
    output_d_enabled <= output_d_config.enable;
    
    -- =============================================================================
    -- FINAL OUTPUT ASSIGNMENT
    -- =============================================================================
    -- This section assigns the final pattern values to the output ports
    
    -- Assign final outputs with enable control
    -- Only active outputs will show patterns; disabled outputs will be off
    output_a <= signed(scaled_pattern_a) when output_a_enabled = '1' else (others => '0');
    output_b <= signed(scaled_pattern_b) when output_b_enabled = '1' else (others => '0');
    output_c <= signed(scaled_pattern_c) when output_c_enabled = '1' else (others => '0');
    output_d <= signed(scaled_pattern_d) when output_d_enabled = '1' else (others => '0');
    
end architecture rtl;
