-- =============================================================================
-- led_pattern_pkg.vhd
-- =============================================================================
-- 
-- LED Pattern Generation Package for BasicBlock Module
-- 
-- PURPOSE: This package contains all the functions needed to generate different
--          LED lighting patterns, similar to traditional Christmas lights.
-- 
-- TARGET PLATFORM: Moku-Go (Liquid Instruments)
--                  - 4 digital outputs (OutputA, OutputB, OutputC, OutputD)
--                  - 16-bit signed output resolution (-32768 to +32767)
--                  - Configurable via 5 control registers (Control0-4)
-- 
-- LEARNING OBJECTIVES:
--   1. Understanding VHDL packages and functions
--   2. Learning about LED pattern generation algorithms
--   3. Understanding how digital patterns map to analog outputs
--   4. Learning about timing and synchronization in embedded systems
-- 
-- =============================================================================

library IEEE;
use IEEE.Std_Logic_1164.all;  -- Standard logic types (std_logic, std_logic_vector)
use IEEE.Numeric_Std.all;      -- Numeric types (unsigned, signed, integer)

package led_pattern_pkg is
    -- =============================================================================
    -- CONSTANTS - These define our pattern types and amplitude levels
    -- =============================================================================
    -- Pattern type constants - these are like "preset buttons" on a remote control
    -- Each constant represents a different lighting pattern you can select
    constant PATTERN_OFF           : std_logic_vector(3 downto 0) := "0000";  -- All LEDs off
    constant PATTERN_ALL_ON        : std_logic_vector(3 downto 0) := "0001";  -- All LEDs on
    constant PATTERN_ALTERNATE     : std_logic_vector(3 downto 0) := "0010";  -- Alternating on/off
    constant PATTERN_CHASE         : std_logic_vector(3 downto 0) := "0011";  -- Moving light effect
    constant PATTERN_TWINKLE       : std_logic_vector(3 downto 0) := "0100";  -- Random twinkling
    constant PATTERN_WAVE          : std_logic_vector(3 downto 0) := "0101";  -- Wave-like pattern
    constant PATTERN_BREATH        : std_logic_vector(3 downto 0) := "0110";  -- Breathing effect
    constant PATTERN_CUSTOM        : std_logic_vector(3 downto 0) := "0111";  -- User-defined pattern
    
    -- Amplitude constants - these control how bright the LEDs appear
    -- In Moku-Go, outputs are 16-bit signed (-32768 to +32767)
    -- For LED patterns, we typically use positive values only
    constant LED_OFF              : unsigned(15 downto 0) := x"0000";  -- LED off (0V)
    constant LED_ON               : unsigned(15 downto 0) := x"7FFF";  -- LED on (max brightness)
    constant LED_HALF             : unsigned(15 downto 0) := x"4000";  -- Half brightness
    constant LED_QUARTER          : unsigned(15 downto 0) := x"2000";  -- Quarter brightness
    
    -- =============================================================================
    -- FUNCTIONS - These are the "recipes" for creating different LED patterns
    -- =============================================================================
    
    -- Main pattern generation function - this is like a "pattern selector"
    -- Inputs:
    --   pattern_type: Which pattern to generate (0000 to 0111)
    --   counter_val: Current time counter value (used for animation)
    --   output_select: Which output we're generating (0-3 for A,B,C,D)
    -- Returns: 16-bit unsigned value representing LED brightness
    function generate_led_pattern(
        pattern_type  : std_logic_vector(3 downto 0);
        counter_val   : unsigned(15 downto 0);
        output_select : unsigned(1 downto 0)
    ) return unsigned;
    
    -- Individual pattern functions - each creates a specific lighting effect
    -- These are like the individual "ingredients" for each pattern
    
    -- Creates a pattern where all LEDs are off
    function generate_all_off(counter_val : unsigned(15 downto 0)) return unsigned;
    
    -- Creates a pattern where all LEDs are on
    function generate_all_on(counter_val : unsigned(15 downto 0)) return unsigned;
    
    -- Creates an alternating pattern (like traditional Christmas lights)
    function generate_alternating(counter_val : unsigned(15 downto 0); output_select : unsigned(1 downto 0)) return unsigned;
    
    -- Creates a "chasing" effect where light appears to move between outputs
    function generate_chase(counter_val : unsigned(15 downto 0); output_select : unsigned(1 downto 0)) return unsigned;
    
    -- Creates a twinkling effect using pseudo-random numbers
    function generate_twinkle(counter_val : unsigned(15 downto 0); output_select : unsigned(1 downto 0)) return unsigned;
    
    -- Creates a wave-like pattern that flows across outputs
    function generate_wave(counter_val : unsigned(15 downto 0); output_select : unsigned(1 downto 0)) return unsigned;
    
    -- Creates a "breathing" effect that fades in and out
    function generate_breath(counter_val : unsigned(15 downto 0)) return unsigned;
    
    -- Creates a custom pattern (placeholder for future expansion)
    function generate_custom(counter_val : unsigned(15 downto 0); output_select : unsigned(1 downto 0)) return unsigned;
    
    -- =============================================================================
    -- UTILITY FUNCTIONS - Helper functions for pattern generation
    -- =============================================================================
    
    -- Checks if a pattern type is valid (0000 to 0111)
    function is_valid_pattern_type(pattern_type : std_logic_vector(3 downto 0)) return boolean;
    
    -- Converts pattern type to human-readable string (useful for debugging)
    function get_pattern_name(pattern_type : std_logic_vector(3 downto 0)) return string;
    
    -- Simple pseudo-random number generator for twinkling effects
    function simple_random(seed : unsigned(15 downto 0)) return unsigned;
    
end package led_pattern_pkg;

-- =============================================================================
-- PACKAGE BODY - This is where we implement all the functions we declared above
-- =============================================================================
package body led_pattern_pkg is
    
    -- =============================================================================
    -- MAIN PATTERN GENERATION FUNCTION
    -- =============================================================================
    -- This function acts like a "pattern router" - it takes the pattern type
    -- and calls the appropriate function to generate that specific pattern
    function generate_led_pattern(
        pattern_type  : std_logic_vector(3 downto 0);
        counter_val   : unsigned(15 downto 0);
        output_select : unsigned(1 downto 0)
    ) return unsigned is
    begin
        -- Case statement acts like a "switch" in other programming languages
        -- It routes the pattern_type to the correct pattern generation function
        case pattern_type is
            when PATTERN_OFF       => return generate_all_off(counter_val);
            when PATTERN_ALL_ON    => return generate_all_on(counter_val);
            when PATTERN_ALTERNATE => return generate_alternating(counter_val, output_select);
            when PATTERN_CHASE     => return generate_chase(counter_val, output_select);
            when PATTERN_TWINKLE   => return generate_twinkle(counter_val, output_select);
            when PATTERN_WAVE      => return generate_wave(counter_val, output_select);
            when PATTERN_BREATH    => return generate_breath(counter_val);
            when PATTERN_CUSTOM    => return generate_custom(counter_val, output_select);
            when others            => return generate_all_off(counter_val);  -- Default to off
        end case;
    end function;
    
    -- =============================================================================
    -- INDIVIDUAL PATTERN FUNCTIONS
    -- =============================================================================
    
    -- ALL OFF PATTERN
    -- This is the simplest pattern - all outputs are always off
    -- Useful for testing or when you want to disable all LEDs
    function generate_all_off(counter_val : unsigned(15 downto 0)) return unsigned is
    begin
        -- Ignore counter_val and output_select - always return OFF
        -- This demonstrates how some patterns don't need all inputs
        return LED_OFF;
    end function;
    
    -- ALL ON PATTERN
    -- All outputs are always on at full brightness
    -- Good for testing if all outputs are working
    function generate_all_on(counter_val : unsigned(15 downto 0)) return unsigned is
    begin
        -- Always return full brightness, regardless of counter or output
        return LED_ON;
    end function;
    
    -- ALTERNATING PATTERN
    -- Creates a classic Christmas light effect where adjacent LEDs alternate
    -- Output A and C will be on while B and D are off, then they switch
    function generate_alternating(counter_val : unsigned(15 downto 0); output_select : unsigned(1 downto 0)) return unsigned is
    begin
        -- Use the counter to create a blinking effect
        -- counter_val(15) gives us a slow clock (every 32768 cycles)
        -- output_select determines which group this output belongs to
        if (counter_val(15) = '1') xor (output_select(0) = '1') then
            return LED_ON;   -- This output should be ON
        else
            return LED_OFF;  -- This output should be OFF
        end if;
    end function;
    
    -- CHASE PATTERN
    -- Creates a moving light effect that appears to travel between outputs
    -- Like a "knight rider" or "Cylon eye" effect
    function generate_chase(counter_val : unsigned(15 downto 0); output_select : unsigned(1 downto 0)) return unsigned is
        variable position : unsigned(1 downto 0);
    begin
        -- Use counter to determine which output should be lit
        -- This creates a moving light that cycles through all outputs
        position := counter_val(15 downto 14);  -- Use upper 2 bits for position
        
        -- Check if this output should be lit based on current position
        if position = output_select then
            return LED_ON;   -- Light this output
        else
            return LED_OFF;  -- Keep other outputs off
        end if;
    end function;
    
    -- TWINKLE PATTERN
    -- Creates a random twinkling effect using pseudo-random numbers
    -- Each output twinkles independently for a natural look
    function generate_twinkle(counter_val : unsigned(15 downto 0); output_select : unsigned(1 downto 0)) return unsigned is
        variable random_val : unsigned(15 downto 0);
        variable twinkle_threshold : unsigned(15 downto 0);
    begin
        -- Generate a pseudo-random number based on counter and output selection
        -- This ensures each output has different twinkling behavior
        random_val := simple_random(counter_val + (output_select & "0000000000000000"));
        
        -- Set a threshold for twinkling (higher threshold = less twinkling)
        twinkle_threshold := x"6000";  -- About 75% threshold
        
        -- If random value is above threshold, turn on the LED
        if random_val > twinkle_threshold then
            return LED_ON;
        else
            return LED_OFF;
        end if;
    end function;
    
    -- WAVE PATTERN
    -- Creates a wave-like effect that flows across the outputs
    -- Like a ripple or wave moving through the LED array
    function generate_wave(counter_val : unsigned(15 downto 0); output_select : unsigned(1 downto 0)) return unsigned is
        variable wave_position : unsigned(15 downto 0);
        variable wave_amplitude : unsigned(15 downto 0);
    begin
        -- Calculate wave position based on counter and output
        -- This creates a sine-wave-like effect across outputs
        wave_position := counter_val + (output_select & "0000000000000000");
        
        -- Use the lower bits of wave_position to create a smooth wave
        -- This creates a repeating pattern that moves across outputs
        case wave_position(15 downto 13) is
            when "000" => wave_amplitude := LED_OFF;      -- Wave trough
            when "001" => wave_amplitude := LED_QUARTER;   -- Rising
            when "010" => wave_amplitude := LED_HALF;      -- Peak
            when "011" => wave_amplitude := LED_HALF;      -- Peak
            when "100" => wave_amplitude := LED_HALF;      -- Peak
            when "101" => wave_amplitude := LED_QUARTER;   -- Falling
            when "110" => wave_amplitude := LED_OFF;       -- Wave trough
            when "111" => wave_amplitude := LED_OFF;       -- Wave trough
            when others => wave_amplitude := LED_OFF;
        end case;
        
        return wave_amplitude;
    end function;
    
    -- BREATH PATTERN
    -- Creates a breathing effect that fades in and out
    -- All outputs breathe together for a synchronized effect
    function generate_breath(counter_val : unsigned(15 downto 0)) return unsigned is
        variable breath_cycle : unsigned(15 downto 0);
    begin
        -- Use counter to create a slow breathing cycle
        -- counter_val(15 downto 8) gives us a medium-speed cycle
        breath_cycle := counter_val(15 downto 8);
        
        -- Create a triangle wave for smooth breathing
        if breath_cycle(7) = '0' then
            -- First half of cycle: fade in
            return breath_cycle(6 downto 0) & "0000000";  -- Scale up
        else
            -- Second half of cycle: fade out
            return (not breath_cycle(6 downto 0)) & "0000000";  -- Scale down
        end if;
    end function;
    
    -- CUSTOM PATTERN
    -- Placeholder for future custom patterns
    -- Students can modify this function to create their own patterns
    function generate_custom(counter_val : unsigned(15 downto 0); output_select : unsigned(1 downto 0)) return unsigned is
    begin
        -- TODO: Students can implement their own custom patterns here
        -- Examples:
        -- - Morse code patterns
        -- - Binary counting patterns
        -- - Music visualization patterns
        -- - Custom animations
        
        -- For now, return a simple pattern based on output selection
        case output_select is
            when "00" => return LED_ON;      -- Output A always on
            when "01" => return LED_OFF;     -- Output B always off
            when "10" => return LED_HALF;    -- Output C half brightness
            when "11" => return LED_QUARTER; -- Output D quarter brightness
            when others => return LED_OFF;
        end case;
    end function;
    
    -- =============================================================================
    -- UTILITY FUNCTIONS
    -- =============================================================================
    
    -- Pattern validation function
    -- Ensures only valid pattern types (0000 to 0111) are used
    function is_valid_pattern_type(pattern_type : std_logic_vector(3 downto 0)) return boolean is
    begin
        -- Check if pattern_type is within our valid range
        -- This prevents errors from invalid pattern selections
        return pattern_type <= "0111";
    end function;
    
    -- Pattern name function for debugging
    -- Converts pattern type codes to human-readable names
    function get_pattern_name(pattern_type : std_logic_vector(3 downto 0)) return string is
    begin
        case pattern_type is
            when PATTERN_OFF       => return "ALL_OFF";
            when PATTERN_ALL_ON    => return "ALL_ON";
            when PATTERN_ALTERNATE => return "ALTERNATING";
            when PATTERN_CHASE     => return "CHASE";
            when PATTERN_TWINKLE   => return "TWINKLE";
            when PATTERN_WAVE      => return "WAVE";
            when PATTERN_BREATH    => return "BREATH";
            when PATTERN_CUSTOM    => return "CUSTOM";
            when others            => return "UNKNOWN";
        end case;
    end function;
    
    -- Simple pseudo-random number generator
    -- Uses Linear Feedback Shift Register (LFSR) technique
    -- This creates seemingly random numbers for twinkling effects
    function simple_random(seed : unsigned(15 downto 0)) return unsigned is
        variable lfsr : unsigned(15 downto 0);
    begin
        -- Initialize LFSR with seed value
        lfsr := seed;
        
        -- Apply LFSR taps for maximum length sequence
        -- This creates a pseudo-random pattern that repeats every 65535 cycles
        lfsr := (lfsr sll 1) xor 
                (lfsr(15) & lfsr(14) & lfsr(13) & 
                 lfsr(12) & lfsr(11) & lfsr(10) & 
                 lfsr(9) & lfsr(8) & lfsr(7) & 
                 lfsr(6) & lfsr(5) & (lfsr(4) xor lfsr(15)) & 
                 (lfsr(3) xor lfsr(14)) & (lfsr(2) xor lfsr(13)) & 
                 lfsr(1) & lfsr(0));
        
        return lfsr;
    end function;
    
end package body led_pattern_pkg;
