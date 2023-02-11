function L = generateLCurve(startingFret, endingFret, duration_sec, Fs)
%Generate an L[n] signal going from the starting fret to the ending fret
%over the specified duration at the specified sampling rate.

%TODO: Comeback and rework this function to be more accurate using
%something like logspace() if possible (depends on if you can work out the
%change of base formula). Would this even be beneficial?

arguments
    startingFret    {mustBeNonnegative, mustBeFinite}
    endingFret      {mustBeNonnegative, mustBeFinite}
    duration_sec    {mustBePositive, mustBeFinite}
    Fs              {mustBePositive, mustBeInteger}
end

% numSamples = duration_sec * Fs;
% assert(mod(numSamples, 1) == 0, "At this point the we only support an integer number of samples")
numSamples = round(duration_sec * Fs);

startingStringLength = fretNumberToRelativeLength(startingFret);
endingStringLength = fretNumberToRelativeLength(endingFret);

frequencyRatio = startingStringLength/endingStringLength;

%change in frequency across each sample
sampleRatio = frequencyRatio^(1/(numSamples-1));

%Compute the geometric sequence
n = 0:numSamples-1;
L = startingStringLength * sampleRatio.^(-n);

%TODO: Think about just setting the end value to be that value to eliminate
%the numerical precision error

%If anything is greater than 1 (which should only happen when 0 is
%specified as a fret value due to numerical precision errors), then just
%make it a 1.
L(L>1) = 1;
end