-- Example_Module_Regs.vhd
-- Template for register record types and defaults.
-- Typically generated from <Module>/regs.yml later.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Example_Module_Regs_pkg is
  -- Control/Config/Status record examples
  type ctrl_t is record
    enable   : std_logic;
    reserved : std_logic_vector(6 downto 0);
  end record;

  type cfg_t is record
    gain     : unsigned(7 downto 0);
    mode     : unsigned(1 downto 0);
  end record;

  type sts_t is record
    ready    : std_logic;
    fault    : std_logic;
  end record;

  constant CTRL_RESET : ctrl_t := (
    enable   => '0',
    reserved => (others => '0')
  );

  constant CFG_RESET : cfg_t := (
    gain     => to_unsigned(16, 8),
    mode     => (others => '0')
  );

  constant STS_RESET : sts_t := (
    ready => '0',
    fault => '0'
  );
end package Example_Module_Regs_pkg;

package body Example_Module_Regs_pkg is
end package body Example_Module_Regs_pkg;
