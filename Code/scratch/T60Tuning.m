%Script to compare the effects of different T60 values

clear;
close all;

%System parameters
Fs = 48000;
duration_sec = 3;
numSamples = round(duration_sec*Fs);

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = Fs/2000;

%Noise pulse characteristics
T60 = 4*10^(-3); %T60 in milliseconds

% %Constant Rate Test
% f_c = 250*ones(1, numSamples);

%Rate changing test
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

%buffers to be filled during processing loop
y = zeros(4, numSamples);
labels = [  "Noise Pulse Train - abs() and DC blocking", 
            "Noise Pulse Train - abs() no DC blocking", 
            "Noise Pulse Train - no abs() or DC blocking", 
            "Noise Burst Generator"];

%Processing objects
noisePulseTrain = NoisePulseTrain(f_cToTicks(f_c(1), Fs), T60);
noiseBurstGenerator = NoiseBurst(f_cToTicks(f_c(1), Fs), T60);

%Processing loop
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    noisePulseTrain.consumeControlSignal(f_c(n));
    noiseBurstGenerator.consumeControlSignal(f_c(n));
    [y(1, n), y(3, n)] = noisePulseTrain.tick();
    y(2, n) = abs(y(3, n));
    y(4, n) = noiseBurstGenerator.tick();
end

%Time-scale for plotting
t = (0:numSamples - 1)/Fs;

%Plot time-domain wavefoms
figure;
for k = 1:length(labels)
    subplot(length(labels), 1, k);
    plot(t, y(k, :));
    title(labels(k));
end

%Plot spectrograms
% figure;
for k = 1:length(labels)
    figure;
%     subplot(length(labels), 1, k);
    spectrogram(y(k, :), window, overlap, N, Fs, "yaxis");  
    title(labels(k));
    ylim([0 y_upperLim]);
end