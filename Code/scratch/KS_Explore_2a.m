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
delay = 50;
% delay = 100;
duration_sec = 3;

%Derived parameters
p = delay + .5;
pitch_f0 = Fs/p;
numSamples = duration_sec*Fs;

%Processing varibles/objects
delayLine = CircularBuffer(delay);
x_n_1_ave = 0;
x_n_ave = 0;

%Removing the DC component and normalize it
bufferData = pinknoise(1, delay);
bufferData = bufferData - mean(bufferData);
bufferData = bufferData / max(abs(bufferData));
% bufferData = [1 zeros(1, delayLine.delay - 1)];
delayLine.initializeDelayLine(bufferData);

%Output buffers/temporary variables
y = zeros(1, numSamples);

%Processing loop
for n = 1:numSamples
    y(n) = delayLine.getCurrentSample();
    x_n_ave = delayLine.getCurrentSample();
    y(n) = .5*(x_n_ave + x_n_1_ave);
    x_n_1_ave = x_n_ave;
    delayLine.tick(y(n));
end

figure;
stem(0:numSamples-1, y);
title("KS Scratch Output");
ylim([0 1]);
xlim([0 3*delay+1]);

figure;
spectrogram(y, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('KS Scratch Spectrogram');
yline(pitch_f0/1000, "--r");