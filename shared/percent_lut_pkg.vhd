-- percent_lut_pkg.vhd
-- Generic Percentage Lookup Table Package for moku-dev-vhdl
-- 
-- PURPOSE: Provides a generic type definition for 0-100% lookup tables
--          that can be used across all modules in the moku-dev-vhdl project.
-- 
-- KEY FEATURES:
-- - Generic data type for flexible bit widths
-- - 0-100% range (101 values) indexed by 7-bit values
-- - Human-friendly percentage mapping (0% = off, 100% = full)
-- - No default tables - modules define their own mappings
-- 
-- USAGE:
--   use work.percent_lut_pkg.all;
--   constant MyLut : percent_lut_type := (x"0000", x"0240", ...);
-- 
-- Date: 2025-01-27
-- Tag: moku-dev-vhdl-shared-package-v1.0

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

package percent_lut_pkg is
    -- Generic type definition for percentage lookup tables
    -- DATA_WIDTH: Width of the output data values
    -- Range: 0-100% (101 values total)
    -- Index: 7-bit values (0-127) can index the full range
    type percent_lut_type is array (0 to 100) of std_logic_vector;
    
    -- Utility functions for working with percentage LUTs
    function get_percent_value(lut : percent_lut_type; index : natural range 0 to 100) return std_logic_vector;
    function get_percent_value_safe(lut : percent_lut_type; index : std_logic_vector(6 downto 0)) return std_logic_vector;
    function get_percent_value_percentage(lut : percent_lut_type; percentage : natural range 0 to 100) return std_logic_vector;
    
    -- Validation functions
    function is_valid_percent_index(index : natural) return boolean;
    function get_safe_percent_index(index : natural) return natural;
    
    -- LUT information functions
    function get_lut_size return natural;
    function get_index_width return natural;
    
end package percent_lut_pkg;

package body percent_lut_pkg is
    
    -- Get value from LUT by index (0-100)
    function get_percent_value(lut : percent_lut_type; index : natural range 0 to 100) return std_logic_vector is
    begin
        return lut(index);
    end function;
    
    -- Get value safely from std_logic_vector input (clamps to valid range)
    function get_percent_value_safe(lut : percent_lut_type; index : std_logic_vector(6 downto 0)) return std_logic_vector is
        variable int_index : natural;
    begin
        int_index := to_integer(unsigned(index));
        -- Clamp to valid range 0-100
        if int_index > 100 then
            int_index := 100;
        end if;
        return lut(int_index);
    end function;
    
    -- Get value by percentage (0-100)
    function get_percent_value_percentage(lut : percent_lut_type; percentage : natural range 0 to 100) return std_logic_vector is
    begin
        return lut(percentage);
    end function;
    
    -- Check if index is valid (0-100)
    function is_valid_percent_index(index : natural) return boolean is
    begin
        return index <= 100;
    end function;
    
    -- Get safe index value (clamps to 0-100)
    function get_safe_percent_index(index : natural) return natural is
    begin
        if index > 100 then
            return 100;
        else
            return index;
        end if;
    end function;
    
    -- Get LUT size (always 101 for 0-100%)
    function get_lut_size return natural is
    begin
        return 101;
    end function;
    
    -- Get index width needed (7 bits for 0-100)
    function get_index_width return natural is
    begin
        return 7;
    end function;
    
end package body;
