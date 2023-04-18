clear all;
close all;

path = "../Data/Recordings/T60-v2 - Single Winding/";
% path = "../sounds/Measurements/Noise Characterization/";
dataName =  "E-string";
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

y_norm = [y(:, 1)/max(abs(y(:, 1))), y(:, 2)/max(abs(y(:, 2)))];
figure;
subplot(2, 1, 1);
plot(t, abs(y_norm(:, 1)));
% plot(t, y_norm(:, 2));
title(dataName + " " + labels{1});
xlabel("Sec");
ylabel("Amplitude");
xlim([0 t(end)]);
% ylim(.75*[-1 1])
% subplot(2, 1, 2);
% plot(t, abs(y_norm(:, 2)));
plot(t, -y_norm(:, 2));
title(dataName + " " + labels{2});
xlabel("Sec");
ylabel("Amplitude");
xlim([0 t(end)]);
% ylim(.75*[-1 1])

for channel = 1:size(y, 2)
    figure;
    spectrogram(y(:, channel), window, overlap, N, Fs, "yaxis");
    ylim([0 y_upperLim_kHz]);
    title(dataName + " " + labels(channel));
end