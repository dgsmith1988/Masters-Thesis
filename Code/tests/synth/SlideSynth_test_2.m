%Test the slide synth patch for various sliding up 1 fret over three
%seconds and down one fret over three seconds

clear all;
close all;
dbstop if error

%Synthsizer and sound parameters
slideSynthParams = SlideSynthParams();
slideSynthParams.enableCSG = true;
slideSynthParams.CSG_noiseSource = "NoisePulseTrain";
slideSynthParams.CSG_harmonicAccentuator = "HarmonicResonatorBank";
slideSynthParams.stringNoiseSource = "Pink";
slideSynthParams.useNoiseFile = false;
slideSynthParams.slideType = "Brass";
slideSynthParams.stringName = "D";
Fs_audio = SystemParams.audioRate;
Fs_ctrl = SystemParams.controlRate;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs_audio; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs_audio/2000;

%********Test Up 1 Fret Over Three Seconds********
%Slide motion parameters
duration_sec = 3;
lowerFret = 0;
higherFret = 1;
L = generateLCurve(lowerFret, higherFret, duration_sec, Fs_ctrl);

%Run the test
y2 = runSlideSynthTest(slideSynthParams, L, duration_sec);

figure;
spectrogram(y2, window, overlap, N, Fs_audio, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Slow Upward Bend Spectrogram');

%********Test Down 1 Fret Over Three Seconds********
%Swap the start/end points and start again
L = generateLCurve(higherFret, lowerFret, duration_sec, Fs_ctrl);

%Run the test
y3 = runSlideSynthTest(slideSynthParams, L, duration_sec);

figure;
spectrogram(y3, window, overlap, N, Fs_audio, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Slow Downward Slide Spectrogram');