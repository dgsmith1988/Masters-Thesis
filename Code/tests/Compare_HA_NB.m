%Compare the different harmonic accentuator methods using the noise burst
%as a sound source.

% close all;
% clear all;

dbstop if error;

%System parameters
Fs = SystemParams.audioRate;
duration_sec = 3;
numSamples = round(duration_sec*Fs);

%Noise pulse and resonator characteristics
period_samp = 0;
T60 = SystemParams.D_string_params.T60;
r = .99;
preTanhGain = 7;

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
nb = zeros(1, numSamples);  %noise burst signal
ro_nb = zeros(1, numSamples);  %resonator output to understand processing chain
y_nb_hrb = zeros(1, numSamples);
y_nb_rt = zeros(1, numSamples);

%Processing/generation objects
noiseBurst = NoiseBurst(period_samp, T60);
harmonicResonatorBank = HarmonicResonatorBank(f_c(1), r);
resoTanh = ResoTanh(f_c(1), r, preTanhGain);

%Processing loop for hard clipped noise pulse train
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    %generate the various stimuli first
    noiseBurst.consumeControlSignal(f_c(n));
    harmonicResonatorBank.consumeControlSignal(f_c(n));
    resoTanh.consumeControlSignal(f_c(n));
    nb(n) = noiseBurst.tick();
    y_nb_hrb(n) = harmonicResonatorBank.tick(nb(n));
    [y_nb_rt(n), ro_nb(n)] = resoTanh.tick(nb(n));
end

figure;
spectrogram(nb, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
hold on; 
plot((0:n-1)/Fs, f_c/1000, ':r');
plot((0:n-1)/Fs, 2*f_c/1000, ':r');
plot((0:n-1)/Fs, 3*f_c/1000, ':r');
plot((0:n-1)/Fs, 4*f_c/1000, ':r');
plot((0:n-1)/Fs, 5*f_c/1000, ':r');
plot((0:n-1)/Fs, 6*f_c/1000, ':r');
hold off;
title("NB Source");

figure;
spectrogram(ro_nb, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
hold on; 
plot((0:n-1)/Fs, f_c/1000, ':r');
plot((0:n-1)/Fs, 2*f_c/1000, ':r');
plot((0:n-1)/Fs, 3*f_c/1000, ':r');
plot((0:n-1)/Fs, 4*f_c/1000, ':r');
plot((0:n-1)/Fs, 5*f_c/1000, ':r');
plot((0:n-1)/Fs, 6*f_c/1000, ':r');
hold off;
title("RO Intermediate-NB Test");

figure;
spectrogram(y_nb_hrb, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
hold on; 
plot((0:n-1)/Fs, f_c/1000, ':r');
plot((0:n-1)/Fs, 2*f_c/1000, ':r');
plot((0:n-1)/Fs, 3*f_c/1000, ':r');
plot((0:n-1)/Fs, 4*f_c/1000, ':r');
plot((0:n-1)/Fs, 5*f_c/1000, ':r');
plot((0:n-1)/Fs, 6*f_c/1000, ':r');
hold off;
title("HR-NB Test");

figure;
spectrogram(y_nb_rt, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
hold on; 
plot((0:n-1)/Fs, f_c/1000, ':r');
plot((0:n-1)/Fs, 2*f_c/1000, ':r');
plot((0:n-1)/Fs, 3*f_c/1000, ':r');
plot((0:n-1)/Fs, 4*f_c/1000, ':r');
plot((0:n-1)/Fs, 5*f_c/1000, ':r');
plot((0:n-1)/Fs, 6*f_c/1000, ':r');
hold off;
title("RT-NB Test");