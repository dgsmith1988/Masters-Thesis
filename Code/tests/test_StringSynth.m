% clear;
dbstop if error
writeAudioFlag = false;

%Processing parameters
durationSec = 2.5;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;

%********Basic test - No CSG, static pitch
L = ones(1, numSamples);
%Processing objects
stringSynth = StringSynth(SystemParams.B_string_params, L(1));
y = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate noise... 
for n = 1:numSamples
    y(n) = stringSynth.tick(L(n));
end

plot(y);
sound(.5*y, Fs)
if writeAudioFlag
    audiowrite("StringSynth - test 1 output.wav", y, Fs);
end
% yin(y', Fs)

%********Basic test - No CSG, half step slide

%Generate the appropriate control signal
startingStringLength = 1;
halfStepRatio = 2^(1/12);
endingStringLength = startingStringLength / halfStepRatio;
sampleRatio = halfStepRatio(1)^(1/(numSamples/2-1));

L = ones(1, numSamples);
L(1) = startingStringLength;
for n = numSamples/2+1:numSamples
    L(n) = L(n-1)/sampleRatio;
end

%Processing loop
stringSynth.pluck(); %Set up the string to generate noise... 
for n = 1:numSamples
    y(n) = stringSynth.tick(L(n));
end

plot(y);
sound(.5*y, Fs)
if writeAudioFlag
    audiowrite("StringSynth - test 2 output.wav", y, Fs);
end