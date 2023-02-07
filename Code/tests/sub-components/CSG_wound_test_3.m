%Test the wound CSG object in the scenario where the slide doesn't move to
%ensure it outputs zeros

close all;
clear all;

dbstop if error;

%System parameters
Fs = SystemParams.audioRate;
stringParams = SystemParams.D_string_params;
stringModeFilterSpec = SystemParams.D_string_modes.chrome;
duration_sec = 2;
numSamples = round(Fs*duration_sec);

%Configure the noise source and harmonic accentuator
% noiseSource = "Burst";
noiseSource = "PulseTrain";
% harmonicAccentuator = "HarmonicResonatorBank";
harmonicAccentuator = "ResoTanh";

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
% window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = 5; %corresponds to 5kHz on the frequency axis

%A slide speed of zero corresponds to an f_c of 0
slideSpeed = 0;

%create/initialize the processing objects
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, noiseSource, harmonicAccentuator);
csg_wound.g_user = 1;   %maximize the signal
y7 = zeros(1, numSamples);

%Processing loop
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    csg_wound.consumeControlSignal(slideSpeed);
    y7(n) = csg_wound.tick();
end

figure;
plot(y7);
title("Wound CSG No Slide Motion Output");

figure;
spectrogram(y7, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Wound CSG No Slide Motion Spectrogram')
% yline([stringModeFilterSpec.poles.F(1), stringModeFilterSpec.poles.F(3)]/1000, 'r');