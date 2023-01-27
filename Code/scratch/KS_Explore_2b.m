%Basic script to examine the KS implementation for comparison purposes...

clear all;
close all;

%System Parameters
Fs = 48000;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs/2000;

%Sound parameters
% delay = 480;
delay = 100;
duration_sec = 3;

%Derived parameters
p = delay + .5;
pitch_f0 = Fs/p;
numSamples = duration_sec*Fs;

%Processing varibles/objects
% loopFilter = FilterObject([.5 .5], 1, 0);
loopFilter = LoopOnePole(SystemParams.e_string_params.a_pol, SystemParams.e_string_params.g_pol, 1);
delayLine = pinknoise(1, delay);
x_n_1_ave = 0;
x_n_ave = 0;
ptr = 1;

%Removing the DC component and normalize it
delayLine = delayLine - mean(delayLine);
delayLine = delayLine / max(abs(delayLine));

%Output buffers/temporary variables
y = zeros(1, numSamples);

%Processing loop
for n = 1:numSamples
    y(n) = loopFilter.tick(delayLine(ptr));
    delayLine(ptr) = y(n);
    ptr = ptr + 1;
    if ptr > delay
        ptr = 1;
    end
end

figure;
plot(y);
title("KS Scratch Output");

figure;
spectrogram(y, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('KS Scratch Spectrogram');
yline(pitch_f0/1000, "--r");