clear all;
close all;

[y1, Fs] = audioread("\sounds\AllCapoed.wav");
y2 = audioread("\sounds\WebSound3.wav");
y3 = audioread("\sounds\WebSound1repeated.wav");

%Spectrogram analysis parameters
windowLength = round(12*10^-3*Fs); %23 ms window
window = hamming(windowLength);
overlap = round(.75*windowLength);
N = 4096;
% y_upperLim_kHz = Fs/2000;
y_upperLim_kHz = 8;

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");
title("All Capoed");
ylim([0 y_upperLim_kHz]);

figure;
spectrogram(y2, window, overlap, N, Fs, "yaxis");
title("Web Sound 3");
ylim([0 y_upperLim_kHz]);

figure;
spectrogram(y3, window, overlap, N, Fs, "yaxis");
title("Web Sound 1 Repeated");
ylim([0 y_upperLim_kHz]);