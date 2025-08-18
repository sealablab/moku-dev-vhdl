-- Slot2/top_probe_driver.vhd
-- Top-level CustomWrapper architecture that instantiates the probe_driver module
-- Features a 16-bit TopLevel status register for clean status reporting
-- 
-- UPDATED: Modified to match new ProbeDriver.vhd bit widths:
-- - Intensity_index: 7 bits (Control2[15:9]) for 0-100 range
-- - PulseDuration_in: 16 bits (Control3[31:16]) padded to 32 bits
-- - CoolDown_in: 16 bits (Control4[31:16]) padded to 32 bits

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

            -- Control0 RESERVED for the TOP file (32 bits)
                -- Control1: [31:16] = reserved, [15:13] = control, [12:8] = mode, [7:0] = status readback
    reset          => Control1(15),                    -- Reset signal (also used to reload parameters)
    enable         => Control1(14),                    -- Enable signal
    trig_in        => Control1(13),                    -- Trigger input signal
            
            -- Control2: [31:16] = reserved, [15:8] = intensity, [7:0] = reserved
            Intensity_index   => Control2(15 downto 9),       -- 7-bit Index into IntensityLUT (0-100)
            
            -- Control3: [31:16] = pulse duration (16-bit), [15:0] = reserved
            PulseDuration_in  => Control3(31 downto 16) & x"0000",  -- 16-bit pulse duration (padded to 32)
            
            -- Control4: [31:16] = cooldown period (16-bit), [15:0] = reserved
            CoolDown_in       => x"0000" & Control4(31 downto 16),  -- 16-bit cooldown period (padded to 32)
          
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
    
    -- TODO: Maybe we should think about some Top-Level CR0 bits to aid in debugging. Something Like a YOLO bit?
	-- TODO: Impement 'YOLO' BIT
    -- =============================================================================
    -- OUTPUT ASSIGNMENTS
    OutputA <= signed(toplevel_status_register);
    -- OutputB: Show ProbeTrigger_Threshold when firing bit (bit 1) is set in status register
    OutputB <= ProbeTrigger_Threshold when toplevel_status_register(1) = '1' else (others => '0');
    OutputC <= probe_intensity_out;


    -- =============================================================================
    -- OutputA: Show probe trigger threshold when probe is firing, otherwise show intensity
    -- Note: probe_intensity_out is only valid during FIRING state, otherwise shows 0
    
    -- OutputB: Show probe intensity when firing, otherwise zero
    
    
    -- OutputC: TopLevel status register (16 bits)
    -- [15] = Error bit, [14:4] = Reserved, [3:0] = State machine status
  -- XX moved on purpose

end architecture Behavioural;
