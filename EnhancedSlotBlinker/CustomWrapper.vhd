-- CustomWrapper.vhd
-- A local copy of the CustomWrapper.vhd interface definition.
-- LI controls the layout of this. It is reproduced here for convenience

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity CustomWrapper is  
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
        -- NEW SIGNALS START HERE --
    );

        -- 300MHz should be doable across the entire product line. 
        -- ClkFast : in std_logic;
    end entity CustomWrapper;
-- HDL/CustomWrapper.vhd
