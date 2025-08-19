-- probe_driver_core.vhd
-- Core state machine implementation for the probe driver
-- REFACTORED: Simple state machine with accurate status register reflection
-- Follows VHDL-2008 standards and industry best practices

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.probe_driver_pkg.all;
use work.IntensityLut_pkg.all;

entity probe_driver_core is
    port (
        -- Clock and Control
        clk                    : in  std_logic;
        reset                  : in  std_logic;
        enable                 : in  std_logic;
        clk_en                 : in  std_logic;
        
        -- Configuration
        config_intensity_index : in  probe_intensity_index_type;
        config_pulse_duration  : in  probe_duration_type;
        config_cooldown_period : in  probe_cooldown_type;
        
        -- Input Signals
        probe_trigger_input    : in  std_logic;
        probe_auto_arm         : in  std_logic;
        
        -- Output Signals
        probe_trigger_output   : out signed(15 downto 0);
        probe_intensity_output : out signed(15 downto 0);
        probe_status_register  : out probe_status_type
    );
end entity probe_driver_core;

architecture rtl of probe_driver_core is
    -- Internal signals using consistent naming
    signal current_state : probe_state_type := IDLE;
    signal pulse_counter : unsigned(15 downto 0) := (others => '0');
    signal cooldown_counter : unsigned(15 downto 0) := (others => '0');
    signal general_counter : signed(15 downto 0) := (others => '0');
    
    -- Configuration signals with safe defaults
    signal intensity_index : probe_intensity_index_type;
    signal pulse_duration : probe_duration_type;
    signal cooldown_period : probe_cooldown_type;
    
    -- Status register - reflects current state
    signal status_reg : probe_status_type := (others => '0');
    
    -- Auto-fire on reset: fires once using safe defaults after first enable
    signal reset_fired : std_logic := '0';
    
begin
    -- =============================================================================
    -- CLOCKED PROCESS - State machine with status register updates
    -- =============================================================================
    state_machine: process(clk) 
    begin
        if rising_edge(clk) and clk_en = '1' then
            if reset = '1' then
                -- Reset logic
                current_state <= IDLE;
                pulse_counter <= (others => '0');
                cooldown_counter <= (others => '0');
                general_counter <= (others => '0');
                status_reg <= (others => '0');
                reset_fired <= '0';
                
                -- Apply safe defaults using package functions
                intensity_index <= get_safe_intensity_index(config_intensity_index);
                pulse_duration <= get_safe_duration(config_pulse_duration);
                cooldown_period <= get_safe_cooldown(config_cooldown_period);
                
            else
                -- State machine logic
                case current_state is
                    when IDLE =>
                        -- Wait for enable signal
                        if enable = '1' then
                            -- After reset, automatically go to ARMED state
                            if reset_fired = '0' then
                                -- Auto-arm: go directly to ARMED state
                                current_state <= ARMED;
                                pulse_counter <= (others => '0');
                                reset_fired <= '1';
                                -- Update status register
                                status_reg <= "0000000000000001";  -- Only bit 0 set (ARMED)
                            else
                                -- Normal: go to ARMED state
                                current_state <= ARMED;
                                pulse_counter <= (others => '0');
                                -- Update status register
                                status_reg <= "0000000000000001";  -- Only bit 0 set (ARMED)
                            end if;
                        end if;
                        
                    when ARMED =>
                        -- Wait for trigger input
                        if probe_trigger_input = '1' then
                            current_state <= FIRING;
                            pulse_counter <= unsigned(pulse_duration);
                            -- Update status register
                            status_reg <= "0000000000000010";  -- Only bit 1 set (FIRING)
                        end if;
                        
                    when FIRING =>
                        -- Actively firing the probe with duration
                        if pulse_counter = 0 then
                                                    -- Duration complete, move to COOL_DOWN
                        current_state <= COOL_DOWN;
                        cooldown_counter <= (others => '0');
                        -- Update status register - use explicit bit assignment
                        status_reg <= "0000000000001000";  -- Only bit 3 set (COOL_DOWN)
                        else
                            -- Decrement counter
                            pulse_counter <= pulse_counter - 1;
                        end if;
                        
                    when COOL_DOWN =>
                        -- Wait for cooldown period
                        if cooldown_counter >= unsigned(cooldown_period) then
                            -- Cooldown complete
                            if probe_auto_arm = '1' then
                                -- Auto-arm: go directly to ARMED
                                current_state <= ARMED;
                                -- Update status register
                                status_reg <= "0000000000000001";  -- Only bit 0 set (ARMED)
                            else
                                -- Normal behavior: go to IDLE
                                current_state <= IDLE;
                                -- Update status register
                                status_reg <= "0000000000000000";  -- All bits clear (IDLE)
                            end if;
                        else
                            cooldown_counter <= cooldown_counter + 1;
                        end if;
                        
                    when others =>
                        current_state <= IDLE;
                        status_reg <= (others => '0');
                end case;
                
                -- Update general counter when enabled
                if enable = '1' then
                    general_counter <= general_counter + 1;
                end if;
            end if;
        end if;
    end process state_machine;
    
    -- =============================================================================
    -- OUTPUT LOGIC - Combinational output assignments based on current state
    -- =============================================================================
    -- Trigger output: active only during FIRING state
    probe_trigger_output <= PROBE_TRIGGER_THRESHOLD when current_state = FIRING else (others => '0');
    
    -- Intensity output: from LUT during FIRING state
    probe_intensity_output <= IntensityLut(to_integer(unsigned(intensity_index))) when current_state = FIRING else (others => '0');
    
    -- Status register output
    probe_status_register <= status_reg;
    
end architecture rtl;
