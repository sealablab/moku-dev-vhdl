-- ProbeDriver_Top.vhd
-- Top-level module implementing the CustomWrapper interface for MCC synthesis
-- This module instantiates the refactored ProbeDriver architecture
-- 
-- REFACTORED: Uses the new 3-tier architecture:
--   - probe_driver_wrapper (interface layer)
--   - probe_driver_core (state machine)
--   - probe_driver_pkg (shared package)
--
-- Date: 2025-01-27
-- Tag: ProbeDriver-v1.0-Refactored

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity CustomWrapper is
    port (
        -- Clock and Reset
        Clk : in std_logic;
        Reset : in std_logic;
        
        -- Input ports (platform-specific)
        InputA : in signed(15 downto 0);
        InputB : in signed(15 downto 0);
        InputC : in signed(15 downto 0);
        InputD : in signed(15 downto 0);
        
        -- Output ports (platform-specific)
        OutputA : out signed(15 downto 0);
        OutputB : out signed(15 downto 0);
        OutputC : out signed(15 downto 0);
        OutputD : out signed(15 downto 0);
        
        -- Control registers (16 x 32-bit)
        Control0 : in std_logic_vector(31 downto 0);
        Control1 : in std_logic_vector(31 downto 0);
        Control2 : in std_logic_vector(31 downto 0);
        Control3 : in std_logic_vector(31 downto 0);
        Control4 : in std_logic_vector(31 downto 0);
        Control5 : in std_logic_vector(31 downto 0);
        Control6 : in std_logic_vector(31 downto 0);
        Control7 : in std_logic_vector(31 downto 0);
        Control8 : in std_logic_vector(31 downto 0);
        Control9 : in std_logic_vector(31 downto 0);
        Control10 : in std_logic_vector(31 downto 0);
        Control11 : in std_logic_vector(31 downto 0);
        Control12 : in std_logic_vector(31 downto 0);
        Control13 : in std_logic_vector(31 downto 0);
        Control14 : in std_logic_vector(31 downto 0);
        Control15 : in std_logic_vector(31 downto 0)
    );
end entity CustomWrapper;

architecture Behavioural of CustomWrapper is
    -- Internal signals for probe driver outputs
    signal probe_trigger_output : signed(15 downto 0);
    signal probe_intensity_output : signed(15 downto 0);
    signal probe_status_register : std_logic_vector(15 downto 0);
    
    -- Clock divider signals
    signal probe_clk_en : std_logic;
    
    -- LED Status Signals for visual feedback
    signal status_leds : std_logic_vector(4 downto 0);
    
    -- Control register mapping signals
    signal global_enable : std_logic;
    signal auto_arm : std_logic;
    signal clock_divider_sel : std_logic_vector(3 downto 0);
    signal soft_trigger : std_logic;
    signal intensity_index : std_logic_vector(6 downto 0);
    signal pulse_duration : std_logic_vector(15 downto 0);
    signal cooldown_period : std_logic_vector(15 downto 0);
    signal status_clear : std_logic;
    
begin
    -- =============================================================================
    -- CONTROL REGISTER MAPPING
    -- =============================================================================
    -- Control0: [31] = Global enable, [30] = Auto-arm, [27:24] = Clock divider, [23] = Soft trigger, [22:16] = Intensity, [15:0] = Duration
    global_enable <= Control0(31);
    auto_arm <= Control0(30);
    clock_divider_sel <= Control0(27 downto 24);
    soft_trigger <= Control0(23);
    intensity_index <= Control0(22 downto 16);
    pulse_duration <= Control0(15 downto 0);
    
    -- Control1: [31:16] = Cooldown, [15] = Status clear (clears sticky flags and LEDs), [14:0] = Reserved
    cooldown_period <= Control1(31 downto 16);
    status_clear <= Control1(15);
    
    -- =============================================================================
    -- STATUS LED LATCH LOGIC
    -- =============================================================================
    -- LED Status Latch Logic - provides visual feedback for probe driver states
    led_status_process: process(Clk)
    begin
        if rising_edge(Clk) then
            if Reset = '1' then
                -- Clear all LED signals on system reset
                status_leds <= (others => '0');
            elsif status_clear = '1' then
                -- Clear all LED signals on LED reset via Control1[15]
                status_leds <= (others => '0');
            else
                -- Latch logic: set LED high when status bit goes high
                if probe_status_register(0) = '1' then
                    status_leds(0) <= '1';  -- ARMED LED
                end if;
                
                if probe_status_register(1) = '1' then
                    status_leds(1) <= '1';  -- FIRING LED
                end if;
                
                if probe_status_register(2) = '1' then
                    status_leds(2) <= '1';  -- FIRED LED (pulse completed)
                end if;
                
                if probe_status_register(3) = '1' then
                    status_leds(3) <= '1';  -- COOL_DOWN LED
                end if;
                
                if probe_status_register(4) = '1' then
                    status_leds(4) <= '1';  -- ERROR LED
                end if;
            end if;
        end if;
    end process led_status_process;
    
    -- =============================================================================
    -- CLOCK DIVIDER INSTANTIATION
    -- =============================================================================
    -- Instantiate the clk_divider module
    u_clk_divider: entity work.clk_divider
        port map (
            clk_in      => Clk,
            reset       => Reset,
            divider_sel => clock_divider_sel,  -- CR0[27:24] controls divider
            clk_en      => probe_clk_en        -- Clock enable for ProbeDriver
        );
    
    -- =============================================================================
    -- PROBE DRIVER CORE INSTANTIATION
    -- =============================================================================
    -- Instantiate the probe_driver_core entity
    u_probe_driver_core: entity work.probe_driver_core
        port map (
            -- Clock and Control
            clk                    => Clk,
            reset                  => Reset,
            enable                 => global_enable,      -- Enable when Control0(31) = '1'
            clk_en                 => probe_clk_en,      -- Clock enable from divider
            status_clear           => status_clear,
            
            -- Configuration
            config_intensity_index => intensity_index,   -- 7-bit Index into IntensityLUT
            config_pulse_duration  => pulse_duration,    -- 16-bit pulse duration
            config_cooldown_period => cooldown_period,    -- 16-bit cooldown period
            
            -- Input Signals
            probe_trigger_input    => soft_trigger,      -- Soft trigger from Control0(23)
            probe_auto_arm         => auto_arm,          -- Auto-arm feature from Control0(30)
            
            -- Output Signals
            probe_trigger_output   => probe_trigger_output,
            probe_intensity_output => probe_intensity_output,
            probe_status_register  => probe_status_register
        );
    
    -- =============================================================================
    -- OUTPUT ASSIGNMENTS
    -- =============================================================================
    -- OutputA: Direct mapping of expanded probe driver status register (16 bits)
    -- [15:5] = Reserved for future use (set to 0), [4:0] = State machine status
    OutputA <= signed(probe_status_register);
    
    -- OutputB: Show ProbeTrigger_Threshold when firing bit (bit 1) is set in status register
    OutputB <= x"4000" when probe_status_register(1) = '1' else (others => '0');
    
    -- OutputC: Probe intensity output (only valid during FIRING state, otherwise shows 0)
    OutputC <= probe_intensity_output;
    
    -- OutputD: Reserved for future use
    OutputD <= (others => '0');
    
end architecture Behavioural;
