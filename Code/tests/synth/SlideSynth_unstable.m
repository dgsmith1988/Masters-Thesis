%Script to generate unstable system where loop gain is positive and
%lagrange filter doesn't generate a fractional component (acts purely as a
%delay in this case)

clear;
close all;
dbstop if error

%Synthesizer and sound parameters
slideSynthParams = SlideSynthParams();
slideSynthParams.enableCSG = false;
slideSynthParams.CSG_noiseSource = "NoisePulseTrain";
slideSynthParams.CSG_harmonicAccentuator = "ResoTanh";
slideSynthParams.stringNoiseSource = "Pink";
slideSynthParams.useNoiseFile = false;
slideSynthParams.slideType = "Brass";
slideSynthParams.stringName = "D";
Fs_audio = SystemParams.audioRate;
Fs_ctrl = SystemParams.controlRate;

%Slide motion parameters
duration_sec = 3;
openString_f0 = getStringParams(slideSynthParams.stringName).f0;
DWGLength = 82.25; %this value makes the loop filter unstable and eliminates fractional component from lagrange interpolation
L = openString_f0 * DWGLength / Fs_audio;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs_audio; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs_audio/2000;

%***************************Don't Touch Below Here***************************%
%Derived parameters and control signals
numSamples_audio = duration_sec * Fs_audio;
numSamples_ctrl = duration_sec * Fs_ctrl;

y1 = runSlideSynthTest(slideSynthParams, L*ones(1, numSamples_ctrl));

figure;
spectrogram(y1, window, overlap, N, Fs_audio, "yaxis");
ylim([0 y_upperLim_kHz]);