-- HumanInterface_pkg.vhd
-- Human-friendly interface package for testbench display and decoding
-- Provides functions to convert raw register values into human-readable format
-- Designed for educational use and debugging clarity

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

package HumanInterface_pkg is
  
  -- =============================================================================
  -- TIMING CONVERSION FUNCTIONS
  -- =============================================================================
  
  -- Convert clock cycles to human-readable time (assumes 32ns clock period)
  function cycles_to_time(cycles : integer) return string;
  
  -- Convert clock cycles to human-readable time with custom clock period
  function cycles_to_time_custom(cycles : integer; clock_period_ns : integer) return string;
  
  -- =============================================================================
  -- CONTROL REGISTER DECODING FUNCTIONS
  -- =============================================================================
  
  -- Decode Control0 register into human-readable format
  function decode_control0(ctrl : std_logic_vector(31 downto 0)) return string;
  
  -- Decode Control1 register into human-readable format
  function decode_control1(ctrl : std_logic_vector(31 downto 0)) return string;
  
  -- Decode any control register as hex with bit field descriptions
  function decode_control_hex(ctrl : std_logic_vector(31 downto 0); name : string) return string;
  
  -- =============================================================================
  -- STATUS REGISTER DECODING FUNCTIONS
  -- =============================================================================
  
  -- Helper: map state bits to a short name
  function probe_state_to_string(bits : std_logic_vector(3 downto 0)) return string;
  
  -- Decode probe driver status register (5 bits)
  function decode_probe_status(status : std_logic_vector(4 downto 0)) return string;
  
  -- Decode top-level status register (16 bits)
  function decode_toplevel_status(status : std_logic_vector(15 downto 0)) return string;
  
  -- Decode generic status register with custom bit field descriptions
  -- (Future enhancement - not yet implemented)
  
  -- =============================================================================
  -- DISPLAY FORMATTING FUNCTIONS
  -- =============================================================================
  
  -- Create a formatted section header
  function make_header(title : string; width : integer := 60) return string;
  
  -- Create a formatted separator line
  function make_separator(width : integer := 60) return string;
  
  -- Format a value with label and units
  function format_value(label_str : string; value : string; unit_str : string := "") return string;
  
  -- Display complete system status in a formatted block
  function display_system_status(ctrl0, ctrl1 : std_logic_vector(31 downto 0);
                                toplevel_status : std_logic_vector(15 downto 0);
                                probe_status : std_logic_vector(4 downto 0)) return string;
  
  -- =============================================================================
  -- CLOCK DIVIDER DECODING
  -- =============================================================================
  
  -- Decode clock divider selection into human-readable format
  function decode_clock_divider(divider_sel : std_logic_vector(3 downto 0)) return string;
  
  -- =============================================================================
  -- INTENSITY AND DURATION DECODING
  -- =============================================================================
  
  -- Decode intensity value (7-bit, 0-100) with percentage
  function decode_intensity(intensity : std_logic_vector(6 downto 0)) return string;
  
  -- Decode duration value with human-readable time
  function decode_duration(duration : std_logic_vector(15 downto 0)) return string;
  
  -- Decode cooldown value with human-readable time
  function decode_cooldown(cooldown : std_logic_vector(15 downto 0)) return string;
  
end package HumanInterface_pkg;

-- =============================================================================
-- PACKAGE BODY - Implementation of all functions
-- =============================================================================
package body HumanInterface_pkg is
  
  -- =============================================================================
  -- TIMING CONVERSION FUNCTIONS
  -- =============================================================================
  
  function cycles_to_time(cycles : integer) return string is
    variable time_ns : integer;
    variable time_us : integer;
    variable time_ms : integer;
  begin
    time_ns := cycles * 32;  -- Default 32ns per cycle
    if time_ns < 1000 then
      return integer'image(time_ns) & "ns";
    elsif time_ns < 1000000 then
      time_us := time_ns / 1000;
      return integer'image(time_us) & "μs";
    else
      time_ms := time_ns / 1000000;
      return integer'image(time_ms) & "ms";
    end if;
  end function;
  
  function cycles_to_time_custom(cycles : integer; clock_period_ns : integer) return string is
    variable time_ns : integer;
    variable time_us : integer;
    variable time_ms : integer;
  begin
    time_ns := cycles * clock_period_ns;
    if time_ns < 1000 then
      return integer'image(time_ns) & "ns";
    elsif time_ns < 1000000 then
      time_us := time_ns / 1000;
      return integer'image(time_us) & "μs";
    else
      time_ms := time_ns / 1000000;
      return integer'image(time_ms) & "ms";
    end if;
  end function;
  
  -- =============================================================================
  -- CLOCK DIVIDER DECODING
  -- =============================================================================
  
  function decode_clock_divider(divider_sel : std_logic_vector(3 downto 0)) return string is
  begin
    case divider_sel is
      when "0000" => return "No Division";
      when "0001" => return "÷2";
      when "0010" => return "÷4";
      when "0011" => return "÷8";
      when "0100" => return "÷16";
      when "0101" => return "÷32";
      when "0110" => return "÷64";
      when "0111" => return "÷128";
      when "1000" => return "÷256";
      when "1001" => return "÷512";
      when "1010" => return "÷1024";
      when "1011" => return "÷2048";
      when "1100" => return "÷4096";
      when "1101" => return "÷8192";
      when "1110" => return "÷16384";
      when "1111" => return "÷32768";
      when others => return "Invalid";
    end case;
  end function;
  
  -- =============================================================================
  -- INTENSITY AND DURATION DECODING
  -- =============================================================================
  
  function decode_intensity(intensity : std_logic_vector(6 downto 0)) return string is
  begin
    return "Int:" & integer'image(to_integer(unsigned(intensity))) & "%";
  end function;
  
  function decode_duration(duration : std_logic_vector(15 downto 0)) return string is
  begin
    return "Dur:" & cycles_to_time(to_integer(unsigned(duration)));
  end function;
  
  function decode_cooldown(cooldown : std_logic_vector(15 downto 0)) return string is
  begin
    return "Cooldown:" & cycles_to_time(to_integer(unsigned(cooldown)));
  end function;
  
  -- =============================================================================
  -- CONTROL REGISTER DECODING FUNCTIONS
  -- =============================================================================
  
  function decode_control0(ctrl : std_logic_vector(31 downto 0)) return string is
    variable enable_str   : string(1 to 3);
    variable auto_arm_str : string(1 to 8);
    variable trigger_str  : string(1 to 8);
  begin
    if ctrl(31) = '0' then enable_str := "ON "; else enable_str := "OFF"; end if;
    if ctrl(30) = '1' then auto_arm_str := "AutoArm "; else auto_arm_str := "Manual  "; end if;
    if ctrl(23) = '1' then trigger_str := "TRIGGER "; else trigger_str := "NoTrig  "; end if;

    return "0x" & to_hstring(ctrl) & " | Enable:" & enable_str & " | " & auto_arm_str & " | " & decode_clock_divider(ctrl(27 downto 24)) &
           " | " & trigger_str & " | " & decode_intensity(ctrl(22 downto 16)) &
           " | " & decode_duration(ctrl(15 downto 0));
  end function;
  
  function decode_control1(ctrl : std_logic_vector(31 downto 0)) return string is
  begin
    return "0x" & to_hstring(ctrl) & " | " & decode_cooldown(ctrl(31 downto 16)) & " | Reserved:0x" & to_hstring(ctrl(15 downto 0));
  end function;
  
  function decode_control_hex(ctrl : std_logic_vector(31 downto 0); name : string) return string is
  begin
    return "0x" & to_hstring(ctrl) & " | " & name & ":" & to_hstring(ctrl);
  end function;
  
  -- =============================================================================
  -- STATUS REGISTER DECODING FUNCTIONS
  -- =============================================================================
  
  function probe_state_to_string(bits : std_logic_vector(3 downto 0)) return string is
  begin
    -- Check for active states using logical OR (any bit high indicates that state is active)
    if bits(0) = '1' then return "ARMED";
    elsif bits(1) = '1' then return "FIRING";
    elsif bits(2) = '1' then return "PULSE_COMPLETE";
    elsif bits(3) = '1' then return "COOL_DOWN";
    elsif bits = "0000" then return "IDLE";
    else return "UNKNOWN_STATE";
    end if;
  end function;
  
  function decode_probe_status(status : std_logic_vector(4 downto 0)) return string is
  begin
    if status(4) = '1' then
      return "0x" & to_hstring(status) & " | State:" & probe_state_to_string(status(3 downto 0)) & " | ERROR";
    else
      return "0x" & to_hstring(status) & " | State:" & probe_state_to_string(status(3 downto 0)) & " | OK";
    end if;
  end function;
  
  function decode_toplevel_status(status : std_logic_vector(15 downto 0)) return string is
  begin
    if status(15) = '1' then
      return "0x" & to_hstring(status) & " | TopLevel: ERROR | " & probe_state_to_string(status(3 downto 0));
    else
      return "0x" & to_hstring(status) & " | TopLevel: OK | " & probe_state_to_string(status(3 downto 0));
    end if;
  end function;
  
  -- =============================================================================
  -- DISPLAY FORMATTING FUNCTIONS
  -- =============================================================================
  
  function make_header(title : string; width : integer := 60) return string is
    variable header : string(1 to width);
    variable title_start : integer;
  begin
    for i in 1 to width loop
      header(i) := '-';
    end loop;
    title_start := (width - title'length) / 2 + 1;
    header(title_start to title_start + title'length - 1) := title;
    return header;
  end function;
  
  function make_separator(width : integer := 60) return string is
    variable separator : string(1 to width);
  begin
    for i in 1 to width loop
      separator(i) := '-';
    end loop;
    return separator;
  end function;
  
  function format_value(label_str : string; value : string; unit_str : string := "") return string is
  begin
    if unit_str = "" then
      return "   " & label_str & ": " & value;
    else
      return "   " & label_str & ": " & value & " " & unit_str;
    end if;
  end function;
  
  function display_system_status(ctrl0, ctrl1 : std_logic_vector(31 downto 0);
                                toplevel_status : std_logic_vector(15 downto 0);
                                probe_status : std_logic_vector(4 downto 0)) return string is
  begin
    return  LF & "-----------------Status-------------------" & LF &
        "Control0: " & decode_control0(ctrl0) & LF &
           "Control1: " & decode_control1(ctrl1) & LF &
           "TopLevel: " & decode_toplevel_status(toplevel_status) & LF &
           "ProbeDrv: " & decode_probe_status(probe_status) & LF &
                 "------------------------------------------" & LF;

  end function;
  
end package body HumanInterface_pkg;
