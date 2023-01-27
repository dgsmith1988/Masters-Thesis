%Test wide/narrow vibrato for the string

clear;
close all;
dbstop if error

%Synthsizer and sound parameters
slideSynthParams = SlideSynthParams();
slideSynthParams.enableCSG = true;
slideSynthParams.CSG_noiseSource = "NoisePulseTrain";
slideSynthParams.CSG_harmonicAccentuator = "ResoTanh";
slideSynthParams.stringNoiseSource = "Pink";
slideSynthParams.useNoiseFile = false;
slideSynthParams.slideType = "Brass";
slideSynthParams.stringName = "E";

%Slide motion parameters
soundDuration_sec = 3;
slideDuration_sec = soundDuration_sec;
centerFret = 5;
wideVibratoWidth = .5;
wideVibratoFreq = 2;
narrowVibratoWidth = .125;
narrowVibratoFreq = 5;

%Spectrogram analysis parameters
Fs = SystemParams.audioRate;
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs/2000;

numSamples = soundDuration_sec * Fs;

%********Test a wide vibrato********
%All the vibrato terms are in frets which are then mapped to the relative
%string length

t = (0:numSamples-1)/Fs;
fretTrajectory = wideVibratoWidth*sin(2*pi*wideVibratoFreq*t) + centerFret;
L = fretNumberToRelativeLength(fretTrajectory);

%Processing objects
slideSynth = SlideSynth(slideSynthParams, L(1));
y10 = zeros(1, numSamples);

%Processing loop
slideSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    slideSynth.consumeControlSignal(L(n))
    y10(n) = slideSynth.tick();
end

figure;
subplot(2, 1, 1)
plot(y10);
title("Slow Wide Vibrato");
subplot(2, 1, 2);
plot(L);
title("L[n]");

figure;
spectrogram(y10, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title("Slow Wide Vibrato")

%********Test a narrow fast vibrato********
%All the vibrato terms are in frets which are then mapped to the relative
%string length
t = (0:numSamples-1)/Fs;
fretTrajectory = narrowVibratoWidth*sin(2*pi*narrowVibratoFreq*t) + centerFret;
L = fretNumberToRelativeLength(fretTrajectory);

%Processing objects
slideSynth = SlideSynth(slideSynthParams, L(1));
y11 = zeros(1, numSamples);

%Processing loop
slideSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    slideSynth.consumeControlSignal(L(n))
    y11(n) = slideSynth.tick();
end

figure;
subplot(2, 1, 1)
plot(y11);
title("Narrow Fast Vibrato");
subplot(2, 1, 2);
plot(L);

figure;
spectrogram(y11, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title("Narrow Fast Vibrato");