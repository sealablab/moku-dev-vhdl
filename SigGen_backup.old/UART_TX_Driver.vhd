-- UART TX Driver for BestSlotBlinker
-- Generates UART TX signal with configurable baud rate and message
-- Can be used as standalone module or integrated with pattern generator

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity UART_TX_Driver is
  generic (
    CLK_FREQ_HZ : integer := 100_000_000;  -- Clock frequency in Hz
    BAUD_RATE   : integer := 115_200       -- UART baud rate
  );
  port (
    clk         : in  std_logic;
    reset       : in  std_logic;
    enable      : in  std_logic;           -- Enable UART transmission
    message_sel : in  std_logic_vector(3 downto 0); -- Message selector
    uart_tx     : out std_logic;           -- UART TX output pin
    busy        : out std_logic;           -- Transmission in progress
    done        : out std_logic            -- Transmission complete
  );
end entity;

architecture rtl of UART_TX_Driver is
  -- Calculate clock cycles per bit
  constant CLKS_PER_BIT : integer := CLK_FREQ_HZ / BAUD_RATE;
  
  -- UART states
  type uart_state_t is (IDLE, START, DATA, STOP);
  signal current_state : uart_state_t := IDLE;
  
  -- Message ROM - 16 different messages
  type message_array_t is array (0 to 15) of std_logic_vector(7 downto 0);
  constant MESSAGE_ROM : message_array_t := (
    x"48", -- "H" - Message 0
    x"45", -- "E" - Message 1  
    x"4C", -- "L" - Message 2
    x"4F", -- "O" - Message 3
    x"21", -- "!" - Message 4
    x"3F", -- "?" - Message 5
    x"2E", -- "." - Message 6
    x"2C", -- "," - Message 7
    x"20", -- " " (space) - Message 8
    x"0A", -- LF (newline) - Message 9
    x"0D", -- CR (carriage return) - Message 10
    x"00", -- NULL - Message 11
    x"41", -- "A" - Message 12
    x"42", -- "B" - Message 13
    x"43", -- "C" - Message 14
    x"44"  -- "D" - Message 15
  );
  
  -- Internal signals
  signal bit_counter    : unsigned(2 downto 0) := (others => '0');  -- 0-7 for data bits
  signal clk_counter    : unsigned(15 downto 0) := (others => '0'); -- Clock counter for timing
  signal current_byte   : std_logic_vector(7 downto 0) := (others => '0');
  signal message_index  : unsigned(3 downto 0) := (others => '0');
  
begin
  -- Main UART state machine
  process(clk, reset)
  begin
    if reset = '1' then
      current_state <= IDLE;
      uart_tx <= '1';        -- Idle state is high
      busy <= '0';
      done <= '0';
      bit_counter <= (others => '0');
      clk_counter <= (others => '0');
      current_byte <= (others => '0');
      message_index <= (others => '0');
      
    elsif rising_edge(clk) then
      case current_state is
        when IDLE =>
          uart_tx <= '1';    -- Idle state
          busy <= '0';
          done <= '0';
          
          if enable = '1' then
            current_state <= START;
            current_byte <= MESSAGE_ROM(to_integer(unsigned(message_sel)));
            clk_counter <= (others => '0');
            busy <= '1';
          end if;
          
        when START =>
          uart_tx <= '0';    -- Start bit (low)
          clk_counter <= clk_counter + 1;
          
          if clk_counter >= CLKS_PER_BIT - 1 then
            current_state <= DATA;
            clk_counter <= (others => '0');
            bit_counter <= (others => '0');
          end if;
          
        when DATA =>
          uart_tx <= current_byte(to_integer(bit_counter)); -- Send data bit
          clk_counter <= clk_counter + 1;
          
          if clk_counter >= CLKS_PER_BIT - 1 then
            clk_counter <= (others => '0');
            bit_counter <= bit_counter + 1;
            
            if bit_counter >= 7 then
              current_state <= STOP;
            end if;
          end if;
          
        when STOP =>
          uart_tx <= '1';    -- Stop bit (high)
          clk_counter <= clk_counter + 1;
          
          if clk_counter >= CLKS_PER_BIT - 1 then
            current_state <= IDLE;
            done <= '1';
            busy <= '0';
          end if;
          
      end case;
    end if;
  end process;

end architecture rtl;
