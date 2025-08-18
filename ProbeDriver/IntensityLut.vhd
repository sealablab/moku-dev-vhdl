-- Slot2/IntensityLut.vhd: 
-- Intensity Lookup Table Package for Probe Driver
-- This package contains the voltage-to-intensity mapping table

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

package IntensityLut_pkg is
  -- Type definition for the lookup table
  type intensity_lut_type is array (0 to 100) of signed(15 downto 0);
  
  -- Constant declaration for the lookup table
  -- ADC configured so 0x7FFF (MAX) = 4.999999V
  -- 3.3V = 0x7FFF * (3.3/4.999999) ≈ 0x7FFF * 0.66 ≈ 0x52AA
  constant IntensityLut : intensity_lut_type := (
    -- 0% to 9% (0V to 0.297V)
    x"0000", x"0008", x"0010", x"0018", x"0020", x"0028", x"0030", x"0038", x"0040", x"0048",
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
    -- 100% (3.3V)
    x"0320"
  );
  
end package IntensityLut_pkg;
