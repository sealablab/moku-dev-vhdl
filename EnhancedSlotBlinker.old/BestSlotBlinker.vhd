-- Enhanced SlotBlinker/SlotBlinker.vhd
-- A configurable blinker with comprehensive control over all outputs
-- Pipelined design for timing closure
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
  -- Pattern generation function (enhanced with better patterns)
  function generate_pattern_enhanced(
    pattern_type : std_logic_vector(3 downto 0);
    counter_val  : unsigned(15 downto 0)
  ) return unsigned is
    variable pattern_result : unsigned(15 downto 0);
    variable temp_val : unsigned(15 downto 0);
    variable sine_step : std_logic_vector(3 downto 0);
  begin
    case pattern_type is
      when "0000" => -- Sawtooth (linear ramp)
        pattern_result := counter_val;
        
      when "0001" => -- Square wave (proper 50% duty cycle)
        if counter_val(15) = '1' then
          pattern_result := x"7FFF"; -- High level
        else
          pattern_result := x"0000"; -- Low level
        end if;
        
      when "0010" => -- Triangle wave (sawtooth folded)
        temp_val := counter_val(14 downto 0) & '0'; -- Double frequency
        if counter_val(15) = '1' then
          pattern_result := x"7FFF" - temp_val; -- Folding down
        else
          pattern_result := temp_val; -- Going up
        end if;
        
      when "0011" => -- Sine approximation (16-step lookup)
        sine_step := std_logic_vector(counter_val(15 downto 12));
        case sine_step is
          when "0000" => pattern_result := x"0000"; -- 0°
          when "0001" => pattern_result := x"3249"; -- 22.5°
          when "0010" => pattern_result := x"5A82"; -- 45°
          when "0011" => pattern_result := x"7FFF"; -- 67.5°
          when "0100" => pattern_result := x"7FFF"; -- 90°
          when "0101" => pattern_result := x"5A82"; -- 112.5°
          when "0110" => pattern_result := x"0000"; -- 135°
          when "0111" => pattern_result := x"A57D"; -- 157.5°
          when "1000" => pattern_result := x"8000"; -- 180°
          when "1001" => pattern_result := x"CDB6"; -- 202.5°
          when "1010" => pattern_result := x"A57D"; -- 225°
          when "1011" => pattern_result := x"8000"; -- 247.5°
          when "1100" => pattern_result := x"8000"; -- 270°
          when "1101" => pattern_result := x"A57D"; -- 292.5°
          when "1110" => pattern_result := x"0000"; -- 315°
          when "1111" => pattern_result := x"5A82"; -- 337.5°
          when others => pattern_result := x"0000";
        end case;
        
      when "0100" => -- Random pattern (improved LFSR-like)
        temp_val := counter_val xor (counter_val srl 7) xor (counter_val srl 13);
        pattern_result := temp_val xor (temp_val sll 3);
        
      when "0101" => -- Staircase (4 steps)
        case counter_val(15 downto 14) is
          when "00" => pattern_result := x"2000"; -- 25%
          when "01" => pattern_result := x"4000"; -- 50%
          when "10" => pattern_result := x"6000"; -- 75%
          when "11" => pattern_result := x"7FFF"; -- 100%
          when others => pattern_result := x"2000";
        end case;
        
      when "0110" => -- Exponential ramp (log-like)
        temp_val := counter_val(15 downto 8) & "00000000"; -- Use upper 8 bits
        if temp_val = x"0000" then
          pattern_result := x"0000";
        else
          pattern_result := temp_val + (temp_val srl 2); -- Approximate exponential
        end if;
        
      when "0111" => -- Pulse train (narrow pulses)
        if counter_val(15 downto 12) = "0000" then
          pattern_result := x"7FFF"; -- Narrow pulse
        else
          pattern_result := x"0000"; -- Long low
        end if;
        
      when "1000" => -- Ramp with reset (sawtooth with clear)
        if counter_val(15 downto 12) = "1111" then
          pattern_result := x"0000"; -- Reset point
        else
          pattern_result := counter_val(11 downto 0) & "0000"; -- Ramp up
        end if;
        
      when "1001" => -- Alternating levels (4 levels alternating)
        case counter_val(15 downto 14) is
          when "00" => pattern_result := x"2000"; -- Level 1
          when "01" => pattern_result := x"6000"; -- Level 2
          when "10" => pattern_result := x"2000"; -- Level 1
          when "11" => pattern_result := x"6000"; -- Level 2
          when others => pattern_result := x"2000";
        end case;
        
      when "1010" => -- Sine with harmonics (richer tone)
        temp_val := counter_val(15 downto 8) & "00000000";
        pattern_result := temp_val + (temp_val srl 2) + (temp_val srl 4);
        
      when "1011" => -- Chirp (frequency sweep)
        temp_val := counter_val(15 downto 8) & "00000000";
        pattern_result := temp_val + (temp_val srl 1) + (temp_val srl 3);
        
      when "1100" => -- Noise burst (random with structure)
        temp_val := counter_val xor (counter_val srl 5) xor (counter_val srl 10);
        if counter_val(15 downto 12) = "0000" then
          pattern_result := temp_val; -- Noise burst
        else
          pattern_result := x"4000"; -- Quiet period
        end if;
        
      when "1101" => -- Dual frequency (beat pattern)
        temp_val := counter_val(15 downto 8) & "00000000";
        pattern_result := temp_val + (temp_val srl 1);
        
      when "1110" => -- Modulated carrier
        temp_val := counter_val(15 downto 8) & "00000000";
        pattern_result := temp_val + (temp_val srl 3) + (temp_val srl 6);
        
      when "1111" => -- Complex waveform (multiple harmonics)
        temp_val := counter_val(15 downto 8) & "00000000";
        pattern_result := temp_val + (temp_val srl 1) + (temp_val srl 2) + (temp_val srl 4);
        
      when others => -- Default to sawtooth
        pattern_result := counter_val;
    end case;
    
    return pattern_result;
  end function;
  
  -- Control register parsing
  signal nEnable          : std_logic;
  signal soft_reset      : std_logic;
  signal sign_control    : std_logic;
  signal global_divider  : unsigned(4 downto 0);
  signal pattern_sel     : std_logic_vector(3 downto 0);
  
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
  
  -- Pipeline registers for Output A
  signal raw_pattern_a_pipe1 : unsigned(15 downto 0);
  signal scaled_counter_a_pipe1 : unsigned(15 downto 0);
  signal scaled_pattern_a_pipe2 : unsigned(15 downto 0);
  
  -- Pipeline registers for Output B
  signal raw_pattern_b_pipe1 : unsigned(15 downto 0);
  signal scaled_counter_b_pipe1 : unsigned(15 downto 0);
  signal scaled_pattern_b_pipe2 : unsigned(15 downto 0);
  
  -- Pipeline registers for Output C
  signal raw_pattern_c_pipe1 : unsigned(15 downto 0);
  signal scaled_counter_c_pipe1 : unsigned(15 downto 0);
  signal scaled_pattern_c_pipe2 : unsigned(15 downto 0);
  
  -- Pipeline registers for Output D
  signal raw_pattern_d_pipe1 : unsigned(15 downto 0);
  signal scaled_counter_d_pipe1 : unsigned(15 downto 0);
  signal scaled_pattern_d_pipe2 : unsigned(15 downto 0);

begin
  -- Parse Control Register 0: Global Control & Timing
  nEnable        <= not control0(31);           -- nEnable (active-low enable)
  soft_reset     <= control0(30);               -- Software reset
  sign_control   <= control0(29);               -- Sign control (0=unsigned, 1=signed)
  global_divider <= unsigned(control0(28 downto 24)) when unsigned(control0(28 downto 24)) > 0 else "00001"; -- Global clock divider (1-32, default 1)
  pattern_sel    <= control0(3 downto 0);       -- Pattern selector (bottom 4 bits - more prominent!)
  
  -- Parse Control Register 1: Output A Configuration
  freq_div_a     <= unsigned(control1(31 downto 24)) when unsigned(control1(31 downto 24)) > 0 else "00000001"; -- Frequency divider (1-256, default 1)
  amp_scale_a    <= unsigned(control1(23 downto 16)) when unsigned(control1(23 downto 16)) > 0 else "11111111"; -- Amplitude scale (0-255, default 100%)
  pattern_type_a <= control1(15 downto 8) when unsigned(control1(15 downto 8)) > 0 else ("0000" & pattern_sel); -- Pattern type (0-255) or global pattern
  phase_offset_a <= unsigned(control1(7 downto 0));   -- Phase offset (0-255)
  
  -- Parse Control Register 2: Output B Configuration
  freq_div_b     <= unsigned(control2(31 downto 24)) when unsigned(control2(31 downto 24)) > 0 else "00000100"; -- Frequency divider (1-256, default 4)
  amp_scale_b   <= unsigned(control2(23 downto 16)) when unsigned(control2(23 downto 16)) > 0 else "11111111"; -- Amplitude scale (0-255, default 100%)
  pattern_type_b <= control2(15 downto 8) when unsigned(control2(15 downto 8)) > 0 else ("0000" & pattern_sel); -- Pattern type (0-255) or global pattern
  phase_offset_b <= unsigned(control2(7 downto 0));   -- Phase offset (0-255)
  
  -- Parse Control Register 3: Output C Configuration
  freq_div_c     <= unsigned(control3(31 downto 24)) when unsigned(control3(31 downto 24)) > 0 else "00010000"; -- Frequency divider (1-256, default 16)
  amp_scale_c   <= unsigned(control3(23 downto 16)) when unsigned(control3(23 downto 16)) > 0 else "11111111"; -- Amplitude scale (0-255, default 100%)
  pattern_type_c <= control3(15 downto 8) when unsigned(control3(15 downto 8)) > 0 else ("0000" & pattern_sel); -- Pattern type (0-255) or global pattern
  phase_offset_c <= unsigned(control3(7 downto 0));   -- Phase offset (0-255)
  
  -- Parse Control Register 4: Output D Configuration
  freq_div_d     <= unsigned(control4(31 downto 24)) when unsigned(control4(31 downto 24)) > 0 else "01000000"; -- Frequency divider (1-256, default 64)
  amp_scale_d   <= unsigned(control4(23 downto 16)) when unsigned(control4(23 downto 16)) > 0 else "11111111"; -- Amplitude scale (0-255, default 100%)
  pattern_type_d <= control4(15 downto 8) when unsigned(control4(15 downto 8)) > 0 else ("0000" & pattern_sel); -- Pattern type (0-255) or global pattern
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
      elsif nEnable = '1' then -- Use nEnable for the main enable
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
  
  -- Pipeline Stage 1: Generate raw patterns and apply frequency/phase
  process(clk)
  begin
    if rising_edge(clk) then
      if reset_sync = '1' then
        -- Reset pipeline registers
        raw_pattern_a_pipe1 <= (others => '0');
        raw_pattern_b_pipe1 <= (others => '0');
        raw_pattern_c_pipe1 <= (others => '0');
        raw_pattern_d_pipe1 <= (others => '0');
        scaled_counter_a_pipe1 <= (others => '0');
        scaled_counter_b_pipe1 <= (others => '0');
        scaled_counter_c_pipe1 <= (others => '0');
        scaled_counter_d_pipe1 <= (others => '0');
      else
        -- Generate raw patterns
        raw_pattern_a_pipe1 <= generate_pattern_enhanced(pattern_type_a(3 downto 0), counter);
        raw_pattern_b_pipe1 <= generate_pattern_enhanced(pattern_type_b(3 downto 0), counter);
        raw_pattern_c_pipe1 <= generate_pattern_enhanced(pattern_type_c(3 downto 0), counter);
        raw_pattern_d_pipe1 <= generate_pattern_enhanced(pattern_type_d(3 downto 0), counter);
        
        -- Apply frequency divider and phase offset
        scaled_counter_a_pipe1 <= (counter + (phase_offset_a & "00000000")) / freq_div_a;
        scaled_counter_b_pipe1 <= (counter + (phase_offset_b & "00000000")) / freq_div_b;
        scaled_counter_c_pipe1 <= (counter + (phase_offset_c & "00000000")) / freq_div_c;
        scaled_counter_d_pipe1 <= (counter + (phase_offset_d & "00000000")) / freq_div_d;
      end if;
    end if;
  end process;
  
  -- Pipeline Stage 2: Apply amplitude scaling
  process(clk)
    variable temp_mult_a, temp_mult_b, temp_mult_c, temp_mult_d : unsigned(23 downto 0);
  begin
    if rising_edge(clk) then
      if reset_sync = '1' then
        scaled_pattern_a_pipe2 <= (others => '0');
        scaled_pattern_b_pipe2 <= (others => '0');
        scaled_pattern_c_pipe2 <= (others => '0');
        scaled_pattern_d_pipe2 <= (others => '0');
      else
        -- Handle amplitude scaling with proper bit width
        temp_mult_a := raw_pattern_a_pipe1 * amp_scale_a;
        temp_mult_b := raw_pattern_b_pipe1 * amp_scale_b;
        temp_mult_c := raw_pattern_c_pipe1 * amp_scale_c;
        temp_mult_d := raw_pattern_d_pipe1 * amp_scale_d;
        
        scaled_pattern_a_pipe2 <= temp_mult_a(23 downto 8);
        scaled_pattern_b_pipe2 <= temp_mult_b(23 downto 8);
        scaled_pattern_c_pipe2 <= temp_mult_c(23 downto 8);
        scaled_pattern_d_pipe2 <= temp_mult_d(23 downto 8);
      end if;
    end if;
  end process;
  
  -- Pipeline Stage 3: Apply sign control and generate final outputs
  process(clk)
  begin
    if rising_edge(clk) then
      if reset_sync = '1' then
        output_a <= (others => '0');
        output_b <= (others => '0');
        output_c <= (others => '0');
        output_d <= (others => '0');
      else
        -- Apply sign control and generate final outputs
        if sign_control = '0' then
          -- Force unsigned: clear sign bit, keep magnitude (0 to +32767)
          output_a <= signed('0' & scaled_pattern_a_pipe2(14 downto 0));
          output_b <= signed('0' & scaled_pattern_b_pipe2(14 downto 0));
          output_c <= signed('0' & scaled_pattern_c_pipe2(14 downto 0));
          output_d <= signed('0' & scaled_pattern_d_pipe2(14 downto 0));
        else
          -- Allow signed: full range (-32768 to +32767)
          output_a <= signed(scaled_pattern_a_pipe2);
          output_b <= signed(scaled_pattern_b_pipe2);
          output_c <= signed(scaled_pattern_c_pipe2);
          output_d <= signed(scaled_pattern_d_pipe2);
        end if;
      end if;
    end if;
  end process;

end architecture rtl;

