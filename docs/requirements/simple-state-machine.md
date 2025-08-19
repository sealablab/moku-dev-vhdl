# simple-state-machine

I believe the ProbeDriver state machine can be further simplififed. I think that we can:

## Simplify state machine 
* remove the 'FIRED' state: 
There is no architectural reason for this to be a 'state' - rather we can just track the fired status using the current status register. 


## Add the 'auto-arm' bit
Let's add an experimental feature called 'Auto-arm', when the 'auto-arm' input to ProbeDriver is set, it should transition directly from CoolDown -> Armed (skipping idle). 

### Plumb the auto-arm bit
I believe the auto-arm bit should be exposed via the Top level modules CR0[30] bit. 

The addition of these features should not change the outcome of the current testbench suite.

Before continuing, ask for any clarification necessary. 
