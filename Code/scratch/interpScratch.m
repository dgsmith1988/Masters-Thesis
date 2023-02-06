clear all;
close all;

%System parameters
Fs_audio = SystemParams.audioRate;
Fs_ctrl = SystemParams.controlRate;
M = 8; %Smoothing window length

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
slideDuration_sec = 1;
staticDuration_sec = soundDuration_sec - slideDuration_sec;
lowerFret = 0;
higherFret = 3;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs_audio; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs_audio/2000;

%Derived parameters
R = Fs_audio/Fs_ctrl;
numSamples_audio = soundDuration_sec * Fs_audio;
numSamples_ctrl = soundDuration_sec * Fs_ctrl;
nRange_audio = 0:numSamples_audio-1;
nRange_ctrl = 0:numSamples_ctrl-1;

%Generate the control signal at the control rate
L = generateLCurve(lowerFret, higherFret, slideDuration_sec, Fs_ctrl);
L = [L, L(end)*ones(1, staticDuration_sec*Fs_ctrl)];

%Apply smoothing and cap the value to valid ranges
L = filter(1/M *ones(1, M), 1, L, L(1)*ones(1, M-1));
L(L > 1) = 1;

%Apply the interpolation between points
L_interp = zeros(1, numSamples_audio);
n_audio = 1;
for n_control = nRange_ctrl+1
    %Hold the last value as we have nothing to interpolate to
    if n_control == nRange_ctrl(end) + 1
        increment = 0;
    else
        %calculate the increment to be added each sample
        increment = (L(n_control+1) - L(n_control))/R;
    end
    
    for k = 0:R-1
        L_interp(n_audio) = L(n_control) + k*increment;
        n_audio = n_audio + 1;
    end
end

figure;
subplot(2, 1, 1);
plot(nRange_ctrl, L);
title("L[n]");
subplot(2, 1, 2);
plot(nRange_audio, L_interp);
title("L interp[n]");

figure;
subplot(2, 1, 1);
plot(nRange_ctrl, L);
xlim(1000 + [-150 150]);
title("L[n] bend zoom");
subplot(2, 1, 2);
plot(nRange_audio, L_interp);
xlim(48000 + [-1000 1000]);
title("L interp[n] bend zoom");

%Processing objects
slideSynth = SlideSynth(slideSynthParams, L(1));
slideSpeed = zeros(1, numSamples_audio);
y = zeros(1, numSamples_audio);

%Processing loop
slideSynth.pluck(); %Set up the string to generate sound...
for n = 1:numSamples_audio
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples_audio);
    end
    slideSynth.consumeControlSignal(L_interp(n));
    slideSpeed(n) = slideSynth.contactSoundGenerator.absoluteSlideSpeed;
    y(n) = slideSynth.tick();
end

figure;
subplot(3, 1, 1);
plot(nRange_audio, y);
title("Synthesized Sound");
subplot(3, 1, 2);
plot(nRange_audio, L_interp, "DisplayName", "L[n]");
title("Control Parameters");
yyaxis right;
plot(nRange_audio, slideSpeed, "DisplayName", "slideSpeed[n]");
legend();
subplot(3, 1, 3);
yyaxis left;
stem(nRange_audio, L_interp, "DisplayName", "L[n]");
ylim([.840 .842]);
yyaxis right;
stem(nRange_audio, slideSpeed, "DisplayName", "slideSpeed[n]");
title("Control Parameters Zoom at Curve");
xlim([47800 48400]);
ylim([-0.01 .1]);
legend();

figure;
spectrogram(y, window, overlap, N, Fs_audio, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Synthesized Sound');