# clarify-top-register.md 

I think we can / should clarify the register layout inside the top probe driver module.

Specifically on lines 24-28
```
    -- ProbeDriverStatusRegister (PDSR)
    signal probe_driver_status_register : std_logic_vector(4 downto 0);
    -- TopLevel Status Register (16 bits)
    signal toplevel_status_register : std_logic_vector(15 downto 0);
```

Please analyze this module and suggest a simplified register layout.
(I think we can/ probably should 'mirror' or 'route' all fields defined in the PDSR to the bottom 5 bits of the top level status register.


