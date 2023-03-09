%Test the wound CSG object in using the combined output from both branches
%and a time-varying slide velocity

close all;
clear;

dbstop if error;

%System parameters
Fs = SystemParams.audioRate;
stringParams = SystemParams.D_string_params;
stringModeFilterSpec = SystemParams.D_string_modes.chrome;
n_w = stringParams.n_w;
duration_sec = 2;
numSamples = round(Fs*duration_sec);

%Configure the noise source and harmonic accentuator
% noiseSource = "Burst";
noiseSource = "PulseTrain";
harmonicAccentuator = "HarmonicResonatorBank";
% harmonicAccentuator = "ResoTanh";

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
% window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
% y_upperLim = Fs/2000;
y_upperLim = 8;

%Generate the parabolic f_c trajectory
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

%convert it to a slide speed
slideSpeed = f_c/n_w;

%*****Isolate Longitudinal Mode Branch Test*****
%create/initialize the processing objects
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, noiseSource, harmonicAccentuator);
csg_wound.g_bal = 0;
csg_wound.g_user = 1;   %maximize the signal
pulseTrain_TV = zeros(1, numSamples);
y4 = zeros(1, numSamples);
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    csg_wound.consumeControlSignal(slideSpeed(n));
    [y4(n), pulseTrain_TV(n)] = csg_wound.tick();
end

figure;
plot(y4);
title("Wound CSG Time-Varying Slide Velocity - Longitudinal Branch Output");

figure;
spectrogram(y4, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
% title('Wound CSG Time-Varying Slide Velocity - Longitudinal Branch')
yline([stringModeFilterSpec.poles.F(1), stringModeFilterSpec.poles.F(3)]/1000, '--k');

%*****Isolate Resonator Branch Test*****
%create/initialize the processing objects
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, noiseSource, harmonicAccentuator);
csg_wound.g_bal = 1;
csg_wound.g_user = 1;   %maximize the signal
y5 = zeros(1, numSamples);
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    csg_wound.consumeControlSignal(slideSpeed(n));
    y5(n) = csg_wound.tick();
end

figure;
plot(y5);
title("Wound CSG Time-Varying Slide Velocity - Harmonics Branch Output");

figure;
spectrogram(y5, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
% title('Wound CSG Time-Varying Slide Velocity - Harmonics Branch');
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
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, noiseSource, harmonicAccentuator);
csg_wound.g_bal = .25; %Favor the modes to bring them out more
csg_wound.g_user = 1;   %maximize the signal
y6 = zeros(1, numSamples);
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    csg_wound.consumeControlSignal(slideSpeed(n));
    y6(n) = csg_wound.tick();
end

figure;
plot(y6);
title("Wound CSG Time-Varying Slide Velocity - Combined Branches Output");

figure;
spectrogram(y6, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
% title('Wound CSG Time-Varying Slide Velocity - Combined Branches')
yline([stringModeFilterSpec.poles.F(1), stringModeFilterSpec.poles.F(3)]/1000, '--k');
hold on; 
plot((0:n-1)/Fs, f_c/1000, ':r');
plot((0:n-1)/Fs, 2*f_c/1000, ':r');
plot((0:n-1)/Fs, 3*f_c/1000, ':r');
plot((0:n-1)/Fs, 4*f_c/1000, ':r');
plot((0:n-1)/Fs, 5*f_c/1000, ':r');
plot((0:n-1)/Fs, 6*f_c/1000, ':r');
hold off;