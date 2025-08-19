-- BestSlotBlinker with UART TX Integration Example
-- Shows how to combine the pattern generator with UART TX functionality
-- This is an example of how to use both modules together

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity BestSlotBlinker_with_UART is
  port (
    clk        : in  std_logic;
    reset      : in  std_logic;
    control0   : in  std_logic_vector(31 downto 0);
    control1   : in  std_logic_vector(31 downto 0);
    control2   : in  std_logic_vector(31 downto 0);
    control3   : in  std_logic_vector(31 downto 0);
    control4   : in  std_logic_vector(31 downto 0);
    -- Pattern outputs
    output_a   : out signed(15 downto 0);
    output_b   : out signed(15 downto 0);
    output_c   : out signed(15 downto 0);
    output_d   : out signed(15 downto 0);
    -- UART TX output
    uart_tx    : out std_logic
  );
end entity;

architecture rtl of BestSlotBlinker_with_UART is
  -- Component declarations
  component SlotBlinker is
    port (
      clk        : in  std_logic;
      reset      : in  std_logic;
      control0   : in  std_logic_vector(31 downto 0);
      control1   : in  std_logic_vector(31 downto 0);
      control2   : in  std_logic_vector(31 downto 0);
      control3   : in  std_logic_vector(31 downto 0);
      control4   : in  std_logic_vector(31 downto 0);
      output_a   : out signed(15 downto 0);
      output_b   : out signed(15 downto 0);
      output_c   : out signed(15 downto 0);
      output_d   : out signed(15 downto 0)
    );
  end component;
  
  component UART_TX_Driver is
    generic (
      CLK_FREQ_HZ : integer := 100_000_000;
      BAUD_RATE   : integer := 115_200
    );
    port (
      clk         : in  std_logic;
      reset       : in  std_logic;
      enable      : in  std_logic;
      message_sel : in  std_logic_vector(3 downto 0);
      uart_tx     : out std_logic;
      busy        : out std_logic;
      done        : out std_logic
    );
  end component;
  
  -- Internal signals
  signal uart_enable      : std_logic := '0';
  signal uart_message_sel : std_logic_vector(3 downto 0) := (others => '0');
  signal uart_busy        : std_logic;
  signal uart_done        : std_logic;
  signal uart_counter     : unsigned(15 downto 0) := (others => '0');
  
begin
  -- Instantiate the main pattern generator
  pattern_gen : SlotBlinker
    port map (
      clk      => clk,
      reset    => reset,
      control0 => control0,
      control1 => control1,
      control2 => control2,
      control3 => control3,
      control4 => control4,
      output_a => output_a,
      output_b => output_b,
      output_c => output_c,
      output_d => output_d
    );
  
  -- Instantiate the UART TX driver
  uart_driver : UART_TX_Driver
    generic map (
      CLK_FREQ_HZ => 100_000_000,  -- Adjust to your clock frequency
      BAUD_RATE   => 115_200        -- Adjust to desired baud rate
    )
    port map (
      clk         => clk,
      reset       => reset,
      enable      => uart_enable,
      message_sel => uart_message_sel,
      uart_tx     => uart_tx,
      busy        => uart_busy,
      done        => uart_done
    );
  
  -- UART control logic - sends messages periodically
  process(clk, reset)
  begin
    if reset = '1' then
      uart_enable <= '0';
      uart_message_sel <= (others => '0');
      uart_counter <= (others => '0');
      
    elsif rising_edge(clk) then
      -- Auto-increment message selector every 65536 clock cycles
      uart_counter <= uart_counter + 1;
      
      -- Send UART message when not busy and counter reaches threshold
      if uart_busy = '0' and uart_counter = x"FFFF" then
        uart_enable <= '1';
        uart_message_sel <= uart_message_sel + 1; -- Cycle through messages
      else
        uart_enable <= '0';
      end if;
    end if;
  end process;

end architecture rtl;
