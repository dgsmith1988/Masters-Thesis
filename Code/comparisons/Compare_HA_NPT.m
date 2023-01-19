%Compare the different harmonic accentuator methods using the noise pulse
%train as a sound source.

close all;
clear all;

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
y_upperLim = 7; %corresponds to 5kHz on the frequency axis
% y_upperLim = Fs/2000;

%Generate f_c control signal
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

%buffers to be filled during processing loop
npt = zeros(1, numSamples);         %noise pulse train signal
ro_npt = zeros(1, numSamples);      %resonator output to understand processing chain
y_npt_hrb = zeros(1, numSamples);   %resonator bank output
y_npt_rt = zeros(1, numSamples);    %resonator->tanh output

%Processing/generation objects
noisePulseTrain = NoisePulseTrain(period_samp, T60);
harmonicResonatorBank = HarmonicResonatorBank(f_c(1), r);
resoTanh = ResoTanh(f_c(1), r, preTanhGain);

%Processing loop
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    %generate the various stimuli first
    noisePulseTrain.consumeControlSignal(f_c(n));
    harmonicResonatorBank.consumeControlSignal(f_c(n));
    resoTanh.consumeControlSignal(f_c(n));
    npt(n) = noisePulseTrain.tick();
    y_npt_hrb(n) = harmonicResonatorBank.tick(npt(n));
    [y_npt_rt(n), ro_npt(n)] = resoTanh.tick(npt(n));
end

figure;
spectrogram(npt, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
hold on; 
plot((0:n-1)/Fs, f_c/1000, ':r');
plot((0:n-1)/Fs, 2*f_c/1000, ':r');
plot((0:n-1)/Fs, 3*f_c/1000, ':r');
plot((0:n-1)/Fs, 4*f_c/1000, ':r');
plot((0:n-1)/Fs, 5*f_c/1000, ':r');
plot((0:n-1)/Fs, 6*f_c/1000, ':r');
hold off;
title("NPT Source");

figure;
spectrogram(ro_npt, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
hold on; 
plot((0:n-1)/Fs, f_c/1000, ':r');
plot((0:n-1)/Fs, 2*f_c/1000, ':r');
plot((0:n-1)/Fs, 3*f_c/1000, ':r');
plot((0:n-1)/Fs, 4*f_c/1000, ':r');
plot((0:n-1)/Fs, 5*f_c/1000, ':r');
plot((0:n-1)/Fs, 6*f_c/1000, ':r');
hold off;
title("RO Intermediate-NPT Test");

figure;
spectrogram(y_npt_hrb, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
hold on; 
plot((0:n-1)/Fs, f_c/1000, ':r');
plot((0:n-1)/Fs, 2*f_c/1000, ':r');
plot((0:n-1)/Fs, 3*f_c/1000, ':r');
plot((0:n-1)/Fs, 4*f_c/1000, ':r');
plot((0:n-1)/Fs, 5*f_c/1000, ':r');
plot((0:n-1)/Fs, 6*f_c/1000, ':r');
hold off;
title("HR-NPT Test");

figure;
spectrogram(y_npt_rt, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
hold on; 
plot((0:n-1)/Fs, f_c/1000, ':r');
plot((0:n-1)/Fs, 2*f_c/1000, ':r');
plot((0:n-1)/Fs, 3*f_c/1000, ':r');
plot((0:n-1)/Fs, 4*f_c/1000, ':r');
plot((0:n-1)/Fs, 5*f_c/1000, ':r');
plot((0:n-1)/Fs, 6*f_c/1000, ':r');
hold off;
title("RT-NPT Test");

figure;
subplot(2, 1, 1);
plot(0:numSamples-1, y_npt_hrb);
title("Noise Pulse Train Through Harmonic Resonator Bank");
subplot(2, 1, 2);
plot(0:numSamples-1, y_npt_rt);
title("Noise Pulse Train ResoTanh");