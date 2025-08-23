-- Example_Module.vhd
-- Top-level wrapper template.
-- If targeting MCC immediately, this file can provide the architecture
-- for the MCC-supplied 'CustomWrapper' entity and instantiate your wrapper/core.
-- To keep this template standalone, we declare a simple Example_Module entity here.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Example_Module is
  port (
    clk    : in  std_logic;
    rst_n  : in  std_logic;
    clk_en : in  std_logic;
    din    : in  signed(15 downto 0);
    dout   : out signed(15 downto 0)
  );
end entity Example_Module;

architecture rtl of Example_Module is
  component Example_Module_Core is
    port (
      clk    : in  std_logic;
      rst_n  : in  std_logic;
      clk_en : in  std_logic;
      din    : in  signed(15 downto 0);
      dout   : out signed(15 downto 0);
      ready  : out std_logic
    );
  end component;

  signal s_ready : std_logic;
begin
  u_core : Example_Module_Core
    port map (
      clk    => clk,
      rst_n  => rst_n,
      clk_en => clk_en,
      din    => din,
      dout   => dout,
      ready  => s_ready
    );

  -- In an MCC build, map registers/IO here or in a dedicated wrapper.
end architecture rtl;
