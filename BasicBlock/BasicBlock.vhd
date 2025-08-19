-- BasicBlock.vhd
-- MCC-compatible BasicBlock architecture for CustomWrapper entity
-- This file provides the complete BasicBlock implementation as an architecture
-- Note: MCC provides the CustomWrapper entity declaration, we provide the Behavioural architecture
--
-- Date: 2025-01-27
-- Tag: BasicBlock-v1.0-Refactored-Consolidated

library IEEE;
use IEEE.Std_Logic_1164.all;  -- Standard logic types (std_logic, std_logic_vector)
use IEEE.Numeric_Std.all;      -- Numeric types (unsigned, signed, integer)

architecture Behavioural of CustomWrapper is
    -- =============================================================================
    -- COMPONENT DECLARATIONS - These tell VHDL about external modules we'll use
    -- =============================================================================
    
    -- BasicBlock wrapper component - this is our main LED pattern generation interface
    -- The wrapper handles control register parsing and module interconnection
    
    -- =============================================================================
    -- INTERNAL SIGNALS - These are like "internal variables" in the module
    -- =============================================================================
    
    -- BasicBlock output signals
    -- These hold the LED pattern outputs from our BasicBlock wrapper
    -- They're the intermediate signals between the wrapper and the platform outputs
    signal basicblock_output_a : signed(15 downto 0);  -- LED pattern for Output A
    signal basicblock_output_b : signed(15 downto 0);  -- LED pattern for Output B
    signal basicblock_output_c : signed(15 downto 0);  -- LED pattern for Output C
    signal basicblock_output_d : signed(15 downto 0);  -- LED pattern for Output D
    
begin
    -- =============================================================================
    -- BASICBLOCK WRAPPER INSTANTIATION
    -- =============================================================================
    -- This section creates an instance of our BasicBlock wrapper module
    -- The wrapper contains all the LED pattern generation logic and control parsing
    
    -- Instantiate the BasicBlock wrapper module
    -- This creates an instance of our main LED pattern generation interface
    -- We connect all the platform signals to the wrapper using port mapping
    basicblock_wrapper_inst : entity work.basicblock_wrapper
        port map (
            -- Clock and Control
            clk        => Clk,        -- Connect platform clock
            reset      => Reset,      -- Connect platform reset
            
            -- Control Registers (only using Control0-4 for BasicBlock)
            control0   => Control0,   -- Connect global configuration
            control1   => Control1,   -- Connect Output A configuration
            control2   => Control2,   -- Connect Output B configuration
            control3   => Control3,   -- Connect Output C configuration
            control4   => Control4,   -- Connect Output D configuration
            
            -- Output Signals
            output_a   => basicblock_output_a,  -- Get Output A pattern
            output_b   => basicblock_output_b,  -- Get Output B pattern
            output_c   => basicblock_output_c,  -- Get Output C pattern
            output_d   => basicblock_output_d   -- Get Output D pattern
        );
    
    -- =============================================================================
    -- OUTPUT ASSIGNMENT
    -- =============================================================================
    -- This section connects our BasicBlock outputs to the platform outputs
    
    -- Connect BasicBlock outputs to platform outputs
    -- This routes our LED patterns to the Moku-Go analog outputs
    OutputA <= basicblock_output_a;  -- Route Output A to platform
    OutputB <= basicblock_output_b;  -- Route Output B to platform
    OutputC <= basicblock_output_c;  -- Route Output C to platform
    OutputD <= basicblock_output_d;  -- Route Output D to platform
    
    -- =============================================================================
    -- PLATFORM INTEGRATION NOTES
    -- =============================================================================
    -- This section explains how BasicBlock integrates with the Moku-Go platform
    
    -- Input Ports (InputA, InputB, InputC, InputD):
    -- - These are not used by BasicBlock
    -- - They're connected for platform compatibility
    -- - In other applications, these might be used for:
    --   * External trigger signals
    --   * Pattern synchronization
    --   * Real-time pattern modification
    --   * Audio/visual input processing
    
    -- Control Registers (Control0-15):
    -- - BasicBlock uses Control0-4 for configuration
    -- - Control5-15 are reserved for future expansion
    -- - This allows BasicBlock to coexist with other features
    -- - Future versions might use additional registers for:
    --   * Advanced pattern sequences
    --   * Pattern synchronization with external sources
    --   * Real-time pattern modification
    --   * Advanced timing controls
    
    -- Output Ports (OutputA, OutputB, OutputC, OutputD):
    -- - These display our LED patterns as analog signals
    -- - Each output is 16-bit signed (-32768 to +32767)
    -- - In Moku-Go, these typically drive:
    --   * LED arrays or displays
    --   * Audio amplifiers
    --   * Control systems
    --   * Test and measurement equipment
    
    -- =============================================================================
    -- DEPLOYMENT AND USAGE
    -- =============================================================================
    -- This section explains how to use BasicBlock in practice
    
    -- To deploy BasicBlock on Moku-Go:
    -- 1. Compile this design using MCC (Moku Cloud Compiler)
    -- 2. Upload the compiled bitstream to your Moku-Go device
    -- 3. Use Moku:Go desktop software or Python API to configure patterns
    -- 4. Control registers can be set programmatically or via the GUI
    
    -- Example Python API usage:
    -- ```python
    -- import moku
    -- m = moku.MokuGo()
    -- m.set_control_register(0, 0x80000000)  # Enable system
    -- m.set_control_register(1, 0x10000000)  # Set Output A to pattern 1
    -- m.set_control_register(2, 0x20000000)  # Set Output B to pattern 2
    -- ```
    
    -- =============================================================================
    -- FUTURE EXPANSION OPPORTUNITIES
    -- =============================================================================
    -- This section outlines how BasicBlock can be extended
    
    -- Pattern System:
    -- - Add new LED patterns by modifying led_pattern_pkg.vhd
    -- - Implement user-defined pattern loading
    -- - Add pattern validation and testing tools
    
    -- Control System:
    -- - Use Control5-15 for advanced features
    -- - Implement real-time pattern modification
    -- - Add pattern synchronization with external sources
    
    -- Integration:
    -- - Use InputA-D for external triggers
    -- - Implement audio-reactive patterns
    -- - Add network-based pattern control
    
end architecture Behavioural;
