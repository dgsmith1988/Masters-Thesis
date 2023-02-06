%Test the slide synth patch for various sliding up 5 frets over .5 seconds
%and reverse

clear;
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
slideSynthParams.stringName = "B";

%Slide motion parameters
soundDuration_sec = 3;
slideDuration_sec = .5;
staticDuration_sec = soundDuration_sec - slideDuration_sec;
lowerFret = 0;
higherFret = 5;

%Spectrogram analysis parameters
Fs = SystemParams.audioRate;
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs/2000;


%********Test 3 frets up over three seconds********
%Generate derived parameters/control signal
numSamples = soundDuration_sec * Fs;
L = generateLCurve(lowerFret, higherFret, slideDuration_sec, Fs);
L = [L, L(end)*ones(1, staticDuration_sec*Fs)];
M = 48;
L = filter(1/M *ones(1, M), 1, L, L(1)*ones(1, M-1));
L(L > 1) = 1;

%Processing objects
slideSynth = SlideSynth(slideSynthParams, L(1));
slideSpeed = zeros(1, numSamples);
y6 = zeros(1, numSamples);

%Processing loop
slideSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    slideSynth.consumeControlSignal(L(n));
    slideSpeed(n) = slideSynth.contactSoundGenerator.absoluteSlideSpeed;
    y6(n) = slideSynth.tick();
end

figure;
subplot(3, 1, 1);
plot(y6);
grid on; grid minor;
title("Upwards bend");
subplot(3, 1, 2);
plot(L);
grid on; grid minor;
subplot(3, 1, 3);
plot(slideSpeed);
grid on; grid minor;
title("Slide Speed");

figure;
spectrogram(y6, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Medium Upward Bend Spectrogram')

%********Test up 3 frets over three seconds********

%Generate the appropriate control signal
L = generateLCurve(higherFret, lowerFret, slideDuration_sec, Fs);
L = [L, L(end)*ones(1, staticDuration_sec*Fs)];

%Processing objects
slideSynth = SlideSynth(slideSynthParams, L(1));
y7 = zeros(1, numSamples);

%Processing loop
slideSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    slideSynth.consumeControlSignal(L(n));
    slideSpeed(n) = slideSynth.contactSoundGenerator.absoluteSlideSpeed;
    y7(n) = slideSynth.tick();
end

figure;
subplot(3, 1, 1);
plot(y7);
grid on; grid minor;
title("Downwards Slide");
subplot(3, 1, 2);
plot(L);
grid on; grid minor;
subplot(3, 1, 3);
plot(slideSpeed);
grid on; grid minor;
title("Slide Speed");

figure;
spectrogram(y7, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Medium Downward Slide Spectrogram')