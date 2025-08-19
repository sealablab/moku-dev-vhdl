-- probe_driver_core_gen_2.vhd
-- Enhanced implementation with more features

entity probe_driver_core_gen_2 is
    port (
        clk                    : in  std_logic;
        reset                  : in  std_logic;
        enable                 : in  std_logic;
        clk_en                 : in  std_logic;
        status_clear           : in  std_logic;  -- Added
        
        config_intensity_index : in  probe_intensity_index_type;
        config_pulse_duration  : in  probe_duration_type;
        config_cooldown_period : in  probe_cooldown_type;
        
        probe_trigger_input    : in  std_logic;
        probe_auto_arm         : in  std_logic;  -- Added
        
        probe_trigger_output   : out signed(15 downto 0);
        probe_intensity_output : out signed(15 downto 0);
        probe_status_register  : out probe_status_type
    );
end entity;
