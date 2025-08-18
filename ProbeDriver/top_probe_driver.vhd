-- Official top_probe_driver.vhd with improved Control Register layout
-- Top-level CustomWrapper architecture that instantiates the probe_driver module
-- Features a 16-bit TopLevel status register for clean status reporting
-- GIT tag 0.99.1 ?
-- Control0:  [31] = Global enable, 
-- Control0:  [23] = Soft trigger, [22:16] = 7-bit intensity, 
-- Control0: [15:0] = 16-bit duration
-- Control1: [31:16] = 16-bit cooldown,
-- Control1: [15:0] = Reserved

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.IntensityLut_pkg.all;
use work.ProbeConfig_pkg.all;

-- =============================================================================
-- ARCHITECTURE - Implementation that instantiates probe_driver
-- =============================================================================
architecture Behavioural of CustomWrapper is
    -- Internal signals for probe driver outputs
    signal probe_trig_out : signed(15 downto 0);
    signal probe_intensity_out : signed(15 downto 0);
    -- ProbeDriverStatusRegister (PDSR) - Expanded to 16 bits
    signal probe_driver_status_register : std_logic_vector(15 downto 0);
    -- NEW: Clock divider signals
    signal probe_clk_en : std_logic;
begin
    -- =============================================================================
    -- CLOCK DIVIDER INSTANTIATION
    -- =============================================================================
    -- Instantiate the clk_divider module
    u_clk_divider: entity work.clk_divider
        port map (
            clk_in      => Clk,
            reset       => Reset,
            divider_sel => Control0(27 downto 24),  -- NEW: CR0[27:24] controls divider
            clk_en      => probe_clk_en             -- NEW: Clock enable for ProbeDriver
        );
    
    -- =============================================================================
    -- PROBE DRIVER INSTANTIATION
    -- =============================================================================
    -- Instantiate the probe_driver entity
    u_probe_driver: entity work.probe_driver
        port map (
            clk            => Clk,
            clk_en         => probe_clk_en,      -- NEW: Clock enable from divider

            -- UPDATED CONTROL REGISTER LAYOUT (matching README_ImprovedControlRegisters.md):
            -- Control0: [31:0] = CR0 (32 bits)
            -- [31]    = Global enable bit (mapped to 'probedriver' enable input)
            -- [30]    = Auto-arm feature (NEW: skip IDLE state, go directly to ARMED after cooldown)
            -- [27:24] = Clock divider selection (NEW: 0=no division, 1=÷2, 2=÷4, ..., 15=÷32768)
            -- [23]    = Soft trigger in
            -- [22:16] = 7-bit intensity index (0-100)
            -- [15:0]  = 16-bit duration_in
            
            -- Control1: [31:0] = CR1 (32 bits)  
            -- [31:16] = 16-bit CoolDown-in
            -- [15:0]  = Reserved for future use
            
            -- Reset from external top-level Reset input; Enable is inverted Control0(31); Trigger from Control0(23)
            reset          => Reset,
            enable         => not Control0(31),  -- Enable when Control0(31) = '0' (auto-fire with safe defaults)
            trig_in        => Control0(23),
            auto_arm       => Control0(30),      -- NEW: Auto-arm feature from CR0[30]
            
            -- =============================================================================
            -- ENABLE LOGIC EXPLANATION:
            -- =============================================================================
            -- The enable signal is inverted from Control0(31) so that:
            -- - When Control0(31) = '0': Module is ENABLED and auto-fires with safe defaults
            -- - When Control0(31) = '1': Module is DISABLED (safety off mode)
            -- This creates intuitive behavior: 0x00 = "on with safe defaults", 0x01 = "off"
            -- =============================================================================
            
            -- Intensity: 7-bit index into IntensityLUT (0-100)
            Intensity_index   => Control0(22 downto 16),       -- 7-bit Index into IntensityLUT
            
            -- Duration: 16-bit pulse duration (clock cycles)
            PulseDuration_in  => Control0(15 downto 0),        -- 16-bit pulse duration
            
            -- Cooldown: 16-bit cooldown period (clock cycles)  
            CoolDown_in       => Control1(31 downto 16),       -- 16-bit cooldown period
          
            trig_out          => probe_trig_out,               -- Capture trigger output
            intensity_out     => probe_intensity_out,          -- Capture intensity output
            status_register   => probe_driver_status_register  -- Capture status register
        );
    
    -- =============================================================================
    -- IMPLEMENTATION STATUS:
    -- =============================================================================
    -- ✅ COMPLETED: Intensity, Duration, and Cooldown mapping to new CR0/CR1 layout
    -- ✅ COMPLETED: All width mismatches resolved (7-bit intensity, 16-bit duration/cooldown)
    -- ✅ COMPLETED: Reset, enable, and trigger signal mapping implemented
    -- ✅ COMPLETED: Control0(31) inverted for intuitive enable logic (0x00 = on, 0x01 = off)
    -- ✅ COMPLETED: Control0(23) connected to soft trigger logic
    -- ✅ COMPLETED: Auto-fire feature enabled when Control0(31) = '0' (safe defaults mode)
    -- ✅ COMPLETED: NEW: Auto-arm feature from Control0(30) - skip IDLE state after cooldown
    -- ✅ COMPLETED: NEW: Simplified state machine - removed FIRED state, status tracked via register
    -- ✅ COMPLETED: NEW: Clock divider integration from CR0[27:24] - flexible timing control
    -- =============================================================================
    
    -- =============================================================================
    -- OUTPUT ASSIGNMENTS
    -- =============================================================================
    -- OutputA: Direct mapping of expanded probe driver status register (16 bits)
    -- [15:5] = Reserved for future use (set to 0), [4:0] = State machine status
    OutputA <= signed(probe_driver_status_register);
    
    -- OutputB: Show ProbeTrigger_Threshold when firing bit (bit 1) is set in status register
    OutputB <= ProbeTrigger_Threshold when probe_driver_status_register(1) = '1' else (others => '0');
    
    -- OutputC: Probe intensity output (only valid during FIRING state, otherwise shows 0)
    OutputC <= probe_intensity_out;

end architecture Behavioural;
