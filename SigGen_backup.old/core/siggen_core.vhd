-- siggen_core.vhd
-- Core signal generation logic for the SigGen module
-- REFACTORED: Extracted from BestSlotBlinker for modular design
-- Follows VHDL-2008 standards and industry best practices

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use work.siggen_pkg.all;
use work.pattern_generator_pkg.all;

entity siggen_core is
    port (
        -- Clock and Control
        clk                    : in  std_logic;
        reset                  : in  std_logic;
        enable                 : in  std_logic;
        
        -- Global Configuration
        global_config          : in  global_config_type;
        
        -- Output Configurations
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
end entity siggen_core;

architecture rtl of siggen_core is
    -- =============================================================================
    -- INTERNAL SIGNALS
    -- =============================================================================
    -- Main counter and divider signals
    signal main_counter        : unsigned(15 downto 0) := (others => '0');
    signal div_counter         : unsigned(7 downto 0) := (others => '0');
    signal reset_sync          : std_logic;
    
    -- Pipeline data for each output
    signal pipeline_a          : pipeline_data_type;
    signal pipeline_b          : pipeline_data_type;
    signal pipeline_c          : pipeline_data_type;
    signal pipeline_d          : pipeline_data_type;
    
    -- Pipeline registers for Output A
    signal raw_pattern_a_pipe1 : unsigned(15 downto 0);
    signal scaled_counter_a_pipe1 : unsigned(15 downto 0);
    signal scaled_pattern_a_pipe2 : unsigned(15 downto 0);
    
    -- Pipeline registers for Output B
    signal raw_pattern_b_pipe1 : unsigned(15 downto 0);
    signal scaled_counter_b_pipe1 : unsigned(15 downto 0);
    signal scaled_pattern_b_pipe2 : unsigned(15 downto 0);
    
    -- Pipeline registers for Output C
    signal raw_pattern_c_pipe1 : unsigned(15 downto 0);
    signal scaled_counter_c_pipe1 : unsigned(15 downto 0);
    signal scaled_pattern_c_pipe2 : unsigned(15 downto 0);
    
    -- Pipeline registers for Output D
    signal raw_pattern_d_pipe1 : unsigned(15 downto 0);
    signal scaled_counter_d_pipe1 : unsigned(15 downto 0);
    signal scaled_pattern_d_pipe2 : unsigned(15 downto 0);
    
begin
    -- =============================================================================
    -- RESET SYNCHRONIZATION
    -- =============================================================================
    reset_sync <= reset;
    
    -- =============================================================================
    -- MAIN COUNTER PROCESS WITH GLOBAL DIVIDER
    -- =============================================================================
    main_counter_process: process(clk) 
    begin
        if rising_edge(clk) then
            if reset_sync = '1' then
                main_counter <= (others => '0');
                div_counter <= (others => '0');
            elsif enable = '1' and global_config.nEnable = '0' then -- Use nEnable for the main enable
                -- Apply global divider
                if div_counter >= global_config.global_divider then
                    main_counter <= main_counter + 1;
                    div_counter <= (others => '0');
                else
                    div_counter <= div_counter + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- =============================================================================
    -- PIPELINE STAGE 1: GENERATE RAW PATTERNS AND APPLY FREQUENCY/PHASE
    -- =============================================================================
    pipeline_stage1: process(clk)
    begin
        if rising_edge(clk) then
            if reset_sync = '1' then
                -- Reset pipeline registers
                raw_pattern_a_pipe1 <= (others => '0');
                raw_pattern_b_pipe1 <= (others => '0');
                raw_pattern_c_pipe1 <= (others => '0');
                raw_pattern_d_pipe1 <= (others => '0');
                scaled_counter_a_pipe1 <= (others => '0');
                scaled_counter_b_pipe1 <= (others => '0');
                scaled_counter_c_pipe1 <= (others => '0');
                scaled_counter_d_pipe1 <= (others => '0');
            else
                -- Generate raw patterns and apply bit mask
                raw_pattern_a_pipe1 <= apply_bit_mask(
                    generate_pattern(output_a_config.pattern_type, main_counter), 
                    global_config.bit_mask
                );
                raw_pattern_b_pipe1 <= apply_bit_mask(
                    generate_pattern(output_b_config.pattern_type, main_counter), 
                    global_config.bit_mask
                );
                raw_pattern_c_pipe1 <= apply_bit_mask(
                    generate_pattern(output_c_config.pattern_type, main_counter), 
                    global_config.bit_mask
                );
                raw_pattern_d_pipe1 <= apply_bit_mask(
                    generate_pattern(output_d_config.pattern_type, main_counter), 
                    global_config.bit_mask
                );
                
                -- Apply frequency divider and phase offset
                scaled_counter_a_pipe1 <= apply_frequency_divider(
                    apply_phase_offset(main_counter, output_a_config.phase_offset),
                    output_a_config.freq_div
                );
                scaled_counter_b_pipe1 <= apply_frequency_divider(
                    apply_phase_offset(main_counter, output_b_config.phase_offset),
                    output_b_config.freq_div
                );
                scaled_counter_c_pipe1 <= apply_frequency_divider(
                    apply_phase_offset(main_counter, output_c_config.phase_offset),
                    output_c_config.freq_div
                );
                scaled_counter_d_pipe1 <= apply_frequency_divider(
                    apply_phase_offset(main_counter, output_d_config.phase_offset),
                    output_d_config.freq_div
                );
            end if;
        end if;
    end process;
    
    -- =============================================================================
    -- PIPELINE STAGE 2: APPLY AMPLITUDE SCALING
    -- =============================================================================
    pipeline_stage2: process(clk)
    begin
        if rising_edge(clk) then
            if reset_sync = '1' then
                scaled_pattern_a_pipe2 <= (others => '0');
                scaled_pattern_b_pipe2 <= (others => '0');
                scaled_pattern_c_pipe2 <= (others => '0');
                scaled_pattern_d_pipe2 <= (others => '0');
            else
                -- Apply amplitude scaling
                scaled_pattern_a_pipe2 <= apply_amplitude_scaling(
                    raw_pattern_a_pipe1, 
                    output_a_config.amp_scale
                );
                scaled_pattern_b_pipe2 <= apply_amplitude_scaling(
                    raw_pattern_b_pipe1, 
                    output_b_config.amp_scale
                );
                scaled_pattern_c_pipe2 <= apply_amplitude_scaling(
                    raw_pattern_c_pipe1, 
                    output_c_config.amp_scale
                );
                scaled_pattern_d_pipe2 <= apply_amplitude_scaling(
                    raw_pattern_d_pipe1, 
                    output_d_config.amp_scale
                );
            end if;
        end if;
    end process;
    
    -- =============================================================================
    -- PIPELINE STAGE 3: APPLY SIGN CONTROL AND GENERATE FINAL OUTPUTS
    -- =============================================================================
    pipeline_stage3: process(clk)
    begin
        if rising_edge(clk) then
            if reset_sync = '1' then
                output_a <= (others => '0');
                output_b <= (others => '0');
                output_c <= (others => '0');
                output_d <= (others => '0');
            else
                -- Apply sign control and generate final outputs
                if global_config.sign_control = '0' then
                    -- Force unsigned: clear sign bit, keep magnitude (0 to +32767)
                    output_a <= signed('0' & scaled_pattern_a_pipe2(14 downto 0));
                    output_b <= signed('0' & scaled_pattern_b_pipe2(14 downto 0));
                    output_c <= signed('0' & scaled_pattern_c_pipe2(14 downto 0));
                    output_d <= signed('0' & scaled_pattern_d_pipe2(14 downto 0));
                else
                    -- Allow signed: full range (-32768 to +32767)
                    output_a <= signed(scaled_pattern_a_pipe2);
                    output_b <= signed(scaled_pattern_b_pipe2);
                    output_c <= signed(scaled_pattern_c_pipe2);
                    output_d <= signed(scaled_pattern_d_pipe2);
                end if;
            end if;
        end if;
    end process;
    
    -- =============================================================================
    -- PIPELINE DATA ASSIGNMENT (for external monitoring if needed)
    -- =============================================================================
    pipeline_a.raw_pattern <= raw_pattern_a_pipe1;
    pipeline_a.scaled_counter <= scaled_counter_a_pipe1;
    pipeline_a.scaled_pattern <= scaled_pattern_a_pipe2;
    
    pipeline_b.raw_pattern <= raw_pattern_b_pipe1;
    pipeline_b.scaled_counter <= scaled_counter_b_pipe1;
    pipeline_b.scaled_pattern <= scaled_pattern_b_pipe2;
    
    pipeline_c.raw_pattern <= raw_pattern_c_pipe1;
    pipeline_c.scaled_counter <= scaled_counter_c_pipe1;
    pipeline_c.scaled_pattern <= scaled_pattern_c_pipe2;
    
    pipeline_d.raw_pattern <= raw_pattern_d_pipe1;
    pipeline_d.scaled_counter <= scaled_counter_d_pipe1;
    pipeline_d.scaled_pattern <= scaled_pattern_d_pipe2;
    
end architecture rtl;
