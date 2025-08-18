-- Slot2/top_probe_driver.vhd
-- Top-level CustomWrapper architecture that instantiates the probe_driver module
-- Features a 16-bit TopLevel status register for clean status reporting

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
            Intensity_index   => Control2(15 downto 8),       -- 8-bit Index into IntensityLUT
            
            -- Control3: [31:0] = pulse duration (full 32-bit)
            PulseDuration_in  => Control3(31 downto 0),       -- 32-bit pulse duration
            
            -- Control4: [31:0] = cooldown period (full 32-bit)
            CoolDown_in       => Control4(31 downto 0),       -- 32-bit cooldown period
          
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
