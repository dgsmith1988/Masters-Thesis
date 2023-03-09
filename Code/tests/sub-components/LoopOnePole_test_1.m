%*********Test 1 - Filter Spec Interpolation********
%This tests the polynomial interpolation in the Loop Filter by attempting
%to crecreate figures 18 and 19 from the 1998 paper "Development and
%calibration of a Guitar Synthesizer"

clear;
close all;

stringParams = SystemParams.e_string_params;
openString_f0 = stringParams.f0;
L_min = SystemParams.minRelativeStringLength;
L_max = SystemParams.maxRelativeStringLength;
numSamples = 2000;
decrement = (L_min - L_max) / (numSamples - 1);
L = L_max:decrement:L_min;

pitch_f0 = calculatePitchF0(L, openString_f0);

%Initialize/instantiate the processing object
%Initial value doesn't really matter here as much
loopFilter = LoopOnePole(stringParams.a_pol, stringParams.g_pol, L(1));

a = zeros(1, numSamples);
g = zeros(1, numSamples);

for n = 1:numSamples
    loopFilter.consumeControlSignal(L(n));
    a(n) = loopFilter.a_param;
    g(n) = loopFilter.g_param;
end

figure;
plot(pitch_f0, a, "--k");
% title("Figure 19 Recreation");
title("Recreation");
xlim([300 1000]);
ylim([-0.03 0]);
grid on;
grid minor;
xlabel("Frequency (Hz)");
ylabel("Loop Filter Coeffecient a");

figure;
plot(pitch_f0, g, "--k");
% title("Figure 18 Recreation");
title("Recreation");
ylim([.99 1]);
xlim([300 1000]);
grid on;
grid minor;
xlabel("Frequency (Hz)");
ylabel("Loop Filter Gain g");