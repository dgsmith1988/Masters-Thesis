%Test the slide synth patch for extreme string length settings

% clear;
% close all;
dbstop if error

%Synthsizer and sound parameters
slideSynthParams = SlideSynthParams();
slideSynthParams.enableCSG = true;
slideSynthParams.CSG_noiseSource = "NoisePulseTrain";
slideSynthParams.CSG_harmonicAccentuator = "ResoTanh";
slideSynthParams.stringNoiseSource = "Pink";
slideSynthParams.useNoiseFile = false;
slideSynthParams.slideType = "Brass";
%This test requires a special string, otherwise delay line values get
%messed up
slideSynthParams.stringName = "C";
Fs_audio = SystemParams.audioRate;
Fs_ctrl = SystemParams.controlRate;

%Slide motion parameters
soundDuration_sec = 3;
slideDuration_sec = soundDuration_sec;
lowerFret = SystemParams.minFretNumber;
higherFret = SystemParams.maxFretNumber;
staticDuration_sec = soundDuration_sec - slideDuration_sec;
L = generateLCurve(lowerFret, higherFret, slideDuration_sec, Fs_ctrl);
L = [L, L(end)*ones(1, staticDuration_sec*Fs_ctrl)];

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs_audio; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs_audio/2000;

%********Test first extreme********
y8 = synthesizeSinglePluck(slideSynthParams, L);

figure;
spectrogram(y8, window, overlap, N, Fs_audio, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Extreme Upward Slide')

%********Test reverse extreme********
%Generate the appropriate control signal
L = generateLCurve(higherFret, lowerFret, slideDuration_sec, Fs_ctrl);
L = [L, L(end)*ones(1, staticDuration_sec*Fs_ctrl)];

y9 = synthesizeSinglePluck(slideSynthParams, L);

figure;
spectrogram(y9, window, overlap, N, Fs_audio, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Extreme Downward Slide')