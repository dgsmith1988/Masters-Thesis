function [L] = fretNumberToRelativeLength(fretNumber)
%Take in a specified fret number (doesn't need to be an integer) and return
%the corresponding relative string length associated with it
arguments
    fretNumber double {mustBeNonnegative, mustBeFinite}
end

L = 2.^(-fretNumber/12);
end

