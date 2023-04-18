%Script to generate the sounds and figures for testing the different noise
%source and harmonic accenutation techniques

% close all;
% clear all;

dbstop if error;

%System parameters
Fs = SystemParams.audioRate;
stringParams = SystemParams.E_string_params;
% stringParams.T60 = 2*10^(-3);
stringParams.T60 = 20*10^(-3);
stringModeFilterSpec = SystemParams.E_string_modes.chrome;
n_w = stringParams.n_w;
duration_sec = 3;
numSamples = round(Fs*duration_sec);

%Configure the noise source and harmonic accentuator
noiseSource = "Burst";
% noiseSource = "PulseTrain";
% harmonicAccentuator = "HarmonicResonatorBank";
harmonicAccentuator = "ResoTanh";

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
% window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = Fs/2000;
% y_upperLim = 8;

%Generate the parabolic f_c trajectory
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

%convert it to a slide speed
slideSpeed = f_c/n_w;

%*****Combined Branches Test*****
%create/initialize the processing objects
csg_wound = CSG_wound(stringParams, stringModeFilterSpec, noiseSource, harmonicAccentuator);
csg_wound.g_bal = .25; %Favor the modes to bring them out more
csg_wound.g_user = 1;   %maximize the signal
y = zeros(1, numSamples);
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    csg_wound.consumeControlSignal(slideSpeed(n));
    y(n) = csg_wound.tick();
end

figure;
plot(y);
% title("Wound CSG Time-Varying Slide Velocity - Combined Branches Output");

figure;
spectrogram(y, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
% title('Wound CSG Time-Varying Slide Velocity - Combined Branches')
% yline([stringModeFilterSpec.poles.F(1), stringModeFilterSpec.poles.F(3)]/1000, '--k');
% hold on; 
% plot((0:n-1)/Fs, f_c/1000, ':r');
% plot((0:n-1)/Fs, 2*f_c/1000, ':r');
% plot((0:n-1)/Fs, 3*f_c/1000, ':r');
% plot((0:n-1)/Fs, 4*f_c/1000, ':r');
% plot((0:n-1)/Fs, 5*f_c/1000, ':r');
% plot((0:n-1)/Fs, 6*f_c/1000, ':r');
% hold off;