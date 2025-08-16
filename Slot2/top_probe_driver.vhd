-- Slot2/top_probe_driver.vhd
-- Top-level CustomWrapper architecture that instantiates the probe_driver module

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.IntensityLut_pkg.all;

-- =============================================================================
-- ENTITY - Port definitions for CustomWrapper
-- =============================================================================
entity CustomWrapper is  
    port (  
        -- Clock and Reset
        Clk : in std_logic;      
        Reset : in std_logic;    
  
        -- Input signals (Platform-specific usage)
        InputA : in signed(15 downto 0);   
        InputB : in signed(15 downto 0);   
        InputC : in signed(15 downto 0);   
        InputD : in signed(15 downto 0);   
  
        -- Output signals (Platform-specific usage)
        OutputA : out signed(15 downto 0);  
        OutputB : out signed(15 downto 0);  
        OutputC : out signed(15 downto 0);  
        OutputD : out signed(15 downto 0);  
  
        -- Control registers (32-bit each)
        Control0  : in std_logic_vector(31 downto 0);   
        Control1  : in std_logic_vector(31 downto 0);   
        Control2  : in std_logic_vector(31 downto 0);   
        Control3  : in std_logic_vector(31 downto 0);   
        Control4  : in std_logic_vector(31 downto 0);   
        Control5  : in std_logic_vector(31 downto 0);   
        Control6  : in std_logic_vector(31 downto 0);   
        Control7  : in std_logic_vector(31 downto 0);   
        Control8  : in std_logic_vector(31 downto 0);   
        Control9  : in std_logic_vector(31 downto 0);   
        Control10 : in std_logic_vector(31 downto 0);   
        Control11 : in std_logic_vector(31 downto 0);   
        Control12 : in std_logic_vector(31 downto 0);   
        Control13 : in std_logic_vector(31 downto 0);   
        Control14 : in std_logic_vector(31 downto 0);   
        Control15 : in std_logic_vector(31 downto 0)    
    );
end entity CustomWrapper;

-- =============================================================================
-- ARCHITECTURE - Implementation that instantiates probe_driver
-- =============================================================================
architecture Behavioural of CustomWrapper is
    -- Constants
    constant ProbeTrigger_Threshold : signed(15 downto 0) := x"4000";  -- 2.5V threshold
    
    -- Internal signals for probe driver outputs
    signal probe_trig_out : std_logic;
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
            intensity_out     => probe_intensity_out            -- Capture intensity output
        );
    
    -- =============================================================================
    -- OUTPUT ASSIGNMENTS
    -- =============================================================================
    -- OutputA: Show probe trigger threshold when probe is firing, otherwise show intensity
    OutputA <= ProbeTrigger_Threshold when probe_trig_out = '1' else probe_intensity_out;
    
    -- OutputB: Show probe intensity when firing, otherwise zero
    OutputB <= probe_intensity_out when probe_trig_out = '1' else (others => '0');
    -- OutputC: This will echo the  ProbeDriverStatusRegister (PDSR) to DIO-OUT 
    OutputC <= signed(Control0(15 downto 0));

end architecture Behavioural;
