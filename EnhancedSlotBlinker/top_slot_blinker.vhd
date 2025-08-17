-- SlotBlinker/top_slot_blinker.vhd
-- Top-level file that instantiates enhanced SlotBlinker and connects to CustomWrapper
-- This creates a configurable test pattern generator for all four outputs

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

-- When using MCC, we define the behavior of CustomWrapper
architecture Behavioural of CustomWrapper is
begin

  -- Instantiate the enhanced SlotBlinker entity
  u_slot_blinker: entity work.SlotBlinker
    port map (
      -- Clock, Reset, and Control registers
      clk       => Clk,
      reset     => Reset,
      control0  => Control0,
      control1  => Control1,
      control2  => Control2,
      control3  => Control3,
      control4  => Control4,
      -- Connect to all four outputs
      output_a  => OutputA,
      output_b  => OutputB,
      output_c  => OutputC,
      output_d  => OutputD
    );

end architecture Behavioural;
