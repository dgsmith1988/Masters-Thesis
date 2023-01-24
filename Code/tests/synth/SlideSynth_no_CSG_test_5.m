%Test the string synth patch for the extreme values defined in the system
%parameters file

clear all;
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
stringParams.n_w = -1;                      %indicate that we don't use a CSG
stringParams.f0 = SystemParams.minPitch_f0; %change the fundamental to the lowest one possible
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


%********Test extreme slide up********
%Generate the appropriate control signal
startingFret = 0;
endingFret = relativeLengthToFretNumber(L_max_pitch);
L = generateLCurve(startingFret, endingFret, slideDuration_sec, Fs);
L = [L, L(end)*ones(1, staticDuration_sec*Fs)];

%Processing objects
slideSynth = SlideSynth(stringParams, stringModeFilterSpec, L(1));
y8 = zeros(1, numSamples);
g_c_8 = zeros(1, numSamples);

%Processing loop
slideSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    slideSynth.consumeControlSignal(L(n))
    g_c_8(n) = slideSynth.stringDWG.g_c_n;
    y8(n) = slideSynth.tick();
end

figure;
subplot(3, 1, 1)
plot(y8);
title("Extreme Upwards bend");
subplot(3, 1, 2);
plot(L);
subplot(3, 1, 3);
plot(g_c_8);
title("g_c[n]");

figure;
spectrogram(y8, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Extreme Upward Bend Spectrogram')

%********Run the test in reverse********
%Generate the appropriate control signal
startingFret = relativeLengthToFretNumber(L_max_pitch);
endingFret = 0;
L = generateLCurve(startingFret, endingFret, slideDuration_sec, Fs);
L = [L, L(end)*ones(1, staticDuration_sec*Fs)];

%Processing objects
slideSynth = SlideSynth(stringParams, stringModeFilterSpec, L(1));
y9 = zeros(1, numSamples);
g_c_9 = zeros(1, numSamples);

%Processing loop
slideSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    slideSynth.consumeControlSignal(L(n))
    g_c_9(n) = slideSynth.stringDWG.g_c_n;
    y9(n) = slideSynth.tick();
end

figure;
subplot(3, 1, 1)
plot(y9);
title("Extreme Downwards Slide");
subplot(3, 1, 2);
plot(L);
title("L[n]");
subplot(3, 1, 3);
plot(g_c_9);
title("g_c[n]");

figure;
spectrogram(y9, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Extreme Downward Slide Spectrogram')