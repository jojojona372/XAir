# README
## XAir
A function for calculating properties of air, similar to XSteam.  

License: GNU AGPLv3  
Author: Jona van der Pal  
Original date: 22-02-2022  
Current version: 07032022  
### Description:  
A function to calculate properties of air according to B.G. Kyle, Chemical and Process
Thermodynamics (Englewood Cliffs, NJ: Prentice-Hall, 1984)  
Similar functionality to XSteam.  
See documentation in the code for a full explanation of what each
function does.  
Available functions: 'h_T', 'T_h', 'T_ps', 'h_ps', 'p_hs', 'p_Ts', 's_Tp', 's_ph', 'load',
'reset', 'delete', 'clear', 'unit', 'info'.  
Using 's_pT' instead of 's_Tp', also works. This is a format that XSteam users should be familiar with.

## xa
### Description:
The function xa works exactly like XAir, except you can use arrays as input, not just single variables.  
For example: If you want to calculate the enthalpy for 10 different pressures and 5 different entropy values, you should use xa. You will get a 10x5 array of enthalpy values as output.  
Of course it's also faster to type "xa" instead of "XAir" :-)  

### To get the most out of both functions, read the documentation in the code. I promise it's worth the effort.  
