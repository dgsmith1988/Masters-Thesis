%Test the wound CSG object in using the combined output from both branches
%and a time-varying slide velocity

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

%Configure the noise source and harmonic accentuator
% noiseSource = "Burst";
noiseSource = "PulseTrain";
% harmonicAccentuator = "HarmonicResonatorBank";
harmonicAccentuator = "ResoTanh";

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
% window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = 7; %corresponds to 5kHz on the frequency axis

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

%*****Isolate Longitudinal Mode Branch Test*****
%create/initialize the processing objects
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, noiseSource, harmonicAccentuator, L_n_1);
csg_wound.g_bal = 0;
pulseTrain_TV = zeros(1, length(L));
y4 = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    csg_wound.consumeControlSignal(L(n));
    [y4(n), pulseTrain_TV(n)] = csg_wound.tick();
end

figure;
plot(y4);
title("Wound CSG Time-Varying Slide Velocity - Longitudinal Branch Output");

figure;
spectrogram(y4, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Wound CSG Time-Varying Slide Velocity - Longitudinal Branch Spectrogram')
yline([stringModeFilterSpec.poles.F(1), stringModeFilterSpec.poles.F(3)]/1000, '--k');

%*****Isolate Resonator Branch Test*****
%create/initialize the processing objects
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, noiseSource, harmonicAccentuator, L_n_1);
csg_wound.g_bal = 1;
y5 = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    csg_wound.consumeControlSignal(L(n));
    y5(n) = csg_wound.tick();
end

figure;
plot(y5);
title("Wound CSG Time-Varying Slide Velocity - Harmonics Branch Output");

figure;
spectrogram(y5, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Wound CSG Time-Varying Slide Velocity - Harmonics Branch Spectrogram');
hold on; 
plot((0:n-1)/Fs, f_c/1000, ':r');
plot((0:n-1)/Fs, 2*f_c/1000, ':r');
plot((0:n-1)/Fs, 3*f_c/1000, ':r');
plot((0:n-1)/Fs, 4*f_c/1000, ':r');
plot((0:n-1)/Fs, 5*f_c/1000, ':r');
plot((0:n-1)/Fs, 6*f_c/1000, ':r');
hold off;

%*****Combined Branches Test*****
%create/initialize the processing objects
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, noiseSource, harmonicAccentuator, L_n_1);
csg_wound.g_bal = .25; %Favor the modes to bring them out more
y6 = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    csg_wound.consumeControlSignal(L(n));
    y6(n) = csg_wound.tick();
end

figure;
plot(y6);
title("Wound CSG Time-Varying Slide Velocity - Combined Branches Output");

figure;
spectrogram(y6, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Wound CSG Time-Varying Slide Velocity - Combined Branches Spectrogram')
yline([stringModeFilterSpec.poles.F(1), stringModeFilterSpec.poles.F(3)]/1000, '--k');
hold on; 
plot((0:n-1)/Fs, f_c/1000, ':r');
plot((0:n-1)/Fs, 2*f_c/1000, ':r');
plot((0:n-1)/Fs, 3*f_c/1000, ':r');
plot((0:n-1)/Fs, 4*f_c/1000, ':r');
plot((0:n-1)/Fs, 5*f_c/1000, ':r');
plot((0:n-1)/Fs, 6*f_c/1000, ':r');
hold off;