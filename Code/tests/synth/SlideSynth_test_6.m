%Test wide/narrow vibrato for the string

clear;
close all;
dbstop if error

%Synthsizer and sound parameters
slideSynthParams = SlideSynthParams();
slideSynthParams.enableCSG = false;
slideSynthParams.CSG_noiseSource = "NoisePulseTrain";
slideSynthParams.CSG_harmonicAccentuator = "ResoTanh";
slideSynthParams.stringNoiseSource = "White";
slideSynthParams.useNoiseFile = false;
slideSynthParams.slideType = "Brass";
slideSynthParams.stringName = "G";
Fs_audio = SystemParams.audioRate;
Fs_ctrl = SystemParams.controlRate;

%Slide motion parameters
soundDuration_sec = 3;
slideDuration_sec = soundDuration_sec;
centerFret = 5;
wideVibratoWidth = .5;
wideVibratoFreq = 2;
narrowVibratoWidth = .125;
narrowVibratoFreq = 5;
%All the vibrato terms are in frets which are then mapped to the relative
%string length
t = (0:Fs_ctrl*soundDuration_sec-1)/Fs_ctrl;
fretTrajectory = wideVibratoWidth*sin(2*pi*wideVibratoFreq*t) + centerFret;
L = fretNumberToRelativeLength(fretTrajectory);

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs_audio; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs_audio/2000;

%********Test a wide vibrato********
y10 = synthesizeSinglePluck(slideSynthParams, L);

figure;
spectrogram(y10, window, overlap, N, Fs_audio, "yaxis");  
ylim([0 y_upperLim_kHz]);
title("Slow Wide Vibrato");

%********Test a narrow fast vibrato********
fretTrajectory = narrowVibratoWidth*sin(2*pi*narrowVibratoFreq*t) + centerFret;
L = fretNumberToRelativeLength(fretTrajectory);

%Processing objects
y11 = synthesizeSinglePluck(slideSynthParams, L);

figure;
spectrogram(y11, window, overlap, N, Fs_audio, "yaxis");  
ylim([0 y_upperLim_kHz]);
title("Narrow Fast Vibrato");