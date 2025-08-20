-- intensity_lut_pkg.vhd
-- Intensity Lookup Table Package for Probe Driver v2.5
-- 
-- REFACTORED: Now uses shared percent_lut_pkg for consistent type definitions
-- IMPORTANT: This LUT serves as both the intensity mapping AND the safety bounds:
-- IntensityLut[0] = 0x00 (off - safe zero intensity)
-- IntensityLut[1] = smallest observable output (MinIntensity - safe minimum)
-- IntensityLut[100] = largest safe output (MaxIntensity - safe maximum)
-- 
-- Users can modify these endpoints to adjust the safe operating range without
-- touching separate configuration files.
--
-- Date: 2025-01-27
-- Tag: ProbeDriver-v2.5-Refactored-Using-Shared-Types

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.percent_lut_pkg.all;

package intensity_lut_pkg is
    -- Use the shared percent_lut_type for consistency across modules
    -- This creates a 16-bit signed intensity lookup table (0-100%)
    constant IntensityLut : percent_lut_type := (
        -- 0% = 0V (off - safe zero intensity)
        x"0000",
        -- 1% = smallest observable output (MinIntensity - safe minimum)
        x"0240",
        -- 2% to 9% (0.066V to 0.297V)
        x"0010", x"0018", x"0020", x"0028", x"0030", x"0038", x"0040", x"0048",
        -- 10% to 19% (0.33V to 0.627V)
        x"0050", x"0058", x"0060", x"0068", x"0070", x"0078", x"0080", x"0088", x"0090", x"0098",
        -- 20% to 29% (0.66V to 0.957V)
        x"00A0", x"00A8", x"00B0", x"00B8", x"00C0", x"00C8", x"00D0", x"00D8", x"00E0", x"00E8",
        -- 30% to 39% (0.99V to 1.287V)
        x"00F0", x"00F8", x"0100", x"0108", x"0110", x"0118", x"0120", x"0128", x"0130", x"0138",
        -- 40% to 49% (1.32V to 1.617V)
        x"0140", x"0148", x"0150", x"0158", x"0160", x"0168", x"0170", x"0178", x"0180", x"0188",
        -- 50% to 59% (1.65V to 1.947V) - 50% = 1.65V
        x"0190", x"0198", x"01A0", x"01A8", x"01B0", x"01B8", x"01C0", x"01C8", x"01D0", x"01D8",
        -- 60% to 69% (1.98V to 2.277V)
        x"01E0", x"01E8", x"01F0", x"01F8", x"0200", x"0208", x"0210", x"0218", x"0220", x"0228",
        -- 70% to 79% (2.31V to 2.607V)
        x"0230", x"0238", x"0240", x"0248", x"0250", x"0258", x"0260", x"0268", x"0270", x"0278",
        -- 80% to 89% (2.64V to 2.937V)
        x"0280", x"0288", x"0290", x"0298", x"02A0", x"02A8", x"02B0", x"02B8", x"02C0", x"02C8",
        -- 90% to 99% (2.97V to 3.267V)
        x"02D0", x"02D8", x"02E0", x"02E8", x"02F0", x"02F8", x"0300", x"0308", x"0310", x"0318",
        -- 100% = largest safe output (MaxIntensity - safe maximum)
        x"0320"
    );
    
    -- Utility functions now use the shared percent_lut_pkg functions
    -- These provide consistent behavior across all modules
    
    -- Get intensity value by index (0-100) using shared function
    function get_intensity_value(index : natural range 0 to 100) return signed;
    
    -- Get intensity value safely from std_logic_vector input using shared function
    function get_intensity_value_safe(index : std_logic_vector(6 downto 0)) return signed;
    
    -- Get intensity value by percentage (0-100) using shared function
    function get_intensity_value_percentage(percentage : natural range 0 to 100) return signed;
    
end package intensity_lut_pkg;

package body intensity_lut_pkg is
    
    -- Get intensity value by index (0-100) - now uses shared function
    function get_intensity_value(index : natural range 0 to 100) return signed is
    begin
        return signed(get_percent_value(IntensityLut, index));
    end function;
    
    -- Get intensity value safely from std_logic_vector input - now uses shared function
    function get_intensity_value_safe(index : std_logic_vector(6 downto 0)) return signed is
    begin
        return signed(get_percent_value_safe(IntensityLut, index));
    end function;
    
    -- Get intensity value by percentage (0-100) - now uses shared function
    function get_intensity_value_percentage(percentage : natural range 0 to 100) return signed is
    begin
        return signed(get_percent_value_percentage(IntensityLut, percentage));
    end function;
    
end package body;
