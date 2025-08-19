-- probe_driver_pkg.vhd
-- Shared package for ProbeDriver components
-- Contains types, constants, and utility functions
-- Follows VHDL-2008 standards and industry best practices
-- REFACTORED: Aligned with new architecture requirements

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

package probe_driver_pkg is
    -- =============================================================================
    -- CONSTANTS
    -- =============================================================================
    -- Probe Configuration Constants
    constant PROBE_INTENSITY_MAX : integer := 100;
    constant PROBE_PULSE_MIN_DURATION : unsigned(15 downto 0) := to_unsigned(100, 16);  -- 100 clock cycles minimum
    constant PROBE_COOLDOWN_MIN : unsigned(15 downto 0) := to_unsigned(1000, 16);       -- 1000 clock cycles minimum
    
    -- Trigger Threshold
    constant PROBE_TRIGGER_THRESHOLD : signed(15 downto 0) := to_signed(16384, 16);  -- Mid-scale for 16-bit signed
    
    -- =============================================================================
    -- TYPES
    -- =============================================================================
    -- State machine states (REFACTORED: Removed FIRED state, matches current implementation)
    type probe_state_type is (IDLE, ARMED, FIRING, COOL_DOWN);
    
    -- Status register type (16 bits for future expansion)
    subtype probe_status_type is std_logic_vector(15 downto 0);
    
    -- Configuration types for consistent data widths
    subtype probe_intensity_index_type is std_logic_vector(6 downto 0);  -- 7 bits for 0-100 range
    subtype probe_duration_type is std_logic_vector(15 downto 0);       -- 16 bits for consistency
    subtype probe_cooldown_type is std_logic_vector(15 downto 0);       -- 16 bits for consistency
    
    -- =============================================================================
    -- FUNCTIONS
    -- =============================================================================
    -- Convert probe state to string for debugging
    function probe_state_to_string(state : probe_state_type) return string;
    
    -- Check if status register indicates specific state
    function is_probe_armed(status : probe_status_type) return boolean;
    function is_probe_firing(status : probe_status_type) return boolean;
    function is_probe_cooldown(status : probe_status_type) return boolean;
    function is_probe_error(status : probe_status_type) return boolean;
    
    -- Utility functions for status register manipulation
    function set_probe_status_bit(status : probe_status_type; bit_position : natural; value : std_logic) return probe_status_type;
    function get_probe_status_bit(status : probe_status_type; bit_position : natural) return std_logic;
    
    -- Safe default value functions
    function get_safe_intensity_index(intensity_in : probe_intensity_index_type) return probe_intensity_index_type;
    function get_safe_duration(duration_in : probe_duration_type) return probe_duration_type;
    function get_safe_cooldown(cooldown_in : probe_cooldown_type) return probe_cooldown_type;
    
end package probe_driver_pkg;

package body probe_driver_pkg is
    function probe_state_to_string(state : probe_state_type) return string is
    begin
        case state is
            when IDLE => return "IDLE";
            when ARMED => return "ARMED";
            when FIRING => return "FIRING";
            when COOL_DOWN => return "COOL_DOWN";
            when others => return "UNKNOWN";
        end case;
    end function;
    
    function is_probe_armed(status : probe_status_type) return boolean is
    begin
        return status(0) = '1';
    end function;
    
    function is_probe_firing(status : probe_status_type) return boolean is
    begin
        return status(1) = '1';
    end function;
    
    function is_probe_cooldown(status : probe_status_type) return boolean is
    begin
        return status(3) = '1';
    end function;
    
    function is_probe_error(status : probe_status_type) return boolean is
    begin
        return status(4) = '1';
    end function;
    
    function set_probe_status_bit(status : probe_status_type; bit_position : natural; value : std_logic) return probe_status_type is
        variable result : probe_status_type := status;
    begin
        if bit_position < 16 then
            result(bit_position) := value;
        end if;
        return result;
    end function;
    
    function get_probe_status_bit(status : probe_status_type; bit_position : natural) return std_logic is
    begin
        if bit_position < 16 then
            return status(bit_position);
        else
            return '0';
        end if;
    end function;
    
    -- Safe default value functions
    function get_safe_intensity_index(intensity_in : probe_intensity_index_type) return probe_intensity_index_type is
    begin
        if intensity_in = "0000000" then
            return "0000001";  -- Safe minimum intensity (IntensityLut[1] = smallest observable output)
        else
            return intensity_in;
        end if;
    end function;
    
    function get_safe_duration(duration_in : probe_duration_type) return probe_duration_type is
    begin
        if duration_in = x"0000" then
            return std_logic_vector(PROBE_PULSE_MIN_DURATION);  -- Safe minimum duration
        else
            return duration_in;
        end if;
    end function;
    
    function get_safe_cooldown(cooldown_in : probe_cooldown_type) return probe_cooldown_type is
    begin
        if cooldown_in = x"0000" then
            return std_logic_vector(PROBE_COOLDOWN_MIN);  -- Safe minimum cooldown
        else
            return cooldown_in;
        end if;
    end function;
    
end package body;
