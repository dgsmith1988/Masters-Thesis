%Attempet to emulate the single string slide lick which was recorded

clear;
close all;
dbstop if error

%Synthsizer and sound parameters
slideSynthParams = SlideSynthParams();
slideSynthParams.enableCSG = false;
slideSynthParams.CSG_noiseSource = "NoisePulseTrain";
slideSynthParams.CSG_harmonicAccentuator = "HarmonicResonatorBank";
slideSynthParams.stringNoiseSource = "Pink";
slideSynthParams.useNoiseFile = false;
slideSynthParams.slideType = "Brass";
slideSynthParams.stringName = "G";
Fs_audio = SystemParams.audioRate;
Fs_ctrl = SystemParams.controlRate;

%Specify the notes and their articulations as well as rhythmic values. The
%BPM value is a constant in the Note class which can be set before running
%the script.

slideLick = ...
{   Note(.5, 0, false, false), ...
    Note(1, 6, true, false), ...
    Note(1, 5, true, false), ...
    Note(.5, 3, true, false), ...
    Note(.5, 0, false, false), ...
    Note(4, 3, true, true), ...
    };

% slideLick = ...
% {   %Note(.5, 0, false, false), ...
%     Note(4, 6, true, true), ...
%     };

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs_audio; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs_audio/2000;

%Pre-allocate the output buffer for speed and eliminating memory allocation
%during the processing loop
numNotes = length(slideLick);
lickDuration_sec = 0;
for k = 1:numNotes
    lickDuration_sec = lickDuration_sec + slideLick{k}.duration_sec;
end

%Allocate slightly more as rounding can occur depending on durations and
%subdivisions
y12 = zeros(1, ceil(1.01*(lickDuration_sec * Fs_audio)));

%Synthesize the sounds and stitch them together in the output buffer
i1 = 1;
for k  = 1:numNotes
    fprintf("Synthesizing note %i/%i\n", k, numNotes);
    L = slideLick{k}.generateLCurve(Fs_ctrl);
    synthSound = synthesizeSinglePluck(slideSynthParams, L);
%     synthSound = runSlideSynthTest(slideSynthParams, L);
    i2 = i1 + length(synthSound) - 1;
    y12(i1:i2) = synthSound;
    i1 = i2 + 1;
end

%Plot the results as well as the spectrogram
figure;
plot(0:length(y12)-1, y12);
title("y[n]");
xlabel("n");
ylabel("Amplitude");

figure;
spectrogram(y12, window, overlap, N, Fs_audio, "yaxis");  
ylim([0 y_upperLim_kHz]);
title("Slide Lick Emulation");