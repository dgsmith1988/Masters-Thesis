%Test the wound CSG object in three different ways
%   1. Longitudinal mode branch
%   2. Resonator branch
%   3. Combined output

close all;
clear;

dbstop if error;

%System parameters
Fs = SystemParams.audioRate;
stringLength = SystemParams.stringLengthMeters;
stringParams = SystemParams.D_string_params;
stringModeFilterSpec = SystemParams.D_string_modes.chrome;
n_w = stringParams.n_w;
duration_sec = 2;
numSamples = round(Fs*duration_sec);

%Keep the f_c constant for now to simplify the tests
f_c = 250*ones(1, numSamples);

%generate the control signal based on the derivations in your notebook
L = zeros(1, numSamples);
L(1) = 1;
for n = 2:numSamples
    L(n) = L(n-1) - f_c(n)/(n_w*stringLength*Fs);
end

%Set the initial one to be slightly greater than 1 in order to produce a
%constant velocity
L_n_1 = L(1) + L(1)-L(2);

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
% window = hamming(windowLength);
window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = 5; %corresponds to 5kHz on the frequency axis

%*****Isolate Longitudinal Mode Branch Test*****
%create/initialize the processing objects
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, @tanh, L_n_1);
csg_wound.g_bal = 0;  %shift the balance to only select the longitudinal modes
y1 = zeros(1, length(L));
noiseTrainPulse = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    csg_wound.consumeControlSignal(L(n));
    [y1(n), noiseTrainPulse(n)] = csg_wound.tick();
end

figure;
plot(y1);
title("Wound CSG Longitudinal Branch Test Output");

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Wound CSG Longitudinal Branch Output Spectrogram')
hold on;
yline([stringModeFilterSpec.poles.F(1), stringModeFilterSpec.poles.F(3)]/1000, 'r');
hold off;

%*****Resonator Branch Test*****
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, @tanh, L_n_1);
csg_wound.g_bal = 1;  %shift the balance to only select the resonator branch
y2 = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    csg_wound.consumeControlSignal(L(n));
    y2(n) = csg_wound.tick();
end

figure;
plot(y2);
title("Wound CSG Resonator Branch Test Output");

figure;
spectrogram(y2, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Wound CSG Resonator Branch Output Spectrogram')
yline(f_c(1)/1000, 'r');

%*****Longitudinal + Resonator Branch Test*****
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, @tanh, L_n_1);
csg_wound.g_bal = .25;  %favor the modes to bring them out more
y3 = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    csg_wound.consumeControlSignal(L(n));
    y3(n) = csg_wound.tick();
end

figure;
plot(y3);
title("Wound CSG Combined Branches Test Output");

figure;
spectrogram(y3, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Wound CSG Combined Branches Output Spectrogram')
yline([f_c(1), stringModeFilterSpec.poles.F(1), stringModeFilterSpec.poles.F(3)]/1000, 'r');