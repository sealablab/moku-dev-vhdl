-- probe_driver_pkg.vhd
-- Shared package for ProbeDriver v2.5 components
-- 
-- REFACTORED: Now follows latest state machine requirements and uses shared types
-- - Uses shared percent_lut_pkg for consistent type definitions
-- - Implements record-based Status Register records
-- - Follows hybrid approach: VHDL enumerated types internally + Status Register records externally
-- 
-- Date: 2025-01-27
-- Tag: ProbeDriver-v2.5-Using-Latest-Requirements

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.percent_lut_pkg.all;

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
    -- State machine states (VHDL enumerated types for internal logic)
    type probe_state_type is (IDLE, ARMED, FIRING, COOL_DOWN);
    
    -- Status Register record following established architecture
    type status_register_t is record
        ready         : std_logic;     -- Module is ready (IDLE state)
        armed         : std_logic;     -- Module is armed
        firing        : std_logic;     -- Module is currently firing
        cooldown      : std_logic;     -- Module is in cooldown
        error         : std_logic;     -- Error condition active
        -- Reserved fields for future expansion
        reserved_5    : std_logic;     -- Reserved for future use
        reserved_6    : std_logic;     -- Reserved for future use
        reserved_7    : std_logic;     -- Reserved for future use
    end record;
    
    -- Configuration types for consistent data widths
    subtype probe_intensity_index_type is std_logic_vector(6 downto 0);  -- 7 bits for 0-100 range
    subtype probe_duration_type is std_logic_vector(15 downto 0);       -- 16 bits for consistency
    subtype probe_cooldown_type is std_logic_vector(15 downto 0);       -- 16 bits for consistency
    
    -- =============================================================================
    -- FUNCTIONS
    -- =============================================================================
    -- Convert probe state to string for debugging
    function probe_state_to_string(state : probe_state_type) return string;
    
    -- Default status register function (required by architecture)
    function get_default_status_register return status_register_t;
    
    -- Status checking functions using record fields
    function is_probe_ready(status : status_register_t) return boolean;
    function is_probe_armed(status : status_register_t) return boolean;
    function is_probe_firing(status : status_register_t) return boolean;
    function is_probe_cooldown(status : status_register_t) return boolean;
    function is_probe_error(status : status_register_t) return boolean;
    
    -- Safe default value functions
    function get_safe_intensity_index(intensity_in : probe_intensity_index_type) return probe_intensity_index_type;
    function get_safe_duration(duration_in : probe_duration_type) return probe_duration_type;
    function get_safe_cooldown(cooldown_in : probe_cooldown_type) return probe_cooldown_type;
    
    -- Intensity lookup functions (now using shared percent_lut_pkg)
    function get_intensity_output(index : probe_intensity_index_type) return signed;
    
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
    
    -- Default status register function (required by architecture)
    function get_default_status_register return status_register_t is
    begin
        return (ready => '1', armed => '0', firing => '0', cooldown => '0', error => '0', reserved_5 => '0', reserved_6 => '0', reserved_7 => '0');
    end function;
    
    -- Status checking functions using record fields
    function is_probe_ready(status : status_register_t) return boolean is
    begin
        return status.ready = '1';
    end function;
    
    function is_probe_armed(status : status_register_t) return boolean is
    begin
        return status.armed = '1';
    end function;
    
    function is_probe_firing(status : status_register_t) return boolean is
    begin
        return status.firing = '1';
    end function;
    
    function is_probe_cooldown(status : status_register_t) return boolean is
    begin
        return status.cooldown = '1';
    end function;
    
    function is_probe_error(status : status_register_t) return boolean is
    begin
        return status.error = '1';
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
    
    -- Intensity lookup function using the shared percent_lut_pkg
    -- Note: This function now delegates to the intensity_lut_pkg which uses shared types
    function get_intensity_output(index : probe_intensity_index_type) return signed is
    begin
        -- This will use the intensity_lut_pkg which now uses shared percent_lut_pkg
        -- We need to include the intensity_lut_pkg to use its functions
        return work.intensity_lut_pkg.get_intensity_value_safe(index);
    end function;
    
end package body;
