%Generate the noise files to make it easier to compare between
%configurations while developing/testing

close all;
clear all;
dbstop if error

%System processing parameters
stringParams = SystemParams.A_string_params;
durationSec = 3;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;
noiseType = "Pink";

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs/2000;

%Generate the constant control signal
L = ones(1, numSamples);

%Processing objects
stringDWG = StringDWG(stringParams, L(1), noiseType, false);
y1 = zeros(1, numSamples);

%Processing loop
noiseData = stringDWG.pluck(); %Set up the string to generate noise...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringDWG.consumeControlSignal(L(n));
    y1(n) = stringDWG.tick(0);
end

plot(y1);
title("Noise File Generation");

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Noise File Generation')

% audiowrite("sounds/pinkNoise.wav", noiseData, Fs);
% audiowrite("sounds/whiteNoise.wav", noiseData, Fs);