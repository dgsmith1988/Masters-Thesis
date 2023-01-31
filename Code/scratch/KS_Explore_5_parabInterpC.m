%Basic script to experiment with parabolic interpolation of KS algorithm
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
pitch_f0 = 80 * Fs / N;
period_samples = calculateTotalDWGLength(pitch_f0, Fs);
interpDelay = calculateInterpDelayLineLength(period_samples, LoopOnePole.phaseDelay);
% delay = 75;
% delay = 25.6;
duration_sec = 3;
numSamples = duration_sec*Fs;

%Processing varibles/objects
loopFilter = LoopOnePole(SystemParams.e_string_params.a_pol, SystemParams.e_string_params.g_pol, 1);
% loopFilter = FilterObject([.5 .5], 1, 0);
delayLine = Lagrange(5, interpDelay);
x_delay = 0;

%Removing the DC component and normalize it
bufferData = pinknoise(1, delayLine.M);
bufferData = bufferData - mean(bufferData);
bufferData = bufferData / max(abs(bufferData));
% bufferData = [0 0 0 1 zeros(1, delayLine.bufferDelay - 4)];
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
plot(y);
title("KS Scratch Output");

%Perform the spectral parabolic interpolation to estimate the f0 of the
%signal
start = numSamples/2;
stop = start + N - 1;
Y = fft(y(start:stop).*(hamming(N)'), N);
% Y = fft(y, N);
Y_dB = mag2db(abs(Y));

[M, I] = max(Y_dB(1:N/2));
alpha = Y_dB(I-1);
beta = Y_dB(I);
gamma = Y_dB(I+1);

p = 1/2 * (alpha-gamma) / (alpha - 2*beta + gamma)
assert(abs(p) <= .5);
bin_estimate = I - 1 + p
y_estimate = beta - 1/4 * (alpha - gamma)*bin_estimate;
% pitch_f0 * N/Fs = Fs/period_samples * N/Fs = N/period_samples;
f0_bin = N / period_samples
bin_err = f0_bin - bin_estimate
err_hz = bin_err * Fs / N

figure;
plot(0:N-1, Y_dB, "DisplayName", "Y dB");
title("Y dB");
xlabel("BIN");
xline(f0_bin, "r", "DisplayName", "True Value");
xline(bin_estimate, "g", "DisplayName", "Estimated Value");
legend();
grid on; grid minor;
xlim([0 N/2-1]);

figure;
spectrogram(y, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('KS Scratch Spectrogram');
yline(pitch_f0/1000, "--r");
yline(bin_estimate*Fs/N/1000, "--k");