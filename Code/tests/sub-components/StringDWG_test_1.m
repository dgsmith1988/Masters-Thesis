%Test the StringDWG with a basic pluck

close all;
clear all;
dbstop if error

%String DWG Parameters
% stringParams = SystemParams.A_string_params;
stringParams = SystemParams.e_string_params;
% noiseType = "White";
noiseType = "Pink";
useNoiseFile = false;
% useNoiseFile = true;
L = SystemParams.minRelativeStringLength;

%System Processing Parameters
durationSec = 3;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs/2000;

%*******************************Test Begins********************************

%Generate the constant control signal
L = L*ones(1, numSamples);

%Processing objects
stringDWG = StringDWG(stringParams, L(1), noiseType, useNoiseFile);
y1 = zeros(1, numSamples);

%Processing loop
stringDWG.pluck(); %Set up the string to generate noise...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringDWG.consumeControlSignal(L(n));
    %zero is passed here as the is no input to the DWG
    y1(n) = stringDWG.tick(0);
end

plot(y1);
title("Single Plucked Note Test");

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Single Plucked Note Spectrogram')
pitch_f0 = calculatePitchF0(L(1), stringParams.f0);
yline(pitch_f0/1000, "--r");