clear;

%Processing parameters
durationSec = 2;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;

%Processing objects
stringSynth = StringSynth(SystemParams.A_string_params);
y = zeros(1, numSamples);

%Processing loop
for n = 1:numSamples
    y(n) = stringSynth.tick();
end

%plot(y);
yin(y', Fs)