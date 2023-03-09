%Test the HarmonicResonatorBank by sending in noise bursts to see the
%spectrum which is generated.

%TODO: Develop a more robust suite of tests later

% close all;
% clear;

dbstop if error;

%System parameters
Fs = SystemParams.audioRate;
duration_sec = 3;
numSamples = round(duration_sec*Fs);

%Noise pulse and resonator characteristics
period_samp = 0;
T60 = SystemParams.D_string_params.T60;
r = .99;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
% window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
% y_upperLim = 7; %corresponds to 5kHz on the frequency axis
y_upperLim = Fs/2000;

%Generate f_c control signal
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

%buffers to be filled during processing loop
nb = zeros(1, numSamples);
y1 = zeros(1, numSamples);

%Processing objects
% noiseBurst = NoiseBurst(period_samp, T60);
harmonicResonatorBank = HarmonicResonatorBank(f_c(1), r);

%Processing loop
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
%     noiseBurst.consumeControlSignal(f_c(n));
    harmonicResonatorBank.consumeControlSignal(f_c(n));
%     nb(n) = noiseBurst.tick();
    nb(n) = Noise.tick();
    y1(n) = harmonicResonatorBank.tick(nb(n));
end

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
hold on; 
plot((0:n-1)/Fs, f_c/1000, ':r');
plot((0:n-1)/Fs, 2*f_c/1000, ':r');
plot((0:n-1)/Fs, 3*f_c/1000, ':r');
plot((0:n-1)/Fs, 4*f_c/1000, ':r');
plot((0:n-1)/Fs, 5*f_c/1000, ':r');
plot((0:n-1)/Fs, 6*f_c/1000, ':r');
hold off;
% title("Harmonic Resonator Test");