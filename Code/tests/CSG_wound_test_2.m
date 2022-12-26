%Test the wound CSG object in using the combined output from both branches
%and a time-varying slide velocity

% close all;
% clear;

dbstop if error;

%System parameters
Fs = SystemParams.audioRate;
stringLength = SystemParams.stringLengthMeters;
stringParams = SystemParams.D_string_params;
stringModeFilterSpec = SystemParams.D_string_modes.chrome;
n_w = stringParams.n_w;
duration_sec = 2;
numSamples = round(Fs*duration_sec);

%Generate the parabolic f_c/velocity trajectory
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

%generate the control signal based on the derivations in your notebook
L = zeros(1, numSamples);
L(1) = 1;
for n = 2:numSamples
    L(n) = L(n-1) - f_c(n)/(n_w*stringLength*Fs);
end

%Set the initial one to be slightly greater than 1 in order to remove the
%discontinuity at the beginning
L_n_1 = L(1);

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
% window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = 5; %corresponds to 5kHz on the frequency axis

%create/initialize the processing objects
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, @tanh, L_n_1);
csg_wound.g_bal = .5;
y4 = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    y4(n) = csg_wound.tick(L(n));
end

figure;
plot(y4);
title("Wound CSG Time-Varying Slide Velocity Output");

figure;
spectrogram(y4, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Wound CSG Time-Varying Slide Velocity Spectrogram')
% hold on;
% yline([stringModeFilterSpec.poles.F(1), stringModeFilterSpec.poles.F(3)]/1000, 'r');
% hold off;

