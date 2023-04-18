clear all;
close all;

%First generate the L[n] signal which was used in synthesizing the musical
%example.

slideLick = ...
{   Note(.5, 0, false, false), ...
    Note(1, 6, true, false), ...
    Note(1, 5, true, false), ...
    Note(.5, 3, true, false), ...
    Note(.5, 0, false, false), ...
    Note(4, 3, true, true), ...
    };

%Synthsizer and sound parameters
slideSynthParams = SlideSynthParams();
slideSynthParams.enableCSG = false;
slideSynthParams.CSG_noiseSource = "NoisePulseTrain";
slideSynthParams.CSG_harmonicAccentuator = "ResoTanh";
slideSynthParams.stringNoiseSource = "Pink";
slideSynthParams.useNoiseFile = false;
slideSynthParams.slideType = "Brass";
slideSynthParams.stringName = "e";
Fs_audio = SystemParams.audioRate;
Fs_ctrl = SystemParams.controlRate;
openString_f0 = getStringParams(slideSynthParams.stringName).f0;

%Pre-allocate the output buffer for speed and eliminating memory allocation
%during the processing loop
numNotes = length(slideLick);
lickDuration_sec = 0;
for k = 1:numNotes
    lickDuration_sec = lickDuration_sec + slideLick{k}.duration_sec;
end

%Allocate slightly more as rounding can occur depending on durations and
%subdivisions
y_synth = zeros(1, ceil(1.01*(lickDuration_sec * Fs_audio)));
L_n = zeros(1, ceil(1.01*(lickDuration_sec * Fs_audio)));

%Synthesize the sounds and stitch the interpolated L[n] values in the
%output buffer
i1 = 1;
for k  = 1:numNotes
    fprintf("Synthesizing note %i/%i\n", k, numNotes);
    L = slideLick{k}.generateLCurve(Fs_ctrl);
    [y_k, L_k_n] = synthesizeSinglePluck(slideSynthParams, L);
    i2 = i1 + length(y_k) - 1;
    y_synth(i1:i2) = y_k;
    L_n(i1:i2) = L_k_n;
    i1 = i2 + 1;
end

%Remove the zeros which were added for padding
L_n = L_n(L_n ~= 0);

n = 0:length(L_n)-1;
t = n / Fs_audio;
figure;
subplot(2, 1, 1);
plot(t, L_n);
ylabel("L[n]");
xlabel("Time (sec)");
title("Synthesized Tone");
grid on;
grid minor;
xlim([0 5.5]);
ylim([.7 1.05]);

%Now do things for the YIN algorithm on the recorded sound
[y_rec, Fs_file] = audioread("../Sound Examples/SlideLick-High-e-Rec.wav");
P.minf0 = 300;
P.maxf0 = 500;
P.sr = Fs_file;
yin_out = yin(y_rec, P);
L_n_file = openString_f0 ./ yin_out.f0_best;
fsr = yin_out.sr/yin_out.hop;
t = (1:yin_out.nframes) / fsr;
subplot(2, 1, 2);
plot(t, L_n_file);
% plot(L_n_file);
% plot(t, yin_out.f0_best);
ylabel("L[n]");
xlabel("Time (sec)");
title("Recorded Example");
grid on;
grid minor;
xlim([0 5.5]);
ylim([.7 1.05]);