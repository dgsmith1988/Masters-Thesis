%Place to work out details associated with parabolic interpolation spectral
%estimation using sines
%https://ccrma.stanford.edu/~jos/sasp/Quadratic_Interpolation_Spectral_Peaks.html

close all;
clear;
% dbstop if error

%FFT size
N = 8*1024;
bins = 0:N-1;

%Basic signal parameters
durationSec = 3;
Fs = SystemParams.audioRate;
Ts = 1/Fs;
numSamples = durationSec * Fs;
n = 0:numSamples-1;
N_bin = [37 100 250] - 0.0;
f = (N_bin)*Fs/N;
A = 1;
A = [A A/2 A/4];

%Window parameters
windowLength = 12*10^-3*Fs; %12 ms window
% window = rectwin(windowLength)';
window = hamming(windowLength)';

%A place to store the syntheziezed tones
x = A'.*sin(2*pi*f'*(n*Ts));

figure;
numTones = size(x, 1);
for i = 1:numTones
    subplot(numTones, 1, i);
    plot(n, x(i, :));
    title(sprintf("x%i", i));
    xlabel("n");
    xlim([0 500]);
    ylim([-1.1 1.1]);
    grid on; grid minor;
end

%mix them all down to one signal and plot
x = sum(x);
figure;
subplot(2, 1, 1);
plot(n, x);
title("x mix-down");
xlabel("n");
xlim([0 700]);
ylim([-1.75 1.75]);
grid on; grid minor;

%grab a frame of the signal and window it
v = window .* x(1:windowLength);
subplot(2, 1, 2);
plot(0:windowLength - 1, v);
title("windowed signal");
grid on; grid minor;

V_fft = fft(x, N);
V_dB = mag2db(abs(V_fft(1:N/2)));

%get the bin with the highest peak (corresponding to the strongest resonance)
%and the corresponding points required for interpolation
[M, I] = max(V_dB);
alpha = V_dB(I-1);
beta = V_dB(I);
gamma = V_dB(I+1);

%calculate the estimated bin and the corresponding magnitude
p = 1/2 * (alpha-gamma) / (alpha - 2*beta + gamma)
assert(abs(p) <= .5);
bin_estimate = I - 1 + p
y_estimate = beta - 1/4 * (alpha - gamma)*bin_estimate
err_hz = (bin_estimate - N_bin(1))*Fs/N

figure;
plot(bins(1:N/2), V_dB);
title("V dB");
xlabel("BIN");
% xlim([0 N/2-1]);
%     ylim([-1.1 1.1]);
grid on; grid minor;
xline(N_bin(1), 'r');
xline(bin_estimate, 'g');