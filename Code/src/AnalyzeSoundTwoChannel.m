% clear all;
% close all;

path = "./sounds/Measurements/Noise Characterization/";
dataName =  "E-glass";
[y, Fs] = audioread(path+dataName + ".wav");
labels = {'AKG', 'DPA'};

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
legend(labels);

for channel = 1:size(y, 2)
    figure;
    spectrogram(y(:, channel), window, overlap, N, Fs, "yaxis");
    ylim([0 y_upperLim_kHz]);
    title(dataName + " " + labels(channel));
end