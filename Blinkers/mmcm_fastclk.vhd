-- # MMCM Clock Multiplier
-- This module instantiates a Xilinx MMCME2_BASE primitive to multiply
-- the 31.25 MHz system clock (`clk_in`) to a faster output (`fast_clk`).
-- The example multiplies by 8x to generate a 250 MHz clock.
-- This is suitable for synthesis in Vivado 2022.2 on the MCC/Moku:Go platform.

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity mmcm_multiplier is
    port (
        clk_in     : in  std_logic;   -- 31.25 MHz input clock
        reset      : in  std_logic;   -- async reset
        fast_clk   : out std_logic;   -- multiplied output clock (e.g., 250 MHz)
        clk_locked : out std_logic    -- '1' when MMCM has locked
    );
end entity;

architecture rtl of mmcm_multiplier is

    signal clkfb     : std_logic;
    signal clk_mmcm  : std_logic;
    signal mmcm_lock : std_logic;

begin

    -- Instantiate the MMCM primitive
    mmcm_inst : MMCME2_BASE
        generic map (
            CLKIN1_PERIOD     => 32.0,     -- 1 / 31.25 MHz = 32.0 ns
            CLKFBOUT_MULT_F   => 16.0,     -- Multiply factor
            DIVCLK_DIVIDE     => 1,        -- Pre-divider
            CLKOUT0_DIVIDE_F  => 2.0,      -- Output divider
            CLKOUT0_PHASE     => 0.0,
            CLKOUT0_DUTY_CYCLE=> 0.5,
            STARTUP_WAIT      => false
        )
        port map (
            CLKIN1    => clk_in,
            CLKFBIN   => clkfb,
            CLKFBOUT  => clkfb,
            CLKOUT0   => clk_mmcm,
            LOCKED    => mmcm_lock,
            PWRDWN    => '0',
            RST       => reset
        );

    fast_clk   <= clk_mmcm;
    clk_locked <= mmcm_lock;

end architecture;

