clear;
close all;
dbstop if error

%System processing parameters
duration_sec = 3;
Fs = SystemParams.audioRate;
numSamples = duration_sec * Fs;
stringLength = SystemParams.stringLengthMeters;
stringParams = SystemParams.D_string_params;
stringModeFilterSpec = SystemParams.D_string_modes.chrome;
waveshaperFunctionHandle = @tanh;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
% window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
% y_upperLim = 5; %corresponds to 5kHz on the frequency axis
y_upperLim = Fs/2000; %corresponds to 5kHz on the frequency axis

%Generate the appropriate control signal
startingFret = 0;
endingFret = 5;
L = generateLCurve(startingFret, endingFret, duration_sec, Fs);

%Processing objects
stringSynth = StringSynth(stringParams, stringModeFilterSpec, L(1));
y1 = zeros(1, numSamples);
feedbackLoopOutput = zeros(1, numSamples);
CSGOutput = zeros(1, numSamples);
f_c = zeros(1, numSamples);
absoluteSlideSpeed = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate noise...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringSynth.consumeControlSignal(L(n))
    f_c(n) = stringSynth.contactSoundGenerator.f_c_n;
    absoluteSlideSpeed(n) = stringSynth.contactSoundGenerator.absoluteSlideSpeed;
    [y1(n), feedbackLoopOutput(n), CSGOutput(n)] = stringSynth.tick();
end

figure;
n_plot = 0:numSamples-1;
subplot(4, 1, 1)
plot(n_plot, y1);
title("Synth Output");
subplot(4, 1, 2);
plot(n_plot, L);
title("L[n]");
subplot(4, 1, 3);
plot(n_plot, f_c);
title("f_c[n]");
subplot(4, 1, 4);
plot(n_plot, absoluteSlideSpeed);
title("absoluteSlideSpeed[n]");

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");
% ylim([0 y_upperLim]);