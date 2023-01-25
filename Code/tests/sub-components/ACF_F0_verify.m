%Scratch for working out details of ACF verification for static pitched DWG
close all;
clear;

%String DWG parameters
noiseType = "Pink";
useNoiseFile = false;
stringParams = SystemParams.A_string_params;

%Modify the parameters to generate an integer sample period for easier
%verification with this method
p0_samples = 100;
Fs = SystemParams.audioRate;
stringParams.f0 = Fs/p0_samples;

%Sound length in seconds and samples
durationSec = 1;
numSamples = durationSec * Fs;

%Generate the constant control signal
L = ones(1, numSamples);

%Processing objects
stringDWG = StringDWG(stringParams, L(1), noiseType, useNoiseFile);
y1 = zeros(1, numSamples);

%Processing loop
stringDWG.pluck(); %Set up the string to generate noise...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringDWG.consumeControlSignal(L(n));
    y1(n) = stringDWG.tick(0.0);
end

[r, lags] = xcorr(y1);
[pks, locs] = findpeaks(r, 'MinPeakDistance', floor(p0_samples/2));

figure;
% subplot(2, 1, 1);
k = 0:p0_samples+1:6*(p0_samples+1);
plot(0:numSamples-1, y1, k, y1(k+1), "ro");
title("Signal");
ylabel("Amplitude");
xlabel("n");
xlim([-5 500]);
grid on;
grid minor;

figure;
subplot(2, 1, 1);
plot(lags, r, lags(locs), pks, 'ro');
title("Auto-correlation - Periodicity");
ylabel("r");
xlabel("Lags");
grid on; grid minor;
xlim([0 800]-25);
ylim([0 200]);

subplot(2, 1, 2);
plot(lags, r, lags(locs), pks, 'ro');
title("Auto-correlation - Zoom-in");
ylabel("r");
xlabel("Lags");
grid on; grid minor;
xlim([-5 125]);
ylim([0 200]);