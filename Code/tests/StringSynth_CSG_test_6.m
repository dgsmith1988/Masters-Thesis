%Test vibrato both in terms of wide as well as narrow for the string

clear;
close all;
dbstop if error

%System processing parameters
soundDuration_sec = 3;
slideDuration_sec = 3;
staticDuration_sec = soundDuration_sec - slideDuration_sec;
Fs = SystemParams.audioRate;
numSamples = soundDuration_sec * Fs;
stringLength = SystemParams.stringLengthMeters;
stringParams = SystemParams.A_string_params;
%Deteremine the L to achieve the highest pitch for this string
L_max_pitch = calculateLFromPitchF0(SystemParams.maxPitch_f0, stringParams.f0);
stringModeFilterSpec = SystemParams.A_string_modes.chrome;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
% window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs/2000;


%********Test a wide vibrato********
%All the vibrato terms are in frets which are then mapped to the relative
%string length
centerFret = 5;
vibratoWidth = .5;
vibratoFreq = 2;
t = (0:numSamples-1)/Fs;
fretTrajectory = vibratoWidth*sin(2*pi*vibratoFreq*t) + centerFret;
L = fretNumberToRelativeLength(fretTrajectory);

%Processing objects
stringSynth = StringSynth(stringParams, stringModeFilterSpec, L(1));
y10 = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    stringSynth.consumeControlSignal(L(n))
    y10(n) = stringSynth.tick();
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
centerFret = 5;
vibratoWidth = .125;
vibratoFreq = 5;
t = (0:numSamples-1)/Fs;
fretTrajectory = vibratoWidth*sin(2*pi*vibratoFreq*t) + centerFret;
L = fretNumberToRelativeLength(fretTrajectory);

%Processing objects
stringSynth = StringSynth(stringParams, stringModeFilterSpec, L(1));
y11 = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    stringSynth.consumeControlSignal(L(n))
    y11(n) = stringSynth.tick();
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