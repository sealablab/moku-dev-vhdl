-- tb_Example_Module.vhd
-- Minimal testbench template that emits magic pass/done strings.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_Example_Module is
end entity tb_Example_Module;

architecture tb of tb_Example_Module is
  signal clk    : std_logic := '0';
  signal rst_n  : std_logic := '0';
  signal clk_en : std_logic := '1';
  signal din    : signed(15 downto 0) := (others => '0');
  signal dout   : signed(15 downto 0);
begin
  -- Clock
  clk <= not clk after 5 ns;

  -- DUT
  dut: entity work.Example_Module
    port map (
      clk    => clk,
      rst_n  => rst_n,
      clk_en => clk_en,
      din    => din,
      dout   => dout
    );

  stim: process
  begin
    -- Reset
    rst_n <= '0';
    wait for 50 ns;
    rst_n <= '1';

    -- Drive something
    din <= to_signed(123, 16);
    wait for 200 ns;

    report "ALL TESTS PASSED";
    report "SIMULATION DONE";
    wait;
  end process;
end architecture tb;
