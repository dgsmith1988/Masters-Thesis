%Scratch for working out details of ACF verification for static pitched DWG
close all;
clear;

%System processing parameters
p0_samples = 100; %make the period of f0 an integer muliple of samples at this sampling frequency
Fs = SystemParams.audioRate;
stringParams = SystemParams.A_string_params;
stringParams.n_w = -1; %indicate that we don't use a CSG
stringParams.f0 = Fs/p0_samples; %set this to a frequency which has an integer length period in samples at this Fs
stringModeFilterSpec = SystemParams.A_string_modes.chrome;
waveshaperFunctionHandle = @tanh;
durationSec = 1;

numSamples = durationSec * Fs;

%Generate the constant control signal
L = ones(1, numSamples);

%Processing objects
stringSynth = StringSynth(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L(1));
y1 = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate noise...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringSynth.consumeControlSignal(L(n));
    y1(n) = stringSynth.tick();
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