# Register terminology 
We use the following naming conventions for different types of registers.  

* Control Registers
* Configuration Registers
* Status Registers

## Control Registers
**Purpose**: Real-time manipulation of module state during operation. **Control registers** are driven directly by the instantiating module, and __should never be assigned or written to__ by the module itself.

``` vhdl
entity my_new_module is
    port (

	    -- Control regi: toggled frequently during runtime
        clk                    : in  std_logic;
        reset                  : in  std_logic;
        enable                 : in  std_logic;
        clk_en                 : in  std_logic;
```
## Configuration Registers
**Purpose:** Configuration registers function exclusively as __inputs__ to the  vhdl module. **Configuration Registers** should never be directly assigned or written to by the module itself.

``` vhdl
        -- Configuration registers
		config_intensity_in    : in  probe_intensity_index_type;
		config_pulse_duration  : in  probe_duration_type;
		...
```
## Status Registers
**Purpose:** Status registers are used to represent internal module state to the outside world. __Any attempt to write to them from the outside world should be treated as an error__.
``` vhdl
        probe_status_register  : out probe_status_type;
	); --end port map
end entity;

```

## Usage examples: 
A top level module can __read and write__ to control registers at any time. The module itself can only __read__ them.

A top level module can __read and write__ to a configuration register at anytime, however, the module itself will only **read** (and potentially validate) the values of incoming configuration register parameters on reset. 

A top level module can __read__ a status register at any time. The module itself can __read and write__ them at any time.

In short, you can think of 'Configuration Registers' as inputs to your module, and 'Status registers' as outputs.



