%Test the Slide Synth without a CSG and no slide motion

close all;
% clear;
dbstop if error

%Synthsizer sound parameter settings
CSG_noiseSource = "NoisePulseTrain";
CSG_harmonicAccentuator = "ResoTanh";
stringBufferInit = "PinkNoise";
slideType = "Brass";
string = "A";
durationSec = 3;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = 24;

%***************************Don't Touch Below Here***************************%
%Derived parameters
stringParams = SystemParams.A_string_params;
stringParams.n_w = -1; %indicate that we don't use a CSG
stringModeFilterSpec = SystemParams.A_string_modes.chrome;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;

%Generate the constant control signal
L = ones(1, numSamples);

%Processing objects
slideSynth = SlideSynth(stringParams, stringModeFilterSpec, L(1));
y1 = zeros(1, numSamples);

%Processing loop
slideSynth.pluck(); %Set up the string to generate noise...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    slideSynth.consumeControlSignal(L(n));
    y1(n) = slideSynth.tick();
end

plot(y1);
title("Single Plucked Note Test");

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Single Plucked Note Spectrogram')