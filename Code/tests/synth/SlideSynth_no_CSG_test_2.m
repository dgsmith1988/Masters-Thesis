%Test the string synth patch for various sliding up 1 fret over three
%seconds and down one fret over three seconds

clear;
close all;
dbstop if error

%System processing parameters
duration_sec = 3;
Fs = SystemParams.audioRate;
numSamples = duration_sec * Fs;
stringLength = SystemParams.stringLengthMeters;
stringParams = SystemParams.D_string_params;
stringParams.n_w = -1; %indicate that we don't use a CSG
stringModeFilterSpec = SystemParams.D_string_modes.chrome;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
% window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = Fs/2000; %corresponds to 15kHz on the frequency axis

%********Test down 1 fret over three seconds********

%Generate the appropriate control signal
startingFret = 0;
endingFret = 1;
L = generateLCurve(startingFret, endingFret, duration_sec, Fs);

%Processing objects
slideSynth = SlideSynth(stringParams, stringModeFilterSpec, L(1));
y2 = zeros(1, numSamples);

%Processing loop
slideSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    slideSynth.consumeControlSignal(L(n))
    y2(n) = slideSynth.tick();
end

figure;
subplot(2, 1, 1)
plot(y2);
title("Upwards bend");
subplot(2, 1, 2);
plot(L);

figure;
spectrogram(y2, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Slow Upward Bend Spectrogram')

%********Test Down 1 Fret over three seconds********

%Generate the appropriate control signal
startingFret = 1;
endingFret = 0;
L = generateLCurve(startingFret, endingFret, duration_sec, Fs);

%Processing objects
slideSynth = SlideSynth(stringParams, stringModeFilterSpec, L(1));
y3 = zeros(1, numSamples);

%Processing loop
slideSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    slideSynth.consumeControlSignal(L(n))
    y3(n) = slideSynth.tick();
end

figure;
subplot(2, 1, 1)
plot(y3);
title("Downwards Slide");
subplot(2, 1, 2);
plot(L);

figure;
spectrogram(y3, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Slow Downward Slide Spectrogram')