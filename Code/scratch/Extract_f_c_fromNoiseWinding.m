%Script to help make a curve which matches the noise characterizations and
%is useful for being able to help with tuning the parameters

close all;
clear all;

dbstop if error;

filePath = "../Sound Examples/NoiseCharacterization-E-Brass.wav";
[y, Fs] = audioread(filePath);
%Extract the first channel as that is the only one we want
y = y(:, 1);

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
% window = hamming(windowLength);
window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs/2000;
% y_upperLim_kHz = 8;

%Slide Event Paramters
slideEventDuration_sec = 3/5;
f0_max = [600, 700, 1000];
increment = 1/Fs;
x = 0:increment:slideEventDuration_sec-increment; %parabola evaluation points
f_c_n = [];

for i = 1:length(f0_max)
%Rate changing test
a = 1/(slideEventDuration_sec/2)^2;
f_c_n_k = f0_max(i)*(-a*(x -.3).^2 + 1);
f_c_n = [f_c_n, repmat(f_c_n_k, 1, 4)];
end

t = (0:length(f_c_n)-1)/Fs;
figure;
spectrogram(y, window, overlap, N, Fs, "yaxis");
ylim([0 y_upperLim_kHz]);
title("Noise Characterization");
hold on;
plot(t, f_c_n/1000, ":r");
hold off;

%Run the control signal through the CSG to generate a similar sound
stringParams = SystemParams.E_string_params;
stringParams.T60 = 2*10^-3;
stringModeFilterSpec = SystemParams.E_string_modes.chrome;
n_w = stringParams.n_w;

%Configure the noise source and harmonic accentuator
noiseSource = "PulseTrain";
% harmonicAccentuator = "HarmonicResonatorBank";
harmonicAccentuator = "ResoTanh";

csg_wound = CSG_wound(stringParams, stringModeFilterSpec, noiseSource, harmonicAccentuator);
csg_wound.g_bal = .15;
numSamples = length(f_c_n);
csg_out = zeros(1, numSamples);
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    csg_wound.consumeControlSignal(f_c_n(n)/n_w);
    csg_out(n) = csg_wound.tick();
end

figure;
spectrogram(csg_out, window, overlap, N, Fs, "yaxis");
ylim([0 y_upperLim_kHz]);
title("Tuned Wound CSG Spectrum");
% hold on;
% plot(t, f_c_n/1000, ":r");
% hold off;
