-- ProbeDriver.vhd
-- MCC-compatible probe driver architecture for CustomWrapper entity v2.5
-- 
-- REFACTORED: Now follows latest state machine requirements
-- - Uses record-based Status Register records
-- - Implements hybrid approach: VHDL enumerated types internally + Status Register records externally
-- - Uses shared percent_lut_pkg for consistent type definitions
-- 
-- This file provides the complete probe driver implementation as an architecture
-- Note: MCC provides the CustomWrapper entity declaration, we provide the Behavioural architecture
--
-- Date: 2025-01-27
-- Tag: ProbeDriver-v2.5-Using-Latest-Requirements

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.probe_driver_pkg.all;

architecture Behavioural of CustomWrapper is
    -- Internal signals for probe driver outputs
    signal probe_trigger_output : signed(15 downto 0);
    signal probe_intensity_output : signed(15 downto 0);
    signal probe_status_record : status_register_t;
    signal probe_status_register : std_logic_vector(7 downto 0);  -- Converted to std_logic_vector
    
    -- Clock divider signals
    signal probe_clk_en : std_logic;
    
    -- LED Status Signals for visual feedback
    signal status_leds : std_logic_vector(4 downto 0);
    
    -- Control register mapping signals
    signal global_enable : std_logic;
    signal auto_arm : std_logic;
    signal clock_divider_sel : std_logic_vector(3 downto 0);
    signal soft_trigger_raw : std_logic;  -- Raw from control register
    signal soft_trigger : std_logic;      -- Processed (auto-de-asserted)
    signal intensity_index : std_logic_vector(6 downto 0);
    signal pulse_duration : std_logic_vector(15 downto 0);
    signal cooldown_period : std_logic_vector(15 downto 0);
    signal status_clear : std_logic;
    
begin
    -- =============================================================================
    -- CONTROL REGISTER MAPPING
    -- =============================================================================
    -- Control0: [31] = Global enable, [30] = Auto-arm, [29] = Reserved, [28] = Status clear, [27:24] = Clock divider, [23] = Soft trigger, [22:16] = Intensity, [15:0] = Duration
    global_enable <= Control0(31);
    auto_arm <= Control0(30);
    status_clear <= Control0(28);  -- Status clear (clears sticky flags and LEDs)
    clock_divider_sel <= Control0(27 downto 24);
    soft_trigger_raw <= Control0(23);  -- Raw control register bit (auto-de-asserted after 1 cycle)
    intensity_index <= Control0(22 downto 16);
    pulse_duration <= Control0(15 downto 0);
    
    -- Control1: [31:16] = Cooldown, [15:0] = Reserved
    cooldown_period <= Control1(31 downto 16);
    
    -- =============================================================================
    -- STATUS RECORD TO STD_LOGIC_VECTOR CONVERSION
    -- =============================================================================
    -- Convert record-based status register to std_logic_vector for external interface
    probe_status_register(0) <= probe_status_record.ready;
    probe_status_register(1) <= probe_status_record.armed;
    probe_status_register(2) <= probe_status_record.firing;
    probe_status_register(3) <= probe_status_record.cooldown;
    probe_status_register(4) <= probe_status_record.error;
    probe_status_register(5) <= probe_status_record.reserved_5;
    probe_status_register(6) <= probe_status_record.reserved_6;
    probe_status_register(7) <= probe_status_record.reserved_7;
    
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
                    status_leds(0) <= '1';  -- READY LED
                end if;
                
                if probe_status_register(1) = '1' then
                    status_leds(1) <= '1';  -- ARMED LED
                end if;
                
                if probe_status_register(2) = '1' then
                    status_leds(2) <= '1';  -- FIRING LED
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
    -- SOFT TRIGGER DE-ASSERTION PROCESS
    -- =============================================================================
    -- Automatically de-assert soft trigger after one clock cycle to prevent
    -- multiple probe firings from a single control register write
    soft_trigger_process: process(Clk)
    begin
        if rising_edge(Clk) then
            if Reset = '1' then
                soft_trigger <= '0';
            else
                -- Set trigger high when control register goes high
                if soft_trigger_raw = '1' then
                    soft_trigger <= '1';
                else
                    -- De-assert after one cycle (unless control register is still high)
                    soft_trigger <= '0';
                end if;
            end if;
        end if;
    end process soft_trigger_process;
    
    -- =============================================================================
    -- CLOCK DIVIDER INSTANTIATION
    -- =============================================================================
    -- Instantiate the unified ClockDivider module
    u_clk_divider: entity work.clock_divider
        generic map (
            DIVIDER_WIDTH => 4,               -- 4-bit divider for ProbeDriver (CR0[27:24])
            MAX_DIVIDER => 15
        )
        port map (
            clk_in      => Clk,
            reset       => Reset,
            divider     => clock_divider_sel,  -- 4-bit divider value
            enable      => '1',                -- Always enabled
            clk_out     => open,               -- Not used in ProbeDriver
            clk_out_en  => probe_clk_en        -- Clock enable for ProbeDriver
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
            probe_status_register  => probe_status_record -- Pass the record to the core
        );
    
    -- =============================================================================
    -- OUTPUT ASSIGNMENTS
    -- =============================================================================
    -- OutputA: Direct mapping of probe driver status register (8 bits)
    -- [7:5] = Reserved for future use (set to 0), [4:0] = State machine status
    OutputA <= signed("00000000" & probe_status_register);
    
    -- OutputB: Show ProbeTrigger_Threshold when firing bit (bit 2) is set in status register
    OutputB <= x"4000" when probe_status_register(2) = '1' else (others => '0');
    
    -- OutputC: Probe intensity output (only valid during FIRING state, otherwise shows 0)
    OutputC <= probe_intensity_output;
    
    -- OutputD: Reserved for future use
    OutputD <= (others => '0');
    
end architecture Behavioural;
