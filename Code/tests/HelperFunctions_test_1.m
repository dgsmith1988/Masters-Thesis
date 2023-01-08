%This tests the functionality associated with the FeedbackLoop's
%consumption of the control signal. The actual sound generation will be
%tested in the StringSynth tests using a dummy CSG as the FeedbackLoop
%needs to operate in the computational context provided by the StringSynth
%to work correctly. These functions are:
% - calculatePitchF0()
% - calculateTotalDWGLength()
% - calculateInterpDelayLineLength()
% - calcualteInterpDelayLineComponents()

clear;
close all;
dbstop if error

%Basic system parameters
Fs = SystemParams.audioRate;
duration_sec = 2;
numSamples = round(duration_sec * Fs);
minString_f0 = SystemParams.minString_f0;
maxString_f0 = SystemParams.maxString_f0;
max_L = SystemParams.maxRelativeStringLength;
min_L = SystemParams.minRelativeStringLength;
min_pitchf0 = minString_f0 / max_L;
max_pitchf0 = maxString_f0 / min_L;
openString_f0 = 110;
N = SystemParams.lagrangeOrder;

%********Test 1********
%Test the basic parametrization functions first to ensure they calculate
%the values correctly. The produced graph should have f0 at L = 1 (max) 
%and 4*f0 at L = .25 (min)

decrement = (min_L - max_L) / (numSamples-1);
L = max_L:decrement:min_L;
pitch_f0 = calculatePitchF0(L, openString_f0);
DWGLength = calculateTotalDWGLength(pitch_f0, Fs);

figure;
subplot(2, 1, 1);
plot(L, pitch_f0);
set(gca, 'xdir', 'reverse' )
ylabel("Pitch f0 (Hz)");
xlabel("Relative String Length");
title("Hyperbolic relationship between L[n] and Pitch f0");
grid on;
grid minor;
subplot(2, 1, 2);
plot(pitch_f0, DWGLength);
ylabel("DWG Length (samples)");
xlabel("Pitch f0 (Hz)");
title("Corresponding DWG Length");
grid on;
grid minor;

%********Test 2********
%Calculate the DWG length values over the range of possible fundamental
%frequency pitches
increment = (max_pitchf0 - min_pitchf0) / (numSamples-1);
pitch_f0 = min_pitchf0:increment:max_pitchf0;
DWGLength = calculateTotalDWGLength(pitch_f0, Fs);
figure;
plot(pitch_f0, DWGLength);
grid on;
grid minor;
ylabel("DWG Length (samples)");
xlabel("Pitch f0 (Hz)");
title("DWG Length range based on min/max pitch f0 values");

%********Test 3********
%Calculate the interpolated delay line length based on the phase delay of
%the loop filter.

%Recalculate this to be a linear sweep across the range of values. Use the
%ceil/cloor functions to start and end on an integer to make the graphs
%easier to interpet and see the periodicity
upperLim = ceil(DWGLength(1));
lowerLim = floor(DWGLength(end));
increment = 2^-5;
DWGLength = lowerLim:increment:upperLim;

%Constants based on filter types used in the signal processing chain
loopFilterDelay = OnePole.phaseDelay;

delay = calculateInterpDelayLineLength(DWGLength, loopFilterDelay);

figure;
subplot(2, 1, 1);
plot(DWGLength, delay, 'DisplayName', "Interp Delay Line Length");
xlabel("DWG Length (samples)");
ylabel("Interpolated Delay Line Length (samples)");
title("FeedbackLoop Parameter Calculation Test");
grid on; grid minor;
subplot(2, 1, 2);
plot(DWGLength - delay, 'DisplayName', "Difference");
ylabel("Difference (samples)");
title("Difference Between DWG Length and Interp Delay Line");
grid on; grid minor;

%********Test 4********
%Calculate the interpolated delay line length sub-components based on the
%delay value passed to it as well as the lagrange interpolation order

[M, D_min, D, d] = calculateInterpDelayLineComponents(N, delay);

figure;
subplot(2, 1, 1);
yyaxis left;
stem(delay, M, 'DisplayName', "M");
xlabel("Delay (samples)");
ylabel("M (samples)");
ylim([97, 106]);
yyaxis right;
stem(delay, D, 'DisplayName', 'D');
ylabel('D (samples)')
ylim([1.9, 3.1])
title("Integer and Langrange Delay Components");
xlim([100, 104])
grid on; grid minor;

subplot(2, 1, 2);
yyaxis left;
stem(delay, D, 'DisplayName', "D");
xlabel("Delay (samples)");
ylabel("D (samples)");
yyaxis right;
stem(delay, d, 'DisplayName', 'd');
ylabel("d (samples)");
title("Langrange Delay Breakdown");
xlim([100, 104])
grid on; grid minor;