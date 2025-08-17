-- Enhanced SlotBlinker/SlotBlinker.vhd
-- A configurable blinker with comprehensive control over all outputs
-- Designed for easy identification on oscilloscope and logic analyzer

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity SlotBlinker is
  port (
    clk        : in  std_logic;
    reset      : in  std_logic;
    control0   : in  std_logic_vector(31 downto 0);
    control1   : in  std_logic_vector(31 downto 0);
    control2   : in  std_logic_vector(31 downto 0);
    control3   : in  std_logic_vector(31 downto 0);
    control4   : in  std_logic_vector(31 downto 0);
    -- Four distinct outputs with configurable patterns
    output_a   : out signed(15 downto 0);
    output_b   : out signed(15 downto 0);
    output_c   : out signed(15 downto 0);
    output_d   : out signed(15 downto 0)
  );
end entity;
  
architecture rtl of SlotBlinker is
  -- Pattern generation function
  function generate_pattern(
    pattern_type : std_logic_vector(7 downto 0);
    counter_val  : unsigned(15 downto 0);
    freq_div     : unsigned(7 downto 0);
    phase_offset : unsigned(7 downto 0)
  ) return unsigned is
    variable scaled_counter : unsigned(15 downto 0);
    variable pattern_result : unsigned(15 downto 0);
  begin
    -- Apply frequency divider and phase offset
    scaled_counter := (counter_val + (phase_offset & "00000000")) / freq_div;
    
    case pattern_type is
      when x"00" => -- Sawtooth (default)
        pattern_result := scaled_counter;
      when x"01" => -- Square wave
        if scaled_counter(15) = '1' then
          pattern_result := x"8000"; -- High
        else
          pattern_result := x"0000"; -- Low
        end if;
      when x"02" => -- Sine approximation (using lookup table approximation)
        case scaled_counter(15 downto 12) is
          when "0000" => pattern_result := x"0000"; -- 0°
          when "0001" => pattern_result := x"4000"; -- 45°
          when "0010" => pattern_result := x"7FFF"; -- 90°
          when "0011" => pattern_result := x"4000"; -- 135°
          when "0100" => pattern_result := x"0000"; -- 180°
          when "0101" => pattern_result := x"C000"; -- 225°
          when "0110" => pattern_result := x"8000"; -- 270°
          when "0111" => pattern_result := x"C000"; -- 315°
          when others => pattern_result := x"0000";
        end case;
      when x"03" => -- Random pattern (pseudo-random)
        pattern_result := scaled_counter xor (scaled_counter srl 7) xor (scaled_counter srl 13);
      when others => -- Default to sawtooth
        pattern_result := scaled_counter;
    end case;
    
    return pattern_result;
  end function;
  
  -- Control register parsing
  signal enable          : std_logic;
  signal soft_reset      : std_logic;
  signal sign_control    : std_logic;
  signal global_divider  : unsigned(4 downto 0);
  signal pattern_sel     : std_logic_vector(7 downto 0);
  
  -- Output A configuration
  signal freq_div_a      : unsigned(7 downto 0);
  signal amp_scale_a     : unsigned(7 downto 0);
  signal pattern_type_a  : std_logic_vector(7 downto 0);
  signal phase_offset_a  : unsigned(7 downto 0);
  
  -- Output B configuration
  signal freq_div_b      : unsigned(7 downto 0);
  signal amp_scale_b     : unsigned(7 downto 0);
  signal pattern_type_b  : std_logic_vector(7 downto 0);
  signal phase_offset_b  : unsigned(7 downto 0);
  
  -- Output C configuration
  signal freq_div_c      : unsigned(7 downto 0);
  signal amp_scale_c     : unsigned(7 downto 0);
  signal pattern_type_c  : std_logic_vector(7 downto 0);
  signal phase_offset_c  : unsigned(7 downto 0);
  
  -- Output D configuration
  signal freq_div_d      : unsigned(7 downto 0);
  signal amp_scale_d     : unsigned(7 downto 0);
  signal pattern_type_d  : std_logic_vector(7 downto 0);
  signal phase_offset_d  : unsigned(7 downto 0);
  
  -- Internal signals
  signal counter         : unsigned(15 downto 0) := (others => '0');
  signal div_counter     : unsigned(7 downto 0) := (others => '0');
  signal reset_sync      : std_logic;
  signal reset_prev      : std_logic;

begin
  -- Parse Control Register 0: Global Control & Timing
  enable         <= not control0(31);           -- Enable (active-low)
  soft_reset     <= control0(30);               -- Software reset
  sign_control   <= control0(29);               -- Sign control (0=unsigned, 1=signed)
  global_divider <= unsigned(control0(28 downto 24)); -- Global clock divider (1-32)
  pattern_sel    <= control0(23 downto 16);     -- Pattern selector
  
  -- Parse Control Register 1: Output A Configuration
  freq_div_a     <= unsigned(control1(31 downto 24)); -- Frequency divider (1-256)
  amp_scale_a    <= unsigned(control1(23 downto 16)); -- Amplitude scale (0-255)
  pattern_type_a <= control1(15 downto 8);      -- Pattern type (0-255)
  phase_offset_a <= unsigned(control1(7 downto 0));   -- Phase offset (0-255)
  
  -- Parse Control Register 2: Output B Configuration
  freq_div_b     <= unsigned(control2(31 downto 24)); -- Frequency divider (1-256)
  amp_scale_b   <= unsigned(control2(23 downto 16)); -- Amplitude scale (0-255)
  pattern_type_b <= control2(15 downto 8);      -- Pattern type (0-255)
  phase_offset_b <= unsigned(control2(7 downto 0));   -- Phase offset (0-255)
  
  -- Parse Control Register 3: Output C Configuration
  freq_div_c     <= unsigned(control3(31 downto 24)); -- Frequency divider (1-256)
  amp_scale_c   <= unsigned(control3(23 downto 16)); -- Amplitude scale (0-255)
  pattern_type_c <= control3(15 downto 8);      -- Pattern type (0-255)
  phase_offset_c <= unsigned(control3(7 downto 0));   -- Phase offset (0-255)
  
  -- Parse Control Register 4: Output D Configuration
  freq_div_d     <= unsigned(control4(31 downto 24)); -- Frequency divider (1-256)
  amp_scale_d   <= unsigned(control4(23 downto 16)); -- Amplitude scale (0-255)
  pattern_type_d <= control4(15 downto 8);      -- Pattern type (0-255)
  phase_offset_d <= unsigned(control4(7 downto 0));   -- Phase offset (0-255)
  
  -- Software reset detection (rising edge)
  reset_sync <= reset or soft_reset;
  
  -- Main counter process with global divider
  process(clk) 
  begin
    if rising_edge(clk) then
      reset_prev <= reset_sync;
      
      if reset_sync = '1' then
        counter <= (others => '0');
        div_counter <= (others => '0');
      elsif enable = '1' then
        -- Apply global divider
        if div_counter >= global_divider then
          counter <= counter + 1;
          div_counter <= (others => '0');
        else
          div_counter <= div_counter + 1;
        end if;
      end if;
    end if;
  end process;
  
  -- Generate outputs with amplitude scaling and sign control
  -- Output A
  process(clk)
    variable raw_pattern : unsigned(15 downto 0);
    variable scaled_pattern : unsigned(15 downto 0);
  begin
    if rising_edge(clk) then
      raw_pattern := generate_pattern(pattern_type_a, counter, freq_div_a, phase_offset_a);
      scaled_pattern := (raw_pattern * amp_scale_a) / 255;
      
      -- Apply sign control
      if sign_control = '0' then
        -- Force unsigned: clear sign bit, keep magnitude (0 to +32767)
        output_a <= signed('0' & scaled_pattern(14 downto 0));
      else
        -- Allow signed: full range (-32768 to +32767)
        output_a <= signed(scaled_pattern);
      end if;
    end if;
  end process;
  
  -- Output B
  process(clk)
    variable raw_pattern : unsigned(15 downto 0);
    variable scaled_pattern : unsigned(15 downto 0);
  begin
    if rising_edge(clk) then
      raw_pattern := generate_pattern(pattern_type_b, counter, freq_div_b, phase_offset_b);
      scaled_pattern := (raw_pattern * amp_scale_b) / 255;
      
      if sign_control = '0' then
        output_b <= signed('0' & scaled_pattern(14 downto 0));
      else
        output_b <= signed(scaled_pattern);
      end if;
    end if;
  end process;
  
  -- Output C
  process(clk)
    variable raw_pattern : unsigned(15 downto 0);
    variable scaled_pattern : unsigned(15 downto 0);
  begin
    if rising_edge(clk) then
      raw_pattern := generate_pattern(pattern_type_c, counter, freq_div_c, phase_offset_c);
      scaled_pattern := (raw_pattern * amp_scale_c) / 255;
      
      if sign_control = '0' then
        output_c <= signed('0' & scaled_pattern(14 downto 0));
      else
        output_c <= signed(scaled_pattern);
      end if;
    end if;
  end process;
  
  -- Output D
  process(clk)
    variable raw_pattern : unsigned(15 downto 0);
    variable scaled_pattern : unsigned(15 downto 0);
  begin
    if rising_edge(clk) then
      raw_pattern := generate_pattern(pattern_type_d, counter, freq_div_d, phase_offset_d);
      scaled_pattern := (raw_pattern * amp_scale_d) / 255;
      
      if sign_control = '0' then
        output_d <= signed('0' & scaled_pattern(14 downto 0));
      else
        output_d <= signed(scaled_pattern);
      end if;
    end if;
  end process;

end architecture rtl;
