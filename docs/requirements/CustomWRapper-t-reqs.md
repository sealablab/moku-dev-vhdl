# Readme-CustomWrapper-TB-reqs

We have a problem across our source tree, and I am unsure how to best resolve it.

The end goal of our synthesis is to create a module that implementes the `CustomWrapper` module definition. (This is controlled by an outside vendor).


Right now, one big issue is that we re-create the overall structure repeatedly (most notably in testbenches).


I would like you to think of a 'good' way to handle this. 


Similiarly - we have a lot of Makefiles laying around the individual modules. Most of them are pretty simple, but all of them are duplicative.  

## Possible solutions

Perhaps we should create a 'top-level' MokuModels directory (inside the 'hdl-moku-dev') sub-module. It can serve as a useful reference to both humans and cursor.

I.e. 
'moku-dev-vhdl' / MokuModules / 
'MokuCustomWrapper.vhd' - the complete CustomWrapper defintion
'Moku-Go.vhd' - this corresponds to the physical MokuGo hardware.



I can/will provide the module definitions. What i need help with is:
* consistently 'including' them inside the ghdl testbenches 
* consistently avoid dupklicating the 'CustomWrapper' module anywhere else


