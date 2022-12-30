function [fretNumber] = relativeLengthToFretNumber(L)
%Convert the relative string length to the fret number/exponent value to
%raise the half-step ratio.

arguments
    L double {mustBePositive, mustBeLessThanOrEqual(L, 1)}
end

fretNumber = -12*log2(L);
end

