%Test the slide synth patch sliding up 3 frets over one second and reverse

clear;
close all;
dbstop if error

%Synthesizer and sound parameters
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

%Slide motion parameters
soundDuration_sec = 3;
slideDuration_sec = 1;
staticDuration_sec = soundDuration_sec - slideDuration_sec;
lowerFret = 0;
higherFret = 3;
L = generateLCurve(lowerFret, higherFret, slideDuration_sec, Fs_ctrl);
L = [L, L(end)*ones(1, staticDuration_sec*Fs_ctrl)];

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs_audio; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs_audio/2000;


%********Test 3 frets up over three seconds********
%Run the test
y4 = runSlideSynthTest(slideSynthParams, L, soundDuration_sec);

figure;
spectrogram(y4, window, overlap, N, Fs_audio, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Medium Upward Bend Spectrogram')

%********Test up 3 frets over three seconds********
%Generate the appropriate control signal
L = generateLCurve(higherFret, lowerFret, slideDuration_sec, Fs_ctrl);
L = [L, L(end)*ones(1, staticDuration_sec*Fs_ctrl)];

y5 = runSlideSynthTest(slideSynthParams, L, soundDuration_sec);

figure;
spectrogram(y5, window, overlap, N, Fs_audio, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Medium Downward Slide Spectrogram')