-- siggen_wrapper.vhd
-- Interface wrapper for the SigGen module
-- REFACTORED: Handles control register parsing and instantiates siggen_core
-- Follows VHDL-2008 standards and industry best practices

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.siggen_pkg.all;

entity siggen_wrapper is
    port (
        -- Clock and Reset
        clk        : in  std_logic;
        reset      : in  std_logic;
        
        -- Control Registers
        control0   : in  std_logic_vector(31 downto 0);
        control1   : in  std_logic_vector(31 downto 0);
        control2   : in  std_logic_vector(31 downto 0);
        control3   : in  std_logic_vector(31 downto 0);
        control4   : in  std_logic_vector(31 downto 0);
        
        -- Output Signals
        output_a   : out signed(15 downto 0);
        output_b   : out signed(15 downto 0);
        output_c   : out signed(15 downto 0);
        output_d   : out signed(15 downto 0)
    );
end entity siggen_wrapper;

architecture rtl of siggen_wrapper is
    -- =============================================================================
    -- INTERNAL SIGNALS
    -- =============================================================================
    -- Parsed configurations
    signal global_config       : global_config_type;
    signal output_a_config     : output_config_type;
    signal output_b_config     : output_config_type;
    signal output_c_config     : output_config_type;
    signal output_d_config     : output_config_type;
    
    -- Core enable signal
    signal core_enable        : std_logic;
    
    -- =============================================================================
    -- COMPONENT INSTANTIATION
    -- =============================================================================
    
begin
    -- =============================================================================
    -- CONTROL REGISTER PARSING
    -- =============================================================================
    -- Parse Control Register 0: Global Control & Timing
    global_config <= parse_global_config(control0);
    
    -- Parse Control Register 1: Output A Configuration
    output_a_config <= parse_output_config(control1);
    
    -- Parse Control Register 2: Output B Configuration
    output_b_config <= parse_output_config(control2);
    
    -- Parse Control Register 3: Output C Configuration
    output_c_config <= parse_output_config(control3);
    
    -- Parse Control Register 4: Output D Configuration
    output_d_config <= parse_output_config(control4);
    
    -- =============================================================================
    -- CORE ENABLE LOGIC
    -- =============================================================================
    -- Core is enabled when global enable is active (nEnable = '0')
    core_enable <= '1' when global_config.nEnable = '0' else '0';
    
    -- =============================================================================
    -- CORE INSTANTIATION
    -- =============================================================================
    siggen_core_inst : entity work.siggen_core
        port map (
            -- Clock and Control
            clk                    => clk,
            reset                  => reset,
            enable                 => core_enable,
            
            -- Global Configuration
            global_config          => global_config,
            
            -- Output Configurations
            output_a_config        => output_a_config,
            output_b_config        => output_b_config,
            output_c_config        => output_c_config,
            output_d_config        => output_d_config,
            
            -- Output Signals
            output_a               => output_a,
            output_b               => output_b,
            output_c               => output_c,
            output_d               => output_d
        );
    
end architecture rtl;
