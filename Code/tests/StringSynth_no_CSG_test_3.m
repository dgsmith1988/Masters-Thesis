%Test the string synth patch for various sliding up 3 fret over one
%second and reverse

clear;
close all;
dbstop if error

%System processing parameters
duration_sec = 1;
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
endingFret = 3;
L = generateL(startingFret, endingFret, duration_sec, Fs);

%Processing objects
stringSynth = StringSynth(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L(1));
y4 = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringSynth.consumeControlSignal(L(n))
    y4(n) = stringSynth.tick();
end

figure;
subplot(2, 1, 1)
plot(y4);
title("Upwards bend");
subplot(2, 1, 2);
plot(L);

figure;
spectrogram(y4, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Medium Upward Bend Spectrogram')

%********Test Down 1 Fret over three seconds********

%Generate the appropriate control signal
startingFret = 3;
endingFret = 0;
L = generateL(startingFret, endingFret, duration_sec, Fs);

%Processing objects
stringSynth = StringSynth(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L(1));
y5 = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringSynth.consumeControlSignal(L(n))
    y5(n) = stringSynth.tick();
end

figure;
subplot(2, 1, 1)
plot(y5);
title("Downwards Slide");
subplot(2, 1, 2);
plot(L);

figure;
spectrogram(y5, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim]);
title('Medium Downward Slide Spectrogram')