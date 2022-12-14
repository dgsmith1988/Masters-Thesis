%Test the String Synth without a CSG and no slide motion

close all;
clear;
dbstop if error

%System processing parameters
stringParams = SystemParams.A_string_params;
stringParams.n_w = -1; %indicate that we don't use a CSG
stringModeFilterSpec = SystemParams.A_string_modes.chrome;
waveshaperFunctionHandle = @tanh;
durationSec = 3;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = 15; %corresponds to 15kHz on the frequency axis

%Generate the constant control signal
L = ones(1, numSamples);

%Processing objects
stringSynth = StringSynth(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L(1));
y1 = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate noise...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringSynth.consumeControlSignal(L(n));
    y1(n) = stringSynth.tick();
end

plot(y1);
title("Single Plucked Note Test");

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Single Plucked Note Spectrogram')