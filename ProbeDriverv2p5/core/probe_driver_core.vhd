-- probe_driver_core.vhd
-- Enhanced implementation with more features for ProbeDriver v2.5
-- 
-- REFACTORED: Now follows latest state machine requirements
-- - Uses record-based Status Register records
-- - Implements hybrid approach: VHDL enumerated types internally + Status Register records externally
-- - Follows established architecture standards

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.probe_driver_pkg.all;

entity probe_driver_core is
    port (
        clk                    : in  std_logic;
        reset                  : in  std_logic;
        enable                 : in  std_logic;
        clk_en                 : in  std_logic;
        status_clear           : in  std_logic;  -- Added
        
        config_intensity_index : in  probe_intensity_index_type;
        config_pulse_duration  : in  probe_duration_type;
        config_cooldown_period : in  probe_cooldown_type;
        
        probe_trigger_input    : in  std_logic;
        probe_auto_arm         : in  std_logic;  -- Added
        
        probe_trigger_output   : out signed(15 downto 0);
        probe_intensity_output : out signed(15 downto 0);
        probe_status_register  : out status_register_t
    );
end entity;

architecture rtl of probe_driver_core is
    -- State machine signal
    signal current_state : probe_state_type := IDLE;
    
    -- Internal counters and signals
    signal pulse_counter : unsigned(15 downto 0) := (others => '0');
    signal cooldown_counter : unsigned(15 downto 0) := (others => '0');
    
    -- Status register signal
    signal status_reg : status_register_t;
    
begin
    -- =============================================================================
    -- STATE MACHINE IMPLEMENTATION
    -- =============================================================================
    state_machine: process(clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state <= IDLE;
                pulse_counter <= (others => '0');
                cooldown_counter <= (others => '0');
            elsif clk_en = '1' then
                case current_state is
                    when IDLE =>
                        if enable = '1' then
                            current_state <= ARMED;
                        end if;
                        
                    when ARMED =>
                        if probe_trigger_input = '1' then
                            current_state <= FIRING;
                            pulse_counter <= (others => '0');
                        elsif enable = '0' then
                            current_state <= IDLE;
                        end if;
                        
                    when FIRING =>
                        if pulse_counter >= unsigned(config_pulse_duration) then
                            current_state <= COOL_DOWN;
                            cooldown_counter <= (others => '0');
                        else
                            pulse_counter <= pulse_counter + 1;
                        end if;
                        
                    when COOL_DOWN =>
                        if cooldown_counter >= unsigned(config_cooldown_period) then
                            if probe_auto_arm = '1' then
                                current_state <= ARMED;
                            else
                                current_state <= IDLE;
                            end if;
                        else
                            cooldown_counter <= cooldown_counter + 1;
                        end if;
                        
                    when others =>
                        current_state <= IDLE;
                end case;
            end if;
        end if;
    end process state_machine;
    
    -- =============================================================================
    -- STATUS REGISTER MAPPING
    -- =============================================================================
    -- Map internal state to status register fields
    status_reg.ready <= '1' when current_state = IDLE else '0';
    status_reg.armed <= '1' when current_state = ARMED else '0';
    status_reg.firing <= '1' when current_state = FIRING else '0';
    status_reg.cooldown <= '1' when current_state = COOL_DOWN else '0';
    status_reg.error <= '0';  -- Set based on error conditions
    status_reg.reserved_5 <= '0';  -- Reserved bits always '0'
    status_reg.reserved_6 <= '0';  -- Reserved bits always '0'
    status_reg.reserved_7 <= '0';  -- Reserved bits always '0'
    
    -- =============================================================================
    -- OUTPUT ASSIGNMENTS
    -- =============================================================================
    -- Status register output
    probe_status_register <= status_reg;
    
    -- Probe trigger output (active during FIRING state)
    probe_trigger_output <= x"7FFF" when current_state = FIRING else (others => '0');
    
    -- Probe intensity output (only valid during FIRING state)
    probe_intensity_output <= get_intensity_output(config_intensity_index) when current_state = FIRING else (others => '0');
    
end architecture rtl;
