%Test the string synth patch for various sliding up 3 fret over one
%second and reverse

clear;
close all;
dbstop if error

%System processing parameters
duration_sec = .5;
Fs = SystemParams.audioRate;
numSamples = duration_sec * Fs;
stringLength = SystemParams.stringLengthMeters;
stringParams = SystemParams.D_string_params;
n_w = stringParams.n_w; %extract the parameter before we overwrite it
stringParams.n_w = -1; %indicate that we don't use a CSG
stringModeFilterSpec = SystemParams.D_string_modes.chrome;
waveshaperFunctionHandle = @tanh;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
% window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = 15; %corresponds to 15kHz on the frequency axis


%********Test down 1 fret over three seconds********

%Generate the appropriate control signal
startingFret = 0;
endingFret = 5;
L = generateL(startingFret, endingFret, duration_sec, Fs);

%Processing objects
stringSynth = StringSynth(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L(1));
y6 = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringSynth.consumeControlSignal(L(n))
    y6(n) = stringSynth.tick();
end

figure;
subplot(2, 1, 1)
plot(y6);
title("Upwards bend");
subplot(2, 1, 2);
plot(L);

figure;
spectrogram(y6, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Fast Upward Bend Spectrogram')

%********Test Down 1 Fret over three seconds********

%Generate the appropriate control signal
startingFret = 5;
endingFret = 0;
L = generateL(startingFret, endingFret, duration_sec, Fs);

%Processing objects
stringSynth = StringSynth(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L(1));
y7 = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringSynth.consumeControlSignal(L(n))
    y7(n) = stringSynth.tick();
end

figure;
subplot(2, 1, 1)
plot(y7);
title("Downwards Slide");
subplot(2, 1, 2);
plot(L);

figure;
spectrogram(y7, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Fast Downward Slide Spectrogram')