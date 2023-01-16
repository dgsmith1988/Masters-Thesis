%Test the ResoTanh by sending in an exponentially decaying noise pulse
%train. 

%TODO: Develop a more robust suite of tests later and look into if the
%amplitude scaling from teh CSG_Wound in total explains the slight
%differences in the output spectrograms from a noise standpoint

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
y_upperLim = 7; %corresponds to 5kHz on the frequency axis

%Generate f_c control signal
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

%buffers to be filled during processing loop
npt = zeros(1, numSamples);
y1 = zeros(1, numSamples);

%Processing objects
noisePulseTrain = NoisePulseTrain(period_samp, T60);
resoTanh = ResoTanh(f_c(1), r);

%Processing loop
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    noisePulseTrain.consumeControlSignal(f_c(n));
    resoTanh.consumeControlSignal(f_c(n));
    npt(n) = noisePulseTrain.tick();
    y1(n) = resoTanh.tick(npt(n));
end

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
hold on; 
plot((0:n-1)/Fs, f_c/1000, 'r');
plot((0:n-1)/Fs, 2*f_c/1000, 'r');
plot((0:n-1)/Fs, 3*f_c/1000, 'r');
plot((0:n-1)/Fs, 4*f_c/1000, 'r');
plot((0:n-1)/Fs, 5*f_c/1000, 'r');
plot((0:n-1)/Fs, 6*f_c/1000, 'r');
hold off;
title("ResoTanh Test");