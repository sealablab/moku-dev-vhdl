-- Example_Module_Core.vhd
-- Minimal, compiling core template (VHDL-2008).
-- Replace the architecture body with real logic; keep ports/style intact.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Example_Module_Core is
  port (
    clk    : in  std_logic;  -- system clock
    rst_n  : in  std_logic;  -- active-low synchronous reset
    clk_en : in  std_logic;  -- clock enable (1 = advance)

    -- Example I/O (edit freely)
    din    : in  signed(15 downto 0);
    dout   : out signed(15 downto 0);

    -- Status example
    ready  : out std_logic
  );
end entity Example_Module_Core;

architecture rtl of Example_Module_Core is
  signal r_acc : signed(15 downto 0) := (others => '0');
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        r_acc <= (others => '0');
      elsif clk_en = '1' then
        r_acc <= din;  -- placeholder: pass-through
      end if;
    end if;
  end process;

  dout  <= r_acc;
  ready <= '1';  -- placeholder
end architecture rtl;
