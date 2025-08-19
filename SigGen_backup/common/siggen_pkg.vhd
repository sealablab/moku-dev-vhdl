-- siggen_pkg.vhd
-- Main package for the SigGen module containing shared types, constants, and utilities
-- Follows VHDL-2008 standards and industry best practices
-- REFACTORED: Modular design aligned with ProbeDriver architecture

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.pattern_generator_pkg.all;

package siggen_pkg is
    -- =============================================================================
    -- CONSTANTS
    -- =============================================================================
    -- Clock divider constants
    constant GLOBAL_DIVIDER_MIN : integer := 1;
    constant GLOBAL_DIVIDER_MAX : integer := 32;
    constant FREQ_DIVIDER_MIN   : integer := 1;
    constant FREQ_DIVIDER_MAX   : integer := 256;
    
    -- Amplitude scaling constants
    constant AMP_SCALE_MIN      : integer := 0;
    constant AMP_SCALE_MAX      : integer := 255;
    constant AMP_SCALE_DEFAULT  : integer := 255; -- 100%
    
    -- Phase offset constants
    constant PHASE_OFFSET_MIN   : integer := 0;
    constant PHASE_OFFSET_MAX   : integer := 15;
    
    -- Bit mask constants
    constant BIT_MASK_DEFAULT   : std_logic_vector(15 downto 0) := x"FFFF";
    
    -- =============================================================================
    -- TYPES
    -- =============================================================================
    -- Output configuration record type
    type output_config_type is record
        freq_div     : unsigned(7 downto 0);   -- Frequency divider (1-256)
        amp_scale    : unsigned(7 downto 0);   -- Amplitude scale (0-255)
        pattern_type : std_logic_vector(3 downto 0); -- Pattern type (0-7)
        phase_offset : unsigned(3 downto 0);   -- Phase offset (0-15)
    end record;
    
    -- Global configuration record type
    type global_config_type is record
        nEnable       : std_logic;                    -- Global enable (active-low)
        sign_control  : std_logic;                    -- Sign control (0=unsigned, 1=signed)
        global_divider: unsigned(4 downto 0);        -- Global clock divider (1-32)
        bit_mask      : std_logic_vector(15 downto 0); -- Bit mask for pattern modification
    end record;
    
    -- Pipeline data record type for each output
    type pipeline_data_type is record
        raw_pattern      : unsigned(15 downto 0); -- Raw pattern from generator
        scaled_counter   : unsigned(15 downto 0); -- Counter with frequency/phase applied
        scaled_pattern   : unsigned(15 downto 0); -- Pattern with amplitude scaling
    end record;
    
    -- =============================================================================
    -- FUNCTIONS
    -- =============================================================================
    -- Configuration validation functions
    function is_valid_freq_divider(freq_div : unsigned(7 downto 0)) return boolean;
    function is_valid_amp_scale(amp_scale : unsigned(7 downto 0)) return boolean;
    function is_valid_phase_offset(phase_offset : unsigned(3 downto 0)) return boolean;
    function is_valid_global_divider(global_div : unsigned(4 downto 0)) return boolean;
    
    -- Safe default functions
    function get_safe_freq_divider(freq_div : unsigned(7 downto 0)) return unsigned;
    function get_safe_amp_scale(amp_scale : unsigned(7 downto 0)) return unsigned;
    function get_safe_phase_offset(phase_offset : unsigned(3 downto 0)) return unsigned;
    function get_safe_global_divider(global_div : unsigned(4 downto 0)) return unsigned;
    
    -- Configuration parsing functions
    function parse_output_config(control_reg : std_logic_vector(31 downto 0)) return output_config_type;
    function parse_global_config(control_reg : std_logic_vector(31 downto 0)) return global_config_type;
    
    -- Utility functions
    function apply_bit_mask(pattern : unsigned(15 downto 0); bit_mask : std_logic_vector(15 downto 0)) return unsigned;
    function apply_phase_offset(counter : unsigned(15 downto 0); phase_offset : unsigned(3 downto 0)) return unsigned;
    function apply_frequency_divider(counter : unsigned(15 downto 0); freq_div : unsigned(7 downto 0)) return unsigned;
    function apply_amplitude_scaling(pattern : unsigned(15 downto 0); amp_scale : unsigned(7 downto 0)) return unsigned;
    
end package siggen_pkg;

package body siggen_pkg is
    -- =============================================================================
    -- CONFIGURATION VALIDATION FUNCTIONS
    -- =============================================================================
    function is_valid_freq_divider(freq_div : unsigned(7 downto 0)) return boolean is
    begin
        return freq_div >= FREQ_DIVIDER_MIN and freq_div <= FREQ_DIVIDER_MAX;
    end function;
    
    function is_valid_amp_scale(amp_scale : unsigned(7 downto 0)) return boolean is
    begin
        return amp_scale >= AMP_SCALE_MIN and amp_scale <= AMP_SCALE_MAX;
    end function;
    
    function is_valid_phase_offset(phase_offset : unsigned(3 downto 0)) return boolean is
    begin
        return phase_offset >= PHASE_OFFSET_MIN and phase_offset <= PHASE_OFFSET_MAX;
    end function;
    
    function is_valid_global_divider(global_div : unsigned(4 downto 0)) return boolean is
    begin
        return global_div >= GLOBAL_DIVIDER_MIN and global_div <= GLOBAL_DIVIDER_MAX;
    end function;
    
    -- =============================================================================
    -- SAFE DEFAULT FUNCTIONS
    -- =============================================================================
    function get_safe_freq_divider(freq_div : unsigned(7 downto 0)) return unsigned is
    begin
        if is_valid_freq_divider(freq_div) then
            return freq_div;
        else
            return to_unsigned(FREQ_DIVIDER_MIN, 8);
        end if;
    end function;
    
    function get_safe_amp_scale(amp_scale : unsigned(7 downto 0)) return unsigned is
    begin
        if is_valid_amp_scale(amp_scale) then
            return amp_scale;
        else
            return to_unsigned(AMP_SCALE_DEFAULT, 8);
        end if;
    end function;
    
    function get_safe_phase_offset(phase_offset : unsigned(3 downto 0)) return unsigned is
    begin
        if is_valid_phase_offset(phase_offset) then
            return phase_offset;
        else
            return to_unsigned(PHASE_OFFSET_MIN, 4);
        end if;
    end function;
    
    function get_safe_global_divider(global_div : unsigned(4 downto 0)) return unsigned is
    begin
        if is_valid_global_divider(global_div) then
            return global_div;
        else
            return to_unsigned(GLOBAL_DIVIDER_MIN, 5);
        end if;
    end function;
    
    -- =============================================================================
    -- CONFIGURATION PARSING FUNCTIONS
    -- =============================================================================
    function parse_output_config(control_reg : std_logic_vector(31 downto 0)) return output_config_type is
        variable config : output_config_type;
    begin
        -- Parse frequency divider (bits 31-24)
        config.freq_div := get_safe_freq_divider(unsigned(control_reg(31 downto 24)));
        
        -- Parse amplitude scale (bits 23-16)
        config.amp_scale := get_safe_amp_scale(unsigned(control_reg(23 downto 16)));
        
        -- Parse pattern type (bits 15-8) or local pattern (bits 3-0)
        if unsigned(control_reg(15 downto 8)) > 0 then
            config.pattern_type := control_reg(11 downto 8); -- Use extended pattern type
        else
            config.pattern_type := control_reg(3 downto 0);  -- Use local pattern type
        end if;
        
        -- Parse phase offset (bits 7-4)
        config.phase_offset := get_safe_phase_offset(unsigned(control_reg(7 downto 4)));
        
        return config;
    end function;
    
    function parse_global_config(control_reg : std_logic_vector(31 downto 0)) return global_config_type is
        variable config : global_config_type;
    begin
        -- Parse global enable (bit 31, active-low)
        config.nEnable := not control_reg(31);
        
        -- Parse sign control (bit 30)
        config.sign_control := control_reg(30);
        
        -- Parse global divider (bits 28-24)
        config.global_divider := get_safe_global_divider(unsigned(control_reg(28 downto 24)));
        
        -- Parse bit mask (bits 15-0)
        if control_reg(15 downto 0) /= x"0000" then
            config.bit_mask := control_reg(15 downto 0);
        else
            config.bit_mask := BIT_MASK_DEFAULT;
        end if;
        
        return config;
    end function;
    
    -- =============================================================================
    -- UTILITY FUNCTIONS
    -- =============================================================================
    function apply_bit_mask(pattern : unsigned(15 downto 0); bit_mask : std_logic_vector(15 downto 0)) return unsigned is
    begin
        return pattern and unsigned(bit_mask);
    end function;
    
    function apply_phase_offset(counter : unsigned(15 downto 0); phase_offset : unsigned(3 downto 0)) return unsigned is
    begin
        return counter + (phase_offset & "00000000");
    end function;
    
    function apply_frequency_divider(counter : unsigned(15 downto 0); freq_div : unsigned(7 downto 0)) return unsigned is
    begin
        return counter / freq_div;
    end function;
    
    function apply_amplitude_scaling(pattern : unsigned(15 downto 0); amp_scale : unsigned(7 downto 0)) return unsigned is
        variable temp_mult : unsigned(23 downto 0);
    begin
        temp_mult := pattern * amp_scale;
        return temp_mult(23 downto 8); -- Return 16-bit result
    end function;
    
end package body siggen_pkg;
