-- ClockDivider.vhd
-- Unified clock divider module for all Moku VHDL modules
-- Provides configurable clock division with generic bit width support
-- 
-- Features:
-- - Configurable divider bit width (1 to 16 bits)
-- - Flexible division ratios (1 to 2^DIVIDER_WIDTH - 1)
-- - Enable/disable control
-- - Both divided clock output and enable pulse
-- - Synchronous reset
-- - Resource efficient (uses only necessary bits)

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity clock_divider is
    generic (
        DIVIDER_WIDTH : positive range 1 to 16 := 4;  -- Configurable divider bit width
        MAX_DIVIDER : natural := 2**DIVIDER_WIDTH - 1  -- Auto-calculated max divider
    );
    port (
        clk_in      : in  std_logic;                                    -- Input clock
        reset       : in  std_logic;                                    -- Synchronous reset
        divider     : in  std_logic_vector(DIVIDER_WIDTH-1 downto 0);   -- Division factor
        enable      : in  std_logic;                                    -- Enable/disable the divider
        clk_out     : out std_logic;                                    -- Divided clock output
        clk_out_en  : out std_logic                                     -- Output enable (high when clk_out is valid)
    );
end entity clock_divider;

architecture rtl of clock_divider is
    -- Internal signals
    signal counter        : unsigned(DIVIDER_WIDTH-1 downto 0) := (others => '0');
    signal divider_value  : unsigned(DIVIDER_WIDTH-1 downto 0) := (others => '0');
    signal clk_out_int   : std_logic := '0';
    signal clk_out_en_int: std_logic := '0';
    
begin
    -- Main clock divider logic
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if reset = '1' then
                -- Reset state
                counter <= (others => '0');
                divider_value <= (others => '0');
                clk_out_int <= '0';
                clk_out_en_int <= '0';
            elsif enable = '1' then
                -- Update divider value from input
                divider_value <= unsigned(divider);
                
                -- Check if divider is valid (non-zero)
                if divider_value = 0 then
                    -- If divider is 0, output same as input (no division)
                    clk_out_int <= '1';
                    clk_out_en_int <= '1';
                else
                    -- Normal division logic
                    if counter >= divider_value - 1 then
                        counter <= (others => '0');
                        clk_out_int <= not clk_out_int;  -- Toggle output
                        clk_out_en_int <= '1';           -- Generate enable pulse
                    else
                        counter <= counter + 1;
                        clk_out_en_int <= '0';           -- Clear enable pulse
                    end if;
                end if;
            else
                -- When disabled, keep outputs low
                clk_out_int <= '0';
                clk_out_en_int <= '0';
                counter <= (others => '0');
            end if;
        end if;
    end process;
    
    -- Assign outputs
    clk_out <= clk_out_int;
    clk_out_en <= clk_out_en_int;
    
end architecture rtl;
