%Test the HarmonicResonatorBank by sending in noise bursts to see the
%spectrum which is generated.

close all;
clear all;

dbstop if error;

%System parameters
Fs = SystemParams.audioRate;
duration_sec = 3;
numSamples = round(duration_sec*Fs);

%HRB characteristics
r = .99;
h_dB = SystemParams.h_dB;
% h_dB = 0:-2.5:-20;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = Fs/2000;

%Generate f_c control signal
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

%buffers to be filled during processing loop
x = zeros(1, numSamples);
y = zeros(1, numSamples);

%Processing objects
harmonicResonatorBank = HarmonicResonatorBank(h_dB, f_c(1), r);

%Processing loop
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    harmonicResonatorBank.consumeControlSignal(f_c(n));
    x(n) = Noise.tick();
    y(n) = harmonicResonatorBank.tick(x(n));
end

figure;
t = (0:n-1)/Fs;
spectrogram(y, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
hold on; 
for k = 1:length(h_dB)
    plot(t, k*f_c/1000, ':r');
end
hold off;
% title("Harmonic Resonator Test");