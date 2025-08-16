-- Slot2/top_probe_driver.vhd
-- Top-level CustomWrapper architecture that instantiates the probe_driver module

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
    -- OUTPUT ASSIGNMENTS
    -- =============================================================================
    -- OutputA: Show probe trigger threshold when probe is firing, otherwise show intensity
    -- Note: probe_intensity_out is only valid during FIRING state, otherwise shows 0
    OutputA <= probe_intensity_out;
    
    -- OutputB: Show probe intensity when firing, otherwise zero
    OutputB <= probe_intensity_out when probe_trig_out = ProbeTrigger_Threshold else (others => '0');
    
    -- OutputC: Echo back Control0(15:0), Control1(7:0), 3 zeros, and status register
    -- Note: OutputC is 16 bits, so we select the most relevant portion
    -- Include Control0(10:0) and status register for meaningful 16-bit output
    OutputC <= signed(Control0(10 downto 0) & probe_driver_status_register);
    
    -- OutputD: Status and control information for debugging/monitoring
    -- [15:8] = probe driver status register (5 bits + 3 padding), [7:0] = control state
    OutputD <= signed("000000000" & probe_driver_status_register & Control1(14 downto 13));

end architecture Behavioural;
