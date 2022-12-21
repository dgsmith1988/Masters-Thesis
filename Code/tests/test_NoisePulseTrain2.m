%Script to test the new noise pulse class using the IIR to generate the
%amplitude envelope

clear;
close;

%System parameters
Fs = SystemParams.audioRate;
duration_sec = 3;
numSamples = round(duration_sec*Fs);

%Noise pulse characteristics
period_samp = 1*Fs/4;
alpha = 127/128;
% alpha = 4095/4096;
f_c = Fs/period_samp;

%buffers to be filled during processing loop
y1 = zeros(1, numSamples);
y2 = zeros(1, numSamples);

%Processing objects
noisePulseTrain2 = NoisePulseTrain2(period_samp, alpha);

%Processing loop
for n = 1:numSamples
    y1(n) = noisePulseTrain2.tick(f_c);
end

figure;
plot(y1);
title("Noise Pulse Train Test");

%Rate changing test
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

%Processing loop
for n = 1:numSamples
    y2(n) = noisePulseTrain2.tick(f_c(n));
end

figure;
plot(y2);
title("Noise Pulse Train Test - Rate Changing");