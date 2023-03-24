clear all;
close all;

path = "C:\Users\Graham\Documents\McGill\M.A\Thesis\Masters-Thesis\LaTeX\Thesis\sound examples\";
dataName =  "SlideLick-High-e";
[x, Fs] = audioread(path+dataName + ".wav");

f_c = SystemParams.e_string_params.f0 - 20;

y = highpass(x, f_c, Fs);

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
% window = hamming(windowLength);
window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs/2000;
% y_upperLim_kHz = 8;

%Plotting code
t = (0:length(y)-1)/Fs;

figure;
plot(t, y);
title(dataName);
xlabel("Sec");
ylabel("Amplitude");

figure;
spectrogram(y, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title(dataName);

figure;
yin(y, Fs);
% yinOut = yin(y, Fs);
% figure;
% plot(yinOut.f0);