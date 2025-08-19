-- pattern_generator_pkg.vhd
-- Package containing pattern generation functions for the SigGen module
-- Extracted from BestSlotBlinker for modular design
-- Follows VHDL-2008 standards and industry best practices

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

package pattern_generator_pkg is
    -- =============================================================================
    -- CONSTANTS
    -- =============================================================================
    -- Pattern type constants for easy identification
    constant PATTERN_SQUARE_WAVE    : std_logic_vector(3 downto 0) := "0000";
    constant PATTERN_SAWTOOTH      : std_logic_vector(3 downto 0) := "0001";
    constant PATTERN_TRIANGLE      : std_logic_vector(3 downto 0) := "0010";
    constant PATTERN_SINE_APPROX   : std_logic_vector(3 downto 0) := "0011";
    constant PATTERN_LFSR_RANDOM   : std_logic_vector(3 downto 0) := "0100";
    constant PATTERN_STAIRCASE     : std_logic_vector(3 downto 0) := "0101";
    constant PATTERN_PULSE_TRAIN   : std_logic_vector(3 downto 0) := "0110";
    constant PATTERN_ALTERNATING   : std_logic_vector(3 downto 0) := "0111";
    
    -- Amplitude constants
    constant AMPLITUDE_MAX         : unsigned(15 downto 0) := x"7FFF";
    constant AMPLITUDE_MIN         : unsigned(15 downto 0) := x"0000";
    constant AMPLITUDE_MID         : unsigned(15 downto 0) := x"4000";
    constant AMPLITUDE_QUARTER     : unsigned(15 downto 0) := x"2000";
    constant AMPLITUDE_THREE_QUARTER : unsigned(15 downto 0) := x"6000";
    
    -- =============================================================================
    -- FUNCTIONS
    -- =============================================================================
    -- Main pattern generation function
    function generate_pattern(
        pattern_type : std_logic_vector(3 downto 0);
        counter_val  : unsigned(15 downto 0)
    ) return unsigned;
    
    -- Individual pattern functions for modularity
    function generate_square_wave(counter_val : unsigned(15 downto 0)) return unsigned;
    function generate_sawtooth(counter_val : unsigned(15 downto 0)) return unsigned;
    function generate_triangle_wave(counter_val : unsigned(15 downto 0)) return unsigned;
    function generate_sine_approximation(counter_val : unsigned(15 downto 0)) return unsigned;
    function generate_lfsr_random(counter_val : unsigned(15 downto 0)) return unsigned;
    function generate_staircase(counter_val : unsigned(15 downto 0)) return unsigned;
    function generate_pulse_train(counter_val : unsigned(15 downto 0)) return unsigned;
    function generate_alternating_levels(counter_val : unsigned(15 downto 0)) return unsigned;
    
    -- Utility functions
    function is_valid_pattern_type(pattern_type : std_logic_vector(3 downto 0)) return boolean;
    function get_pattern_name(pattern_type : std_logic_vector(3 downto 0)) return string;
    
end package pattern_generator_pkg;

package body pattern_generator_pkg is
    -- =============================================================================
    -- MAIN PATTERN GENERATION FUNCTION
    -- =============================================================================
    function generate_pattern(
        pattern_type : std_logic_vector(3 downto 0);
        counter_val  : unsigned(15 downto 0)
    ) return unsigned is
    begin
        case pattern_type is
            when PATTERN_SQUARE_WAVE    => return generate_square_wave(counter_val);
            when PATTERN_SAWTOOTH       => return generate_sawtooth(counter_val);
            when PATTERN_TRIANGLE       => return generate_triangle_wave(counter_val);
            when PATTERN_SINE_APPROX    => return generate_sine_approximation(counter_val);
            when PATTERN_LFSR_RANDOM    => return generate_lfsr_random(counter_val);
            when PATTERN_STAIRCASE      => return generate_staircase(counter_val);
            when PATTERN_PULSE_TRAIN    => return generate_pulse_train(counter_val);
            when PATTERN_ALTERNATING    => return generate_alternating_levels(counter_val);
            when others                 => return generate_sawtooth(counter_val); -- Default
        end case;
    end function;
    
    -- =============================================================================
    -- INDIVIDUAL PATTERN FUNCTIONS
    -- =============================================================================
    function generate_square_wave(counter_val : unsigned(15 downto 0)) return unsigned is
    begin
        -- Square wave with proper 50% duty cycle
        if counter_val(15) = '1' then
            return AMPLITUDE_MAX; -- High level
        else
            return AMPLITUDE_MIN; -- Low level
        end if;
    end function;
    
    function generate_sawtooth(counter_val : unsigned(15 downto 0)) return unsigned is
    begin
        -- Linear ramp from 0 to 32767
        return counter_val;
    end function;
    
    function generate_triangle_wave(counter_val : unsigned(15 downto 0)) return unsigned is
        variable temp_val : unsigned(15 downto 0);
    begin
        -- Triangle wave (sawtooth folded)
        temp_val := counter_val(14 downto 0) & '0'; -- Double frequency
        if counter_val(15) = '1' then
            return AMPLITUDE_MAX - temp_val; -- Folding down
        else
            return temp_val; -- Going up
        end if;
    end function;
    
    function generate_sine_approximation(counter_val : unsigned(15 downto 0)) return unsigned is
        variable sine_step : std_logic_vector(3 downto 0);
    begin
        -- 16-step sine approximation
        sine_step := std_logic_vector(counter_val(15 downto 12));
        case sine_step is
            when "0000" => return x"0000"; -- 0°
            when "0001" => return x"3249"; -- 22.5°
            when "0010" => return x"5A82"; -- 45°
            when "0011" => return x"7FFF"; -- 67.5°
            when "0100" => return x"7FFF"; -- 90°
            when "0101" => return x"5A82"; -- 112.5°
            when "0110" => return x"0000"; -- 135°
            when "0111" => return x"A57D"; -- 157.5°
            when "1000" => return x"8000"; -- 180°
            when "1001" => return x"CDB6"; -- 202.5°
            when "1010" => return x"A57D"; -- 225°
            when "1011" => return x"8000"; -- 247.5°
            when "1100" => return x"8000"; -- 270°
            when "1101" => return x"A57D"; -- 292.5°
            when "1110" => return x"0000"; -- 315°
            when "1111" => return x"5A82"; -- 337.5°
            when others => return x"0000";
        end case;
    end function;
    
    function generate_lfsr_random(counter_val : unsigned(15 downto 0)) return unsigned is
        variable lfsr_state : unsigned(15 downto 0);
    begin
        -- Improved LFSR-based random pattern
        -- Initialize LFSR with counter value to ensure different sequences
        lfsr_state := counter_val;
        -- Apply LFSR taps: bits 15, 14, 13, 4 (maximal length 16-bit LFSR)
        lfsr_state := (lfsr_state sll 1) xor 
                     (lfsr_state(15) & lfsr_state(14) & lfsr_state(13) & 
                      lfsr_state(12) & lfsr_state(11) & lfsr_state(10) & 
                      lfsr_state(9) & lfsr_state(8) & lfsr_state(7) & 
                      lfsr_state(6) & lfsr_state(5) & (lfsr_state(4) xor lfsr_state(15)) & 
                      (lfsr_state(3) xor lfsr_state(14)) & (lfsr_state(2) xor lfsr_state(13)) & 
                      lfsr_state(1) & lfsr_state(0));
        return lfsr_state;
    end function;
    
    function generate_staircase(counter_val : unsigned(15 downto 0)) return unsigned is
    begin
        -- Staircase with 4 steps
        case counter_val(15 downto 14) is
            when "00" => return AMPLITUDE_QUARTER;      -- 25%
            when "01" => return AMPLITUDE_MID;          -- 50%
            when "10" => return AMPLITUDE_THREE_QUARTER; -- 75%
            when "11" => return AMPLITUDE_MAX;          -- 100%
            when others => return AMPLITUDE_QUARTER;
        end case;
    end function;
    
    function generate_pulse_train(counter_val : unsigned(15 downto 0)) return unsigned is
    begin
        -- Pulse train with narrow pulses
        if counter_val(15 downto 12) = "0000" then
            return AMPLITUDE_MAX; -- Narrow pulse
        else
            return AMPLITUDE_MIN; -- Long low
        end if;
    end function;
    
    function generate_alternating_levels(counter_val : unsigned(15 downto 0)) return unsigned is
    begin
        -- Alternating levels (4 levels alternating)
        case counter_val(15 downto 14) is
            when "00" => return AMPLITUDE_QUARTER;      -- Level 1
            when "01" => return AMPLITUDE_THREE_QUARTER; -- Level 2
            when "10" => return AMPLITUDE_QUARTER;      -- Level 1
            when "11" => return AMPLITUDE_THREE_QUARTER; -- Level 2
            when others => return AMPLITUDE_QUARTER;
        end case;
    end function;
    
    -- =============================================================================
    -- UTILITY FUNCTIONS
    -- =============================================================================
    function is_valid_pattern_type(pattern_type : std_logic_vector(3 downto 0)) return boolean is
    begin
        return pattern_type <= "0111"; -- Valid patterns are 0000 to 0111
    end function;
    
    function get_pattern_name(pattern_type : std_logic_vector(3 downto 0)) return string is
    begin
        case pattern_type is
            when PATTERN_SQUARE_WAVE    => return "SQUARE_WAVE";
            when PATTERN_SAWTOOTH       => return "SAWTOOTH";
            when PATTERN_TRIANGLE       => return "TRIANGLE";
            when PATTERN_SINE_APPROX    => return "SINE_APPROX";
            when PATTERN_LFSR_RANDOM    => return "LFSR_RANDOM";
            when PATTERN_STAIRCASE      => return "STAIRCASE";
            when PATTERN_PULSE_TRAIN    => return "PULSE_TRAIN";
            when PATTERN_ALTERNATING    => return "ALTERNATING_LEVELS";
            when others                 => return "UNKNOWN";
        end case;
    end function;
    
end package body pattern_generator_pkg;
