%Test for the time-varying length signal

% close all;
% clear;
dbstop if error;

%System parameters
Fs = SystemParams.audioRate;
stringLength = SystemParams.stringLengthMeters;
stringParams = SystemParams.E_string_params;
stringModeFilterSpec = SystemParams.E_string_modes.brass;
f0 = stringParams.f0;
pulseLength_ms = stringParams.pulseLength;
decayRate = stringParams.decayRate;
n_w = stringParams.n_w;
duration_sec = .6;
numSamples = round(Fs*duration_sec);

%Keep the f_c constant for now to simplify the tests
a = 1/.09;
increment = duration_sec/numSamples;
x = 0:increment:duration_sec-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

%generate the control signal based on the derivations in your notebook
L = zeros(1, numSamples);
L(1) = 1;
for n = 2:numSamples
    L(n) = L(n-1) - f_c(n)/(n_w*stringLength*Fs);
end
L_n_1 = L(1);

%create/initialize the processing objects
contactSoundGenerator = ContactSoundGenerator(stringParams, stringModeFilterSpec, @tanh, L_n_1);

y = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    y(n) = contactSoundGenerator.tick(L(n));
end

figure;
plot(y);
title("CSG Test Output");

figure;
windowLength = 12*10^-3*Fs;
% window = hamming(windowLength);
window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = 5;
spectrogram(y, window, overlap, N, Fs, "yaxis"); title('x3'); ylim([0 y_upperLim]);
title('CSG output spectrogram')
