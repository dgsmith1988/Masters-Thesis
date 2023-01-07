function L = generateL(startingFret, endingFret, duration_sec, Fs)

numSamples = duration_sec * Fs;

startingStringLength = fretNumberToRelativeLength(startingFret);
endingStringLength = fretNumberToRelativeLength(endingFret);

frequencyRatio = startingStringLength/endingStringLength;
sampleRatio = frequencyRatio^(1/numSamples);

L = ones(1, numSamples);
L(1) = startingStringLength;

for n = 2:numSamples
    L(n) = L(n-1)/sampleRatio;
end

end