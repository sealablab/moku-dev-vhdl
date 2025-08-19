-- =============================================================================
-- BasicBlock_Top.vhd
-- =============================================================================
-- 
-- Top-Level Module for BasicBlock LED Pattern Generator
-- 
-- PURPOSE: This is the main entry point for the BasicBlock module. It implements
--          the CustomWrapper interface that Moku-Go expects, making it compatible
--          with the MCC (Moku Cloud Compiler) platform. Think of this as the
--          "main function" of our LED pattern generator.
-- 
-- TARGET PLATFORM: Moku-Go (Liquid Instruments)
--                  - FPGA-based signal generation and analysis platform
--                  - 4 analog outputs (OutputA, OutputB, OutputC, OutputD)
--                  - 16-bit signed resolution (-32768 to +32767)
--                  - Configurable via control registers
-- 
-- PLATFORM INTEGRATION: This module implements the CustomWrapper interface
--                       that Moku-Go expects, making it compatible with:
--                       - MCC (Moku Cloud Compiler)
--                       - Moku:Go desktop software
--                       - Python API control
--                       - External control systems
-- 
-- LEARNING OBJECTIVES:
--   1. Understanding VHDL top-level module design
--   2. Learning about platform interface requirements
--   3. Understanding how to integrate with existing systems
--   4. Learning about signal routing and module interconnection
--   5. Understanding how to create deployable FPGA designs
-- 
-- =============================================================================

library IEEE;
use IEEE.Std_Logic_1164.all;  -- Standard logic types (std_logic, std_logic_vector)
use IEEE.Numeric_Std.all;      -- Numeric types (unsigned, signed, integer)

entity CustomWrapper is
    port (
        -- =============================================================================
        -- CLOCK AND RESET SIGNALS
        -- =============================================================================
        -- These are the basic signals that every digital system needs
        -- In Moku-Go, these are provided by the platform and cannot be changed
        Clk : in std_logic;    -- Main system clock (125 MHz in Moku-Go)
        Reset : in std_logic;  -- System reset signal (1=reset, 0=normal)
        
        -- =============================================================================
        -- INPUT PORTS (PLATFORM-SPECIFIC)
        -- =============================================================================
        -- These are the input signals that Moku-Go provides
        -- In BasicBlock, we don't use these inputs (they're for other applications)
        -- But we must declare them to maintain platform compatibility
        InputA : in signed(15 downto 0);  -- Input signal A (unused in BasicBlock)
        InputB : in signed(15 downto 0);  -- Input signal B (unused in BasicBlock)
        InputC : in signed(15 downto 0);  -- Input signal C (unused in BasicBlock)
        InputD : in signed(15 downto 0);  -- Input signal D (unused in BasicBlock)
        
        -- =============================================================================
        -- OUTPUT PORTS (PLATFORM-SPECIFIC)
        -- =============================================================================
        -- These are the output signals that go to the Moku-Go analog outputs
        -- Each output is 16-bit signed (-32768 to +32767) for fine control
        -- These will display our LED patterns as analog signals
        OutputA : out signed(15 downto 0);  -- LED pattern for Output A
        OutputB : out signed(15 downto 0);  -- LED pattern for Output B
        OutputC : out signed(15 downto 0);  -- LED pattern for Output C
        OutputD : out signed(15 downto 0);  -- LED pattern for Output D
        
        -- =============================================================================
        -- CONTROL REGISTERS (PLATFORM-SPECIFIC)
        -- =============================================================================
        -- These are the control registers that configure the BasicBlock module
        -- In Moku-Go, these are typically set by software or external control
        -- We use 5 registers (Control0-4) for our configuration
        Control0 : in std_logic_vector(31 downto 0);  -- Global configuration
        Control1 : in std_logic_vector(31 downto 0);  -- Output A configuration
        Control2 : in std_logic_vector(31 downto 0);  -- Output B configuration
        Control3 : in std_logic_vector(31 downto 0);  -- Output C configuration
        Control4 : in std_logic_vector(31 downto 0);  -- Output D configuration
        
        -- =============================================================================
        -- UNUSED CONTROL REGISTERS
        -- =============================================================================
        -- These control registers are not used by BasicBlock
        -- But we must declare them to maintain platform compatibility
        -- They're available for future expansion or other features
        Control5 : in std_logic_vector(31 downto 0);   -- Reserved for future use
        Control6 : in std_logic_vector(31 downto 0);   -- Reserved for future use
        Control7 : in std_logic_vector(31 downto 0);   -- Reserved for future use
        Control8 : in std_logic_vector(31 downto 0);   -- Reserved for future use
        Control9 : in std_logic_vector(31 downto 0);   -- Reserved for future use
        Control10 : in std_logic_vector(31 downto 0);  -- Reserved for future use
        Control11 : in std_logic_vector(31 downto 0);  -- Reserved for future use
        Control12 : in std_logic_vector(31 downto 0);  -- Reserved for future use
        Control13 : in std_logic_vector(31 downto 0);  -- Reserved for future use
        Control14 : in std_logic_vector(31 downto 0);  -- Reserved for future use
        Control15 : in std_logic_vector(31 downto 0)   -- Reserved for future use
    );
end entity CustomWrapper;

architecture Behavioural of CustomWrapper is
    -- =============================================================================
    -- COMPONENT DECLARATIONS - These tell VHDL about external modules we'll use
    -- =============================================================================
    
    -- BasicBlock wrapper component - this is our main LED pattern generation interface
    -- The wrapper handles control register parsing and module interconnection
    component basicblock_wrapper is
        port (
            -- Clock and Control
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
    end component;
    
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
    basicblock_wrapper_inst : basicblock_wrapper
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
