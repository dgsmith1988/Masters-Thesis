%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        %
% Instructions for the MATLAB Files associated with the article          %
%                                                                        %
% Timo I. Laakso, Vesa Valimaki, Matti Karjalainen, and Unto K. Laine,   %
% "Splitting the unit delay - tools for fractional delay filter design," %
% IEEE Signal Processing Magazine, vol. 13, no. 1, January 1996.         %
%                                                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

The accompanying set of MATLAB routines can be used to design fractional
delay FIR and allpass filters and to plot their responses.
The basic MATLAB and the MATLAB Signal Processing Toolbox are needed.

The Figures included in the above article can be plotted using 
the files FDFIR2.M and FDAP2.M. The former generates the 
magnitude and phase delay curves and the impulse responses 
for FIR fractional delay (FD) filters. The latter gives the phase 
delay responses and the impulse responses of the allpass 
fractional delay filters. These two functions use the other files 
which are the actual filter design functions and their subroutines.

The FIR FD package consists of the following 11 MATLAB routines (m-files):

fdfir2.m (main program)
iniheq2.m
inihip2.m
inihsin2.m
hsincw2.m
hsplin2.m
hgls2.m
hlagr2.m
heqrip2.m
hcontro2.m
firfar2.m

The allpass FD package consists of the following MATLAB routines (m-files):

fdap2.m (main program)
aplsp2.m
aplspi2.m
aplspd2.m
aplspdi2.m
apflat2.m
apeqp2.m
apeqpd2.m
apfar2.m
bincof2.m
eigsolv2.m
envelop2.m
numint2.m

Comments or suggestions can be sent by e-mail to 
Timo I. Laakso <laaksot@cmsa.westminster.ac.uk> or to 
Vesa Valimaki <vesa.valimaki@hut.fi>.

This software is being provided to you, the LICENSEE, by Helsinki
University of Technology (HUT) under the following license. 
By obtaining, using and/or copying this software, you agree that you 
have read, understood, and will comply with these terms and conditions:  

Permission to use, copy, modify and distribute, including the right to grant 
others rights to distribute at any tier, this software and its documentation 
for any purpose and without fee or royalty is hereby granted, provided that you 
agree to comply with the following copyright notice and statements, including 
the disclaimer, and that the same appear on ALL copies of the software and 
documentation, including modifications that you make for internal use or for 
distribution:

Copyright 1996 by Helsinki University of Technology (HUT)
All rights reserved.  

The allpass design package is copyrighted by NOKIA, MIT, and GE (1994).

THIS SOFTWARE IS PROVIDED "AS IS", AND Helsinki University of Technology MAKE NO 
REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED.  By way of example, but not 
limitation, Helsinki University of Technology MAKE NO REPRESENTATIONS OR WARRANTIES OF 
MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE OR THAT THE USE OF THE 
LICENSED SOFTWARE OR DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS, 
COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.   

The name of the HUT may NOT be used in advertising or publicity pertaining 
to distribution of the software.  
Title to copyright in this software and any associated documentation 
shall at all times remain with the HUT and USER agrees to preserve same.  

Enjoy your designs!

Timo Laakso and Vesa Valimaki
London, January 26, 1996

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%