-- Slot2/testbench/simple_tb.vhd
-- Very simple testbench to test basic VHDL functionality

library IEEE;
use IEEE.Std_Logic_1164.all;

entity simple_tb is
end entity simple_tb;

architecture test of simple_tb is
  signal clk : std_logic := '0';
  constant CLK_PERIOD : time := 10 ns;
begin
  -- Simple clock generation
  clk <= not clk after CLK_PERIOD / 2;
  
  -- Simple test process
  process
  begin
    wait for CLK_PERIOD * 5;
    report "Simple testbench completed successfully";
    wait;
  end process;
  
end architecture test;
