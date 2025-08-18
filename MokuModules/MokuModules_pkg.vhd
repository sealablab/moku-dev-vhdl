-- MokuModules_pkg.vhd
-- Package containing standardized component declarations for Moku hardware modules
-- This eliminates the need to duplicate component declarations across testbenches

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

package MokuModules_pkg is

    -- =============================================================================
    -- CUSTOMWRAPPER COMPONENT DECLARATION
    -- =============================================================================
    -- Standardized component declaration for CustomWrapper entity
    -- Use this in testbenches instead of duplicating the port definition
    component CustomWrapper is
        port (
            Clk : in std_logic;
            Reset : in std_logic;

            -- Input and Output use is platform-specific. These ports exist on all
            -- platforms but may not be externally connected.
            InputA : in signed(15 downto 0);
            InputB : in signed(15 downto 0);
            InputC : in signed(15 downto 0);
            InputD : in signed(15 downto 0);

            -- ExtTrig : in std_logic;  -- is ExtTrig on *all* platforms?

            OutputA : out signed(15 downto 0);
            OutputB : out signed(15 downto 0);
            OutputC : out signed(15 downto 0);
            OutputD : out signed(15 downto 0);

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
            -- NEW SIGNALS START HERE --
        );
    end component;

    -- =============================================================================
    -- MOKUGO COMPONENT DECLARATION
    -- =============================================================================
    -- Standardized component declaration for MokuGo entity
    component MokuGo is
        port (
            Input1 : in signed(15 downto 0);
            Input2 : in signed(15 downto 0);

            Output1 : out signed(15 downto 0);
            Output2 : out signed(15 downto 0);

            Control15 : in std_logic_vector(31 downto 0)
        );
    end component;

    -- =============================================================================
    -- COMMON CONSTANTS AND TYPES
    -- =============================================================================
    -- Standard clock periods for different platforms
    constant MOKUGO_CLK_PERIOD : time := 32 ns;  -- Real hardware timing
    constant MOKULAB_CLK_PERIOD : time := 10 ns;  -- Typical simulation
    constant MOKUPRO_CLK_PERIOD : time := 5 ns;   -- High-speed simulation

    -- Standard reset values
    constant RESET_ACTIVE : std_logic := '1';
    constant RESET_INACTIVE : std_logic := '0';

end package MokuModules_pkg;
