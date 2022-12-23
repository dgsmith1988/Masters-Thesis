%Script to test the new noise pulse class using the IIR to generate the
%amplitude envelope

clear;
close all;

%System parameters
Fs = SystemParams.audioRate;
Ts = 1/Fs;
duration_sec = 1;
numSamples = round(duration_sec*Fs);

%Noise pulse characteristics
period_samp = 1*Fs/4;
decayRate = SystemParams.E_string_params.decayRate;

%10000 is a tuning parameter here as the decay rate from the thesis did not
%sound good
decayRate = exp(-10000/(decayRate*Fs));
% decayRate = 127/128;
% decayRate = 4095/4096;
f_c = Fs/period_samp;

%buffers to be filled during processing loop
y1 = zeros(1, numSamples);
y2 = zeros(1, numSamples);

%Processing objects
exponentialDecay = ExponentialDecay(period_samp, decayRate);

%Processing loop
for n = 1:numSamples
    y1(n) = exponentialDecay.tick(f_c);
end

figure;
subplot(2, 1, 1);
stem(y1);
title("Exponential Decay Test - Constant Rate");

%Rate changing test
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

%Processing loop
for n = 1:numSamples
    y2(n) = exponentialDecay.tick(f_c(n));
end

subplot(2, 1, 2);
stem(y2);
title("Exponential Decay Test - Rate Changing");