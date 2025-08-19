-- SigGen.vhd
-- MCC-compatible SigGen architecture for CustomWrapper entity
-- This file provides the complete SigGen implementation as an architecture
-- Note: MCC provides the CustomWrapper entity declaration, we provide the Behavioural architecture
--
-- Date: 2025-01-27
-- Tag: SigGen-v1.0-Refactored-Consolidated

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

architecture Behavioural of CustomWrapper is
    -- =============================================================================
    -- COMPONENT INSTANTIATION
    -- =============================================================================
    
    -- =============================================================================
    -- INTERNAL SIGNALS
    -- =============================================================================
    -- SigGen output signals
    signal siggen_output_a : signed(15 downto 0);
    signal siggen_output_b : signed(15 downto 0);
    signal siggen_output_c : signed(15 downto 0);
    signal siggen_output_d : signed(15 downto 0);
    
begin
    -- =============================================================================
    -- SIGGEN WRAPPER INSTANTIATION
    -- =============================================================================
    siggen_wrapper_inst : entity work.siggen_wrapper
        port map (
            -- Clock and Reset
            clk        => Clk,
            reset      => Reset,
            
            -- Control Registers (only using Control0-4 for SigGen)
            control0   => Control0,
            control1   => Control1,
            control2   => Control2,
            control3   => Control3,
            control4   => Control4,
            
            -- Output Signals
            output_a   => siggen_output_a,
            output_b   => siggen_output_b,
            output_c   => siggen_output_c,
            output_d   => siggen_output_d
        );
    
    -- =============================================================================
    -- OUTPUT ASSIGNMENT
    -- =============================================================================
    -- Connect SigGen outputs to platform outputs
    OutputA <= siggen_output_a;
    OutputB <= siggen_output_b;
    OutputC <= siggen_output_c;
    OutputD <= siggen_output_d;
    
end architecture Behavioural;
