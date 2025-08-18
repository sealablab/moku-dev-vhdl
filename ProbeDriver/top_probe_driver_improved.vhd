-- Updated top_probe_driver_improved.vhd with new Control Register layout
-- Top-level CustomWrapper architecture that instantiates the probe_driver module
-- Features a 16-bit TopLevel status register for clean status reporting
-- 
-- Control Register Layout (matching README_ImprovedControlRegisters.md):
-- Control0: [31] = Global enable, [23] = Soft trigger, [22:16] = 7-bit intensity, [15:0] = 16-bit duration
-- Control1: [31:16] = 16-bit cooldown, [15:0] = Reserved

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
    -- ProbeDriverStatusRegister (PDSR)
    signal probe_driver_status_register : std_logic_vector(4 downto 0);
    -- TopLevel Status Register (16 bits)
    signal toplevel_status_register : std_logic_vector(15 downto 0);    
begin
    -- =============================================================================
    -- PROBE DRIVER INSTANTIATION
    -- =============================================================================
    -- Instantiate the probe_driver entity
    u_probe_driver: entity work.probe_driver
        port map (
            clk            => Clk,

            -- UPDATED CONTROL REGISTER LAYOUT (matching README_ImprovedControlRegisters.md):
            -- Control0: [31:0] = CR0 (32 bits)
            -- [31]    = Global enable bit (mapped to both 'top' and 'probedriver' enable inputs)
            -- [23]    = Soft trigger in
            -- [22:16] = 7-bit intensity index (0-100)
            -- [15:0]  = 16-bit duration_in
            
            -- Control1: [31:0] = CR1 (32 bits)  
            -- [31:16] = 16-bit CoolDown-in
            -- [15:0]  = Reserved for future use
            
            -- Note: Reset, enable, and trigger will be handled later as mentioned in requirements
            reset          => '0',                              -- TODO: Map to appropriate control bit
            enable         => '1',                              -- TODO: Map to Control0(31) global enable
            trig_in        => '0',                              -- TODO: Map to Control0(23) soft trigger
            
            -- =============================================================================
            -- IMPLEMENTATION STATUS:
            -- =============================================================================
            -- ✅ COMPLETED: Intensity, Duration, and Cooldown mapping to new CR0/CR1 layout
            -- ✅ COMPLETED: All width mismatches resolved (7-bit intensity, 16-bit duration/cooldown)
            -- ❌ TODO: Implement reset, enable, and trigger signal mapping
            -- ❌ TODO: Connect Control0(31) to global enable logic
            -- ❌ TODO: Connect Control0(23) to soft trigger logic
            -- ❌ TODO: Determine appropriate reset signal source
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
    -- TOPLEVEL STATUS REGISTER CONSTRUCTION
    -- =============================================================================
    -- Construct 16-bit TopLevel status register
    -- [15] = Error bit (probe driver status register bit 4)
    -- [14:4] = Reserved for future use (set to 0)
    -- [3:0] = Probe driver status register bits [3:0] (state machine status)
    toplevel_status_register <= probe_driver_status_register(4) & 
                               "00000000000" & 
                               probe_driver_status_register(3 downto 0);
    
    -- =============================================================================
    -- OUTPUT ASSIGNMENTS
    -- =============================================================================
    -- OutputA: TopLevel status register (16 bits)
    -- [15] = Error bit, [14:4] = Reserved, [3:0] = State machine status
    OutputA <= signed(toplevel_status_register);
    
    -- OutputB: Show ProbeTrigger_Threshold when firing bit (bit 1) is set in status register
    OutputB <= ProbeTrigger_Threshold when toplevel_status_register(1) = '1' else (others => '0');
    
    -- OutputC: Probe intensity output (only valid during FIRING state, otherwise shows 0)
    OutputC <= probe_intensity_out;

end architecture Behavioural;
