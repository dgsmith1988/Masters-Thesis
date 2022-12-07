function [fretNumber] = relativeLengthToFretNum(L)
%Convert the relative string length to the fret number/exponent value to
%raise the half-step ratio to based on the formula 
%   f_n = f_os*2^(fretNum/12)
%where:
%   f_n = fundamental of note at corresponding fret/relative lenght
%   f_os = fundamental of the open string (or zero fret)
%   fretNum = fret number corresponding to relative string length (can be
%   non-integer values)
fretNumber = -12*log2(L);
end

