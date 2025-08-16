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
  constant ProbeMinDuration : unsigned(15 downto 0) := to_unsigned(2, 16);      -- Minimum pulse duration (clock cycles)
  constant ProbeMaxDuration : unsigned(15 downto 0) := to_unsigned(32, 16);     -- Maximum pulse duration (clock cycles)  
  constant ProbeCoolDownMin : unsigned(31 downto 0) := to_unsigned(1, 32);      -- Probe cool down period (clock cycles)
  
  -- =============================================================================
  -- CONFIGURATION VALIDATION CONSTANTS
  -- =============================================================================
  
  -- Intensity range validation
  constant ProbeIntensityMin : integer := 0;    -- Minimum valid intensity index
  constant ProbeIntensityMax : integer := 100;  -- Maximum valid intensity index
  
  -- =============================================================================
  -- TIMING CALCULATIONS (for reference)
  -- =============================================================================
  -- Assuming 100MHz clock:
  -- ProbeMinDuration = 2 cycles = 20ns
  -- ProbeMaxDuration = 32 cycles = 320ns
  -- ProbeCoolDownMin = 1 cycle = 10ns
  
end package ProbeConfig_pkg;
