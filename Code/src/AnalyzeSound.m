% clear all;
% close all;

% path = "Single Winding Stimulation\";
path = "Slide Licks\";
dataName =  "High e-string";
% dataName =  "High e-string brass";
[y, Fs] = audioread(path+dataName + ".wav");

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
% window = hamming(windowLength);
window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
% y_upperLim_kHz = Fs/2000;
y_upperLim_kHz = 8;

%Plotting code
t = (0:length(y)-1)/Fs;

figure;
plot(t, y);
% title(dataName + " L2T Coupling Test");
title(dataName);
xlabel("Sec");
ylabel("Amplitude");

figure;
spectrogram(y, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
% title(dataName + " L2T Coupling Spectrogram");
title(dataName);

figure;
yin(y, Fs);