-- SlotBlinker/top_slot_blinker.vhd
-- Top-level file that instantiates SlotBlinker and connects to CustomWrapper
-- This creates a simple test pattern generator for all four outputs

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

-- When using MCC, we define the behavior of CustomWrapper
architecture Behavioural of CustomWrapper is
begin

  -- Instantiate the SlotBlinker entity
  u_slot_blinker: entity work.SlotBlinker
    port map (
      -- Clock, Reset, and Control0 should always come first
      clk       => Clk,
      reset     => Reset,
      control0  => Control0,
      -- Connect to all four outputs
      output_a  => OutputA,
      output_b  => OutputB,
      output_c  => OutputC,
      output_d  => OutputD
    );

end architecture Behavioural;
