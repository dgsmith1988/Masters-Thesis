% clear;
dbstop if error
%Processing parameters
durationSec = 2.5;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;

L = ones(1, numSamples);
%Processing objects
stringSynth = StringSynth(SystemParams.E_string_params, L(1));
y = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate noise... 
for n = 1:numSamples
    y(n) = stringSynth.tick(L(n));
end

plot(y);
sound(.5*y, Fs)
% audiowrite("string_out.wav", y, Fs);
% yin(y', Fs)