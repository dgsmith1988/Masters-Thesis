%Place to work out details associated with parabolic interpolation spectral
%estimation
%https://ccrma.stanford.edu/~jos/sasp/Quadratic_Interpolation_Spectral_Peaks.html

close all;
clear;
% dbstop if error

%FFT size
N = 1024;
bins = 0:N-1;

%Basic signal parameters
durationSec = 3;
Fs = SystemParams.audioRate;
Ts = 1/Fs;
numSamples = durationSec * Fs;
n = 0:numSamples-1;
% f = [100 970 6005];
N_bin = [35 72 250]-.25;
f = (N_bin)*Fs/N;
A = [1 .5 .25];

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = rectwin(windowLength);
overlap = .75*windowLength;
y_upperLim_kHz = 24;

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

X_fft = fft(sum(x), N);

figure;
stem(bins, abs(X_fft));
title("X FFT");
xlabel("BIN");
% xlim([0 N/2-1]);
%     ylim([-1.1 1.1]);
grid on; grid minor;
xline(N_bin, 'r');

%get the interpolation points for each estimate
[~, I] = mink(abs(bins - N_bin'), 3, 2);
interp_bins = bins(I);