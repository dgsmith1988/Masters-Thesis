%Simple plucking of the string

clear;
close all;
dbstop if error

%Synthsizer and sound parameters
slideSynthParams = SlideSynthParams();
slideSynthParams.enableCSG = false;
slideSynthParams.CSG_noiseSource = "NoisePulseTrain";
slideSynthParams.CSG_harmonicAccentuator = "ResoTanh";
slideSynthParams.stringNoiseSource = "Pink";
slideSynthParams.useNoiseFile = false;
slideSynthParams.slideType = "Brass";
slideSynthParams.stringName = "B";
duration_sec = 3;

%Slide motion parameters
startingFret = 0;
endingFret = 0;

%Spectrogram analysis parameters
Fs = SystemParams.audioRate;
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs/2000;

%***************************Don't Touch Below Here***************************%
%Derived parameters and control signals
numSamples = duration_sec * Fs;
L = generateLCurve(startingFret, endingFret, duration_sec, Fs);

%Processing objects
slideSynth = SlideSynth(slideSynthParams, L(1));

%Output buffers
y1 = zeros(1, numSamples);
feedbackLoopOutput = zeros(1, numSamples);
CSGOutput = zeros(1, numSamples);
f_c = zeros(1, numSamples);
absoluteSlideSpeed = zeros(1, numSamples);

%Processing loop
slideSynth.pluck(); %Set up the string to generate noise...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    slideSynth.consumeControlSignal(L(n))
%     f_c(n) = slideSynth.contactSoundGenerator.f_c_n;
%     absoluteSlideSpeed(n) = slideSynth.contactSoundGenerator.absoluteSlideSpeed;
    [y1(n), feedbackLoopOutput(n), CSGOutput(n)] = slideSynth.tick();
end

figure;
n_plot = 0:numSamples-1;
subplot(4, 1, 1)
plot(n_plot, y1);
title("Synth Output");
subplot(4, 1, 2);
plot(n_plot, L);
title("L[n]");
subplot(4, 1, 3);
plot(n_plot, f_c);
title("f_c[n]");
subplot(4, 1, 4);
plot(n_plot, absoluteSlideSpeed);
title("absoluteSlideSpeed[n]");

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");
ylim([0 y_upperLim_kHz]);