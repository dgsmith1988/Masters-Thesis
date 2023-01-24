clear all;
close all;

%System parameters
Fs = 48000;
duration_sec = 3;
numSamples = Fs*duration_sec;

%Spectrogram parameters
N = 8*1024;
bins = 0:N-1;
windowLength = 12*10^-3*Fs; %12 ms window
window = rectwin(windowLength)';
% window = hamming(windowLength)';
overlap = .75*windowLength;
y_upperLim_kHz = Fs/2000;
% y_upperLim_kHz = 8;
dcBlocker = DCBlocker(.995);

x_white = 2*rand(1, numSamples) - 1.0;
x_pink =  pinknoise(1, numSamples);
x_pink = x_pink/max(x_pink);
w_0 = 3*2*pi/N;
x_sine = sin(w_0*(0:numSamples-1)) + 2;

% y_white = x_white - mean(x_white);
y_white = highpass(x_white, SystemParams.minPitch_f0, SystemParams.audioRate);
% y_white = dcBlocker.tick(x_white);
% y_pink = x_pink - mean(x_pink);
y_pink = highpass(x_pink, SystemParams.minPitch_f0, SystemParams.audioRate);
% y_pink = dcBlocker.tick(x_pink);
y_sine_td = x_sine - mean(x_sine);
y_sine_filt = dcBlocker.tick(x_sine);

X_white = abs(fft(x_white, N));
X_pink = abs(fft(x_pink, N));
Y_white = abs(fft(y_white, N));
Y_pink = abs(fft(y_pink, N));

x_white_mean = mean(x_white)
y_white_mean = mean(y_white)
x_pink_mean = mean(x_pink)
y_pink_mean = mean(y_pink)

figure;
subplot(2, 1, 1);
plot(0:N-1, X_white);
% xlim([0 5]);
title("X White");
subplot(2, 1, 2);
plot(0:N-1, Y_white);
% xlim([0 5]);
title("Y White");

figure;
subplot(2, 1, 1);
plot(0:N-1, X_pink);
% xlim([0 5]);
title("X Pink");
subplot(2, 1, 2);
plot(0:N-1, Y_pink);
% xlim([0 5]);
title("Y Pink");