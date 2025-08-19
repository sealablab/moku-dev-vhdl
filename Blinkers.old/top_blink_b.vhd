-- Blinkers/top_blink_b.vhd
-- Illustrates how to instantiate a `basic_b` blinker 
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

-- Note: If you are confused about what the 'CustomWrapper' interface is, please see [[CustomWrapper.md]]

-- when using MCC the way we define `main` is to specify the __behavior__ of `CustomWrapper`
architecture Behavioural of CustomWrapper is
-- 
begin

  -- instantiate a single `blink_b` entity named `u_blink`
  u_blink: entity work.blink_b
	-- Clk, Reset, and Control0 should probably always come first in your port map
    port map (
      clk       => Clk,
      reset     => Reset,
      control0  => Control0,
	  -- Module specific
      blink_out => OutputA
    );

end architecture Behavioural;


