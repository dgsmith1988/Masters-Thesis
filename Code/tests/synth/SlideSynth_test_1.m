%Simple plucking of the string

clear;
close all;
dbstop if error

%Synthesizer and sound parameters
slideSynthParams = SlideSynthParams();
slideSynthParams.enableCSG = false;
slideSynthParams.CSG_noiseSource = "NoisePulseTrain";
slideSynthParams.CSG_harmonicAccentuator = "ResoTanh";
slideSynthParams.stringNoiseSource = "Pink";
slideSynthParams.useNoiseFile = false;
slideSynthParams.slideType = "Brass";
slideSynthParams.stringName = "B";
duration_sec = 3;
Fs_audio = SystemParams.audioRate;
Fs_ctrl = SystemParams.controlRate;
R = Fs_audio / Fs_ctrl;

%Slide motion parameters
startingFret = 0;
endingFret = 0;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs_audio; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs_audio/2000;

%***************************Don't Touch Below Here***************************%
%Derived parameters and control signals
numSamples_audio = duration_sec * Fs_audio;
numSamples_ctrl = duration_sec * Fs_ctrl;
L = generateLCurve(startingFret, endingFret, duration_sec, Fs_ctrl);

%Processing objects
slideSynth = SlideSynth(slideSynthParams, L(1));

%Output buffers
y1 = zeros(1, numSamples_audio);
stringDWGOutput = zeros(1, numSamples_audio);
CSGOutput = zeros(1, numSamples_audio);
f_c = zeros(1, numSamples_audio);
slideSpeed = zeros(1, numSamples_audio);

%Processing loop
slideSynth.pluck(); %Set up the string to generate noise...
n = 1;
for m = 1:numSamples_ctrl
    slideSynth.consumeControlSignal(L(n))
    for k = 1:R
        if(mod(n, 100) == 0)
            fprintf("n = %i/%i\n", n, numSamples_audio);
        end
        [y1(n), stringDWGOutput(n), CSGOutput(n)] = slideSynth.tick();
        %Extract the parameters here as they don't get updated until the
        %call to slideSynth.tick() due to interpolation
        f_c(n) = slideSynth.contactSoundGenerator.f_c_n;
        slideSpeed(n) = slideSynth.contactSoundGenerator.slideSpeed_n;
        n = n + 1;
    end
end

figure;
n_plot = 0:numSamples_audio-1;
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
plot(n_plot, slideSpeed);
title("absoluteSlideSpeed[n]");

figure;
spectrogram(y1, window, overlap, N, Fs_audio, "yaxis");
ylim([0 y_upperLim_kHz]);