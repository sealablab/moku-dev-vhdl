-- Slot2/top_probe_driver.vhd
-- Top-level CustomWrapper architecture that instantiates the probe_driver module

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.IntensityLut_pkg.all;

-- =============================================================================
-- ARCHITECTURE - Implementation that instantiates probe_driver
-- =============================================================================
architecture Behavioural of CustomWrapper is
    -- Constants
    constant ProbeTrigger_Threshold : signed(15 downto 0) := x"4000";  -- 2.5V threshold
    
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
            reset          => Reset,
            enable         => Control0(31),                    -- Topmost bit of Control0 set to enable
            trig_in        => Control0(0),                     -- Use control0(0) as trigger input
            -- Module specific
            Intensity_index   => Control1(7 downto 0),        -- 8 bit index
            PulseDuration_in  => Control2(31 downto 0),       -- 32-bit pulse duration from control2
            CoolDown_in       => Control3(31 downto 0),       -- 32-bit cooldown from control3
            trig_out          => probe_trig_out,               -- Capture trigger output
            intensity_out     => probe_intensity_out,          -- Capture intensity output
            status_register   => probe_driver_status_register  -- Capture status register
        );
    
    -- =============================================================================
    -- OUTPUT ASSIGNMENTS
    -- =============================================================================
    -- OutputA: Show probe trigger threshold when probe is firing, otherwise show intensity
    OutputA <= ProbeTrigger_Threshold when probe_trig_out = ProbeTrigger_Threshold else probe_intensity_out;
    
    -- OutputB: Show probe intensity when firing, otherwise zero
    OutputB <= probe_intensity_out when probe_trig_out = ProbeTrigger_Threshold else (others => '0');
    -- OutputC: Echo back Control0(15:0), Control1(7:0), 3 zeros, and status register
    OutputC <= signed(Control0(15 downto 0) & Control1(7 downto 0) & "000" & probe_driver_status_register);

end architecture Behavioural;
