-- EnhancedSlotBlinker.vhd
-- MCC-compatible EnhancedSlotBlinker architecture for CustomWrapper entity
-- This file provides the complete EnhancedSlotBlinker implementation as an architecture
-- Note: MCC provides the CustomWrapper entity declaration, we provide the Behavioural architecture
--
-- Date: 2025-01-27
-- Tag: EnhancedSlotBlinker-v1.0-Refactored-Consolidated

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

-- When using MCC, we define the behaviour of CustomWrapper
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
