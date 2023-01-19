%Experiment with how to eliminate DC component from NPT

% close all;
% clear all;

dbstop if error;
s
%System parameters
Fs = SystemParams.audioRate;
duration_sec = 3;
numSamples = round(duration_sec*Fs);

%Noise pulse and resonator characteristics
period_samp = 0;
T60 = SystemParams.D_string_params.T60;

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
y_dc_blocker = zeros(1, numSamples);

%Processing/generation objects
noisePulseTrain = NoisePulseTrain(period_samp, T60);
dcBlocker = DCBlocker(DCBlocker.R_default);

%Processing loop
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    %generate the various stimuli first
    noisePulseTrain.consumeControlSignal(f_c(n));
    npt(n) = noisePulseTrain.tick();
    y_dc_blocker(n) = dcBlocker.tick(npt(n));
end

figure;
spectrogram(npt, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title("NPT Source");

figure;
spectrogram(y_dc_blocker, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title("DC Blocker Out");

figure;
subplot(2, 1, 1);
plot(0:numSamples-1, npt);
title("NPT");
subplot(2, 1, 2);
plot(0:numSamples-1, y_dc_blocker);
title("NPT after DC Blocking");