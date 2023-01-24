%Place to work out details associated with parabolic interpolation spectral
%estimation for String DWG
%https://ccrma.stanford.edu/~jos/sasp/Quadratic_Interpolation_Spectral_Peaks.html

% close all;
clear all;
% dbstop if error

%FFT size
N = 8*1024;
bins = 0:N-1;

%System processing parameters
durationSec = 3;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;
stringParams = SystemParams.A_string_params;
stringParams.n_w = -1; %indicate that we don't use a CSG
% stringParams.f0 = 12 * Fs / N;
% stringParams.f0 = SystemParams.minString_f0;
stringParams.f0 = SystemParams.maxPitch_f0/2;
stringModeFilterSpec = SystemParams.A_string_modes.chrome;
f0_bin = stringParams.f0 * N / Fs;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
% window = rectwin(windowLength)';
window = hamming(windowLength)';
overlap = .75*windowLength;
% y_upperLim_kHz = Fs/2000;
y_upperLim_kHz = 8;

%Generate the constant control signal
L = ones(1, numSamples);

%Processing objects
stringSynth = StringSynth(stringParams, stringModeFilterSpec, L(1));
dcBlocker = DCBlocker(.995);
x = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate noise...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringSynth.consumeControlSignal(L(n));
    x(n) = stringSynth.tick();
end

X_fft = fft(x, N);
X_dB = mag2db(abs(X_fft(1:N/2)));

%search in an interval around where the f0_bin should be. this interval is
%chosen to make sure we don't get any other harmonics. given that we are
%using noise as the source to initialize the buffer with it is not possible
%to guarantee the highest resonance will correspond to the fundamental.

%TODO: See if there is a more robust argument regarding the interval and
%the possible harmonics and if this could guarantee things regarding
%fundamental detection.
upper = ceil(1.5*f0_bin);
[M, I] = max(X_dB(1:upper));
alpha = X_dB(I-1);
beta = X_dB(I);
gamma = X_dB(I+1);

%calculate the estimated bin and the corresponding magnitude
p = 1/2 * (alpha-gamma) / (alpha - 2*beta + gamma)
assert(abs(p) <= .5);
bin_estimate = I - 1 + p
y_estimate = beta - 1/4 * (alpha - gamma)*bin_estimate;
bin_err = f0_bin - bin_estimate
err_hz = bin_err * Fs / N

figure;
plot(bins(1:N/2), X_dB);
title("X dB");
xlabel("BIN");
xline(f0_bin, "r");
xline(bin_estimate, "g");
xline(upper, "--k")
grid on; grid minor;

figure;
spectrogram(x, window, overlap, N, Fs, "yaxis"); 
ylim([0 y_upperLim_kHz]);
title('F0 Verification Spectrogram');
yline(stringParams.f0/1000, 'r');