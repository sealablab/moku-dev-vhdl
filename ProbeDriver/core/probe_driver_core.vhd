-- probe_driver_core.vhd
-- Core state machine implementation for the probe driver
-- REFACTORED: Pure state machine logic, no interface concerns
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
    
    -- Status register
    signal status_reg : probe_status_type := (others => '0');
    
    -- Auto-fire on reset: fires once using safe defaults after first enable
    signal reset_fired : std_logic := '0';
    
begin
    -- =============================================================================
    -- CLOCKED PROCESS - State machine and timing logic
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
                            current_state <= ARMED;
                            pulse_counter <= (others => '0');
                            status_reg <= set_probe_status_bit(status_reg, 0, '1');  -- Set bit 0 when entering ARMED
                            
                            -- Auto-fire once on first enable after reset
                            if reset_fired = '0' then
                                reset_fired <= '1';
                            end if;
                        end if;
                        
                    when ARMED =>
                        -- Wait for trigger input OR auto-advance on first fire after reset
                        if probe_trigger_input = '1' or (reset_fired = '0') then
                            current_state <= FIRING;
                            -- Initialize pulse counter to duration value
                            pulse_counter <= unsigned(pulse_duration);
                            status_reg <= set_probe_status_bit(status_reg, 1, '1');  -- Set bit 1 when entering FIRING
                        end if;
                        
                    when FIRING =>
                        -- Actively firing the probe with duration
                        if pulse_counter = 0 then
                            -- Duration complete, move directly to COOL_DOWN
                            current_state <= COOL_DOWN;
                            cooldown_counter <= (others => '0');
                            status_reg <= set_probe_status_bit(status_reg, 2, '1');  -- Set bit 2 to indicate pulse completed
                            status_reg <= set_probe_status_bit(status_reg, 3, '1');  -- Set bit 3 when entering COOL_DOWN
                        else
                            -- Decrement counter
                            pulse_counter <= pulse_counter - 1;
                        end if;
                        
                    when COOL_DOWN =>
                        -- Wait for cooldown period
                        if cooldown_counter >= unsigned(cooldown_period) then
                            -- Auto-arm logic - if auto_arm is enabled, go directly to ARMED
                            if probe_auto_arm = '1' then
                                current_state <= ARMED;
                                status_reg <= set_probe_status_bit(status_reg, 0, '1');  -- Set bit 0 when entering ARMED
                                status_reg <= set_probe_status_bit(status_reg, 3, '0');  -- Clear bit 3 when leaving COOL_DOWN
                            else
                                -- Normal behavior: go to IDLE
                                current_state <= IDLE;
                                status_reg <= set_probe_status_bit(status_reg, 3, '0');  -- Clear bit 3 when leaving COOL_DOWN
                            end if;
                        else
                            cooldown_counter <= cooldown_counter + 1;
                        end if;
                        
                    when others =>
                        current_state <= IDLE;
                end case;
                
                -- Update general counter when enabled
                if enable = '1' then
                    general_counter <= general_counter + 1;
                end if;
            end if;
        end if;
    end process state_machine;
    
    -- =============================================================================
    -- OUTPUT LOGIC - Combinational output assignments
    -- =============================================================================
    -- Trigger output: active only during FIRING state
    probe_trigger_output <= PROBE_TRIGGER_THRESHOLD when current_state = FIRING else (others => '0');
    
    -- Intensity output: from LUT during FIRING state
    probe_intensity_output <= IntensityLut(to_integer(unsigned(intensity_index))) when current_state = FIRING else (others => '0');
    
    -- Status register output
    probe_status_register <= status_reg;
    
end architecture rtl;
