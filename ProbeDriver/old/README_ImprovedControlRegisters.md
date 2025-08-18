# Improved Control Register Layout for ProbeDriver

 
CR0[31]: This should be treated as a -global' nEnable bit and mapped to both the 'top' and 'probedriver' enable inputs 
CR0[23]: soft trigger in
CR0[22:16]: **7**-bit intensity-Index
CR0[15:0]:  **16**-bit duration_in 

CR1[31:16]: **16-bit** CoolDown-in 
## Changes: 
Note that the 'intensity' - this can be subtle. 
### IntensityLUT
The IntensityLUTs are **exactly** 101 units wide. 
IntensityLut[0] shall always be 0x00
IntensityLut[1] shall be the lowest observable intensity value
IntensityLut[100] shall be the largest safe intensity value



