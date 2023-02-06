%Test the slide synth patch sliding up 3 frets over one second and reverse

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
slideSynthParams.stringName = "D";

%Slide motion parameters
soundDuration_sec = 3;
slideDuration_sec = 1;
staticDuration_sec = soundDuration_sec - slideDuration_sec;
lowerFret = 0;
higherFret = 3;

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
M = 8;
L = filter(1/M *ones(1, M), 1, L, L(1)*ones(1, M-1));
L(L > 1) = 1;

%Processing objects
slideSynth = SlideSynth(slideSynthParams, L(1));
y4 = zeros(1, numSamples);
slideSpeed = zeros(1, numSamples);

%Processing loop
slideSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    slideSynth.consumeControlSignal(L(n))
    slideSpeed(n) = slideSynth.contactSoundGenerator.absoluteSlideSpeed;
    y4(n) = slideSynth.tick();
end

figure;
subplot(3, 1, 1);
plot(y4);
title("Upwards bend");
subplot(3, 1, 2);
plot(L);
title("L[n]");
subplot(3, 1, 3);
plot(slideSpeed);
title("Slide Speed");

figure;
spectrogram(y4, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Medium Upward Bend Spectrogram')

%********Test up 3 frets over three seconds********

%Generate the appropriate control signal
L = generateLCurve(higherFret, lowerFret, slideDuration_sec, Fs);
L = [L, L(end)*ones(1, staticDuration_sec*Fs)];

%Processing objects
slideSynth = SlideSynth(slideSynthParams, L(1));
y5 = zeros(1, numSamples);

%Processing loop
slideSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    slideSynth.consumeControlSignal(L(n))
    slideSpeed(n) = slideSynth.contactSoundGenerator.absoluteSlideSpeed;
    y5(n) = slideSynth.tick();
end

figure;
subplot(3, 1, 1);
plot(y5);
title("Downwards Slide");
subplot(3, 1, 2);
plot(L);
title("L[n]");
subplot(3, 1, 3);
plot(slideSpeed);
title("Slide Speed");

figure;
spectrogram(y5, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Medium Downward Slide Spectrogram')