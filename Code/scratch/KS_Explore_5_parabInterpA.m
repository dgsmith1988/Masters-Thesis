%Experiment with parablolic interpolation here

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
% delay = 100;
delay = 36;
duration_sec = 3;
libre
%Derived parameters
period_samples = delay + .5;
pitch_f0 = Fs/period_samples;
numSamples = duration_sec*Fs;

%Processing varibles/objects
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
    x_n_ave = delayLine(ptr);
    y(n) = .5*(x_n_ave + x_n_1_ave);
    x_n_1_ave = x_n_ave;
    delayLine(ptr) = y(n);
    ptr = ptr + 1;
    if ptr > delay
        ptr = 1;
    end
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