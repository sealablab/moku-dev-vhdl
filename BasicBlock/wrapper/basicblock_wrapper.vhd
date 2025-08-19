-- =============================================================================
-- basicblock_wrapper.vhd
-- =============================================================================
-- 
-- Interface Wrapper for BasicBlock Module
-- 
-- PURPOSE: This module acts as a "translator" between the external control
--          registers and the internal BasicBlock core. It parses the control
--          register data and converts it into the configuration structures
--          that the core module can understand.
-- 
-- TARGET PLATFORM: Moku-Go (Liquid Instruments)
--                  - FPGA-based signal generation and analysis platform
--                  - 4 analog outputs (OutputA, OutputB, OutputC, OutputD)
--                  - 16-bit signed resolution (-32768 to +32767)
--                  - Configurable via control registers
-- 
-- INTEGRATION: This module integrates the core BasicBlock logic with the
--              Moku-Go control register system and the clk-divider module.
-- 
-- LEARNING OBJECTIVES:
--   1. Understanding VHDL component instantiation and port mapping
--   2. Learning about control register parsing and validation
--   3. Understanding how to create clean interfaces between modules
--   4. Learning about signal routing and module interconnection
--   5. Understanding how to integrate with existing platform infrastructure
-- 
-- =============================================================================

library IEEE;
use IEEE.Std_Logic_1164.all;  -- Standard logic types (std_logic, std_logic_vector)
use IEEE.Numeric_Std.all;      -- Numeric types (unsigned, signed, integer)
use work.basicblock_pkg.all;   -- Our BasicBlock package with types and utilities

entity basicblock_wrapper is
    port (
        -- =============================================================================
        -- CLOCK AND CONTROL SIGNALS
        -- =============================================================================
        -- These are the basic signals that every digital system needs
        clk        : in  std_logic;  -- Main system clock (125 MHz in Moku-Go)
        reset      : in  std_logic;  -- Reset signal (1=reset, 0=normal)
        
        -- =============================================================================
        -- CONTROL REGISTERS
        -- =============================================================================
        -- These are the control registers that configure the BasicBlock module
        -- In Moku-Go, these are typically set by software or external control
        control0   : in  std_logic_vector(31 downto 0);  -- Global configuration
        control1   : in  std_logic_vector(31 downto 0);  -- Output A configuration
        control2   : in  std_logic_vector(31 downto 0);  -- Output B configuration
        control3   : in  std_logic_vector(31 downto 0);  -- Output C configuration
        control4   : in  std_logic_vector(31 downto 0);  -- Output D configuration
        
        -- =============================================================================
        -- OUTPUT SIGNALS
        -- =============================================================================
        -- These are the LED pattern outputs that go to the Moku-Go outputs
        -- Each output is 16-bit signed (-32768 to +32767) for fine control
        output_a   : out signed(15 downto 0);  -- LED pattern for Output A
        output_b   : out signed(15 downto 0);  -- LED pattern for Output B
        output_c   : out signed(15 downto 0);  -- LED pattern for Output C
        output_d   : out signed(15 downto 0)   -- LED pattern for Output D
    );
end entity basicblock_wrapper;

architecture rtl of basicblock_wrapper is
    -- =============================================================================
    -- INTERNAL SIGNALS - These are like "internal variables" in the module
    -- =============================================================================
    
    -- Parsed configuration signals
    -- These hold the configuration data after parsing the control registers
    -- They're easier to work with than raw register data
    signal global_config       : global_config_type;   -- Global system settings
    signal output_a_config     : output_config_type;   -- Settings for Output A
    signal output_b_config     : output_config_type;   -- Settings for Output B
    signal output_c_config     : output_config_type;   -- Settings for Output C
    signal output_d_config     : output_config_type;   -- Settings for Output D
    
    -- Core enable signal
    -- This controls whether the BasicBlock core is active
    signal core_enable        : std_logic;
    
    -- Clock divider interface signals
    -- These connect to the clk-divider module for timing control
    signal clk_divider_enable : std_logic;                    -- Enable signal for clock divider
    signal clk_divider_ratio  : std_logic_vector(15 downto 0); -- Division ratio for clock divider
    signal clk_divider_output : std_logic;                    -- Output from clock divider
    
    -- =============================================================================
    -- COMPONENT DECLARATIONS - These tell VHDL about external modules we'll use
    -- =============================================================================
    
    -- BasicBlock core component - this is our main LED pattern generation module
    -- We'll instantiate this to create the actual LED patterns
    component basicblock_core is
        port (
            -- Clock and Control
            clk                    : in  std_logic;
            reset                  : in  std_logic;
            enable                 : in  std_logic;
            
            -- Clock Divider Integration
            clk_divider_enable    : out std_logic;
            clk_divider_ratio     : out std_logic_vector(15 downto 0);
            clk_divider_output    : in  std_logic;
            
            -- Configuration Inputs
            global_config          : in  global_config_type;
            output_a_config        : in  output_config_type;
            output_b_config        : in  output_config_type;
            output_c_config        : in  output_config_type;
            output_d_config        : in  output_config_type;
            
            -- Output Signals
            output_a               : out signed(15 downto 0);
            output_b               : out signed(15 downto 0);
            output_c               : out signed(15 downto 0);
            output_d               : out signed(15 downto 0)
        );
    end component;
    
    -- Clock divider component - this is the existing clk-divider module
    -- We'll instantiate this to provide flexible timing control
    component clk_divider is
        port (
            clk_in     : in  std_logic;                    -- Input clock (125 MHz)
            clk_out    : out std_logic;                    -- Output clock (divided frequency)
            ratio      : in  std_logic_vector(15 downto 0); -- Division ratio
            enable     : in  std_logic;                    -- Enable signal
            reset      : in  std_logic                     -- Reset signal
        );
    end component;
    
begin
    -- =============================================================================
    -- CONTROL REGISTER PARSING
    -- =============================================================================
    -- This section takes the raw control register data and converts it into
    -- structured configuration records that are easy to work with
    
    -- Parse Control Register 0: Global Configuration
    -- This register contains settings that affect all outputs at once
    -- Examples: master enable, clock divider, sync mode, reset pattern
    global_config <= parse_global_config(control0);
    
    -- Parse Control Register 1: Output A Configuration
    -- This register contains settings for Output A only
    -- Examples: pattern type, pattern speed, brightness, enable
    output_a_config <= parse_output_config(control1);
    
    -- Parse Control Register 2: Output B Configuration
    -- This register contains settings for Output B only
    output_b_config <= parse_output_config(control2);
    
    -- Parse Control Register 3: Output C Configuration
    -- This register contains settings for Output C only
    output_c_config <= parse_output_config(control3);
    
    -- Parse Control Register 4: Output D Configuration
    -- This register contains settings for Output D only
    output_d_config <= parse_output_config(control4);
    
    -- =============================================================================
    -- CORE ENABLE LOGIC
    -- =============================================================================
    -- This section controls whether the BasicBlock core is active
    
    -- Core is enabled when global enable is active
    -- This prevents unnecessary power consumption when disabled
    core_enable <= global_config.master_enable;
    
    -- =============================================================================
    -- CLOCK DIVIDER INSTANTIATION
    -- =============================================================================
    -- This section creates an instance of the existing clk-divider module
    -- The clk-divider provides flexible timing control for our LED patterns
    
    -- Instantiate the clock divider module
    -- This creates an instance of the existing clk-divider module
    -- We connect our signals to its ports using port mapping
    clock_divider_inst : clk_divider
        port map (
            clk_in  => clk,                    -- Connect our main clock
            clk_out => clk_divider_output,     -- Get the divided clock output
            ratio   => clk_divider_ratio,      -- Set the division ratio
            enable  => clk_divider_enable,     -- Enable/disable the divider
            reset   => reset                   -- Reset the divider
        );
    
    -- =============================================================================
    -- BASICBLOCK CORE INSTANTIATION
    -- =============================================================================
    -- This section creates an instance of our BasicBlock core module
    -- The core contains all the LED pattern generation logic
    
    -- Instantiate the BasicBlock core module
    -- This creates an instance of our main LED pattern generation module
    -- We connect all the configuration and timing signals
    basicblock_core_inst : basicblock_core
        port map (
            -- Clock and Control
            clk                    => clk,                    -- Connect main clock
            reset                  => reset,                  -- Connect reset signal
            enable                 => core_enable,            -- Connect core enable
            
            -- Clock Divider Integration
            clk_divider_enable    => clk_divider_enable,     -- Connect divider enable
            clk_divider_ratio     => clk_divider_ratio,      -- Connect divider ratio
            clk_divider_output    => clk_divider_output,     -- Connect divider output
            
            -- Configuration Inputs
            global_config          => global_config,          -- Connect global settings
            output_a_config        => output_a_config,        -- Connect Output A settings
            output_b_config        => output_b_config,        -- Connect Output B settings
            output_c_config        => output_c_config,        -- Connect Output C settings
            output_d_config        => output_d_config,        -- Connect Output D settings
            
            -- Output Signals
            output_a               => output_a,               -- Connect Output A
            output_b               => output_b,               -- Connect Output B
            output_c               => output_c,               -- Connect Output C
            output_d               => output_d                -- Connect Output D
        );
    
    -- =============================================================================
    -- SIGNAL ROUTING AND INTERCONNECTION
    -- =============================================================================
    -- This section shows how signals flow between different parts of the system
    
    -- The signal flow is:
    -- 1. Control registers (control0-4) contain raw configuration data
    -- 2. Wrapper parses this data into structured configuration records
    -- 3. Configuration records are sent to the BasicBlock core
    -- 4. Core generates LED patterns based on configuration
    -- 5. Patterns are sent to Moku-Go outputs (output_a, output_b, output_c, output_d)
    -- 6. Clock divider provides timing control for pattern changes
    
    -- This modular approach makes the system:
    -- - Easy to understand (each module has a clear purpose)
    -- - Easy to modify (change one module without affecting others)
    -- - Easy to test (test each module independently)
    -- - Easy to reuse (use modules in other projects)
    
end architecture rtl;
