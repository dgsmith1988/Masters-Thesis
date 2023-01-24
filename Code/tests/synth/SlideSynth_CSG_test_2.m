%Test the slide synth patch for various sliding up 1 fret over three
%seconds and down one fret over three seconds

clear;
close all;
dbstop if error

%Synthsizer and sound parameters
slideSynthParams = SlideSynthParams();
slideSynthParams.enableCSG = true;
slideSynthParams.CSG_noiseSource = "NoisePulseTrain";
slideSynthParams.CSG_harmonicAccentuator = "ResoTanh";
slideSynthParams.stringNoiseSource = "Pink";
slideSynthParams.useNoiseFile = true;
slideSynthParams.slideType = "Brass";
slideSynthParams.stringName = "D";
duration_sec = 3;

%Slide motion parameters
startingFret = 0;
endingFret = 1;

%Spectrogram analysis parameters
Fs = SystemParams.audioRate;
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs/2000;

%********Test down 1 fret over three seconds********
%Derived parameters/control signal
numSamples = duration_sec * Fs;
L = generateLCurve(startingFret, endingFret, duration_sec, Fs);

%Processing objects
slideSynth = SlideSynth(slideSynthParams, L(1));
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
ylim([0 y_upperLim_kHz]);
title('Slow Upward Bend Spectrogram')

%********Test Down 1 Fret over three seconds********
%Swap the start/end points and start again
temp = startingFret;
startingFret = endingFret;
endingFret = temp;
L = generateLCurve(startingFret, endingFret, duration_sec, Fs);

%Processing object initialization
slideSynth = SlideSynth(slideSynthParams, L(1));

%Output buffers
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
ylim([0 y_upperLim_kHz]);
title('Slow Downward Slide Spectrogram')