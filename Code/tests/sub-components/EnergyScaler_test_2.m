%Test this block by running a signal through it which goes through the
%range of DWGLength values it will be operating on. This is for an
%decreasing DWG Length signal.

clear;
close all;

Fs = SystemParams.audioRate;
Ts = 1/Fs;
duration_sec = 2;
numSamples = round(duration_sec * Fs);
nRange = 0:numSamples-1;
minString_f0 = SystemParams.minString_f0;
maxString_f0 = SystemParams.maxString_f0;
max_L = SystemParams.maxRelativeStringLength;
min_L = SystemParams.minRelativeStringLength;
min_pitchf0 = minString_f0 / max_L;
max_pitchf0 = maxString_f0 / min_L;

%********Test 1 - Linearly Decreasing DWG Length*********
%We should expect this g_c(n) to be a constant value corresponding to the
%value of decrement in this test at the final output.

%Generate the sweep signal to test the block with
sweepStop = ceil(calculateTotalDWGLength(max_pitchf0, SystemParams.audioRate));
sweepStart = floor(calculateTotalDWGLength(min_pitchf0, SystemParams.audioRate));
decrement = (sweepStop - sweepStart) / (numSamples - 1);
DWGLengthSweep = sweepStart:decrement:sweepStop;

%Buffer to store output
g_c = zeros(1, numSamples);

%Create/initialize processing object
energyScaler = EnergyScaler(DWGLengthSweep(1)-decrement);

%Processing loop
for n = nRange + 1
    g_c(n) = energyScaler.tick(DWGLengthSweep(n));
end

figure;
subplot(2, 1, 1);
yyaxis left;
plot(nRange, g_c);
ylabel("g_c (Linear gain)");
ylim([.9 1.1])
yyaxis right;
plot(nRange, DWGLengthSweep);
ylabel("DWG Length (Samples)");
xlabel("n (Time-step)");
title("g_c for Linearly Decreasing DWG Length");

delta_x_theory = decrement*ones(1, numSamples);
g_c_theory = sqrt(abs(1-delta_x_theory));
g_c_err = g_c_theory - g_c;

subplot(2, 1, 2);
plot(nRange, g_c_err)
ylabel("g_c Error");
xlabel("n (Time-step)");

%********Test 2 - Increasing Decreasing Parabolic DWG Length*********

%Generate the sweep signal to test the block with by sampling the
%continuous domain signal
a = (sweepStop - sweepStart) / duration_sec^2;
c = sweepStart;
DWGLengthSweep = a*(nRange*Ts).^2 + c;

%Reset the internal state of the energy sscaler. Use this value based on
%the parametrization above to produce continuity and agreement between the
%theory and measured.
energyScaler.prevDWGLength = a*(-1*Ts)^2 + c;

%Processing loop
for n = nRange + 1
    g_c(n) = energyScaler.tick(DWGLengthSweep(n));
end

figure;
subplot(2, 1, 1);
yyaxis left;
plot(nRange, g_c);
ylabel("g_c (Linear gain)");
ylim([.98 1.02])
yyaxis right;
plot(nRange, DWGLengthSweep);
ylabel("DWG Length (Samples)");
xlabel("n (Time-step)");
title("g_c for Decreasing Parabolic DWG Length");

DWG_n_theory = a*(nRange*Ts).^2 + c;
DWG_n_1_theory = a*((nRange-1)*Ts).^2 + c;
delta_x_theory = DWG_n_theory - DWG_n_1_theory;
g_c_theory = sqrt(abs(1-delta_x_theory));
g_c_err = g_c_theory - g_c;

subplot(2, 1, 2);
plot(nRange, g_c_err)
ylabel("g_c Error");
xlabel("n (Time-step)");