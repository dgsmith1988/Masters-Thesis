clear all;
close all;

%Read in the files/data
[synthesized, Fs] = audioread("SlideLick-A-Synth.wav");
[recorded, ~] = audioread("SlideLick-A-Rec.wav");

%Spectrogram analysis parameters
windowLength = round(12*10^-3*Fs); %23 ms window
window = hamming(windowLength);
overlap = round(.75*windowLength);
N = 4096;
y_upperLim_kHz = Fs/2000;
% y_upperLim_kHz = 8;

figure;
spectrogram(synthesized, window, overlap, N, Fs, "yaxis");
title("Synthesized Lick - A String");
ylim([0 y_upperLim_kHz]);

figure;
spectrogram(recorded, window, overlap, N, Fs, "yaxis");
title("Recorded Lick - A String");
ylim([0 y_upperLim_kHz]);