-- clk_divider.vhd
-- Standalone clock divider module for ProbeDriver
-- Provides configurable clock division using CR0[27:24] control bits

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity clk_divider is
    port (
        clk_in      : in  std_logic;                    -- Input clock
        reset       : in  std_logic;                    -- Synchronous reset
        divider_sel : in  std_logic_vector(3 downto 0); -- Divider selection (CR0[27:24])
        clk_en      : out std_logic                     -- Clock enable output
    );
end entity clk_divider;

architecture rtl of clk_divider is
    signal counter        : unsigned(15 downto 0) := (others => '0');
    signal divider_value  : unsigned(15 downto 0) := (others => '0');
    signal clk_en_int    : std_logic := '0';
    
    -- Function to convert divider select to actual divider value
    function get_divider_value(sel : std_logic_vector(3 downto 0)) return unsigned is
    begin
        case sel is
            when "0000" => return to_unsigned(1, 16);      -- No division
            when "0001" => return to_unsigned(2, 16);      -- Divide by 2
            when "0010" => return to_unsigned(4, 16);      -- Divide by 4
            when "0011" => return to_unsigned(8, 16);      -- Divide by 8
            when "0100" => return to_unsigned(16, 16);     -- Divide by 16
            when "0101" => return to_unsigned(32, 16);     -- Divide by 32
            when "0110" => return to_unsigned(64, 16);     -- Divide by 64
            when "0111" => return to_unsigned(128, 16);    -- Divide by 128
            when "1000" => return to_unsigned(256, 16);    -- Divide by 256
            when "1001" => return to_unsigned(512, 16);    -- Divide by 512
            when "1010" => return to_unsigned(1024, 16);   -- Divide by 1024
            when "1011" => return to_unsigned(2048, 16);   -- Divide by 2048
            when "1100" => return to_unsigned(4096, 16);   -- Divide by 4096
            when "1101" => return to_unsigned(8192, 16);   -- Divide by 8192
            when "1110" => return to_unsigned(16384, 16);  -- Divide by 16384
            when "1111" => return to_unsigned(32768, 16);  -- Divide by 32768
            when others => return to_unsigned(1, 16);      -- Default to no division
        end case;
    end function;
    
begin
    -- Main clock divider logic
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if reset = '1' then
                counter <= (others => '0');
                divider_value <= get_divider_value(divider_sel);
                clk_en_int <= '0';
            else
                divider_value <= get_divider_value(divider_sel);
                
                if counter >= divider_value - 1 then
                    counter <= (others => '0');
                    clk_en_int <= '1';
                else
                    counter <= counter + 1;
                    clk_en_int <= '0';
                end if;
            end if;
        end if;
    end process;
    
    clk_en <= clk_en_int;
    
end architecture rtl;
