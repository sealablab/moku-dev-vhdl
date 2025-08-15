-- Slot2/top_probe_driver.vhd
-- Top-level CustomWrapper architecture that instantiates the probe_driver module

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

-- This architecture defines the behaviour of CustomWrapper
architecture Behavioural of CustomWrapper is
begin

  -- instantiate a single `probe_driver` entity named `u_probe_driver`
  u_probe_driver: entity work.probe_driver
    -- Clk, Reset, and Control0 should probably always come first in your port map
    port map (
      clk        => Clk,
      reset      => Reset,
      enable     => Control0(31), -- Topmost bit of Control0 set to enable
      trig_in    => Control0(0),  -- Use control0(0) as trigger input
      -- Module specific
      Intensity_in      => Control1(8 downto 0),      -- 9-bit intensity from control1
      PulseDuration_in  => Control2(31 downto 0),     -- 32-bit pulse duration from control2
      CoolDown_in       => Control3(31 downto 0),     -- 32-bit cooldown from control3
      trig_out          => open,                      -- Not connected
      intensity_out     => OutputA                    -- Connect intensity output to OutputA
    );

end architecture Behavioural;
