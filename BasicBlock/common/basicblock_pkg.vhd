-- =============================================================================
-- basicblock_pkg.vhd
-- =============================================================================
-- 
-- Main Package for the BasicBlock Module
-- 
-- PURPOSE: This package contains shared types, constants, and utility functions
--          that are used throughout the BasicBlock module. It acts as a "central
--          library" that other parts of the module can reference.
-- 
-- TARGET PLATFORM: Moku-Go (Liquid Instruments)
--                  - FPGA-based signal generation and analysis platform
--                  - 4 analog outputs (OutputA, OutputB, OutputC, OutputD)
--                  - 16-bit signed resolution (-32768 to +32767)
--                  - Configurable via control registers
-- 
-- LEARNING OBJECTIVES:
--   1. Understanding VHDL packages and type systems
--   2. Learning about control register parsing and validation
--   3. Understanding how to create reusable utility functions
--   4. Learning about safe programming practices in VHDL
-- 
-- =============================================================================

library IEEE;
use IEEE.Std_Logic_1164.all;  -- Standard logic types (std_logic, std_logic_vector)
use IEEE.Numeric_Std.all;      -- Numeric types (unsigned, signed, integer)
use work.led_pattern_pkg.all;  -- Our LED pattern generation package

package basicblock_pkg is
    -- =============================================================================
    -- CONSTANTS - These define the limits and defaults for our system
    -- =============================================================================
    
    -- Clock divider constants - these control how fast our patterns run
    -- In Moku-Go, the main clock is typically 125 MHz, so we need to divide it
    -- down to create visible LED patterns (humans can see changes up to about 60 Hz)
    constant CLOCK_DIVIDER_MIN : integer := 1;      -- Fastest possible (125 MHz)
    constant CLOCK_DIVIDER_MAX : integer := 65535;  -- Slowest possible (~1.9 kHz)
    constant CLOCK_DIVIDER_DEFAULT : integer := 1000; -- Default speed (~125 kHz)
    
    -- Pattern speed constants - these control how fast individual patterns change
    -- Higher values = slower patterns (more time between changes)
    constant PATTERN_SPEED_MIN : integer := 1;      -- Fastest pattern changes
    constant PATTERN_SPEED_MAX : integer := 255;    -- Slowest pattern changes
    constant PATTERN_SPEED_DEFAULT : integer := 64; -- Default pattern speed
    
    -- Brightness constants - these control LED intensity levels
    -- In Moku-Go, outputs are 16-bit signed, so we use positive values for brightness
    constant BRIGHTNESS_MIN : integer := 0;         -- Completely off
    constant BRIGHTNESS_MAX : integer := 255;       -- Maximum brightness
    constant BRIGHTNESS_DEFAULT : integer := 255;   -- Default to full brightness
    
    -- =============================================================================
    -- TYPES - These define the structure of our configuration data
    -- =============================================================================
    
    -- Output configuration record type
    -- This is like a "settings card" for each output (A, B, C, or D)
    -- Each output can have its own pattern, speed, and brightness
    type output_config_type is record
        pattern_type  : std_logic_vector(3 downto 0); -- Which pattern to show (0000-0111)
        pattern_speed : unsigned(7 downto 0);         -- How fast the pattern changes (1-255)
        brightness    : unsigned(7 downto 0);         -- How bright the LED appears (0-255)
        enable        : std_logic;                    -- Whether this output is active (1=on, 0=off)
    end record;
    
    -- Global configuration record type
    -- This contains settings that affect all outputs at once
    -- Like a "master control panel" for the entire system
    type global_config_type is record
        master_enable : std_logic;                    -- Master on/off switch (1=on, 0=off)
        clock_divider : unsigned(15 downto 0);       -- Main clock divider (1-65535)
        sync_mode     : std_logic;                    -- Synchronize all outputs (1=sync, 0=independent)
        reset_pattern : std_logic;                    -- Reset all patterns to start (1=reset, 0=normal)
    end record;
    
    -- LED state record type
    -- This tracks the current state of each LED output
    -- Useful for debugging and monitoring
    type led_state_type is record
        current_pattern : std_logic_vector(3 downto 0); -- Current pattern being displayed
        current_brightness : unsigned(15 downto 0);     -- Current brightness level
        pattern_counter   : unsigned(15 downto 0);      -- Internal counter for pattern timing
        is_active         : std_logic;                  -- Whether this LED is currently lit
    end record;
    
    -- =============================================================================
    -- FUNCTIONS - These are the "tools" that other parts of the module can use
    -- =============================================================================
    
    -- Configuration validation functions
    -- These functions check if configuration values are within safe limits
    -- They help prevent errors and ensure the system works correctly
    
    -- Check if a clock divider value is valid
    function is_valid_clock_divider(divider : unsigned(15 downto 0)) return boolean;
    
    -- Check if a pattern speed value is valid
    function is_valid_pattern_speed(speed : unsigned(7 downto 0)) return boolean;
    
    -- Check if a brightness value is valid
    function is_valid_brightness(brightness : unsigned(7 downto 0)) return boolean;
    
    -- Safe default functions
    -- These functions return safe values even if invalid inputs are provided
    -- They help make the system robust and prevent crashes
    
    -- Get a safe clock divider value
    function get_safe_clock_divider(divider : unsigned(15 downto 0)) return unsigned;
    
    -- Get a safe pattern speed value
    function get_safe_pattern_speed(speed : unsigned(7 downto 0)) return unsigned;
    
    -- Get a safe brightness value
    function get_safe_brightness(brightness : unsigned(7 downto 0)) return unsigned;
    
    -- Configuration parsing functions
    -- These functions take raw control register data and convert it into
    -- structured configuration records that are easy to use
    
    -- Parse output configuration from a control register
    function parse_output_config(control_reg : std_logic_vector(31 downto 0)) return output_config_type;
    
    -- Parse global configuration from a control register
    function parse_global_config(control_reg : std_logic_vector(31 downto 0)) return global_config_type;
    
    -- Utility functions
    -- These are helper functions that perform common tasks
    
    -- Apply brightness scaling to a pattern value
    function apply_brightness_scaling(pattern : unsigned(15 downto 0); brightness : unsigned(7 downto 0)) return unsigned;
    
    -- Check if a pattern type is valid
    function is_valid_pattern_type(pattern_type : std_logic_vector(3 downto 0)) return boolean;
    
    -- Convert configuration to human-readable string (for debugging)
    function config_to_string(config : output_config_type) return string;
    
end package basicblock_pkg;

-- =============================================================================
-- PACKAGE BODY - This is where we implement all the functions we declared above
-- =============================================================================
package body basicblock_pkg is
    
    -- =============================================================================
    -- CONFIGURATION VALIDATION FUNCTIONS
    -- =============================================================================
    
    -- Clock divider validation
    -- Ensures the clock divider is within safe limits
    function is_valid_clock_divider(divider : unsigned(15 downto 0)) return boolean is
    begin
        -- Check if divider is within our defined range
        -- This prevents the system from running too fast or too slow
        return divider >= CLOCK_DIVIDER_MIN and divider <= CLOCK_DIVIDER_MAX;
    end function;
    
    -- Pattern speed validation
    -- Ensures the pattern speed is within safe limits
    function is_valid_pattern_speed(speed : unsigned(7 downto 0)) return boolean is
    begin
        -- Check if speed is within our defined range
        -- This prevents patterns from being invisible or painfully slow
        return speed >= PATTERN_SPEED_MIN and speed <= PATTERN_SPEED_MAX;
    end function;
    
    -- Brightness validation
    -- Ensures the brightness value is within safe limits
    function is_valid_brightness(brightness : unsigned(7 downto 0)) return boolean is
    begin
        -- Check if brightness is within our defined range
        -- This prevents outputs from being too dim or too bright
        return brightness >= BRIGHTNESS_MIN and brightness <= BRIGHTNESS_MAX;
    end function;
    
    -- =============================================================================
    -- SAFE DEFAULT FUNCTIONS
    -- =============================================================================
    
    -- Safe clock divider
    -- Returns a safe value even if the input is invalid
    function get_safe_clock_divider(divider : unsigned(15 downto 0)) return unsigned is
    begin
        -- If the input is valid, use it; otherwise, use the default
        -- This prevents the system from crashing due to invalid inputs
        if is_valid_clock_divider(divider) then
            return divider;
        else
            return to_unsigned(CLOCK_DIVIDER_DEFAULT, 16);
        end if;
    end function;
    
    -- Safe pattern speed
    -- Returns a safe value even if the input is invalid
    function get_safe_pattern_speed(speed : unsigned(7 downto 0)) return unsigned is
    begin
        -- If the input is valid, use it; otherwise, use the default
        if is_valid_pattern_speed(speed) then
            return speed;
        else
            return to_unsigned(PATTERN_SPEED_DEFAULT, 8);
        end if;
    end function;
    
    -- Safe brightness
    -- Returns a safe value even if the input is invalid
    function get_safe_brightness(brightness : unsigned(7 downto 0)) return unsigned is
    begin
        -- If the input is valid, use it; otherwise, use the default
        if is_valid_brightness(brightness) then
            return brightness;
        else
            return to_unsigned(BRIGHTNESS_DEFAULT, 8);
        end if;
    end function;
    
    -- =============================================================================
    -- CONFIGURATION PARSING FUNCTIONS
    -- =============================================================================
    
    -- Parse output configuration
    -- Takes a 32-bit control register and extracts the configuration for one output
    -- This is how we convert raw register data into usable configuration
    function parse_output_config(control_reg : std_logic_vector(31 downto 0)) return output_config_type is
        variable config : output_config_type;
    begin
        -- Extract pattern type from bits 31-28
        -- This tells us which LED pattern to display
        config.pattern_type := control_reg(31 downto 28);
        
        -- Extract pattern speed from bits 27-20
        -- This controls how fast the pattern changes
        config.pattern_speed := get_safe_pattern_speed(unsigned(control_reg(27 downto 20)));
        
        -- Extract brightness from bits 19-12
        -- This controls how bright the LED appears
        config.brightness := get_safe_brightness(unsigned(control_reg(19 downto 12)));
        
        -- Extract enable bit from bit 11
        -- This turns the output on or off
        config.enable := control_reg(11);
        
        -- Bits 10-0 are reserved for future use
        -- This shows how we can extend the system later
        
        return config;
    end function;
    
    -- Parse global configuration
    -- Takes a 32-bit control register and extracts global system settings
    function parse_global_config(control_reg : std_logic_vector(31 downto 0)) return global_config_type is
        variable config : global_config_type;
    begin
        -- Extract master enable from bit 31
        -- This is the main on/off switch for the entire system
        config.master_enable := control_reg(31);
        
        -- Extract clock divider from bits 30-15
        -- This controls the overall speed of all patterns
        config.clock_divider := get_safe_clock_divider(unsigned(control_reg(30 downto 15)));
        
        -- Extract sync mode from bit 14
        -- When enabled, all outputs change patterns at the same time
        config.sync_mode := control_reg(14);
        
        -- Extract reset pattern from bit 13
        -- When enabled, all patterns restart from the beginning
        config.reset_pattern := control_reg(13);
        
        -- Bits 12-0 are reserved for future use
        
        return config;
    end function;
    
    -- =============================================================================
    -- UTILITY FUNCTIONS
    -- =============================================================================
    
    -- Apply brightness scaling
    -- Takes a pattern value and scales it by the brightness setting
    -- This allows us to dim or brighten patterns without changing the pattern itself
    function apply_brightness_scaling(pattern : unsigned(15 downto 0); brightness : unsigned(7 downto 0)) return unsigned is
        variable scaled_pattern : unsigned(23 downto 0);
    begin
        -- Multiply the pattern by the brightness value
        -- This creates a scaled version of the pattern
        scaled_pattern := pattern * brightness;
        
        -- Return the upper 16 bits of the result
        -- This gives us the properly scaled pattern
        return scaled_pattern(23 downto 8);
    end function;
    
    -- Pattern type validation
    -- Checks if a pattern type is valid using our LED pattern package
    function is_valid_pattern_type(pattern_type : std_logic_vector(3 downto 0)) return boolean is
    begin
        -- Use the validation function from our LED pattern package
        -- This ensures consistency across the entire module
        return work.led_pattern_pkg.is_valid_pattern_type(pattern_type);
    end function;
    
    -- Configuration to string conversion
    -- Converts configuration to human-readable text for debugging
    -- This is very useful when testing and troubleshooting
    function config_to_string(config : output_config_type) return string is
        variable pattern_name : string(1 to 20);
    begin
        -- Get the human-readable name for the pattern type
        pattern_name := work.led_pattern_pkg.get_pattern_name(config.pattern_type);
        
        -- Return a formatted string with all the configuration details
        return "Pattern: " & pattern_name & 
               ", Speed: " & integer'image(to_integer(config.pattern_speed)) &
               ", Brightness: " & integer'image(to_integer(config.brightness)) &
               ", Enable: " & std_logic'image(config.enable);
    end function;
    
end package body basicblock_pkg;
