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
% delay = 150;
% delay = 100;
delay = 75.3;
% delay = 75;
% delay = 25;
duration_sec = 3;

%Processing varibles/objects
loopFilter = LoopOnePole(SystemParams.e_string_params.a_pol, SystemParams.e_string_params.g_pol, 1);
% delayLine = CircularBuffer(delay);
delayLine = Lagrange_v2(5, delay);
x_delay = 0;

%Derived parameters
p = delay + loopFilter.phaseDelay;
pitch_f0 = Fs/p;
numSamples = duration_sec*Fs;

%Removing the DC component and normalize it
% bufferData = pinknoise(1, delayLine.bufferDelay);
bufferData = pinknoise(1, delayLine.M);
bufferData = bufferData - mean(bufferData);
bufferData = bufferData / max(abs(bufferData));
% bufferData = [0 0 0 1 zeros(1, delayLine.bufferDelay - 4)];
% delayLine.initializeDelayLine(bufferData);
delayLine.initializeNonInterpolatingPart(bufferData);

%Output buffers/temporary variables
y = zeros(1, numSamples);

%Processing loop
for n = 1:numSamples
    x_delay = delayLine.getCurrentSample();
    y(n) = loopFilter.tick(x_delay);
%     delayLine.tick(y(n));
    delayLine.writeSample(y(n));
    delayLine.incrementPointers();
end

figure;
stem(0:numSamples-1, y);
title("KS Scratch Output");
xlim([-1 3*delay + 1]);
ylim([0 1.1]);
grid on;
grid minor;

figure;
spectrogram(y, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('KS Scratch Spectrogram');
yline(pitch_f0/1000, "--r");