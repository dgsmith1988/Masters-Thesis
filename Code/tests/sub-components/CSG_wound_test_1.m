%Test the wound CSG object in three different ways using a constant slide
%velocity
%   1. Longitudinal mode branch
%   2. Resonator branch
%   3. Combined output

% close all;
% clear all;

dbstop if error;

%System parameters
Fs = SystemParams.audioRate;
stringLength = SystemParams.stringLengthMeters;
stringParams = SystemParams.E_string_params;
stringModeFilterSpec = SystemParams.E_string_modes.brass;
n_w = stringParams.n_w;
duration_sec = 2;
numSamples = round(Fs*duration_sec);
% noiseSource = "Burst";
noiseSource = "PulseTrain";
harmonicAccentuator = "HarmonicResonatorBank";
% harmonicAccentuator = "ResoTanh";

%Keep the f_c constant for now to simplify the tests
f_c = 250*ones(1, numSamples);
slideSpeed = f_c/n_w;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
% window = hamming(windowLength);
window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = 5; %corresponds to 5kHz on the frequency axis

%*****Isolate Longitudinal Mode Branch Test*****
%Xreate/initialize the processing objects
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, noiseSource, harmonicAccentuator);
noiseTrainPulse = zeros(1, numSamples);
y1 = zeros(1, numSamples);
csg_wound.g_bal = 0;    %shift the balance to only select the longitudinal modes
csg_wound.g_user = 1;   %maximize the signal

%Processing loop
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    csg_wound.consumeControlSignal(slideSpeed(n));
    [y1(n), noiseTrainPulse(n)] = csg_wound.tick();
end

figure;
plot(y1);
title("Wound CSG Longitudinal Branch Test Output");

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
% title('Wound CSG Longitudinal Branch Output Spectrogram')
yline([stringModeFilterSpec.poles.F(1), stringModeFilterSpec.poles.F(3)]/1000, '--k');

%*****Resonator Branch Test*****
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, noiseSource, harmonicAccentuator);
csg_wound.g_bal = 1;  %shift the balance to only select the resonator branch
csg_wound.g_user = 1;   %maximize the signal
y2 = zeros(1, numSamples);

%Processing loop
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    csg_wound.consumeControlSignal(slideSpeed(n));
    y2(n) = csg_wound.tick();
end

figure;
plot(y2);
% title("Wound CSG Resonator Branch Test Output");

figure;
spectrogram(y2, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
% title('Wound CSG Harmonics Branch Output Spectrogram')
yline(f_c(1)/1000*[1 2 3 4 5 6], ':r');

%*****Longitudinal + Harmonics Branch Test*****
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, noiseSource, harmonicAccentuator);
csg_wound.g_bal = .25;  %favor the modes to bring them out more
csg_wound.g_user = 1;   %maximize the signal
y3 = zeros(1, numSamples);

%Processing loop
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    csg_wound.consumeControlSignal(slideSpeed(n));
    y3(n) = csg_wound.tick();
end

figure;
plot(y3);
% title("Wound CSG Combined Branches Test Output");

figure;
spectrogram(y3, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
% title('Wound CSG Combined Branches Output Spectrogram')
yline([stringModeFilterSpec.poles.F(1), stringModeFilterSpec.poles.F(3)]/1000, '--k');
yline(f_c(1)/1000*[1 2 3 4 5 6], ':r');
yline([f_c(1), stringModeFilterSpec.poles.F(1), stringModeFilterSpec.poles.F(3)]/1000, ':r');