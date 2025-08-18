-- Slot2/ProbeConfig.vhd
-- Probe Driver Configuration Package
-- This package contains all configuration constants for the probe driver
-- Centralized configuration management for easy version control

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

package ProbeConfig_pkg is
  -- =============================================================================
  -- PROBE DRIVER CONFIGURATION CONSTANTS
  -- =============================================================================
  
  -- Trigger threshold configuration
  -- ADC configured so 0x7FFF (MAX) = 4.999999V
  -- 2.5V = 0x7FFF * (2.5/4.999999) ≈ 0x7FFF * 0.5 ≈ 0x4000
  constant ProbeTrigger_Threshold : signed(15 downto 0) := x"4000";  -- 2.5V threshold constant
  
  -- Timing configuration constants
  constant PulseMinDuration : unsigned(15 downto 0) := to_unsigned(16, 16);      -- Minimum pulse duration (clock cycles) - INCLUSIVE
  constant PulseMaxDuration : unsigned(15 downto 0) := to_unsigned(1024, 16);     -- Maximum pulse duration (clock cycles) - INCLUSIVE
  constant ProbeCoolDownMin : unsigned(31 downto 0) := to_unsigned(24, 32);      -- Probe cool down period (clock cycles) - INCLUSIVE
  
  -- =============================================================================
  -- CONFIGURATION VALIDATION CONSTANTS
  -- =============================================================================
  
  -- Intensity range validation
  -- Note: Intensity bounds are now defined by the IntensityLut endpoints:
  -- IntensityLut[0] = 0x00 (off)
  -- IntensityLut[1] = smallest observable output (MinIntensity)
  -- IntensityLut[100] = largest safe output (MaxIntensity)
  constant ProbeIntensityMin : integer := 0;    -- Minimum valid intensity index (always 0)
  constant ProbeIntensityMax : integer := 100;  -- Maximum valid intensity index (always 100)
  
  -- =============================================================================
  -- TIMING CALCULATIONS (for reference)
  -- =============================================================================
  -- Assuming 100MHz clock:
  -- ProbeMinDuration = 2 cycles = 20ns
  -- ProbeMaxDuration = 32 cycles = 320ns
  -- ProbeCoolDownMin = 1 cycle = 10ns
  
end package ProbeConfig_pkg;
