%Basic script to experiment with parabolic interpolation of KS algorithm
clear all;
close all;

%String DWG Parameters
% stringParams = SystemParams.A_string_params;
% stringParams = SystemParams.G_string_params;
% stringParams = SystemParams.B_string_params;
stringParams = SystemParams.e_string_params;
noiseType = "Pink";
useNoiseFile = false;
Fs = SystemParams.audioRate;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs/2000;

%Sound parameters
f0_bin = 32;
duration_sec = 3;

%Derived parameters
pitch_f0 = f0_bin * Fs / N;
L = stringParams.f0 / pitch_f0;
period_samples = calculateTotalDWGLength(pitch_f0, Fs);
numSamples = duration_sec * Fs;
% f0_bin = N / period_samples;

%Processing varibles/objects
stringDWG = StringDWG(stringParams, L, noiseType, useNoiseFile);
y = zeros(1, numSamples);

%Processing loop
stringDWG.pluck();
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    y(n) = stringDWG.tick(0);
end

figure;
plot(y);
title("KS Scratch Output");

%Perform the spectral parabolic interpolation to estimate the f0 of the
%signal
start = numSamples/2;
stop = start + N - 1;
Y = fft(y(1:N).*(hamming(N)'), N);
% Y = fft(y(start:stop).*(hamming(N)'), N);0
% Y = fft(y, N);
Y_dB = mag2db(abs(Y));

upper = ceil(1.5*f0_bin);
[M, I] = max(Y_dB(1:upper));
% [M, I] = max(Y_dB(1:N/2));
alpha = Y_dB(I-1);
beta = Y_dB(I);
gamma = Y_dB(I+1);

p = 1/2 * (alpha-gamma) / (alpha - 2*beta + gamma)
assert(abs(p) <= .5);
bin_estimate = I - 1 + p
y_estimate = beta - 1/4 * (alpha - gamma)*bin_estimate;
% pitch_f0 * N/Fs = Fs/period_samples * N/Fs = N/period_samples...
bin_err = f0_bin - bin_estimate
err_hz = bin_err * Fs / N

figure;
plot(0:N-1, Y_dB, "DisplayName", "Y dB");
title("Y dB");
xlabel("BIN");
xline(f0_bin, "r", "DisplayName", "Theoretical Value");
xline(bin_estimate, "g", "DisplayName", "Estimated Value");
xline(upper, "--k", "DisplayName", "Upper");
legend();
grid on; grid minor;
xlim([0 N/2-1]);

figure;
spectrogram(y, window, overlap, N, Fs, "yaxis");
ylim([0 y_upperLim_kHz]);
title('KS Scratch Spectrogram');
yline(pitch_f0/1000, "--r");
yline(bin_estimate*Fs/N/1000, "--k");